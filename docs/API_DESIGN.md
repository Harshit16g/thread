# TabL: API Design & Data Models
*Version 1.0, January 2025*

---

## 1. Introduction
This document provides a detailed reference for the TabL application's data layer. It outlines the complete database schema, the relationships between tables, and the design of our API, which is built on the **Supabase-first** principle.

The API is not a separate, standalone server. Instead, it is a combination of:
1.  **Auto-Generated REST API**: Provided by Supabase for all standard CRUD operations on our database tables.
2.  **PostgreSQL Functions (RPCs)**: For executing complex, secure, server-side business logic.

This document serves as the technical blueprint for all frontend-to-backend communication. For a higher-level overview, please see the **[Architectural Foundation document](./Architectural_Foundation_and_Integration_Strategy.md)**.

---

## 2. Database Schema (PostgreSQL)
The following schema is designed for scalability and data integrity, hosted on Neon and managed via Supabase.

### 2.1. `users` Table
Stores public user profile information and internal metadata. Private authentication data is stored separately in Supabase's `auth.users` table.

| Column             | Type      | Constraints                               | Description                               |
| ------------------ | --------- | ----------------------------------------- | ----------------------------------------- |
| `id`               | `UUID`    | `PRIMARY KEY`, `REFERENCES auth.users(id)` | Foreign key to the Supabase auth user.    |
| `username`         | `TEXT`    | `UNIQUE`, `NOT NULL`                      | The user's public and unique handle.      |
| `reputation_score` | `INT`     | `DEFAULT 0`                               | A score reflecting the user's reliability.|
| `created_at`       | `TIMESTAMPTZ` | `DEFAULT now()`                         | Timestamp of when the user was created.   |

### 2.2. `wallets` Table
Holds the internal ledger balances for the MVP. Designed for atomic updates.

| Column      | Type        | Constraints                      | Description                                |
| ----------- | ----------- | -------------------------------- | ------------------------------------------ |
| `id`        | `UUID`      | `PRIMARY KEY`, `DEFAULT gen_random_uuid()` | Unique identifier for the wallet.          |
| `user_id`   | `UUID`      | `UNIQUE`, `REFERENCES users(id)` | The user who owns this wallet.             |
| `balance`   | `DECIMAL(18, 8)` | `NOT NULL`, `CHECK (balance >= 0)` | The user's token balance. High precision.  |
| `updated_at`| `TIMESTAMPTZ` | `DEFAULT now()`                  | Timestamp of the last balance update.      |

### 2.3. `listings` Table
A generic table for all peer-to-peer service offerings.

| Column          | Type          | Constraints                      | Description                                    |
| --------------- | ------------- | -------------------------------- | ---------------------------------------------- |
| `id`            | `UUID`        | `PRIMARY KEY`, `DEFAULT gen_random_uuid()` | Unique identifier for the listing.             |
| `provider_id`   | `UUID`        | `REFERENCES users(id)`           | The user offering the service.                 |
| `title`         | `TEXT`        | `NOT NULL`                       | The public title of the service.               |
| `description`   | `TEXT`        |                                  | Detailed description of the service.           |
| `price`         | `DECIMAL(10, 2)` | `CHECK (price >= 0)`             | The cost of the service.                       |
| `metadata`      | `JSONB`       |                                  | Flexible field for service-specific data.      |
| `is_available`  | `BOOLEAN`     | `DEFAULT TRUE`                   | Whether the service is currently available.    |
| `created_at`    | `TIMESTAMPTZ`   | `DEFAULT now()`                  | Timestamp of when the listing was created.     |

**Example `metadata` JSONB object for a "Ride Sharing" service:**
```json
{
  "vehicle_type": "Sedan",
  "vehicle_model": "Tesla Model 3",
  "max_passengers": 3,
  "origin_point": "POINT(-74.0060 40.7128)",
  "destination_point": "POINT(-73.935242 40.730610)"
}
```

### 2.4. `transactions` Table
An **immutable log** of all confirmed service engagements. Records should not be updated after completion.

| Column         | Type          | Constraints                      | Description                               |
| -------------- | ------------- | -------------------------------- | ----------------------------------------- |
| `id`           | `UUID`        | `PRIMARY KEY`, `DEFAULT gen_random_uuid()` | Unique identifier for the transaction.    |
| `listing_id`   | `UUID`        | `REFERENCES listings(id)`        | The listing that was booked.              |
| `consumer_id`  | `UUID`        | `REFERENCES users(id)`           | The user who booked the service.          |
| `provider_id`  | `UUID`        | `REFERENCES users(id)`           | The user who provided the service.        |
| `amount`       | `DECIMAL(10, 2)` | `NOT NULL`                       | The final amount paid for the service.    |
| `status`       | `TEXT`        | `NOT NULL`                       | e.g., 'completed', 'cancelled_by_consumer'|
| `created_at`   | `TIMESTAMPTZ`   | `DEFAULT now()`                  | Timestamp of when the booking was made.   |

---

## 3. Row-Level Security (RLS) Policies
RLS is critical to our security model. It ensures that users can only access and modify data they are authorized to. All tables will have RLS enabled.

-   **`users` Table Policies**:
    -   Users can view any other user's public profile (`username`, `reputation_score`).
    -   Users can only update their own profile.
-   **`wallets` Table Policies**:
    -   Users can only view their own wallet balance.
    -   **No direct write access is allowed.** All balance changes *must* go through a trusted PostgreSQL function (RPC).
-   **`listings` Table Policies**:
    -   Anyone can view `is_available = true` listings.
    -   Users can only create listings for themselves (`provider_id = auth.uid()`).
    -   Users can only update or delete their own listings.
-   **`transactions` Table Policies**:
    -   Users can only view transactions where they are either the `consumer_id` or the `provider_id`.
    -   **No `UPDATE` or `DELETE` access is allowed**, enforcing the table's immutability.

---

## 4. PostgreSQL Functions (RPCs)
These server-side functions contain business logic that is too sensitive or complex to run on the client. They are the core of our secure API.

### `login_with_device_info(user_email TEXT, user_password TEXT, device_id TEXT)`
-   **Description**: The primary function for user login. It extends the standard login flow to include our security model.
-   **Logic**:
    1.  Authenticates the user using their credentials.
    2.  If successful, logs the `device_id` and request IP address to a separate `audit_log` table.
    3.  Returns a session token to the client.

### `create_listing_with_validation(provider_id UUID, title TEXT, ...)`
-   **Description**: Creates a new service listing.
-   **Logic**:
    1.  Validates that the `provider_id` matches the currently authenticated user (`auth.uid()`).
    2.  Performs data validation on the input fields.
    3.  Inserts the new record into the `listings` table.

### `execute_internal_transfer(from_user_id UUID, to_user_id UUID, transfer_amount DECIMAL)`
-   **Description**: Atomically transfers tokens between two users in the internal wallet ledger. This is a security-critical function.
-   **Logic**:
    1.  Begins a transaction block.
    2.  Verifies that the `from_user_id` is the authenticated user and has sufficient funds.
    3.  Decrements the sender's balance.
    4.  Increments the receiver's balance.
    5.  Commits the transaction. If any step fails, the entire transaction is rolled back.

### `complete_transaction_and_update_reputation(transaction_id UUID)`
-   **Description**: Marks a transaction as complete and updates the reputation scores for the participants.
-   **Logic**:
    1.  Updates the `transactions` table status to `completed`.
    2.  Increments the `reputation_score` for both the provider and the consumer.
