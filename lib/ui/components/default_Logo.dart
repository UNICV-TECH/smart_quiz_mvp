import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
enum AppLogoSize { small, medium, large }
enum _ImageSourceType { asset, network }
class AppLogoWidget extends StatelessWidget {
  final AppLogoSize size;
  final String logoPath;
  final _ImageSourceType _source;
  final String semanticLabel;
  const AppLogoWidget._({
    required this.size,
    required this.logoPath,
    required _ImageSourceType source,
    required this.semanticLabel,
  }) : _source = source;
  // Construtor para imagens LOCAIS (assets)
  factory AppLogoWidget.asset({
    Key? key,
    required AppLogoSize size,
    required String logoPath,
    String semanticLabel = 'Logo do aplicativo',
  }) {
    return AppLogoWidget._(
      size: size,
      logoPath: logoPath,
      source: _ImageSourceType.asset,
      semanticLabel: semanticLabel,
    );
  }
  // Construtor para imagens da REDE (Supabase/HTTP)
  factory AppLogoWidget.network({
    Key? key,
    required AppLogoSize size,
    required String logoPath,
    String semanticLabel = 'Logo do aplicativo',
  }) {
    return AppLogoWidget._(
      size: size,
      logoPath: logoPath,
      source: _ImageSourceType.network,
      semanticLabel: semanticLabel,
    );
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double logoWidth;
    switch (size) {
      case AppLogoSize.small: logoWidth = screenWidth * 0.24; break;
      case AppLogoSize.medium: logoWidth = screenWidth * 0.65; break;
      case AppLogoSize.large: logoWidth = screenWidth * 0.92; break;
    }
    // Placeholder Material em caso de erro
    final Widget errorWidget = SizedBox(
      width: logoWidth,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),        
        size: logoWidth * 0.5, // Ícone proporcional ao tamanho do logo
      ),
    );
    switch (_source) {
      case _ImageSourceType.network:
        return Image.network(
          logoPath,
          width: logoWidth,
          fit: BoxFit.contain,
          semanticLabel: semanticLabel,
          errorBuilder: (context, error, stackTrace) => errorWidget,
        );
      case _ImageSourceType.asset:
        return Image.asset(
          logoPath,
          width: logoWidth,
          fit: BoxFit.contain,
          semanticLabel: semanticLabel,
          errorBuilder: (context, error, stackTrace) => errorWidget,
        );
    }
  }
}
// PREVIEW DO COMPONENTE
const String supabaseLogoUrl = 'https://ibprddrdjzazqqaxhilj.supabase.co/storage/v1/object/public/test/LogoFundoClaro.png';
@Preview(
  name: 'Logo Responsivo (Material)',
  size: Size(450, 250),
)
Widget logoMaterialPreview() {
  return Scaffold(
    backgroundColor: Colors.grey[200],
    body: Center(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AppLogoWidget.network(
            size: AppLogoSize.medium,
            logoPath: supabaseLogoUrl,
            // Exemplo de como fornecer uma descrição mais específica
            semanticLabel: 'Logo do Centro Universitário Cidade Verde',
          ),
        ),
      ),
    ),
  );
}