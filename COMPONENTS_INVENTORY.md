# UI Components Inventory

Comprehensive documentation of all UI components in the UniCV Tech MVP application, including their properties, usage examples, and role in the test-taking flow.

---

## Table of Contents

1. [Test-Taking Flow Overview](#test-taking-flow-overview)
2. [Navigation Components](#navigation-components)
3. [Button Components](#button-components)
4. [Input Components](#input-components)
5. [Selection Components](#selection-components)
6. [Card Components](#card-components)
7. [Display Components](#display-components)
8. [Layout Components](#layout-components)

---

## Test-Taking Flow Overview

The test-taking flow consists of three main screens:

1. **HomeScreen** (`home.screen.dart`) - Subject selection
2. **QuizConfigScreen** (`QuizConfig_screen.dart`) - Quiz configuration (question quantity)
3. **ExamScreen** (`exam_screen.dart`) - Test execution and navigation

### Flow Diagram

```
HomeScreen → QuizConfigScreen → ExamScreen
   ↓              ↓                  ↓
SubjectCard → SelectionBox → AlternativeSelectorVertical
              DefaultButton    QuestionNavigation
                               NavigationButtons
```

---

## Navigation Components

### CustomNavBar

**File:** `lib/ui/components/default_navbar.dart`

**Description:** Bottom navigation bar with animated circular indicator that follows the selected item. Features a curved notch effect around the active item.

#### Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `selectedIndex` | `int?` | No | `null` | Currently selected tab index (0-based) |
| `onItemTapped` | `Function(int)?` | No | `null` | Callback when a tab is tapped |

#### Usage

```dart
CustomNavBar(
  selectedIndex: _navBarIndex,
  onItemTapped: (index) {
    setState(() {
      _navBarIndex = index;
    });
    if (index == 0) {
      Navigator.popUntil(context, ModalRoute.withName('/home'));
    }
  },
)
```

#### Test-Taking Flow Role

- **Used in:** HomeScreen, QuizConfigScreen
- **Purpose:** Global navigation between Home, Explore, and Profile sections
- **Behavior:** In QuizConfigScreen, tapping "Início" returns to HomeScreen

---

### QuestionNavigation

**File:** `lib/ui/components/default_question_navigation.dart`

**Description:** Horizontal scrollable question navigation bar displaying numbered circles for each question. Shows visual feedback for answered/current questions.

#### Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `totalQuestions` | `int` | Yes | - | Total number of questions in the exam |
| `currentQuestion` | `int` | Yes | - | Currently displayed question (1-based) |
| `onQuestionSelected` | `Function(int)` | Yes | - | Callback when a question is tapped |
| `answeredQuestions` | `Set<int>` | Yes | - | Set of answered question numbers |

#### Visual States

- **Current Question:** Green circle with white number
- **Answered Question:** Green circle with white number
- **Unanswered Active:** White circle with green number and grey border
- **Inactive:** Grey circle with grey dash

#### Usage

```dart
QuestionNavigation(
  totalQuestions: exam.questions.length,
  currentQuestion: currentQuestionIndex + 1,
  onQuestionSelected: (questionNumber) {
    setState(() {
      currentQuestionIndex = questionNumber - 1;
    });
  },
  answeredQuestions: selectedAnswers.keys.toSet(),
)
```

#### Test-Taking Flow Role

- **Used in:** ExamScreen
- **Purpose:** Quick navigation between exam questions
- **Behavior:** Displays up to 15 questions, auto-scrolls to current question

---

## Button Components

### DefaultButtonOrange

**File:** `lib/ui/components/default_button_orange.dart`

**Description:** Primary action button with orange background. Supports three visual states: primary, secondary, and disabled.

#### Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `texto` | `String` | Yes | - | Button text |
| `onPressed` | `VoidCallback?` | Yes | - | Tap callback |
| `icone` | `IconData?` | No | `null` | Optional leading icon |
| `tipo` | `BotaoTipo` | No | `primario` | Button type (primario/secundario/desabilitado) |
| `corFundo` | `Color?` | No | Per type | Custom background color |
| `corTexto` | `Color?` | No | Per type | Custom text color |
| `altura` | `double` | No | `67.0` | Button height |
| `largura` | `double` | No | `infinity` | Button width |

#### Button Types

- **primario:** Orange background (#EF992D), white text
- **secundario:** Lighter orange (#DC9B3C), white text  
- **desabilitado:** Grey background, grey text, non-interactive

#### Usage

```dart
DefaultButtonOrange(
  texto: 'Iniciar',
  onPressed: isButtonEnabled ? _startQuiz : null,
  tipo: isButtonEnabled ? BotaoTipo.primario : BotaoTipo.desabilitado,
)
```

#### Test-Taking Flow Role

- **Used in:** QuizConfigScreen ("Iniciar" button), ExamHistoryAccordion ("Expandir" button)
- **Purpose:** Primary action to start quiz or expand exam details
- **Behavior:** Disabled until required selections are made

---

### DefaultButtonBack

**File:** `lib/ui/components/default_button_back.dart`

**Description:** Text button with left arrow icon for backward navigation in exam.

#### Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `text` | `String` | Yes | - | Button text (e.g., "Anterior") |
| `onPressed` | `VoidCallback` | Yes | - | Tap callback |
| `icon` | `IconData?` | No | `null` | Optional leading icon |
| `fontSize` | `double` | No | `14` | Text font size |

#### Usage

```dart
DefaultButtonBack(
  text: 'Anterior',
  icon: Icons.arrow_back_ios,
  onPressed: () {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
    }
  },
)
```

#### Test-Taking Flow Role

- **Used in:** ExamScreen
- **Purpose:** Navigate to previous question
- **Behavior:** Hidden on first question, decrements question index

---

### DefaultButtonForward

**File:** `lib/ui/components/default_button_forward.dart`

**Description:** Text button with right arrow icon for forward navigation in exam.

#### Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `text` | `String` | Yes | - | Button text (e.g., "Próxima", "Finalizar") |
| `onPressed` | `VoidCallback` | Yes | - | Tap callback |
| `icon` | `IconData?` | No | `null` | Optional trailing icon |
| `fontSize` | `double` | No | `14` | Text font size |

#### Usage

```dart
DefaultButtonForward(
  text: isLastQuestion ? 'Finalizar' : 'Próxima',
  icon: Icons.arrow_forward_ios,
  onPressed: () {
    if (isLastQuestion) {
      _showFinishDialog();
    } else {
      setState(() {
        currentQuestionIndex++;
      });
    }
  },
)
```

#### Test-Taking Flow Role

- **Used in:** ExamScreen
- **Purpose:** Navigate to next question or finish exam
- **Behavior:** Text changes to "Finalizar" on last question

---

### DefaultButtonArrowBack

**File:** `lib/ui/components/default_button_arrow_back.dart`

**Description:** Icon-only back button with arrow icon, used for screen-level navigation.

#### Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `onPressed` | `VoidCallback?` | Yes | - | Tap callback (typically Navigator.pop) |
| `iconSize` | `double` | No | `28.0` | Icon size |
| `iconColor` | `Color?` | No | `deepGreen` | Icon color |

#### Usage

```dart
DefaultButtonArrowBack(
  onPressed: () => Navigator.of(context).pop(),
)
```

#### Test-Taking Flow Role

- **Used in:** QuizConfigScreen, ExamScreen
- **Purpose:** Return to previous screen
- **Behavior:** Pops current route from navigation stack

---

## Input Components

### ComponenteInput

**File:** `lib/ui/components/default_input.dart`

**Description:** Standard text input field with label, hint text, and error state support.

#### Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `controller` | `TextEditingController?` | No | `null` | Text editing controller |
| `labelText` | `String` | Yes | - | Field label |
| `hintText` | `String` | No | `''` | Placeholder text |
| `errorMessage` | `String?` | No | `null` | Error message to display |
| `keyboardType` | `TextInputType` | No | `text` | Keyboard type |
| `onChanged` | `ValueChanged<String>?` | No | `null` | Text change callback |
| `validator` | `String? Function(String?)?` | No | `null` | Form validator |
| `width` | `double` | No | `infinity` | Input width |
| `backgroundColor` | `Color` | No | `greenChart` | Background fill color |
| `borderColor` | `Color` | No | `transparent` | Default border color |
| `borderColorFocus` | `Color` | No | `borderColorFocus` | Focused border color |
| `borderColorError` | `Color` | No | `borderColorError` | Error border color |
| `borderRadius` | `double` | No | `15.0` | Border radius |
| `textStyle` | `TextStyle` | No | 16px primaryDark | Input text style |
| `labelStyle` | `TextStyle` | No | 18px bold | Label text style |

#### Usage

```dart
ComponenteInput(
  labelText: 'E-mail',
  hintText: 'exemplo@email.com',
  controller: _emailController,
  keyboardType: TextInputType.emailAddress,
  errorMessage: _emailError,
  onChanged: (value) {
    setState(() {
      _emailError = _validateEmail(value);
    });
  },
)
```

#### Test-Taking Flow Role

- **Used in:** Login, signup, and profile screens (not directly in test flow)
- **Purpose:** Collect user text input

---

### ComponentePasswordInput

**File:** `lib/ui/components/default_password_input_47.dart`

**Description:** Password input field with visibility toggle. Extends ComponenteInput with obscureText functionality.

#### Properties

Inherits all properties from `ComponenteInput`, plus:

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `initialObscureText` | `bool` | No | `true` | Initial visibility state |

#### Features

- Toggle icon (eye/eye-off) in suffix position
- Automatic keyboard type: `visiblePassword`
- Maintains obscured state locally

#### Usage

```dart
ComponentePasswordInput(
  labelText: 'Senha',
  hintText: 'Digite sua senha',
  controller: _passwordController,
  errorMessage: _passwordError,
)
```

#### Test-Taking Flow Role

- **Used in:** Login and signup screens (authentication, not test flow)
- **Purpose:** Secure password entry

---

## Selection Components

### SelectionBox

**File:** `lib/ui/components/default_chekbox.dart`

**Description:** Single-choice selection list with checkmark indicators. Used for selecting from multiple options.

#### Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `options` | `List<String>` | Yes | - | List of selectable options |
| `onOptionSelected` | `ValueChanged<String>` | Yes | - | Selection callback |
| `initialOption` | `String?` | No | `null` | Initially selected option |

#### Visual States

- **Selected:** Green checkmark in green box, bold green text
- **Unselected:** Transparent box with grey border, normal grey text

#### Usage

```dart
SelectionBox(
  options: ['5', '10', '15', '20'],
  initialOption: _selectedQuantity,
  onOptionSelected: (quantity) {
    setState(() {
      _selectedQuantity = quantity;
    });
  },
)
```

#### Test-Taking Flow Role

- **Used in:** QuizConfigScreen
- **Purpose:** Select number of questions for the quiz
- **Behavior:** Enables start button when selection is made

---

### AlternativeSelectorVertical

**File:** `lib/ui/components/default_radio_group.dart`

**Description:** Radio button group for exam question alternatives. Displays options with letter labels (A, B, C, etc.).

#### Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `labels` | `List<String>` | Yes | - | Alternative text labels |
| `selectedOption` | `String?` | Yes | - | Currently selected letter (A, B, C...) |
| `onChanged` | `Function(String)` | Yes | - | Selection callback with letter |

#### Features

- Auto-generates letter labels (A, B, C, D, E...)
- Circular indicators with letters
- Selected: green circle, Unselected: grey circle

#### Usage

```dart
AlternativeSelectorVertical(
  labels: currentQuestion.alternatives,
  selectedOption: selectedAnswers[currentQuestion.id],
  onChanged: (option) {
    setState(() {
      selectedAnswers[currentQuestion.id] = option;
    });
  },
)
```

#### Test-Taking Flow Role

- **Used in:** ExamScreen
- **Purpose:** Select answer for current question
- **Behavior:** Stores selection in map by question ID

---

## Card Components

### SubjectCard

**File:** `lib/ui/components/default_subject_card.dart`

**Description:** Selectable card representing a subject/course. Features hover effects and selection state.

#### Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `icon` | `Widget` | Yes | - | Subject icon (usually Icon widget) |
| `title` | `String` | Yes | - | Subject name |
| `onTap` | `VoidCallback?` | No | `null` | Tap callback |
| `isSelected` | `bool` | No | `false` | Selection state |
| `borderRadius` | `double` | No | `20` | Card corner radius |
| `padding` | `EdgeInsetsGeometry` | No | `20h, 18v` | Internal padding |

#### Visual States

- **Selected:** White background, green border (1.4px), green icon and text
- **Hover:** Same as selected but without green text
- **Default:** Light grey background, light border (1px), dark text

#### Usage

```dart
SubjectCard(
  icon: Icon(Icons.psychology_outlined, color: AppColors.green, size: 30),
  title: 'Psicologia',
  isSelected: _selectedCourseId == 'psicologia',
  onTap: () => _onCourseSelected(courseData),
)
```

#### Additional Components

- **SubjectCardData:** Data model for subject information
- **SubjectCardList:** ListView wrapper for multiple SubjectCards

#### Test-Taking Flow Role

- **Used in:** HomeScreen
- **Purpose:** Select subject for quiz
- **Behavior:** Selection required to proceed to QuizConfigScreen

---

### UserProfileCard

**File:** `lib/ui/components/default_user_profile_card.dart`

**Description:** User profile display with editable name field. Shows avatar, name, and email.

#### Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `userName` | `String` | Yes | - | User's display name |
| `userEmail` | `String` | Yes | - | User's email address |
| `profileImageUrl` | `String?` | No | `null` | Profile image URL |
| `onNameUpdate` | `Future<bool> Function(String)?` | No | `null` | Name update handler |
| `onShowFeedback` | `void Function(String, {bool})?` | No | `null` | Feedback message handler |
| `padding` | `EdgeInsets` | No | `16 all` | Card padding |
| `margin` | `EdgeInsets` | No | `zero` | Card margin |
| `backgroundColor` | `Color` | No | `white` | Background color |
| `borderRadius` | `double` | No | `12.0` | Corner radius |

#### Features

- Inline name editing with confirm/cancel buttons
- Loading state during save
- Circular avatar with fallback icon
- Network image support with error handling

#### Usage

```dart
UserProfileCard(
  userName: _currentUser.name,
  userEmail: _currentUser.email,
  profileImageUrl: _currentUser.avatarUrl,
  onNameUpdate: (newName) async {
    return await _userService.updateName(newName);
  },
  onShowFeedback: (message, {isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  },
)
```

#### Test-Taking Flow Role

- **Used in:** Profile screen (not directly in test flow)
- **Purpose:** Display and edit user profile information

---

### DefaultScorecard

**File:** `lib/ui/components/default_scoreCard.dart`

**Description:** Card component displaying an icon with a numeric score value.

#### Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `icon` | `IconData` | Yes | - | Score category icon |
| `score` | `int` | Yes | - | Numeric score value |
| `iconColor` | `Color?` | No | `grey[600]` | Icon color |
| `scoreColor` | `Color?` | No | `grey[800]` | Score text color |
| `backgroundColor` | `Color?` | No | `white` | Card background |
| `borderColor` | `Color?` | No | `grey[300]` | Border color |
| `width` | `double?` | No | `null` | Card width |
| `height` | `double?` | No | `80` | Card height |
| `padding` | `EdgeInsets?` | No | `16h, 12v` | Internal padding |
| `margin` | `EdgeInsets?` | No | `8h, 4v` | External margin |
| `iconSize` | `double?` | No | `32.0` | Icon size (24-40 range) |
| `fontSize` | `double?` | No | Auto | Score font size |
| `onTap` | `VoidCallback?` | No | `null` | Tap callback |

#### Usage

```dart
DefaultScorecard(
  icon: Icons.check_circle,
  score: 85,
  iconColor: AppColors.green,
  scoreColor: AppColors.primaryDark,
)
```

#### Test-Taking Flow Role

- **Used in:** Results/statistics screens
- **Purpose:** Display test scores and metrics

---

## Display Components

### AppLogoWidget

**File:** `lib/ui/components/default_Logo.dart`

**Description:** Responsive logo image component supporting both local assets and network URLs.

#### Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `size` | `AppLogoSize` | Yes | - | Logo size (small/medium/large) |
| `logoPath` | `String` | Yes | - | Path to logo (asset or URL) |
| `semanticLabel` | `String` | No | 'Logo do aplicativo' | Accessibility label |

#### Size Options

- **small:** 24% of screen width
- **medium:** 65% of screen width
- **large:** 92% of screen width

#### Constructors

- `AppLogoWidget.asset()` - For local asset images
- `AppLogoWidget.network()` - For network/Supabase images

#### Usage

```dart
// Network image
AppLogoWidget.network(
  size: AppLogoSize.small,
  logoPath: 'https://example.com/logo.png',
  semanticLabel: 'Logo UniCV',
)

// Asset image
AppLogoWidget.asset(
  size: AppLogoSize.medium,
  logoPath: 'assets/images/logo_color.png',
)
```

#### Test-Taking Flow Role

- **Used in:** HomeScreen, QuizConfigScreen, ExamScreen
- **Purpose:** Brand consistency across all screens
- **Behavior:** Responsive sizing, error fallback icon

---

### DefaultAccordion

**File:** `lib/ui/components/default_accordion.dart`

**Description:** Expandable/collapsible accordion with title, content, and optional icon.

#### Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `title` | `String` | Yes | - | Accordion title |
| `content` | `String` | Yes | - | Expandable content text |
| `icon` | `IconData?` | No | `null` | Leading icon |
| `titleColor` | `Color?` | No | `primaryDark` | Title text color |
| `contentColor` | `Color?` | No | `secondaryDark` | Content text color |
| `backgroundColor` | `Color?` | No | `white` | Card background |
| `iconColor` | `Color?` | No | `green` | Icon color |

#### Features

- Rounded corners (15px)
- Shadow effect
- Icon in colored circular background
- Smooth expand/collapse animation

#### Usage

```dart
DefaultAccordion(
  title: 'Sobre o Aplicativo',
  content: 'Este aplicativo foi desenvolvido para...',
  icon: Icons.info_outline,
)
```

#### Test-Taking Flow Role

- **Used in:** Help, About screens
- **Purpose:** Display collapsible information sections

---

### ExamHistoryAccordion

**File:** `lib/ui/components/default_exam_history_accordion.dart`

**Description:** Complex accordion component for displaying exam history with detailed statistics and question timeline.

#### Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `service` | `ExamHistoryRepository` | Yes | - | Data repository |
| `iconByKey` | `Map<String, IconData>` | No | `{}` | Icon mapping by subject key |
| `onExpandExam` | `Function(subject, attempt)?` | No | `null` | Exam expansion callback |

#### Features

- Integrates with `ExamHistoryViewModel`
- Displays per-subject statistics (total exams, questions, correct answers)
- Individual attempt cards with date and duration
- Question timeline with color-coded dots:
  - **Green:** Correct answer
  - **Red:** Incorrect answer
  - **Transparent with border:** Unanswered
- Loading, error, and empty states
- "Expandir" button to view full exam details

#### Data Models

- `SubjectExamHistory`: Subject-level aggregated data
- `ExamAttempt`: Individual exam attempt data
- `QuestionOutcome`: Enum (correct/incorrect/unanswered)

#### Usage

```dart
ExamHistoryAccordion(
  service: ExamHistoryRepository(),
  iconByKey: {
    'psicologia': Icons.psychology_outlined,
    'direito': Icons.gavel_outlined,
  },
  onExpandExam: (subject, attempt) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExamDetailScreen(
          subject: subject,
          attempt: attempt,
        ),
      ),
    );
  },
)
```

#### Test-Taking Flow Role

- **Used in:** History/Results screen
- **Purpose:** Review past exam performance
- **Behavior:** Loads exam history from repository, displays statistics

---

## Layout Components

### ItemConfiguracao

**File:** `lib/ui/components/default_config.dart`

**Description:** List item component for configuration/settings menus with icon, text, and arrow.

#### Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `icone` | `IconData` | Yes | - | Leading icon |
| `texto` | `String` | Yes | - | Item text |
| `onTap` | `VoidCallback` | Yes | - | Tap callback |
| `corIcone` | `Color?` | No | `webNeutral700` | Icon color |
| `corTexto` | `Color?` | No | `primaryDark` | Text color |
| `corSeta` | `Color?` | No | `webNeutral700` | Arrow color |
| `corDivider` | `Color?` | No | `webNeutral200` | Divider color |
| `padding` | `EdgeInsets?` | No | `16h, 16v` | Item padding |
| `tamanhoIcone` | `double?` | No | `24.0` | Icon size |
| `tamanhoFonte` | `double?` | No | `16.0` | Font size |

#### Features

- Divider line below each item
- Trailing arrow icon
- InkWell tap effect

#### Usage

```dart
ItemConfiguracao(
  icone: Icons.help_outline,
  texto: 'Ajuda',
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => HelpScreen()),
    );
  },
)
```

#### Test-Taking Flow Role

- **Used in:** Profile/Settings screen
- **Purpose:** Navigation to configuration screens

---

## Component Summary by Screen

### HomeScreen Components

1. **AppLogoWidget** - Branding
2. **SubjectCard** - Subject selection (multiple instances)
3. **CustomNavBar** - Bottom navigation

### QuizConfigScreen Components

1. **AppLogoWidget** - Branding
2. **DefaultButtonArrowBack** - Back navigation
3. **SelectionBox** - Question quantity selection
4. **DefaultButtonOrange** - "Iniciar" action
5. **CustomNavBar** - Bottom navigation

### ExamScreen Components

1. **AppLogoWidget** - Branding
2. **DefaultButtonArrowBack** - Back navigation
3. **QuestionNavigation** - Question progress indicator
4. **AlternativeSelectorVertical** - Answer selection
5. **DefaultButtonBack** - Previous question
6. **DefaultButtonForward** - Next question / Finish

---

## Design System Notes

### Color Scheme

- **Primary Green:** `AppColors.green` - Used for selected states, primary actions
- **Deep Green:** `AppColors.deepGreen` - Text, icons
- **Orange:** `AppColors.orange` - Primary action buttons
- **Grey Shades:** Various neutral colors for borders, backgrounds

### Typography

- **Title:** Bold, 18-20px
- **Subtitle:** Medium weight, 14-16px
- **Body:** Regular, 14-16px
- **Font Family:** Poppins (primary), Montserrat (selection components)

### Spacing

- **Screen Padding:** 24-33px horizontal
- **Card Padding:** 16-20px horizontal, 12-18px vertical
- **Component Spacing:** 12-16px between elements

### Border Radius

- **Cards:** 15-20px
- **Buttons:** 15-19px
- **Inputs:** 15px

---

## Best Practices

1. **State Management:** Use `setState()` for local component state, Provider for shared state
2. **Navigation:** Use `Navigator.push()` for forward navigation, `Navigator.pop()` for back
3. **Validation:** Enable/disable buttons based on required input validation
4. **Feedback:** Provide visual feedback (loading states, selection indicators)
5. **Accessibility:** Include semantic labels for images and interactive elements
6. **Responsiveness:** Components use relative sizing (percentage of screen width)
7. **Error Handling:** Display error states with retry options

---

## Future Enhancements

- Add loading skeleton screens for async data
- Implement haptic feedback on button taps
- Add animation transitions between questions
- Support dark mode color schemes
- Internationalization support for component text
