# Project Context & Domain Knowledge

## What This Project Is

A **Manga Reading Platform** capstone project for Ho Chi Minh City University of Technology and Education (HCMUTE). 2-person team. The platform lets users browse, read, and interact with manga content sourced from MangaDex API.

## Authoritative Documents

| Document | Location | What it contains |
|----------|----------|-----------------|
| PROJECT-REFERENCE.md | `docs/PROJECT-REFERENCE.md` | All 29 FRs, 29 UCs, UC specs, architecture, diagrams |
| Capstone.md | `docs/Capstone.md` | Full capstone report (converted from docx) |

When in doubt about requirements, acceptance criteria, or architecture decisions, consult `docs/PROJECT-REFERENCE.md` first. It is the single source of truth.

## System Actors

| Actor | Role | Platform |
|-------|------|----------|
| Reader | Browse, read, comment, rate manga | Web + Mobile |
| Premium User | Reader + offline reading, early access, ad-free | Web + Mobile |
| Administrator | Manage users, content, moderation, sync | Web (Admin Panel) |
| Scheduler | Automated MangaDex sync jobs | Backend (cron) |
| MangaDex API | External manga data source | External |

## Feature Priority (for development order)

### CRITICAL — Must implement first
- FR-01 User Registration
- FR-02 User Login/Logout
- FR-05 View Manga List
- FR-06 Search & Filter Manga
- FR-07 View Manga Details
- FR-08 Read Manga Online
- FR-23 RBAC
- FR-24 User Management (Admin)
- FR-25 Content Management (Admin)

### HIGH — Second wave
- FR-03 Password Reset
- FR-04 User Profile Management
- FR-10 Track Reading Progress
- FR-11 Sync Reading Across Devices
- FR-12 Comment on Manga
- FR-13 Rate Manga
- FR-14 Add to Favorites
- FR-26 Content Moderation
- FR-27 Report Handling

### MEDIUM — Third wave
- FR-09 Reading Mode Settings
- FR-16 Recommendation System
- FR-17 Notification System
- FR-18 Search Optimization
- FR-19 Payment Integration
- FR-20 Premium Subscription

### LOW — If time permits
- FR-15 Social Sharing
- FR-21 Offline Reading
- FR-22 Early Access Content
- FR-28 AI Chatbot Support
- FR-29 AI Content Moderation

## Tech Stack (decided)

| Layer | Technology | Notes |
|-------|-----------|-------|
| Frontend | Flutter 3.x | Cross-platform: Web + iOS + Android |
| Backend | Java Spring Boot | RESTful API |
| Database | PostgreSQL | Primary data store |
| Search | Elasticsearch | Full-text manga search |
| Storage | AWS S3 + CloudFront | Manga images |
| Auth | Spring Security + JWT + bcrypt | Stateless auth |
| Payments | MoMo, VNPAY | Vietnamese gateways |
| Notifications | Firebase Cloud Messaging | Push notifications |
| AI | LLM API (external) | Chatbot, recommendations |
| Content Source | MangaDex API | Manga data sync |

## Reference Projects (in REF/)

Use these as architecture and pattern references. Do NOT copy code verbatim — study and adapt.

| Project | Use it for |
|---------|-----------|
| `flutter_manga_reader` | **Primary reference** — clean architecture, Riverpod, multi-package, go_router, Drift DB, Material 3 |
| `flutter-wonderous-app` | UI polish, animations, responsive design, Provider patterns |
| `MangaDex` | MangaDex-specific API patterns, color scheme (coral #f26d5b), Dio usage |
| `Tachidesk-Sorayomi` | Hooks + Riverpod, infinite scroll pagination, GraphQL, Hive storage |
| `miru-app` | Desktop UI with Fluent design, multi-source handling, media playback |
| `Fludex` | Simple MangaDex integration, mangadex_library package usage |

### How to use REF/

1. Before implementing a feature, check if a similar feature exists in REF/ projects
2. Study how they structured the feature (folder, widgets, state management)
3. Adapt the pattern to our architecture (Riverpod + GoRouter + freezed)
4. Do NOT import or depend on REF/ code — it's reference material only

## Non-Functional Requirements (key constraints)

- Page load time: < 2 seconds
- Image load time: < 1 second per image
- Auth response: < 1 second
- Search results: < 2 seconds
- Support Vietnamese and English
- HTTPS/TLS 1.3 everywhere
- WCAG 2.1 AA accessibility

## Domain Vocabulary

| Term | Meaning |
|------|---------|
| Manga | A Japanese-style comic, with a cover, description, author, genre tags, and status (ongoing/completed) |
| Chapter | A numbered section of a manga containing ordered page images |
| Page | A single image within a chapter |
| Reading Progress | User's last-read position (manga + chapter + page) |
| Favorites | User's bookmarked manga list |
| MangaDex ID | Unique identifier from MangaDex API for deduplication |
| Sync Job | Automated/manual process to fetch data from MangaDex API and update local DB |
| Premium | Paid subscription granting offline reading, early access, ad-free experience |
| OTP | One-time password for email verification and password reset (6 digits, 5-min expiry) |
