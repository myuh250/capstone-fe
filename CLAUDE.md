# Manga Reading Platform — Capstone Project

## Project Overview

Cross-platform manga reading application (Web, iOS, Android) built with Flutter frontend and Spring Boot backend. Data sourced from MangaDex API. Vietnamese market focus with MoMo/VNPAY payment integration.

## Repository Layout

```
CAPSTONE/
├── docs/                    # Capstone document & PROJECT-REFERENCE.md
│   └── PROJECT-REFERENCE.md # Single source of truth for all FRs, UCs, architecture
├── SOURCE/
│   ├── frontend/            # Flutter app (this is where FE code lives)
│   └── backend/             # Spring Boot API
├── REF/                     # Reference projects (read-only, do NOT modify)
│   ├── flutter_manga_reader/  # Primary architecture reference
│   ├── Fludex/                # Basic MangaDex reader
│   ├── MangaDex/              # MangaDex mobile client
│   ├── flutter-wonderous-app/ # UI/animation patterns reference
│   ├── miru-app/              # Multi-source reader reference
│   └── Tachidesk-Sorayomi/    # Server-client architecture reference
└── .ai-rules/               # Agent rules (loaded by this file)
```

## Rules

All AI agents (Claude, Cursor, Copilot, etc.) MUST follow the rules in `.ai-rules/`. Load them in this order:

1. `.ai-rules/frontend.md` — Flutter frontend rules (primary focus)
2. `.ai-rules/conventions.md` — Code conventions & naming
3. `.ai-rules/project-context.md` — Domain knowledge & constraints

## Key Commands

```bash
# Frontend
cd SOURCE/frontend && flutter pub get
cd SOURCE/frontend && flutter run -d chrome     # web
cd SOURCE/frontend && flutter run                # mobile
cd SOURCE/frontend && dart run build_runner build --delete-conflicting-outputs

# Backend
cd SOURCE/backend && ./mvnw spring-boot:run
```

## Important

- `docs/PROJECT-REFERENCE.md` contains all 29 FRs, 29 UCs, architecture, and diagrams. Always consult it for requirements.
- `REF/` is read-only. Study patterns but never modify reference projects.
- Frontend is the current development focus.
