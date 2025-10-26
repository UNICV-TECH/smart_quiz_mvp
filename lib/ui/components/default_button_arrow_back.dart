import 'package:flutter/material.dart';
import 'package:unicv_tech_mvp/ui/components/default_button_back.dart';
import 'package:unicv_tech_mvp/ui/theme/app_color.dart';


// Preview atualizado para usar o nome correto da classe.
@Preview(name: 'Botão Voltar (Seta)')
Widget backArrowButtonPreview() { // Renomeado para clareza
  return Container(
    width: 150,
    height: 150,
    color: AppColors.backgroundGradient1, // Usando uma cor do seu tema
    alignment: Alignment.center,
    child: DefaultButtonArrowBack( // Usando o nome correto da classe
      onPressed: () {
        debugPrint("Botão Voltar (Seta) pressionado!");
      },
    ),
  );
}

// Classe principal renomeada para DefaultButtonArrowBack
class DefaultButtonArrowBack extends StatelessWidget { 
  /// A ação a ser executada quando o botão for pressionado.
  /// Geralmente será `() => Navigator.of(context).pop()`.
  final VoidCallback? onPressed;

  /// O tamanho do ícone. O padrão é 28.
  final double iconSize;

  /// A cor do ícone. O padrão é `AppColors.deepGreen`.
  final Color? iconColor;

  // Construtor CORRIGIDO para usar o nome da classe DefaultButtonArrowBack
  const DefaultButtonArrowBack({ 
    super.key,
    required this.onPressed,
    this.iconSize = 28.0,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Voltar',
      splashRadius: 24.0,
      icon: Icon(
        Icons.arrow_back_ios_new_rounded,
        size: iconSize,
        // Usando AppColors.deepGreen se iconColor for nulo
        color: iconColor ?? AppColors.deepGreen, 
      ),
      onPressed: onPressed,
    );
  }
}
