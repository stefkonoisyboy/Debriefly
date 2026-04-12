---
inclusion: auto
---

# Technology Stack

## Framework & Language

- Flutter SDK (cross-platform UI framework)
- Dart SDK: ^3.11.4
- Material Design components

## Dependencies

- `cupertino_icons: ^1.0.8` - iOS-style icons
- `flutter_lints: ^6.0.0` - Recommended linting rules (dev dependency)

## Build System

Flutter uses its own build system with platform-specific tooling:

- Android: Gradle (Kotlin DSL)
- iOS/macOS: Xcode projects
- Windows/Linux: CMake

## Code Quality

- Static analysis configured via `analysis_options.yaml`
- Uses `package:flutter_lints/flutter.yaml` for recommended lint rules
- Lints can be disabled per-line with `// ignore: name_of_lint` or per-file with `// ignore_for_file: name_of_lint`

## Common Commands

### Development

```bash
# Run the app in debug mode
flutter run

# Run on specific device
flutter run -d <device_id>

# Hot reload (press 'r' in terminal while app is running)
# Hot restart (press 'R' in terminal while app is running)
```

### Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart
```

### Build

```bash
# Build for Android
flutter build apk
flutter build appbundle

# Build for iOS
flutter build ios

# Build for web
flutter build web

# Build for desktop
flutter build windows
flutter build macos
flutter build linux
```

### Maintenance

```bash
# Get dependencies
flutter pub get

# Upgrade dependencies
flutter pub upgrade

# Check for outdated packages
flutter pub outdated

# Run static analysis
flutter analyze

# Format code
flutter format .
```

### Clean

```bash
# Clean build artifacts
flutter clean
```

## Backend Stack

- **Framework**: NestJS 11 with TypeScript
- **Runtime**: Node.js
- **Database**: PostgreSQL 16 with pgvector extension
- **ORM**: TypeORM 0.3
- **Authentication**: Passport.js with JWT strategy
- **Validation**: class-validator + class-transformer
- **Email**: Nodemailer with MJML templates
- **File Storage**: Cloudinary
- **AI Integration**: Google Gemini (gemini-2.5-flash)
- **Testing**: Jest

### Backend Commands

```bash
# Development server with watch mode (run manually in terminal)
npm run start:dev

# Production build
npm run build

# Start production server
npm run start:prod

# Lint and fix
npm run lint

# Run tests
npm run test

# Run tests with coverage
npm run test:cov

# Run e2e tests
npm run test:e2e

# Database seeding
npm run seed

# Migration commands
npm run migration:generate -- ./src/migrations/<Name>
npm run migration:run
npm run migration:revert
npm run migration:show
```

### Backend TypeScript Configuration

- Module system: NodeNext with ESM interop
- Decorators enabled (required for NestJS)
- Target: ES2023
- Strict null checks enabled

### Backend Key Libraries

- **@nestjs/core**: NestJS framework core
- **@nestjs/typeorm**: TypeORM integration
- **@nestjs/jwt**: JWT authentication
- **@nestjs/passport**: Passport.js integration
- **@nestjs/config**: Configuration management
- **@nestjs-modules/mailer**: Email service
- **typeorm**: ORM for PostgreSQL
- **bcryptjs**: Password hashing
- **class-validator**: DTO validation
- **cloudinary**: File upload and storage
- **@google/genai**: Google Gemini AI integration

### Backend Environment Variables

Required environment variables (see `api/.env`):

- **PORT**: Server port (default: 3000)
- **DATABASE_HOST**: PostgreSQL host
- **DATABASE_PORT**: PostgreSQL port
- **DATABASE_USERNAME**: Database user
- **DATABASE_PASSWORD**: Database password
- **DATABASE_NAME**: Database name
- **JWT_SECRET**: Secret for JWT signing
- **SMTP_HOST**: SMTP server host
- **SMTP_PORT**: SMTP server port
- **SMTP_FROM**: Email sender address
- **FRONTEND_URL**: Frontend URL for email links
- **GEMINI_API_KEY**: Google Gemini API key

### Database Setup

PostgreSQL runs via Docker Compose:

```bash
# Start database
docker compose up -d

# Stop database (data persists)
docker compose down

# Stop and remove data
docker compose down -v
```
