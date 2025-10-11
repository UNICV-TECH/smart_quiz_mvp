import 'package:flutter/material.dart';
import 'package:unicv_tech_mvp/ui/components/default_button_orange.dart';
import 'components/default_navbar.dart';
import 'components/default_subject_card.dart';
import 'components/default_scorecard.dart';
import 'theme/app_color.dart';

// Constante para tamanho padrão dos previews
const Size tamanhoPadraoPreview = Size(353, 100);

// Preview do botão primário - apenas texto
@Preview(
  name: 'Botão Primário (Texto)',
  size: tamanhoPadraoPreview,
  textScaleFactor: 1.2,
  brightness: Brightness.light,
)
Widget componenteBotaoPrimarioPreview() {
  return Container(
    child: Center(
      child: DefaultButtonOrange(
        texto: "Primário",
        onPressed: () {},
        tipo: BotaoTipo.primario,
      ),
    ),
  );
}

// Preview do botão primário - apenas ícone
@Preview(
  name: 'Botão Primário (Ícone)',
  size: tamanhoPadraoPreview,
  textScaleFactor: 1.2,
  brightness: Brightness.light,
)
Widget componenteBotaoPrimarioIconePreview() {
  return Container(
    child: Center(
      child: DefaultButtonOrange(
        texto: "",
        icone: Icons.add,
        onPressed: () {},
        tipo: BotaoTipo.primario,
      ),
    ),
  );
}

// Preview do botão primário - texto + ícone
@Preview(
  name: 'Botão Primário (Texto + Ícone)',
  size: tamanhoPadraoPreview,
  textScaleFactor: 1.2,
  brightness: Brightness.light,
)
Widget componenteBotaoPrimarioTextoIconePreview() {
  // ignore: avoid_unnecessary_containers
  return Container(
    child: Center(
      child: DefaultButtonOrange(
        texto: "Primário",
        icone: Icons.add,
        onPressed: () {},
        tipo: BotaoTipo.primario,
      ),
    ),
  );
}

// Preview do botão secundário - texto
@Preview(
  name: 'Botão Secundário (Texto)',
  size: tamanhoPadraoPreview,
  textScaleFactor: 1.2,
  brightness: Brightness.light,
)
Widget componenteBotaoSecundarioPreview() {
  return Container(
    child: Center(
      child: DefaultButtonOrange(
        texto: "Secundário",
        onPressed: () {},
        tipo: BotaoTipo.secundario,
      ),
    ),
  );
}

// Preview do botão desabilitado - texto
@Preview(
  name: 'Botão Desabilitado (Texto)',
  size: tamanhoPadraoPreview,
  textScaleFactor: 1.2,
  brightness: Brightness.light,
)
Widget componenteBotaoDesabilitadoPreview() {
  return Container(
    child: Center(
      child: DefaultButtonOrange(
        texto: "Desabilitado",
        onPressed: () {},
        tipo: BotaoTipo.desabilitado,
      ),
    ),
  );
}

// ==================== SCORE CARD PREVIEWS ====================

// Preview do ScoreCard - Acertos
@Preview(
  name: 'ScoreCard - Acertos',
  size: tamanhoPadraoPreview,
  textScaleFactor: 1.0,
  brightness: Brightness.light,
)
Widget scoreCardAcertosPreview() {
  return Container(
    child: Center(
      child: const ScoreCard(
        icon: Icons.check_circle,
        score: 15,
        iconColor: Colors.green,
        scoreColor: Colors.green,
      ),
    ),
  );
}

// Preview do ScoreCard - Erros
@Preview(
  name: 'ScoreCard - Erros',
  size: tamanhoPadraoPreview,
  textScaleFactor: 1.0,
  brightness: Brightness.light,
)
Widget scoreCardErrosPreview() {
  return Container(
    child: Center(
      child: const ScoreCard(
        icon: Icons.cancel,
        score: 3,
        iconColor: Colors.red,
        scoreColor: Colors.red,
      ),
    ),
  );
}

// Preview do ScoreCard - Pontos
@Preview(
  name: 'ScoreCard - Pontos',
  size: tamanhoPadraoPreview,
  textScaleFactor: 1.0,
  brightness: Brightness.light,
)
Widget scoreCardPontosPreview() {
  return Container(
    child: Center(
      child: const ScoreCard(
        icon: Icons.stars,
        score: 150,
        iconColor: Colors.amber,
        scoreColor: Colors.amber,
        backgroundColor: Color(0xFFFFF8E1),
        borderColor: Color(0xFFFFD54F),
      ),
    ),
  );
}

// Preview do ScoreCard - Customizado
@Preview(
  name: 'ScoreCard - Customizado',
  size: tamanhoPadraoPreview,
  textScaleFactor: 1.0,
  brightness: Brightness.light,
)
Widget scoreCardCustomizadoPreview() {
  return Container(
    child: Center(
      child: const ScoreCard(
        icon: Icons.emoji_events,
        score: 42,
        iconColor: Color(0xFF9C27B0),
        scoreColor: Color(0xFF7B1FA2),
        backgroundColor: Color(0xFFF3E5F5),
        borderColor: Color(0xFFBA68C8),
      ),
    ),
  );
}

// Preview do ScoreCard - Básico
@Preview(
  name: 'ScoreCard - Básico',
  size: tamanhoPadraoPreview,
  textScaleFactor: 1.0,
  brightness: Brightness.light,
)
Widget scoreCardBasicoPreview() {
  return Container(
    child: Center(
      child: const ScoreCard(
        icon: Icons.score,
        score: 25,
      ),
    ),
  );
}

@Preview(
  name: 'Subject Card List',
  size: Size(360, 320),
  textScaleFactor: 1.0,
  brightness: Brightness.light,
)
Widget subjectCardListPreview() {
  final List<SubjectCardData> subjects = [
    SubjectCardData(
      id: 'psychology',
      icon: const Icon(Icons.psychology_alt, color: AppColors.green, size: 28),
      title: 'Psicologia',
    ),
    SubjectCardData(
      id: 'social',
      icon: const Icon(Icons.groups_3_outlined,
          color: AppColors.secondaryDark, size: 28),
      title: 'Ciências Sociais',
    ),
    SubjectCardData(
      id: 'business',
      icon: const Icon(Icons.settings_suggest_outlined,
          color: AppColors.secondaryDark, size: 28),
      title: 'Administração',
    ),
    SubjectCardData(
      id: 'finance',
      icon: const Icon(Icons.attach_money,
          color: AppColors.secondaryDark, size: 28),
      title: 'Gestão Financeira',
    ),
    SubjectCardData(
      id: 'pedagogy',
      icon: const Icon(Icons.class_outlined,
          color: AppColors.secondaryDark, size: 28),
      title: 'Pedagogia',
    ),
  ];

  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      backgroundColor: AppColors.background,
      body: SubjectCardList(
        padding: const EdgeInsets.all(24),
        subjects: subjects,
        selectedSubjectId: subjects.first.id,
      ),
    ),
  );
}

class Preview {
  final String name;
  final Size? size;
  final double? textScaleFactor;
  final Brightness? brightness;

  const Preview({
    required this.name,
    this.size,
    this.textScaleFactor,
    this.brightness,
  });
}

@Preview(
  name: 'Navbar',
  size: tamanhoPadraoPreview,
  textScaleFactor: 1.0,
  brightness: Brightness.light,
)
Widget customNavBarPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      backgroundColor: Colors.grey[200],
      body: const Stack(
        children: [
          Center(child: Text('Conteúdo de teste')),
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomNavBar(),
          ),
        ],
      ),
    ),
  );
}