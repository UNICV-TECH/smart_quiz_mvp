# Question Indicator UX/UI Enhancements Plan

## Current Behavior Overview
- The quiz screen displays a horizontal list of circular question indicators (\`QuestionNavigation\`).
- Indicators currently share identical styling for the active and answered states (solid green fill, white text).
- Total indicators are hard-limited to 15, displaying grey placeholders with \`-\` when \`totalQuestions\` exceeds the limit.
- Scroll positioning relies on a fixed offset (\`46.0\` pixels) and may not center the current question.
- Progress feedback is limited to the visual state of each circle—no text or progress bar.

## Issues Identified
1. **State clarity:** Users cannot distinguish the current question from answered ones because both use the same fill color and typography.
2. **Fixed indicator count:** The hardcoded 15-item limit introduces inactive placeholders, wastes space, and misrepresents progress for longer exams.
3. **Scrolling ergonomics:** The magic-number offset leads to inconsistent centering, especially on small screens or with varying item widths.
4. **Interaction feedback:** Lack of tactile/visual feedback (hover, press, ripple) makes navigation feel unresponsive.
5. **Progress communication:** There is no textual or graphical progress summary to reinforce completion status.
6. **Accessibility:** Reliance on color alone makes state differentiation difficult for users with color-vision deficiencies.

## Enhancement Suggestions

### 1. Visual State Differentiation
- Give the current question a distinctive treatment (e.g., ring border, glow, subtle scale animation).
- Represent answered questions with a checkmark icon and a softer green fill to contrast with the current item.
- Use AppColors.green variants or gradients to reinforce state changes without breaking the palette.

### 2. Dynamic Layout Behavior
- Generate indicators dynamically using \`totalQuestions\` rather than a fixed list length.
- Adjust circle size responsively (e.g., 40px for ≤10 questions, 35px for 11–20, 30px for >20) to preserve readability.
- Consider adaptive spacing and padding to keep the bar compact on mobile screens.

### 3. Progress Indicators
- Show text above the bar (e.g., “5 de 10 respondidas”) using \`AppColors.greyText\` for subtle emphasis.
- Add a thin linear progress bar below the indicators to visualize overall completion.
- Optionally highlight unanswered questions with a secondary accent (e.g., dashed border) to prompt action.

### 4. Interaction Improvements
- Wrap each indicator in \`InkWell\` to provide ripple feedback and improved tap hitboxes.
- Add a short-scale animation (95%) on press to convey responsiveness.
- Refine auto-scroll logic to center the current item and expose surrounding items with edge fading or gradient masks.

### 5. Accessibility Enhancements
- Provide semantic labels (e.g., “Questão 4 – Respondida”) for screen readers.
- Supplement color cues with icons or patterns for high-contrast and color-blind users.
- Ensure focus indicators remain visible when navigating via keyboard or accessibility services.

## Implementation Priority
1. **Quick Wins (1–2h):** Remove fixed length, add progress text, differentiate current vs. answered styling.
2. **Medium Effort (3–4h):** Introduce checkmarks, improve scroll centering, add touch feedback animations.
3. **Polish (4–6h):** Implement responsive sizing, progress bar, nuanced animations, and accessibility refinements.

## Code Impact Areas
- \`lib/ui/components/default_question_navigation.dart\` for state logic, rendering, and animations.
- \`lib/views/exam_screen.dart\` (progress indicator builder) for layout and scroll behavior.
- \`lib/ui/theme/app_color.dart\` and related style utilities if new color tokens or gradients are required.
