#!/bin/bash
echo "Checking Dart syntax for new files..."
dart analyze --no-fatal-infos lib/services/repositorie/exam_repository.dart 2>&1 | grep -E "error|warning" || echo "✓ exam_repository.dart - OK"
dart analyze --no-fatal-infos lib/viewmodels/quiz_config_view_model.dart 2>&1 | grep -E "error|warning" || echo "✓ quiz_config_view_model.dart - OK"
dart analyze --no-fatal-infos lib/services/repositorie/mock_exam_repository.dart 2>&1 | grep -E "error|warning" || echo "✓ mock_exam_repository.dart - OK"
dart analyze --no-fatal-infos lib/views/quiz_config_screen_wrapper.dart 2>&1 | grep -E "error|warning" || echo "✓ quiz_config_screen_wrapper.dart - OK"
dart analyze --no-fatal-infos lib/views/QuizConfig_screen.dart 2>&1 | grep -E "error|warning" || echo "✓ QuizConfig_screen.dart - OK"
dart analyze --no-fatal-infos lib/views/exam_screen.dart 2>&1 | grep -E "error|warning" || echo "✓ exam_screen.dart - OK"
