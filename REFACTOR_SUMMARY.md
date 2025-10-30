# Home Screen Refactor Summary

## Changes Made

### 1. Created Course Model (`lib/models/course.dart`)
- Defines `Course` class matching Supabase schema:
  - `id` (UUID)
  - `courseKey` (unique identifier like 'psicologia', 'direito')
  - `title` (display name)
  - `description` (optional)
  - `iconKey` (icon identifier for UI mapping)
  - `isActive` (boolean flag)
- Includes JSON serialization methods for Supabase integration

### 2. Created Course Repository (`lib/repositories/course_repository.dart`)
- `CourseRepository` class handles Supabase queries
- `fetchCourses()`: Retrieves all active courses ordered by title
- `fetchCourseByCourseKey(String)`: Retrieves specific course by course_key
- Filters by `is_active = true` to show only enabled courses

### 3. Created CourseSelectionViewModel (`lib/viewmodels/course_selection_view_model.dart`)
- Extends `ChangeNotifier` for Provider integration
- Manages course loading state, error handling, and selection
- Methods:
  - `loadCourses()`: Fetches courses from repository
  - `selectCourse(String)`: Updates selected course by ID
  - `getSelectedCourse()`: Returns selected Course object

### 4. Refactored HomeScreen (`lib/views/home.screen.dart`)
- **Removed**: Hardcoded `_courses` list
- **Added**: Provider integration with `CourseSelectionViewModel`
- **Added**: Loading state with `CircularProgressIndicator`
- **Added**: Error handling with retry functionality
- **Added**: Navigation to `QuizConfigScreen` with selected course data
- **Updated**: Icon mapping from course `icon_key` to Flutter IconData
- **Updated**: Passes both `id` and `course_key` to QuizConfig screen

### 5. Updated MainNavigationScreen (`lib/views/main_navigation_screen.dart`)
- Wrapped `HomeScreen` with `ChangeNotifierProvider`
- Provides `CourseSelectionViewModel` with `CourseRepository` instance
- Uses Supabase client for data fetching

## Supabase Schema Alignment

The refactor now correctly aligns with the documented schema:

```sql
CREATE TABLE courses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  course_key TEXT UNIQUE NOT NULL,  -- e.g., 'psicologia', 'direito'
  title TEXT NOT NULL,               -- e.g., 'Psicologia', 'Direito'
  description TEXT,
  icon_key TEXT,                     -- Icon identifier for UI
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Column Mapping
- `id` → UUID primary key
- `course_key` → Unique identifier for programmatic use (e.g., 'psicologia')
- `title` → Display name shown to users (e.g., 'Psicologia')
- `icon_key` → Maps to Flutter icon (e.g., 'psychology_outlined')
- `is_active` → Boolean filter for enabled courses

## Navigation Flow

1. User opens MainNavigationScreen → HomeScreen loads
2. HomeScreen calls `loadCourses()` on mount
3. Repository queries `courses` table filtering by `is_active = true`
4. Courses displayed from Supabase with title and icon
5. User selects course → ViewModel updates selection
6. Navigation to QuizConfigScreen with course data (id, course_key, title, icon)
7. QuizConfig can use `course_key` to query related exams

## Icon Key Mapping

The following icon_key values are mapped in HomeScreen:

```dart
'psychology_outlined' → Icons.psychology_outlined
'groups_outlined' → Icons.groups_outlined
'business_center_outlined' → Icons.business_center_outlined
'monetization_on_outlined' → Icons.monetization_on_outlined
'school_outlined' → Icons.school_outlined (default)
'palette_outlined' → Icons.palette_outlined
'gavel_outlined' → Icons.gavel_outlined
'calculate_outlined' → Icons.calculate_outlined
```

## Benefits

- **Schema Compliance**: Follows documented Supabase schema exactly
- **Dynamic Data**: Courses loaded from Supabase, no hardcoding
- **State Management**: Provider pattern for reactive UI
- **Error Handling**: Graceful error states with retry
- **Separation of Concerns**: Model, Repository, ViewModel, View layers
- **Maintainability**: Easy to add/modify courses via database
- **Extensibility**: course_key enables querying related exams and questions
