import 'package:flutter/material.dart';
import '../ui/theme/app_color.dart';
import '../constants/app_strings.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: size.width,
            height: size.height,
            decoration: const BoxDecoration(
              color: AppColors.whiteBg,
            ),
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            width: size.width,
            height: size.height,
            color: AppColors.green.withValues(alpha: 0.8),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: size.height * 0.5,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.transparent,
                    AppColors.greyGradient,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: size.height * 0.4,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(207),
                ),
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.07,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/logo.webp',
                width: size.width * 0.7,
                height: size.height * 0.15,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: size.height * 0.4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  // Texto "Bem vindo"
                  const Text(
                    AppStrings.welcomeTitle,
                    style: TextStyle(
                      color: AppColors.green,
                      fontSize: 53,
                      fontFamily: 'Open Sans',
                      fontWeight: FontWeight.bold,
                      height: 0.55,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Texto secundário
                  const Text(
                    AppStrings.welcomeSubtitle,
                    style: TextStyle(
                      color: AppColors.green,
                      fontSize: 15,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.normal,
                      height: 1.9,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 45),
                  // Botão Entrar
                  SizedBox(
                    width: double.infinity,
                    height: 67,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        AppStrings.enterButton,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 20,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
