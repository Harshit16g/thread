# 🛠 Development Plan & Roadmap

A detailed development path for **TabL** — covering MVP, feature expansion, and future decentralization.

---

## ✅ MVP Phase (Months 1–3)

- [ ] 🔑 **User Authentication**  
  - Integrate Supabase OAuth
  - Implement device fingerprint & IP tagging during sign-up

- [ ] 🏪 **Basic Marketplace**  
  - Service listing: rides, rentals, food, delivery
  - Booking flow: request → confirm → pay

- [ ] 🗺 **Google Maps Integration**  
  - Show service providers on map
  - Route & distance calculation

- [ ] 💰 **Native Token (Internal Ledger)**  
  - Basic wallet UI: view balance, send, receive
  - Deduct platform transaction fee in tokens

- [ ] 🛡 **Immutable Transaction Log**  
  - Record all bookings & payments into Neon DB

- [ ] 📰 **Community News Module**  
  - Create/post news
  - Admin or trusted user moderation

- [ ] 📱 **App Foundation**  
  - Feature-first folder structure
  - State management (Bloc or Cubit)
  - Basic theming & responsive design

---

## ⚡ Phase 2 (Months 4–6)

- [ ] ✅ **Decentralized User Verification**  
  - Referral-based verification
  - Reward verifiers in native tokens
  - Store verification proofs

- [ ] 📢 **Voting & Governance**  
  - Community proposals & voting
  - Token-weighted votes

- [ ] 🛰 **Realtime Features**  
  - Supabase Realtime & Upstash Redis
  - Live updates on services & bookings

- [ ] 🛠 **Hardware Tagging Enhancements**  
  - Unique device ID & clustering to prevent fraud

- [ ] 🐛 **Monitoring & Analytics**  
  - Integrate Sentry for crash & error logging
  - Basic user activity metrics

---

## 🌱 Phase 3 (6+ months)

- [ ] 🌐 **Native Token on Blockchain**  
  - Migrate internal ledger to EVM / Solana / custom chain
  - Enable wallet export/import

- [ ] 🧠 **Advanced Fraud Detection**  
  - AI & ML to detect fake patterns
  - Auto-flag suspicious users

- [ ] 📦 **Marketplace Expansion**  
  - Add more service categories
  - Ratings & reviews

- [ ] 🔔 **Notifications & Campaigns**  
  - Push notifications
  - Referral campaigns & bonuses

- [ ] 🌍 **Decentralized Moderation**  
  - Community-powered reporting & content moderation

- [ ] 📊 **User Reputation System**  
  - Public reputation scores based on history & feedback

---

## 📦 Deliverables Summary

| Phase     | Highlights                                                    |
| --------- | ------------------------------------------------------------ |
| MVP       | Auth, marketplace, maps, internal token, immutable logs, news|
| Phase 2   | Decentralized verification, voting, realtime, hardware tagging|
| Phase 3   | Blockchain migration, AI fraud, advanced marketplace, notifications, moderation|

---

## 🧭 **Notes & Priorities**

- Start with internal native token ledger; migrate on-chain later.
- Privacy first: never store plain personal data.
- Decentralization: verification & voting should be fully community-driven.
- Scale backend with Supabase Realtime, Upstash Redis, and Neon.

---

## ✅ Next Steps

- Finalize data models & DB schema
- Draw detailed user flows & wireframes
- Define API contracts & backend services
- Start MVP implementation

---

Built with ❤️ by the TabL team.