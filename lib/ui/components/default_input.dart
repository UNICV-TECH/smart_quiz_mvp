import 'package:flutter/material.dart';
import 'package:unicv_tech_mvp/ui/theme/app_color.dart';

class Preview {
  final String name;
  final Size? size;
  final Brightness? brightness;

  const Preview({required this.name, this.size, this.brightness});
}

const Size tamanhoPadraoPreview = Size(350, 150);

// --- PREVIEWS ---

@Preview(
  name: 'Input Padrão',
  size: tamanhoPadraoPreview,
  brightness: Brightness.light,
)
Widget componenteInputPadraoPreview() {
  return const Scaffold(
    backgroundColor: Colors.white,
    body: Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: ComponenteInput(
          labelText: 'E-mail',
          hintText: 'exemplo@email.com',
        ),
      ),
    ),
  );
}

@Preview(
  name: 'Input com Erro',
  size: tamanhoPadraoPreview,
  brightness: Brightness.light,
)
Widget componenteInputErroPreview() {
  return const Scaffold(
    backgroundColor: Colors.white,
    body: Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: ComponenteInput(
          labelText: 'E-mail',
          hintText: 'exemplo@email.com',
          // A mensagem de erro ativa o estilo de erro
          errorMessage: 'Formato de e-mail inválido',
          // Customizando a cor da borda de erro para este preview
          borderColorError: Colors.deepOrange,
        ),
      ),
    ),
  );
}

@Preview(
  name: 'Input Customizado',
  size: tamanhoPadraoPreview,
  brightness: Brightness.light,
)
Widget componenteInputCustomizadoPreview() {
  return Scaffold(
    backgroundColor: Colors.white,
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ComponenteInput(
          labelText: 'Nome Completo',
          hintText: 'Digite seu nome...',
          borderRadius: 12.0, // Borda menos arredondada
          backgroundColor: Colors.blue.shade50,
          borderColorFocus: Colors.green,
          labelStyle: const TextStyle(
            fontSize: 16,
            color: Colors.indigo,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    ),
  );
}

class ComponenteInput extends StatelessWidget {
  // Variáveis que o componente irá receber
  final TextEditingController? controller;
  final String labelText;
  final String hintText;
  final String? errorMessage;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final double width;
  final double height;
  final Color backgroundColor;
  final Color borderColor;
  final Color borderColorFocus;
  final Color borderColorError;
  final double borderRadius;
  final TextStyle textStyle;
  final TextStyle labelStyle;
  final String? Function(String?)? validator;

  // Construtor do componente com parâmetros nomeados
  const ComponenteInput({
    super.key,
    this.controller,
    required this.labelText,
    this.hintText = '',
    this.errorMessage,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.width = double.infinity,
    this.height = 49.0, // Altura padrão para o campo
    this.backgroundColor = AppColors.greenChart,
    this.borderColor = AppColors.transparent,
    this.borderColorFocus = AppColors.borderColorFocus,
    this.borderColorError = AppColors.borderColorError,
    this.borderRadius =
        15.0, // Metade da altura para ser totalmente arredondado
    this.textStyle =
        const TextStyle(fontSize: 16, color: AppColors.primaryDark),
    this.labelStyle = const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: AppColors.estiloLabel,
    ),
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    // Define a borda com base no estado de erro
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: BorderSide(
        color: errorMessage != null ? borderColorError : borderColor,
        width: 1.0,
      ),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: BorderSide(
        color: borderColorFocus,
        width: 2.0,
      ),
    );

    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: BorderSide(
        color: borderColorError,
        width: 2.0,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label do campo de texto
        Text(
          labelText,
          style: labelStyle,
        ),
        const SizedBox(height: 8.0), // Espaçamento entre o label e o campo

        // Campo de Texto
        SizedBox(
          width: width,
          height: height,
          child: TextFormField(
            validator: validator,
            controller: controller,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: textStyle,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: textStyle.copyWith(color: AppColors.estiloLabel),
              filled: true,
              fillColor: backgroundColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
              border: border,
              enabledBorder: border,
              focusedBorder: focusedBorder,
              errorBorder: errorBorder,
              focusedErrorBorder: errorBorder,
              // Exibe a mensagem de erro abaixo do campo (padrão do Flutter)
              // Se quiser um comportamento diferente, pode deixar `errorText` nulo
              // e controlar a exibição do erro fora do componente.
              errorText: errorMessage,
              errorStyle: const TextStyle(
                  height: 0.1, color: AppColors.transparent, fontSize: 0),
            ),
          ),
        ),
      ],
    );
  }
}
