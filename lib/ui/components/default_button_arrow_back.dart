import 'package:flutter/material.dart';
import 'package:unicv_tech_mvp/ui/components/default_button_back.dart';
import 'package:unicv_tech_mvp/ui/theme/app_color.dart';

@Preview(name: 'Botão Voltar')
Widget backButtonPreview() {
  return Container(
    width: 150,
    height: 150,
    color: AppColors.backgroundGradient1,
    alignment: Alignment.center,
    child: DefaultButtonBack(
      onPressed: () {
        debugPrint("Botão Voltar pressionado!");
      },
    ),
  );
}

class DefaultButtonBack extends StatelessWidget {
  /// A ação a ser executada quando o botão for pressionado.
  /// Geralmente será `() => Navigator.of(context).pop()`.
  final VoidCallback? onPressed;

  /// O tamanho do ícone. O padrão é 28.
  final double iconSize;

  /// A cor do ícone. O padrão é `AppColors.deepGreen`.
  final Color? iconColor;

  const DefaultButtonBack({
    super.key,
    required this.onPressed,
    this.iconSize = 28.0,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      // O tooltip melhora a acessibilidade, descrevendo a ação do botão.
      tooltip: 'Voltar',
      // Define um raio para a animação de "splash" ao tocar.
      splashRadius: 24.0,
      icon: Icon(
        // Ícone padrão do Material Design para "voltar" no iOS.
        Icons.arrow_back_ios_new_rounded,
        size: iconSize,
        color: iconColor ?? AppColors.deepGreen,
      ),
      onPressed: onPressed,
    );
  }
}
