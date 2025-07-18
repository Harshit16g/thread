# TabL: Security & Fraud Prevention Model
*Version 1.0, January 2025*

---

## 1. Introduction
Security is the cornerstone of the TabL platform. Our success depends on creating a trusted environment where users feel safe to transact and interact. This document details the specific security measures and fraud prevention mechanisms that are architected into the core of the application.

This model is a practical implementation of the principles laid out in the **[Architectural Foundation document](./Architectural_Foundation_and_Integration_Strategy.md)**.

---

## 2. The Core Principles of Security

Our security model is built on three core principles:

1.  **Least Privilege**: Users and services should only have access to the data and operations that are absolutely necessary for their function. This is enforced by Supabase's Row-Level Security (RLS).
2.  **Server-Side Authority**: All sensitive business logic (e.g., financial transactions, reputation updates) is executed on the server via trusted PostgreSQL functions (RPCs), never on the client.
3.  **Proactive Auditing**: We log critical events to proactively detect and respond to suspicious activity.

---

## 3. Hardware & IP Tagging Mechanism

This is our primary defense against account takeover and multi-account fraud. The goal is to build a trusted relationship between a user account and the devices they use.

#### **Implementation Details:**

1.  **Client-Side Fingerprinting**:
    -   When a user registers or logs in, the Flutter app will use the `device_info_plus` and `ip_address` packages to gather a unique device identifier and the public IP address.
    -   This information, which we'll call the `DeviceFingerprint`, is sent along with every authentication request.

2.  **Server-Side Logging & Verification (RPC)**:
    -   We will use a custom RPC function, `login_with_device_info`, instead of a standard Supabase login call.
    -   This function will:
        a. Authenticate the user.
        b. Upon success, write the `DeviceFingerprint` and the request's IP address to a secure `audit.auth_logs` table. This table is not accessible via the public API.
        c. Return the session token to the user.

3.  **Fraud Detection Logic**:
    -   A scheduled Supabase Function will run periodically (e.g., every hour) to analyze the `audit.auth_logs` table.
    -   It will look for suspicious patterns, such as:
        -   A single user account logging in from an unusually high number of different devices or IP addresses in a short time.
        -   Multiple user accounts logging in from the exact same device fingerprint.
    -   If a high-risk pattern is detected, the system can automatically flag the account for manual review or temporarily lock it.

---

## 4. Immutable Transaction Ledger

To ensure the integrity of the platform's economic activity, all completed transactions are treated as an immutable log.

-   **RLS Policy**: The `transactions` table has RLS policies that **completely forbid `UPDATE` and `DELETE` operations** from the public API. Once a transaction is written, it cannot be altered.
-   **Cancellations & Refunds**: Instead of deleting a transaction, a new transaction is created with a `status` of `cancelled` or `refunded`. This new record will reference the original transaction, providing a clear and auditable trail of events.

---

## 5. Secure Wallet & Transaction Flow

The internal wallet system is a security-critical component and is protected by multiple layers.

-   **No Direct Wallet Access**: RLS policies prevent any user, including the owner, from directly updating their `balance` in the `wallets` table.
-   **Trusted RPC for All Transfers**: All balance changes *must* be initiated through the `execute_internal_transfer` PostgreSQL function.
-   **Atomic Operations**: This function is wrapped in a `TRANSACTION` block. This ensures that a transfer is **atomic**: either both the debit from the sender and the credit to the receiver succeed, or they both fail. It is impossible for tokens to be "lost" mid-transaction.
-   **Server-Side Balance Checks**: The RPC function is the single source of truth for verifying if a user has sufficient funds. The client-side UI can show a balance, but the actual validation happens securely on the server just before the transaction is executed.

---

## 6. Path to Decentralized Identity (DID)

As outlined in the development plan, the long-term vision is to move beyond traditional email/password authentication to a fully decentralized identity model.

-   **Phase 1 (MVP)**: The user's identity is tied to their Supabase Auth account. Our hardware and IP tagging provides a strong layer of security on top of this.
-   **Phase 3 (Decentralization)**: We will introduce a new `IdentityRepository` that will allow users to connect a non-custodial wallet (like MetaMask or Phantom) as their primary means of identity.
    -   **Authentication Flow**: Instead of sending an email/password, the user will sign a message with their wallet's private key. A server-side RPC will verify this signature to authenticate them.
    -   This gives users full control over their identity, fulfilling the "super-app" vision of a truly decentralized platform.
