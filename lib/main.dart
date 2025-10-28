import 'package:flutter/material.dart';
// 1. Importa a tela que queremos testar
import 'package:unicv_tech_mvp/ui/theme/app_color.dart';
import 'package:unicv_tech_mvp/views/QuizConfig_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 3. Cria um curso "fictício" para passar para a tela de teste
    final Map<String, dynamic> testCourse = {
      'id': 'teste_curso',
      'title': 'Curso de Teste',
      'icon': Icons.science_outlined // Um ícone qualquer
    };

    return MaterialApp(
      title: 'UniCV Tech',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.green),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      // 4. Inicia o app diretamente na QuizConfigScreen, passando o curso de teste
      home: QuizConfigScreen(course: testCourse), 
    );
  }
}

