import 'package:flutter/material.dart';
import '../theme/app_color.dart';

enum BotaoTipo { primario, secundario, desabilitado }

class DefaultButtonOrange extends StatelessWidget {
  // Variáveis que o componente do botão irá receber
  final String texto;
  final IconData? icone;
  final VoidCallback? onPressed;
  final Color? corFundo;
  final Color? corTexto;
  final double altura;
  final double largura;
  final BotaoTipo tipo;

  // Construtor do componente com parâmetros nomeados
  const DefaultButtonOrange({
    super.key,
    required this.texto,
    this.icone,
    required this.onPressed,
    this.corFundo,
    this.corTexto,
    this.altura = 67.0,
    this.largura = double.infinity,
    this.tipo = BotaoTipo.primario,
  });

  @override
  Widget build(BuildContext context) {
    // Define cores padrão com base no tipo de botão
    Color background;
    Color textColor;

    switch (tipo) {
      case BotaoTipo.primario:
        background = corFundo ?? const Color.fromRGBO(239, 153, 45, 1.0);
        textColor = corTexto ?? AppColors.white;
        break;
      case BotaoTipo.secundario:
        background = corFundo ?? const Color.fromRGBO(220, 155, 60, 1.0);
        textColor = corTexto ?? AppColors.white;
        break;
      case BotaoTipo.desabilitado:
        background = corFundo ?? AppColors.greyShade400;
        textColor = corTexto ?? AppColors.greyShade200;
        break;
    }

    return SizedBox(
      width: largura,
      height: altura,
      child: ElevatedButton(
        onPressed: tipo == BotaoTipo.desabilitado ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(19.0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icone != null) Icon(icone, color: textColor),
            if (icone != null && texto.isNotEmpty) SizedBox(width: 8),
            if (texto.isNotEmpty)
              Text(
                texto,
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: "", // Defina a fonte que quiser
                ),
              ),
          ],
        ),
      ),
    );
  }
}
