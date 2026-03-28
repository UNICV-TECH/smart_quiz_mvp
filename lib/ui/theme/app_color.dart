import 'package:flutter/material.dart';

class AppColors {
  //white
  static const Color white = Color(0xFFFFFFFF);
  static const Color whiteBg = Color(0xFFFCFCFC); // fundo branco quase puro

  //green
  static const Color green1 = Color(0xFF4CAF50);
  static const Color green2 = Color(0xFF3F8B3A); // branco opaco
  static const Color accentGreen = Color(0xFF3A6B3F);
  static const Color green = Color(0xFF3B5C34);
  static const Color deepGreen = Color(0xFF2F4A2B);
  static const Color greenSplash = Color(0xFF4D7B58); // verde splash screen
  static const Color greenmusgo = Color(0xFF516448);
  static const Color greenmusgoopacidade = Color(0xFF8B9486);
  static const Color backgroundGradient1 = Color(0xFFEAF5EF);
  static const Color greenChart = Color.fromARGB(70, 59, 92, 52);
  static const Color inputLogin = Color.fromARGB(20, 59, 92, 52);

  //black
  static const Color primaryDark = Color.fromARGB(255, 0, 0, 0);
  static const Color blackopaco = Color(0x14000000);

  //red
  static const Color error = Color(0xFFE32F24);
  static const Color borderColorError = Color(0xFFF44336);
  static const Color iconRed = Color.fromARGB(255, 213, 44, 52);
  static const Color red3 = Color(0xFFFF5722);
  static const Color red = Color(0xFFD9503F);
  static const Color red2 = Color(0xFFFF5252);
  static const Color iconBackgroundRed = Color.fromARGB(20, 213, 44, 52);

  //orange
  static const Color orange = Color(0xFFEF992D);
  static const Color orangeChart = Color(0xFFDC9B3C);

  //grey
  static const Color secondaryDark = Color(0xFF666465);
  static const Color greyText = Color(0xFF666666); // cinza para texto
  static const Color greyGradient = Color(0xFF858585); // cinza para gradiente
  static const Color greyLight = Color(0xFFE0E0E0); // cinza claro
  static const Color checklistUnselectedText = Color(0xFF616161); // cinza texto
  static const Color estiloLabel = Color.fromARGB(255, 158, 158, 158);
  static const Color greyShade400 = Color(0xFFBDBDBD);
  static const Color tertiaryDark = Color(0xFFccc1c7);
  static const Color checklistUnselectedBorder =
      Color(0xFFBDBDBD); // cinza borda
  static const Color greyShade200 = Color(0xFFEEEEEE);

  //pink
  static const Color brandButtonBorder = Color.fromARGB(130, 245, 47, 130);
  static const Color iconBackgroundPink = Color.fromARGB(20, 245, 47, 130);

  //tranparente
  static const Color shadow = Color(0x1A000000);
  static const Color transparent = Colors.transparent;

  //blue
  static const Color borderColorFocus = Color.fromARGB(255, 33, 150, 243);
  static const Color indigo = Color(0xFF3F51B5);
  static const Color blueShade = Color(0xFFE3F2FD);

  //yellow
  static const Color backgroundGradient2 = Color(0xFFF7E9D2);
  
  static const Color dividerColor = Color(0xFFD3D9CF);
  static const Color cardFill = Color(0xFFEFF4EA);

  //grupo web no figma
  static const Color webNeutral100 = Color(0xFFF9F9F9);
  static const Color webNeutral200 = Color(0xFFE6E6E6);
  static const Color webNeutral300 = Color(0xFFCCCCCC);
  static const Color webNeutral400 = Color(0xFFB3B3B3);
  static const Color webNeutral500 = Color(0xFF8C8C8C);
  static const Color webNeutral600 = Color(0xFF737373);
  static const Color webNeutral700 = Color(0xFF595959);
  static const Color webNeutral800 = Color(0xFF404040);
  static const Color webNeutral900 = Color(0xFF262626);

  static const fosco = Color.fromRGBO(0, 0, 0, 0.2);

  //navbar
  static const greenNavBar = Color(0xFF38553A);

  // ── Cores das telas gamificadas ──────────────────────────

  // Fundo de pagina
  static const Color pageBg = Color(0xFFF5F7F3);

  // Header gradiente verde
  static const Color headerGradientStart = Color(0xFF2F4A2B);
  static const Color headerGradientMid = Color(0xFF3B5C34);
  static const Color headerGradientEnd = Color(0xFF4D7B58);

  // Fundo verde claro (exam screen)
  static const Color bgLightGreen = Color(0xFFE8F5ED);

  // Verdes de gamificacao
  static const Color gamificationDark = Color(0xFF2E7D32);
  static const Color gamificationOlive = Color(0xFF558B2F);
  static const Color gamificationLight = Color(0xFF81C784);
  static const Color gamificationLighter = Color(0xFFA5D6A7);
  static const Color gamificationBright = Color(0xFF66BB6A);
  static const Color gamificationBorder = Color(0xFFC8E6C9);
  static const Color gamificationBgLight = Color(0xFFE8F5E9);
  static const Color gamificationBgPale = Color(0xFFF1F8E9);

  // Resultado - scorecards
  static const Color scoreCorrect = Color(0xFF3F8B3A);
  static const Color scoreBgCorrect = Color(0xFFE5F4E3);
  static const Color scoreIncorrect = Color(0xFFD9503F);
  static const Color scoreBgIncorrect = Color(0xFFF9E5E3);
  static const Color scoreBgUnanswered = Color(0xFFF1F3F0);

  // Dourado / level up
  static const Color gold = Color(0xFFFFD700);
  static const Color goldDark = Color(0xFFFFA000);
  static const Color goldLight = Color(0xFFFFD54F);
  static const Color goldYellow = Color(0xFFFFEB3B);
  static const Color goldBgStart = Color(0xFFFFF8E1);
  static const Color goldBgEnd = Color(0xFFFFF3E0);
  static const Color goldShadow = Color(0x30FFD54F);
  static const Color levelUpBrown = Color(0xFF5D4037);
  static const Color orangeDeep = Color(0xFFFF6F00);

  // Stats cards (perfil)
  static const Color statGold = Color(0xFFFFB300);
  static const Color statBlue = Color(0xFF42A5F5);
  static const Color statBgBlue = Color(0xFFE3F2FD);

  // Texto
  static const Color textDark = Color(0xFF2E2E2E);
  static const Color textMediumGrey = Color(0xFF888888);
  static const Color textSubtle = Color(0xFF999999);
  static const Color textGrey = Color(0xFF9E9E9E);
  static const Color borderLight = Color(0xFFE8E8E8);

  // Sombras
  static const Color shadowLight = Color(0x0D000000);
  static const Color shadowMedium = Color(0x0A000000);
  static const Color shadowSmall = Color(0x08000000);
  static const Color shadowDark = Color(0x18000000);
  static const Color shadowGreen = Color(0x404CAF50);
}