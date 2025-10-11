import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/widget_previews.dart';

// 1. DEFINIÇÕES DE ESTILO E ENUM

/// Enum para identificar os estilos de forma clara no código.
enum AppTextStyle {
  titleLarge,     // bold 56
  titleMedium,    // bold 40
  titleSmall,     // bold 20
  subtitleMedium, // regular 16
  subtitleSmall,  // regular 15
}

/// Classe privada que contém as definições de estilo base (sem a fonte).
class _AppTextStyles {
  static const TextStyle titleLarge = TextStyle(
    fontSize: 56,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle titleMedium = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle titleSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle subtitleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400, // w400 é 'regular'
  );
  static const TextStyle subtitleSmall = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400, // w400 é 'regular'
  );
}

/// Extension para acessar facilmente o TextStyle a partir do enum.
extension AppTextStyleExtension on AppTextStyle {
  /// Retorna o TextStyle correspondente ao enum.
  TextStyle get style {
    switch (this) {
      case AppTextStyle.titleLarge:
        return _AppTextStyles.titleLarge;
      case AppTextStyle.titleMedium:
        return _AppTextStyles.titleMedium;
      case AppTextStyle.titleSmall:
        return _AppTextStyles.titleSmall;
      case AppTextStyle.subtitleMedium:
        return _AppTextStyles.subtitleMedium;
      case AppTextStyle.subtitleSmall:
        return _AppTextStyles.subtitleSmall;
    }
  }
}

// 2. WIDGET PRINCIPAL 

/// Componente de texto reutilizável com estilos pré-definidos e animação de toque.
class AppText extends StatelessWidget {
  final TextSpan? textSpan;
  final String? data;
  final AppTextStyle style;
  final Color? color;
  final TextAlign? textAlign;
  final VoidCallback? onPressed;

  /// Construtor padrão para textos com um único estilo.
  const AppText(
    this.data, {
    super.key,
    this.style = AppTextStyle.subtitleMedium,
    this.color,
    this.textAlign,
    this.onPressed,
  }) : textSpan = null;

  /// Construtor para textos com múltiplos estilos (texto rico).
  const AppText.rich(
    this.textSpan, {
    super.key,
    this.style = AppTextStyle.subtitleMedium,
    this.color,
    this.textAlign,
    this.onPressed,
  }) : data = null;

  @override
  Widget build(BuildContext context) {
    final baseStyle = style.style;
    final finalStyle = GoogleFonts.montserrat(
      textStyle: baseStyle,
      color: color,
    );

    Widget textWidget = (textSpan != null)
        ? RichText(
            textAlign: textAlign ?? TextAlign.start,
            text: TextSpan(
              style: finalStyle,
              children: [textSpan!],
            ),
          )
        : Text(
            data!,
            style: finalStyle,
            textAlign: textAlign,
          );

    if (onPressed != null) {
      return InkWell(
        onTap: onPressed,
        // Adiciona um padding mínimo para a área de toque ser confortável,
        // mas sem afetar o layout visual de forma drástica.
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: textWidget,
        ),
      );
    }

    return textWidget;
  }
}

// 3. PREVIEWS DO COMPONENTE

@Preview(name: 'Title Large')
Widget titleLargePreview() {
  return const Center(
    child: AppText('Title Large 56 bold', style: AppTextStyle.titleLarge),
  );
}

@Preview(name: 'Title Medium')
Widget titleMediumPreview() {
  return const Center(
    child: AppText('Title Medium 40 bold', style: AppTextStyle.titleMedium),
  );
}

@Preview(name: 'Title Small')
Widget titleSmallPreview() {
  return const Center(
    child: AppText('Title Small 20 bold', style: AppTextStyle.titleSmall),
  );
}

@Preview(name: 'Subtitle Medium')
Widget subtitleMediumPreview() {
  return const Center(
    child: AppText('Subtitle Medium 16 regular', style: AppTextStyle.subtitleMedium),
  );
}

@Preview(name: 'Subtitle Small')
Widget subtitleSmallPreview() {
  return const Center(
    child: AppText('Subtitle Small 15 regular', style: AppTextStyle.subtitleSmall),
  );
}

@Preview(name: 'Custom Color')
Widget customColorPreview() {
  return const Center(
    child: AppText(
      'Texto com cor customizada',
      style: AppTextStyle.titleSmall,
      color: Colors.deepPurple,
    ),
  );
}

@Preview(name: 'Clickable Text (onPressed)')
Widget clickableTextPreview() {

  return Material(
    child: Center(
      child: AppText(
        'Este texto é clicável',
        style: AppTextStyle.subtitleMedium,
        color: Colors.blue,
        onPressed: () {
          debugPrint('Texto clicável foi tocado!');
        },
      ),
    ),
  );
}

@Preview(name: 'Rich Text (Mixed Styles)')
Widget richTextPreview() {
  return const Center(
    child: AppText.rich(
      TextSpan(
        children: [
          TextSpan(text: 'Texto com uma '),
          TextSpan(
            text: 'palavra importante',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          TextSpan(text: ' em destaque.'),
        ],
      ),
      style: AppTextStyle.subtitleMedium,
      textAlign: TextAlign.center,
    ),
  );
}