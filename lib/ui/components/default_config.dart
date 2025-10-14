import 'package:flutter/material.dart';
import 'package:unicv_tech_mvp/ui/theme/app_color.dart';

// Preview do componente - Exemplo com múltiplos itens
@Preview(name: 'Item Configuração - Lista completa')
Widget configurationItemListPreview() {
  return Scaffold(
    backgroundColor: AppColors.white,
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ItemConfiguracao(
            icone: Icons.assessment_outlined,
            texto: 'Resultados',
            onTap: () {
              debugPrint('Navegar para Resultados');
            },
          ),
          ItemConfiguracao(
            icone: Icons.notifications_outlined,
            texto: 'Notificações',
            onTap: () {
              debugPrint('Navegar para Notificações');
            },
          ),
          ItemConfiguracao(
            icone: Icons.help_outline,
            texto: 'Ajuda',
            onTap: () {
              debugPrint('Navegar para Ajuda');
            },
          ),
          ItemConfiguracao(
            icone: Icons.logout,
            texto: 'Sair',
            onTap: () {
              debugPrint('Realizar logout');
            },
          ),
        ],
      ),
    ),
  );
}

class Preview {
  const Preview({required String name});
}

class ItemConfiguracao extends StatelessWidget {
  final IconData icone;
  final String texto;
  final VoidCallback onTap;
  final Color? corIcone;
  final Color? corTexto;
  final Color? corSeta;
  final Color? corDivider;
  final EdgeInsets? padding;
  final double? tamanhoIcone;
  final double? tamanhoFonte;

  const ItemConfiguracao({
    super.key,
    required this.icone,
    required this.texto,
    required this.onTap,
    this.corIcone,
    this.corTexto,
    this.corSeta,
    this.corDivider,
    this.padding,
    this.tamanhoIcone,
    this.tamanhoFonte,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor = corIcone ?? AppColors.webNeutral700;
    final Color textColor = corTexto ?? AppColors.primaryDark;
    final Color arrowColor = corSeta ?? AppColors.webNeutral700;
    final Color dividerColor = corDivider ?? AppColors.webNeutral200;
    final EdgeInsets itemPadding =
        padding ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0);
    final double iconSize = tamanhoIcone ?? 24.0;
    final double fontSize = tamanhoFonte ?? 16.0;

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: itemPadding,
              child: Row(
                children: [
                  Icon(
                    icone,
                    color: iconColor,
                    size: iconSize,
                  ),
                  const SizedBox(width: 16.0),
                  
                  Expanded(
                    child: Text(
                      texto,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                  
                  Icon(
                    Icons.arrow_forward_ios,
                    color: arrowColor,
                    size: 18.0,
                  ),
                ],
              ),
            ),
          ),
        ),
        
        Divider(
          height: 1,
          thickness: 1,
          color: dividerColor,
          indent: 0,
          endIndent: 0,
        ),
      ],
    );
  }
}

