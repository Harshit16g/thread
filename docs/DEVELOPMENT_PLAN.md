# TabL: Development Plan & Phased Roadmap
*Version 1.1, January 2025*

---

## Introduction

This document outlines the phased development and implementation roadmap for the TabL Super-App. The plan is structured to deliver value incrementally, starting with a robust Minimum Viable Product (MVP) and progressively layering on more advanced and decentralized features.

This roadmap is a living document and will be updated as the project progresses and priorities evolve. It is directly tied to the technical specifications outlined in the **[Architectural Foundation & Integration Strategy](./Architectural_Foundation_and_Integration_Strategy.md)**.

---

## Phase 1: Core Foundation & MVP (Months 1-3)

**Goal**: To launch a secure and functional platform for peer-to-peer service listings and transactions using an internal ledger.

#### **Key Objectives & Deliverables:**

1.  **Core Infrastructure Setup**:
    -   [ ] Set up `dev` and `prod` projects in Supabase.
    -   [ ] Configure custom domains (`dev.auth.oeeez.online`, `auth.oeeez.online`).
    -   [ ] Implement the environment management strategy as per the architecture doc.
    -   [ ] Integrate Sentry for error monitoring.

2.  **User Authentication & Security**:
    -   [ ] Implement user registration, login, and profile management using Supabase Auth.
    -   [ ] **Deliverable**: Implement the `AuthRepository` and `AuthBloc`.
    -   [ ] **Deliverable**: Implement the server-side **Hardware & IP Tagging** security model for all authentication events using Supabase Functions.

3.  **Marketplace MVP**:
    -   [ ] Implement the ability for users to create, view, and manage service listings.
    -   [ ] Implement a basic search and filtering system for listings.
    -   [ ] **Deliverable**: `ListingsRepository` and `MarketplaceBloc`.

4.  **Transaction Flow MVP**:
    -   [ ] Implement the ability for users to book a service from a listing.
    -   [ ] Create the `transactions` table to serve as an immutable ledger.
    -   [ ] **Deliverable**: `TransactionRepository` and `TransactionBloc` to manage the lifecycle of a booking (`requested`, `confirmed`, `completed`, `cancelled`).

5.  **Internal Wallet System**:
    -   [ ] Implement the `wallets` table in the database to manage user token balances.
    -   [ ] Create RPC functions in Supabase for secure, atomic balance transfers.
    -   [ ] **Deliverable**: `WalletRepository` (internal ledger version) and `WalletBloc`.

---

## Phase 2: Community & Engagement Features (Months 4-6)

**Goal**: To enhance the platform with features that drive user engagement and build a community.

#### **Key Objectives & Deliverables:**

1.  **Community News Feed**:
    -   [ ] Implement the ability for verified users to post, read, and interact with community news articles.
    -   [ ] Develop a basic moderation system within Supabase.
    -   [ ] **Deliverable**: `NewsRepository` and `NewsFeedBloc`.

2.  **User Reputation System**:
    -   [ ] Implement a user reputation score that is updated automatically upon the successful completion of transactions.
    -   [ ] Display reputation scores clearly on user profiles and service listings.
    -   [ ] **Deliverable**: Enhancement of the `complete_transaction` RPC to include reputation logic.

3.  **Real-time Notifications**:
    -   [ ] Implement Supabase Realtime for instant in-app notifications (e.g., "Your ride has been confirmed").
    -   [ ] Integrate Resend for transactional email notifications (e.g., "Welcome to TabL").
    -   [ ] **Deliverable**: `NotificationService` integrated with the relevant BLoCs.

4.  **Enhanced Search & Discovery**:
    -   [ ] Integrate Redis for caching popular listings to improve search performance.
    -   [ ] Implement location-based search using Supabase's PostGIS capabilities.
    -   [ ] **Deliverable**: Upgraded `MarketplaceRepository` with caching and geo-search capabilities.

---

## Phase 3: Path to Decentralization (Months 7-12)

**Goal**: To begin the transition to a truly decentralized ecosystem by migrating the core token and identity systems to a public blockchain.

#### **Key Objectives & Deliverables:**

1.  **Blockchain Integration Research**:
    -   [ ] Evaluate and select a target blockchain (e.g., Solana, Polygon, Arbitrum) based on transaction speed, cost, and ecosystem maturity.
    -   [ ] Define the on-chain token contract and governance model.

2.  **Decentralized Wallet Implementation**:
    -   [ ] **Deliverable**: Create a new `WalletRepository` implementation (e.g., `WalletRepositorySolanaImpl`) that interacts with the public blockchain.
    -   [ ] The app's UI will switch to this new implementation with no changes to the BLoCs or UI code, as per the architecture.
    -   [ ] Implement a secure flow for users to create or import a non-custodial wallet.

3.  **Decentralized Identity (DID)**:
    -   [ ] Research and implement a DID solution (e.g., SpruceID, Polygon ID) to give users full control over their identity.
    -   [ ] **Deliverable**: A new `IdentityRepository` to manage the creation and verification of DIDs, replacing parts of the initial Supabase profile system.

4.  **Self-Hosted Distribution (If Required)**:
    -   [ ] If departing from traditional app stores, implement the `Self-Hosting and Distribution Strategy`.
    -   [ ] **Deliverable**: A download portal, in-app update mechanism, and self-hosted analytics as defined in the strategy document.

---

## Future Phases (Post-Year 1)

-   **On-Chain Governance**: Implement a system for token holders to vote on platform proposals.
-   **Advanced Service Types**: Expand the marketplace to include more complex service types with unique validation and transaction flows.
-   **Full Microservices Migration**: If the platform scales beyond the capabilities of the Supabase monolith, begin breaking out core logic into independent microservices as originally envisioned in the advanced architecture diagrams.
