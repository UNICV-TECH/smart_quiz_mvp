# UI Components Inventory

This document provides a comprehensive catalog of all 17 reusable UI components in the `lib/ui/components/` directory, organized by category with their properties, usage examples, and role in the application's test-taking flow.

---

## Table of Contents

1. [Navigation Components](#navigation-components)
2. [Button Components](#button-components)
3. [Input Components](#input-components)
4. [Card Components](#card-components)
5. [Display Components](#display-components)
6. [Layout Components](#layout-components)
7. [Component Usage Flow](#component-usage-flow)

---

## Navigation Components

### 1. CustomNavBar
**File:** `default_navbar.dart`

**Description:** A custom bottom navigation bar with a unique curved design featuring an animated elevated circle that highlights the selected item.

**Properties:**
- `selectedIndex` (int?): The currently selected tab index (0-2)
- `onItemTapped` (Function(int)?): Callback when a tab is tapped

**Items:**
- 0: Início (Home)
- 1: Explorar (Explore)
- 2: Perfil (Profile)

**Styling:**
- Background Color: `AppColors.greenNavBar`
- Height: 110px with 70px circular indicator
- Animation Duration: 520ms with easeInOut curve
- Custom clipper creates curved notch for selected item

**Usage in Flow:**
```dart
CustomNavBar(
  selectedIndex: _navBarIndex,
  onItemTapped: (index) {
    setState(() { _navBarIndex = index; });
  },
)
```

**Used in:**
- `home.screen.dart` - Main navigation
- `QuizConfig_screen.dart` - Quiz configuration navigation

---

### 2. QuestionNavigation
**File:** `default_question_navigation.dart`

**Description:** A horizontal scrollable navigation bar displaying numbered circles representing exam questions with visual feedback for answered/current/inactive states.

**Properties:**
- `totalQuestions` (int): Total number of questions in the exam
- `currentQuestion` (int): Currently displayed question number (1-based)
- `onQuestionSelected` (Function(int)): Callback when a question circle is tapped
- `answeredQuestions` (Set<int>): Set of question numbers that have been answered

**Visual States:**
- **Current/Answered:** Green background (`AppColors.green`), white text
- **Active (unanswered):** White background, green text, grey border
- **Inactive:** Grey background and text

**Dimensions:**
- Circle size: 40x40px
- Spacing: 3px horizontal margin
- Fixed count: 15 circles displayed

**Usage in Flow:**
```dart
QuestionNavigation(
  totalQuestions: exam.questions.length,
  currentQuestion: currentQuestionIndex + 1,
  onQuestionSelected: (questionNumber) {
    setState(() { currentQuestionIndex = questionNumber - 1; });
  },
  answeredQuestions: selectedAnswers.keys.toSet(),
)
```

**Used in:**
- `exam_screen.dart` - Question navigation during exam

---

## Button Components

### 3. DefaultButtonOrange
**File:** `default_button_orange.dart`

**Description:** Primary action button with orange background, used for main CTAs throughout the application.

**Properties:**
- `texto` (String): Button text
- `icone` (IconData?): Optional leading icon
- `onPressed` (VoidCallback?): Action callback
- `corFundo` (Color?): Custom background color
- `corTexto` (Color?): Custom text color
- `altura` (double): Button height (default: 67.0)
- `largura` (double): Button width (default: double.infinity)
- `tipo` (BotaoTipo): Button type enum

**Button Types:**
- `BotaoTipo.primario`: Orange background (RGB 239, 153, 45)
- `BotaoTipo.secundario`: Darker orange (RGB 220, 155, 60)
- `BotaoTipo.desabilitado`: Grey background, disabled state

**Styling:**
- Border radius: 19px
- Font size: 20px, bold
- Full width by default

**Usage in Flow:**
```dart
DefaultButtonOrange(
  texto: 'Iniciar',
  onPressed: _startQuiz,
  tipo: BotaoTipo.primario,
)
```

**Used in:**
- `QuizConfig_screen.dart` - "Iniciar" button to start quiz
- `default_exam_history_accordion.dart` - "Expandir" and "Tentar novamente" buttons

---

### 4. DefaultButtonArrowBack
**File:** `default_button_arrow_back.dart`

**Description:** Icon-only back button with iOS-style arrow, typically used in top-left navigation.

**Properties:**
- `onPressed` (VoidCallback?): Action callback (usually `Navigator.pop`)
- `iconSize` (double): Icon size (default: 28.0)
- `iconColor` (Color?): Icon color (default: `AppColors.deepGreen`)

**Styling:**
- Icon: `Icons.arrow_back_ios_new_rounded`
- Splash radius: 24px
- Tooltip: "Voltar"

**Usage in Flow:**
```dart
DefaultButtonArrowBack(
  onPressed: () => Navigator.of(context).pop(),
)
```

**Used in:**
- `QuizConfig_screen.dart` - Back navigation
- `exam_screen.dart` - Exit exam navigation

---

### 5. DefaultButtonBack
**File:** `default_button_back.dart`

**Description:** Text button with icon for "Previous" navigation in multi-step flows.

**Properties:**
- `text` (String): Button label (e.g., "Anterior")
- `onPressed` (VoidCallback): Action callback
- `icon` (IconData?): Optional leading icon
- `fontSize` (double): Text size (default: 14)

**Styling:**
- Icon color: `AppColors.primaryDark`
- Text color: `AppColors.webNeutral800`
- Font weight: w600, size: 16

**Usage in Flow:**
```dart
DefaultButtonBack(
  text: 'Anterior',
  icon: Icons.arrow_back_ios,
  onPressed: () {
    setState(() { currentQuestionIndex--; });
  },
)
```

**Used in:**
- `exam_screen.dart` - Navigate to previous question

---

### 6. DefaultButtonForward
**File:** `default_button_forward.dart`

**Description:** Text button with trailing icon for "Next/Finish" navigation in multi-step flows.

**Properties:**
- `text` (String): Button label (e.g., "Próxima", "Finalizar")
- `onPressed` (VoidCallback): Action callback
- `icon` (IconData?): Optional trailing icon
- `fontSize` (double): Text size (default: 14)

**Styling:**
- Text and icon color: `AppColors.primaryDark`
- Font weight: w600, size: 16
- Icon positioned after text

**Usage in Flow:**
```dart
DefaultButtonForward(
  text: isLastQuestion ? 'Finalizar' : 'Próxima',
  icon: Icons.arrow_forward_ios,
  onPressed: _handleNext,
)
```

**Used in:**
- `exam_screen.dart` - Navigate to next question or finish exam

---

## Input Components

### 7. ComponenteInput
**File:** `default_input.dart`

**Description:** Standard text input field with label, hint text, and validation support.

**Properties:**
- `controller` (TextEditingController?): Text controller
- `labelText` (String): Field label above input
- `hintText` (String): Placeholder text (default: '')
- `errorMessage` (String?): Validation error message
- `keyboardType` (TextInputType): Keyboard type (default: text)
- `onChanged` (ValueChanged<String>?): Change callback
- `validator` (String? Function(String?)?): Validation function
- `width` (double): Field width (default: double.infinity)
- `backgroundColor` (Color): Background color (default: `AppColors.greenChart`)
- `borderColor`, `borderColorFocus`, `borderColorError` (Color): Border colors
- `borderRadius` (double): Corner radius (default: 15.0)
- `textStyle`, `labelStyle` (TextStyle): Text styling

**Styling:**
- Label: Bold 18px, color `AppColors.estiloLabel`
- Input: 16px, color `AppColors.primaryDark`
- Padding: 20px horizontal
- Error text: 12px, red color

**Usage Example:**
```dart
ComponenteInput(
  labelText: 'E-mail',
  hintText: 'exemplo@email.com',
  keyboardType: TextInputType.emailAddress,
  validator: _validateEmail,
)
```

---

### 8. ComponentePasswordInput
**File:** `default_password_input_47.dart`

**Description:** Password input field with visibility toggle icon, inheriting ComponenteInput styling.

**Properties:**
- Same as ComponenteInput, plus:
- `initialObscureText` (bool): Initial visibility state (default: true)

**Features:**
- Toggle icon: `Icons.visibility` / `Icons.visibility_off`
- Suffix icon button to toggle password visibility
- State management for obscureText property
- KeyboardType: `TextInputType.visiblePassword`

**Usage Example:**
```dart
ComponentePasswordInput(
  labelText: 'Senha',
  hintText: 'Digite sua senha',
  errorMessage: _passwordError,
)
```

---

### 9. SelectionBox
**File:** `default_chekbox.dart`

**Description:** Custom checkbox list for single-selection from multiple options, used for quiz configuration.

**Properties:**
- `options` (List<String>): List of option texts
- `onOptionSelected` (ValueChanged<String>): Selection callback
- `initialOption` (String?): Initially selected option

**Visual States:**
- **Selected:** Green checkmark in green box, bold green text
- **Unselected:** Empty grey-bordered box, normal grey text

**Styling:**
- Checkbox size: 24.07x24.07px
- Border radius: 8px
- Spacing: 12px between checkbox and text
- Font: Montserrat, 16px

**Usage in Flow:**
```dart
SelectionBox(
  options: ['5', '10', '15', '20'],
  initialOption: _selectedQuantity,
  onOptionSelected: (quantity) {
    setState(() { _selectedQuantity = quantity; });
  },
)
```

**Used in:**
- `QuizConfig_screen.dart` - Select number of questions (5, 10, 15, 20)

---

### 10. AlternativeSelectorVertical
**File:** `default_radio_group.dart`

**Description:** Vertical radio button group for multiple-choice question alternatives (A, B, C, D, E).

**Properties:**
- `labels` (List<String>): Alternative text options
- `selectedOption` (String?): Currently selected option letter
- `onChanged` (Function(String)): Selection callback

**Features:**
- Automatically generates letters A-E based on list length
- Circular button with letter inside
- Tappable row including text

**Visual States:**
- **Selected:** Green circle (`AppColors.green`)
- **Unselected:** Grey circle (`AppColors.webNeutral400`)

**Styling:**
- Circle size: 36x36px
- Text color: Always white
- Spacing: 12px between circle and text
- Vertical padding: 6px

**Usage in Flow:**
```dart
AlternativeSelectorVertical(
  labels: currentQuestion.alternatives,
  selectedOption: currentAnswer,
  onChanged: (option) {
    setState(() {
      selectedAnswers[currentQuestion.id] = option;
    });
  },
)
```

**Used in:**
- `exam_screen.dart` - Select answer for each question

---

## Card Components

### 11. SubjectCard
**File:** `default_subject_card.dart`

**Description:** Interactive card for displaying and selecting academic subjects/courses with icon and title.

**Properties:**
- `icon` (Widget): Subject icon widget
- `title` (String): Subject name
- `onTap` (VoidCallback?): Selection callback
- `isSelected` (bool): Selection state (default: false)
- `borderRadius` (double): Corner radius (default: 20)
- `padding` (EdgeInsetsGeometry): Internal padding (default: 20h, 18v)

**Visual States:**
- **Selected:** White background, green border (1.4px), green text, stronger shadow
- **Hover:** Same as selected
- **Default:** Light grey background, grey border (1px), dark text, subtle shadow

**Styling:**
- Icon size: 44x44px container
- Font: 16px, weight w500/w600
- Border radius: 20px
- Animated transitions: 180ms easeOutCubic
- Box shadow with hover/selection enhancement

**Usage in Flow:**
```dart
SubjectCard(
  icon: Icon(Icons.psychology_outlined, color: AppColors.green, size: 30),
  title: 'Psicologia',
  isSelected: _selectedCourseId == 'psicologia',
  onTap: () => _onCourseSelected(course),
)
```

**Used in:**
- `home.screen.dart` - Select subject for exam (8 subjects displayed)

---

### 12. UserProfileCard
**File:** `default_user_profile_card.dart`

**Description:** Profile card with avatar, editable name, email, and inline editing functionality.

**Properties:**
- `userName` (String): User's display name
- `userEmail` (String): User's email address
- `profileImageUrl` (String?): Optional profile image URL
- `onNameUpdate` (Future<bool> Function(String)?): Async name update callback
- `onShowFeedback` (void Function(String, {bool isError})?): Feedback callback
- `padding`, `margin` (EdgeInsets): Card spacing
- `backgroundColor` (Color): Card background (default: white)
- `borderRadius` (double): Corner radius (default: 12.0)

**Features:**
- Editable name field with inline edit/cancel buttons
- Loading state during name update
- Default avatar icon fallback
- Error handling with image loading
- Keyboard support (Enter key to save)

**Visual Elements:**
- Avatar: 60x60px circle with green border
- Edit icon: 16px green
- Check/close buttons: 32x32px constraints
- Name: 18px bold
- Email: 14px regular grey

**Usage Example:**
```dart
UserProfileCard(
  userName: "João Silva",
  userEmail: "joao.silva@gmail.com",
  onNameUpdate: (newName) async {
    // API call to update name
    return true;
  },
  onShowFeedback: (message, {isError = false}) {
    // Show snackbar
  },
)
```

---

### 13. DefaultScorecard
**File:** `default_scoreCard.dart`

**Description:** Simple card displaying an icon with a numerical score, used for statistics display.

**Properties:**
- `icon` (IconData): Score icon
- `score` (int): Numerical score value
- `iconColor` (Color?): Icon color
- `scoreColor` (Color?): Score text color
- `backgroundColor` (Color?): Card background (default: white)
- `borderColor` (Color?): Border color (default: grey)
- `width`, `height` (double?): Dimensions (height default: 80)
- `padding`, `margin` (EdgeInsets?): Spacing
- `iconSize` (double?): Icon size (default: 32, clamped 24-40)
- `fontSize` (double?): Score font size (auto-calculated from icon size)
- `onTap` (VoidCallback?): Optional tap callback

**Styling:**
- Border radius: 12px
- Border width: 1px
- Elevation: 0
- Icon and score in horizontal row with 16px spacing
- Font weight: Bold

**Usage Example:**
```dart
DefaultScorecard(
  icon: Icons.check_circle_outline,
  score: 85,
  iconColor: AppColors.green,
  scoreColor: AppColors.primaryDark,
)
```

---

## Display Components

### 14. AppLogoWidget
**File:** `default_Logo.dart`

**Description:** Responsive logo widget supporting both local assets and network images with size presets.

**Factories:**
- `AppLogoWidget.asset()`: Load from local assets
- `AppLogoWidget.network()`: Load from network URL

**Properties:**
- `size` (AppLogoSize): Predefined size enum
- `logoPath` (String): Image path or URL
- `semanticLabel` (String): Accessibility label (default: 'Logo do aplicativo')

**Size Presets (relative to screen width):**
- `AppLogoSize.small`: 24% of screen width
- `AppLogoSize.medium`: 65% of screen width
- `AppLogoSize.large`: 92% of screen width

**Features:**
- Automatic error handling with placeholder icon
- Responsive sizing based on screen dimensions
- BoxFit.contain for aspect ratio preservation

**Usage in Flow:**
```dart
AppLogoWidget.network(
  size: AppLogoSize.small,
  logoPath: 'https://...supabase.../LogoFundoClaro.png',
  semanticLabel: 'Logo UniCV',
)
```

**Used in:**
- `home.screen.dart` - Header logo
- `QuizConfig_screen.dart` - Header logo
- `exam_screen.dart` - Header logo

---

### 15. AppText
**File:** `ui/theme/string_text.dart`

**Description:** Reusable text component with predefined style system and optional click handling.

**Constructors:**
- `AppText(String)`: Single-style text
- `AppText.rich(TextSpan)`: Multi-style rich text

**Properties:**
- `data` (String?): Text content (for single-style)
- `textSpan` (TextSpan?): Rich text content
- `style` (AppTextStyle): Predefined style enum
- `color` (Color?): Text color override
- `textAlign` (TextAlign?): Text alignment
- `onPressed` (VoidCallback?): Makes text tappable

**Style Presets:**
- `titleLarge`: 56px bold
- `titleMedium`: 40px bold
- `titleSmall`: 20px bold
- `subtitleMedium`: 16px regular
- `subtitleSmall`: 15px regular

**Features:**
- Google Fonts Montserrat integration
- Automatic padding for clickable text (2px)
- InkWell ripple effect when tappable

**Usage in Flow:**
```dart
AppText(
  'Para qual prova',
  style: AppTextStyle.titleSmall,
  color: AppColors.primaryDark,
)

AppText.rich(
  TextSpan(
    children: [
      TextSpan(text: 'Texto com uma '),
      TextSpan(
        text: 'palavra importante',
        style: TextStyle(fontWeight: FontWeight.w900),
      ),
    ],
  ),
  style: AppTextStyle.subtitleMedium,
)
```

**Used in:**
- `home.screen.dart` - Headings and descriptions
- `QuizConfig_screen.dart` - Titles and instructions

---

## Layout Components

### 16. DefaultAccordion
**File:** `default_accordion.dart`

**Description:** Expandable accordion item with icon, title, and collapsible content.

**Properties:**
- `title` (String): Accordion header text
- `content` (String): Expandable content text
- `icon` (IconData?): Optional leading icon
- `titleColor` (Color?): Title text color (default: `AppColors.primaryDark`)
- `contentColor` (Color?): Content text color (default: `AppColors.secondaryDark`)
- `backgroundColor` (Color?): Card background (default: white)
- `iconColor` (Color?): Icon and expand arrow color (default: `AppColors.green`)

**Styling:**
- Border radius: 15px
- Box shadow: 6px blur, offset (0, 2)
- Title: 16px, Poppins, w600
- Content: 14px, Poppins, line-height 1.5
- Icon container: 10px padding, 10px border radius
- Padding: 20h, 8v (tile) / 20h, 20v (content)

**Features:**
- ExpansionTile with custom theme
- Icon with colored background
- No divider color (transparent)
- Left-aligned content text

**Usage Example:**
```dart
DefaultAccordion(
  title: 'Resultados',
  content: 'Aqui você pode ver seus resultados...',
  icon: Icons.assessment_outlined,
)
```

---

### 17. ExamHistoryAccordion
**File:** `default_exam_history_accordion.dart`

**Description:** Complex accordion component displaying exam history by subject with nested attempt details, timelines, and expansion controls.

**Properties:**
- `service` (ExamHistoryRepository): Data service
- `iconByKey` (Map<String, IconData>): Subject icon mapping
- `onExpandExam` (Function(SubjectExamHistory, ExamAttempt)?): Expand callback

**Architecture:**
- Uses Provider pattern with `ExamHistoryViewModel`
- Nested components: `_SubjectHistoryTile`, `_SubjectTotals`, `_AttemptBlock`, `_QuestionTimeline`
- Loading, error, and empty states

**Visual Structure:**

**Subject Tile (collapsed):**
- 54x54px icon container with border
- Subject name with "Prova " prefix
- Animated circular expand button (32x32px)
- Padding: 16h, 18v

**Expanded Content:**
- Subject totals (total exams, questions, correct answers)
- List of exam attempts with dividers
- Each attempt shows:
  - Date (DD/MM/YY format)
  - Duration (minutes and seconds)
  - Question timeline (circles colored by outcome)
  - "Expandir" button

**Question Timeline:**
- Circular indicators (28x28px) for each question
- Color coding:
  - **Correct:** Green background (#3F8B3A)
  - **Incorrect:** Red background (#D9503F)
  - **Unanswered:** Transparent with grey border

**Styling:**
- Gradient background: Light green to beige
- Deep green (#2F4A2B) for primary text
- Accent green (#3A6B3F) for highlights
- Card fill: #EFF4EA
- Border radius: 20px throughout
- Animation: 250ms easeInOut for expansion

**Usage Example:**
```dart
ExamHistoryAccordion(
  service: examHistoryRepository,
  iconByKey: {
    'psicologia': Icons.psychology_outlined,
    'direito': Icons.gavel_outlined,
  },
  onExpandExam: (subject, attempt) {
    // Navigate to detailed exam review
  },
)
```

---

## Component Usage Flow

### Test-Taking Journey

#### 1. Home Screen (`home.screen.dart`)
**Components Used:**
- `AppLogoWidget` - Branding in header
- `AppText` - Headings and descriptions
- `SubjectCard` - Subject selection (8 cards)
- `CustomNavBar` - Bottom navigation

**Flow:**
```
User lands → Views logo → Reads "Para qual prova gostaria de se preparar?" 
→ Scrolls through SubjectCards → Selects subject (card highlights) 
→ Navigates using CustomNavBar or card action
```

---

#### 2. Quiz Configuration Screen (`QuizConfig_screen.dart`)
**Components Used:**
- `AppLogoWidget` - Consistent header branding
- `DefaultButtonArrowBack` - Back navigation
- `AppText` - Instructions ("Escolha a quantidade de questões")
- `SelectionBox` - Question count selection (5, 10, 15, 20)
- `DefaultButtonOrange` - "Iniciar" CTA
- `CustomNavBar` - Bottom navigation

**Flow:**
```
User enters from subject selection → Sees back button (DefaultButtonArrowBack) 
→ Reads instructions (AppText) → Selects question count (SelectionBox) 
→ Button becomes enabled (orange) → Clicks "Iniciar" (DefaultButtonOrange) 
→ Navigates to exam or uses CustomNavBar to switch views
```

---

#### 3. Exam Screen (`exam_screen.dart`)
**Components Used:**
- `AppLogoWidget` - Branding consistency
- `DefaultButtonArrowBack` - Exit exam
- `QuestionNavigation` - Question tracker (15 circles)
- `AlternativeSelectorVertical` - Answer selection (A-E)
- `DefaultButtonBack` - Previous question
- `DefaultButtonForward` - Next question / Finish

**Flow:**
```
User starts exam → Sees logo + back button → Question tracker shows progress 
→ Reads question enunciation → Selects answer (AlternativeSelectorVertical) 
→ Question circle turns green in QuestionNavigation 
→ Clicks "Próxima" (DefaultButtonForward) → Moves through questions 
→ Can jump to any question via QuestionNavigation 
→ Can go back with "Anterior" (DefaultButtonBack) 
→ Last question shows "Finalizar" → Confirmation dialog → Submits exam
```

---

#### 4. Profile/Settings Screens (Inferred)
**Components Used:**
- `UserProfileCard` - User info with editable name
- `DefaultScorecard` - Statistics display
- `ItemConfiguracao` - Settings menu items
- `DefaultAccordion` - FAQ or help sections
- `ExamHistoryAccordion` - Historical exam results

**Flow:**
```
User navigates via CustomNavBar → Views profile (UserProfileCard) 
→ Edits name inline → Views scores (DefaultScorecard) 
→ Browses settings (ItemConfiguracao) → Expands history (ExamHistoryAccordion) 
→ Views past attempts with question-by-question breakdown 
→ Expands individual exams for review
```

---

## Design System Notes

### Color Palette
- **Primary Green:** `AppColors.green` - Used for selections, CTAs, success states
- **Primary Dark:** `AppColors.primaryDark` - Main text color
- **Secondary Dark:** `AppColors.secondaryDark` - Secondary text
- **Orange:** Used in `DefaultButtonOrange` for primary actions
- **Neutrals:** `AppColors.webNeutral` series for borders, backgrounds

### Typography
- **Font Family:** Montserrat (via Google Fonts) for AppText
- **Hierarchy:**
  - Titles: 56px, 40px, 20px (bold)
  - Body: 16px, 15px (regular)
  - Labels: 18px bold, 14px regular

### Spacing
- **Horizontal Padding:** 33px (home), 24px (exam)
- **Vertical Spacing:** 16-35px between sections
- **Component Padding:** 16-20px internal

### Interaction Patterns
- **Selection:** Green highlight with border change
- **Hover:** Subtle shadow enhancement, color shift
- **Disabled:** Grey colors, no interaction
- **Loading:** CircularProgressIndicator with theme color
- **Navigation:** Consistent back buttons, forward progression

### Accessibility
- **Semantic Labels:** All logos and icons have labels
- **Touch Targets:** Minimum 44x44px (mobile best practice)
- **Color Contrast:** Dark text on light backgrounds
- **Visual Feedback:** Clear selection states, hover effects
- **Error States:** Explicit error messages with color coding

---

## Component Dependencies

### External Packages
- `google_fonts` - Montserrat font in AppText, SelectionBox
- `provider` - State management in ExamHistoryAccordion

### Internal Dependencies
- `ui/theme/app_color.dart` - All components use AppColors
- `ui/theme/string_text.dart` - AppText component
- `models/exam_history.dart` - ExamHistoryAccordion data models
- `services/repositorie/exam_history_repository.dart` - ExamHistoryAccordion service
- `viewmodels/exam_history_view_model.dart` - ExamHistoryAccordion ViewModel

---

## Best Practices

### Usage Guidelines
1. **Consistency:** Always use these components instead of creating one-off widgets
2. **Theming:** Rely on AppColors constants rather than hardcoded colors
3. **State Management:** Use setState for local state, Provider for complex components
4. **Validation:** Use built-in validators for input components
5. **Navigation:** Prefer DefaultButtonArrowBack for top-level navigation
6. **Feedback:** Provide visual feedback for all user interactions
7. **Loading States:** Show loading indicators during async operations
8. **Error Handling:** Display clear error messages using component error properties

### Performance
- Components use `const` constructors where possible
- Animated components use efficient duration (180-520ms)
- ScrollControllers are properly disposed
- Image loading includes error builders

---

*Last Updated: 2024*  
*Total Components: 17*  
*Framework: Flutter 3.1.0+*
