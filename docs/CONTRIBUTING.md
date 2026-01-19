# Contributing to Utammy's Mobile App

Thank you for considering contributing to Utammy's Mobile App! This document provides guidelines and best practices for contributing.

## Development Setup

1. Follow the instructions in [SETUP.md](SETUP.md) to set up your development environment
2. Create a new branch for your feature: `git checkout -b feature/your-feature-name`
3. Make your changes following the coding standards below

## Coding Standards

### Dart/Flutter Code Style

- Follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter format .` before committing
- Run `flutter analyze` to check for issues
- Maintain consistent naming conventions:
  - Classes: `PascalCase`
  - Variables/Functions: `camelCase`
  - Constants: `lowerCamelCase` with `const`
  - Private members: prefix with `_`

### Project Structure

```
lib/
├── main.dart           # Entry point only
├── models/             # Data models and entities
├── screens/            # Full-page UI screens
├── services/           # Business logic, API calls
└── widgets/            # Reusable UI components
```

### API Integration

- All API calls should go through `ApiService` in `lib/services/api_service.dart`
- Use proper error handling with try-catch blocks
- Display user-friendly error messages
- Example:
  ```dart
  try {
    final data = await ApiService.get('products');
    // Handle success
  } catch (e) {
    // Handle error with user-friendly message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to load products')),
    );
  }
  ```

### State Management

- Use Flutter's built-in state management (StatefulWidget) for simple cases
- Consider Provider or Riverpod for complex state management (to be added as needed)

### Testing

- Write unit tests for business logic in `test/`
- Test file naming: `*_test.dart`
- Run tests before committing: `flutter test`
- Aim for meaningful test coverage

## Git Workflow

### Branch Naming

- Features: `feature/description-of-feature`
- Bug fixes: `bugfix/description-of-bug`
- Hotfixes: `hotfix/description-of-hotfix`

### Commit Messages

Follow the conventional commits specification:

```
type(scope): brief description

Longer description if needed

Examples:
feat(catalog): add product listing screen
fix(api): handle network timeout errors
docs(readme): update setup instructions
style(ui): adjust button colors
refactor(service): simplify API error handling
test(api): add tests for API service
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Pull Request Process

1. Ensure your code follows the coding standards
2. Run `flutter analyze` and fix any issues
3. Run `flutter test` and ensure all tests pass
4. Update documentation if needed
5. Create a pull request with a clear description:
   - What changes were made
   - Why the changes were necessary
   - How to test the changes
   - Screenshots for UI changes

## Adding Dependencies

1. Check if the dependency is necessary
2. Add to `pubspec.yaml` under appropriate section
3. Run `flutter pub get`
4. Update documentation if the dependency affects setup or configuration

## Environment Variables

- Never commit the `.env` file
- Update `.env.example` if adding new environment variables
- Document new variables in README.md

## UI/UX Guidelines

- Follow Material Design 3 guidelines
- Ensure responsive design for different screen sizes
- Test on both Android and iOS if possible
- Maintain consistent spacing and colors
- Use theme colors from `Theme.of(context)`

## API Integration Guidelines

- All endpoints should be documented
- Use proper HTTP methods (GET, POST, PUT, DELETE)
- Handle authentication tokens properly
- Implement proper error handling
- Show loading indicators during API calls

## Code Review

All submissions require code review. Reviewers will check for:
- Code quality and readability
- Adherence to coding standards
- Proper error handling
- Test coverage
- Documentation updates

## Questions or Issues?

- Open an issue in the repository
- Contact the maintainers
- Check existing documentation

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.
