# Test Execution Guide

## Quick Start

### Prerequisites
```bash
# Ensure Flutter SDK is installed
flutter --version

# Install dependencies
flutter pub get
```

### Run All Tests
```bash
flutter test
```

### Run Specific Test Suites

#### Unit Tests (No Mocking Required)
```bash
flutter test test/unit_test.dart
```
**Coverage**: 
- CourseSelectionViewModel: 7 tests
- QuizConfigViewModel: 8 tests  
- Data flow validation: 2 tests

#### Widget Integration Tests
```bash
flutter test test/widget_integration_test.dart
```
**Coverage**:
- UI state management: 4 tests
- Navigation flow: 1 test

#### Full Integration Tests (Requires Mockito)
```bash
flutter test test/integration_test.dart
```
**Coverage**:
- Complete flow: 30+ tests
- Supabase operations: 6 tests
- Error handling: 5 tests
- State management: 3 tests

### Verify Test Setup
```bash
flutter test test/simple_test.dart
```

---

## Test Results Expected

### Unit Tests - `test/unit_test.dart`
✅ Should run successfully without any external dependencies

**Expected Output:**
```
00:01 +17: All tests passed!
```

### Widget Tests - `test/widget_integration_test.dart`  
✅ Tests UI interactions and state updates

**Expected Output:**
```
00:02 +6: All tests passed!
```

### Integration Tests - `test/integration_test.dart`
⚠️ Requires Supabase mocks (already provided)

**Expected Output:**
```
00:03 +28: All tests passed!
```

---

## Test Coverage Report

### Generate Coverage
```bash
flutter test --coverage
```

### View Coverage Report (macOS/Linux)
```bash
# Install lcov if not already installed
brew install lcov  # macOS
# or
sudo apt-get install lcov  # Linux

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open in browser
open coverage/html/index.html  # macOS
xdg-open coverage/html/index.html  # Linux
```

---

## Troubleshooting

### Issue: "Operation not permitted" error
**Cause**: Flutter cache permission issue (non-blocking)
**Solution**: Tests should still run. If they don't:
```bash
flutter clean
flutter pub get
flutter test
```

### Issue: Tests fail with missing dependencies
**Solution**:
```bash
flutter pub get
flutter pub upgrade
```

### Issue: Mock generation fails
**Solution**: Manual mocks are already provided in `test/integration_test.mocks.dart`

### Issue: "Unable to load asset" errors
**Solution**: Ensure you're running tests with `flutter test`, not `dart test`

---

## Continuous Integration

### GitHub Actions Example
```yaml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.1.0'
          
      - name: Install dependencies
        run: flutter pub get
        
      - name: Run unit tests
        run: flutter test test/unit_test.dart
        
      - name: Run widget tests  
        run: flutter test test/widget_integration_test.dart
        
      - name: Run all tests with coverage
        run: flutter test --coverage
        
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info
```

---

## Test Maintenance Checklist

When adding new features:
- [ ] Add unit tests for ViewModels
- [ ] Add widget tests for UI components
- [ ] Add integration tests for data flow
- [ ] Test error scenarios
- [ ] Test loading states
- [ ] Update test documentation
- [ ] Verify all tests pass locally
- [ ] Check coverage hasn't decreased

---

## Performance Benchmarks

### Expected Test Execution Times
- Simple test: < 1 second
- Unit tests: 2-3 seconds  
- Widget tests: 3-5 seconds
- Integration tests: 5-10 seconds
- All tests: 10-15 seconds

### If Tests Run Slower
1. Check for unnecessary `pumpAndSettle()` calls
2. Reduce artificial delays in tests
3. Use `pump()` instead of `pumpAndSettle()` where possible
4. Consider splitting large test files

---

## Test Data

### Mock Data Used
- **Courses**: 8 predefined courses (Psychology, Social Sciences, etc.)
- **Exam Metadata**: Generated based on course
- **Questions**: Mocked Supabase responses
- **User IDs**: Test user IDs (e.g., 'test-user-123')

### Test Database (Supabase Mocking)
All Supabase operations are mocked in integration tests:
- No real database connection required
- Consistent test data across runs
- Fast test execution
- No test data cleanup needed

---

## Next Steps

1. ✅ Tests are ready to run
2. ✅ Documentation is complete
3. ✅ Mock files are in place
4. Run tests: `flutter test`
5. Review coverage: `flutter test --coverage`
6. Integrate into CI/CD pipeline

---

## Additional Resources

- **Detailed Coverage**: See `TEST_FLOW_REVIEW.md`
- **Test Documentation**: See `test/README.md`
- **Build Commands**: See `AGENTS.md`
- **Architecture**: See MVVM pattern in `/lib` directory
