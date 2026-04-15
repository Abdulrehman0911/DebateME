# DebateME

A gamified AI-powered debate trainer built with Flutter. Debate against adaptive AI personas, sharpen your rebuttal strategy, and track your progress with Elo-style scoring.

## Live App
- Web: https://debateme-15b75.web.app

## Features
- Adaptive AI debate opponent with persona-based style
- Custom match setup (topic, stance, rounds, opponent)
- Steel-man rounds to improve argument quality and fairness
- Match scorecard with coaching feedback
- Match history and performance tracking
- Swipe navigation between main app tabs on mobile and web

## Tech Stack
- Flutter (Android, iOS, Web, Desktop)
- Firebase Auth + Firestore
- Hive for local data persistence
- Gemini API via `google_generative_ai`

## Project Structure
- `lib/features/`: feature modules (`home`, `arena`, `history`, etc.)
- `lib/core/`: constants, services, models, theme
- `lib/widgets/`: reusable UI components
- `assets/`: static assets

## Getting Started
### Prerequisites
- Flutter SDK (stable)
- Firebase project configured
- Gemini API key

### Setup
1. Clone the repository:
	```bash
	git clone https://github.com/Abdulrehman0911/DebateME.git
	cd DebateME
	```
2. Install dependencies:
	```bash
	flutter pub get
	```
3. Create environment file:
	```bash
	cp .env.example .env
	```
4. Fill `.env` values:
	- `GEMINI_API_KEY`
	- optional `GEMINI_MODEL` (defaults to `gemini-2.5-flash`)
5. Run the app:
	```bash
	flutter run
	```

## Quality Checks
```bash
flutter analyze
flutter test
```

## Web Deployment (Firebase Hosting)
1. Build web:
	```bash
	flutter build web
	```
2. Deploy:
	```bash
	firebase deploy --only hosting
	```

The hosted app URL is configured as: https://debateme-15b75.web.app

## Screenshots
Create screenshots in `artifacts/screenshots/` when running local E2E validations.

## Security Notes
- Never commit `.env`.
- Rotate API keys immediately if they are exposed.
- Use `.env.example` for onboarding.

## Contributing
See `CONTRIBUTING.md` for contribution and validation workflow.
