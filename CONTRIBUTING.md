# Contributing to DebateME

## Setup
1. Install Flutter SDK (stable channel).
2. Run `flutter pub get`.
3. Create `.env` from `.env.example` and set `GEMINI_API_KEY`.
4. Run `flutter run`.

## Development Standards
- Keep changes focused and small.
- Prefer readable widgets and clear naming.
- Add tests when introducing logic-heavy behavior.
- Keep UI responsive for mobile and web.

## Validation Before PR
- `flutter analyze`
- `flutter test`
- Manually verify: login, custom match start, one full match, scorecard screen.

## Commit Style
Use concise, action-based commit messages, for example:
- `feat(home): add swipe navigation and sticky match CTA`
- `fix(ai): use configurable Gemini model and stronger key checks`
- `docs: add setup, deployment, and contribution guide`
