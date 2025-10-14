import 'package:flutter/material.dart';
import 'package:unicv_tech_mvp/ui/theme/app_color.dart';


const Size tamanhoPadraoPreview = Size(350, 150);

// --- PREVIEWS PARA O NOVO COMPONENTE DE SENHA ---

@Preview(
  name: 'Input de Senha Padrão',
  size: tamanhoPadraoPreview,
  brightness: Brightness.light,
)
Widget componentePasswordInputPadraoPreview() {
  return const Scaffold(
    backgroundColor: Colors.white,
    body: Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: ComponentePasswordInput(
          labelText: 'Senha',
          hintText: 'Digite sua senha',
        ),
      ),
    ),
  );
}

class Preview {
  const Preview({required String name, required Size size, required Brightness brightness});
}

@Preview(
  name: 'Input de Senha com Erro',
  size: tamanhoPadraoPreview,
  brightness: Brightness.light,
)
Widget componentePasswordInputErroPreview() {
  return const Scaffold(
    backgroundColor: Colors.white,
    body: Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: ComponentePasswordInput(
          labelText: 'Senha',
          hintText: 'Digite sua senha',
          errorMessage: 'Senha curta demais',
        ),
      ),
    ),
  );
}

@Preview(
  name: 'Input de Senha Visível',
  size: tamanhoPadraoPreview,
  brightness: Brightness.light,
)
Widget componentePasswordInputVisivelPreview() {
  // Usamos um wrapper stateful para demonstrar a interatividade no preview
  return Scaffold(
    backgroundColor: Colors.white,
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ComponentePasswordInput(
          labelText: 'Senha',
          hintText: 'Digite sua senha',
          // Para o preview, podemos definir o estado inicial
          initialObscureText: false, 
        ),
      ),
    ),
  );
}


// --- O NOVO COMPONENTE DE SENHA ---

class ComponentePasswordInput extends StatefulWidget {
  // Parâmetros herdados do ComponenteInput para consistência
  final TextEditingController? controller;
  final String labelText;
  final String hintText;
  final String? errorMessage;
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
  final bool initialObscureText; // Parâmetro adicional para previews

  const ComponentePasswordInput({
    super.key,
    this.controller,
    required this.labelText,
    this.hintText = '',
    this.errorMessage,
    this.onChanged,
    this.width = double.infinity,
    this.height = 49.0,
    this.backgroundColor = AppColors.greenChart,
    this.borderColor = AppColors.transparent,
    this.borderColorFocus = AppColors.borderColorFocus,
    this.borderColorError = AppColors.borderColorError,
    this.borderRadius = 15.0,
    this.textStyle = const TextStyle(fontSize: 16, color: AppColors.primaryDark),
    this.labelStyle = const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: AppColors.estiloLabel,
    ),
    this.initialObscureText = true, // Por padrão a senha começa oculta
  });

  @override
  State<ComponentePasswordInput> createState() => _ComponentePasswordInputState();
}

class _ComponentePasswordInputState extends State<ComponentePasswordInput> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.initialObscureText;
  }

  @override
  Widget build(BuildContext context) {
    // Lógica de bordas reutilizada do seu ComponenteInput
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      borderSide: BorderSide(
        color: widget.errorMessage != null ? widget.borderColorError : widget.borderColor,
        width: 1.0,
      ),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      borderSide: BorderSide(
        color: widget.borderColorFocus,
        width: 2.0,
      ),
    );

    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      borderSide: BorderSide(
        color: widget.borderColorError,
        width: 2.0,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label do campo
        Text(
          widget.labelText,
          style: widget.labelStyle,
        ),
        const SizedBox(height: 8.0),

        // Campo de Texto
        SizedBox(
          width: widget.width,
          height: widget.height,
          child: TextFormField(
            controller: widget.controller,
            onChanged: widget.onChanged,
            style: widget.textStyle,
            obscureText: _obscureText, // Aplica o estado de visibilidade
            keyboardType: TextInputType.visiblePassword,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: widget.textStyle.copyWith(color: AppColors.estiloLabel),
              filled: true,
              fillColor: widget.backgroundColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
              border: border,
              enabledBorder: border,
              focusedBorder: focusedBorder,
              errorBorder: errorBorder,
              focusedErrorBorder: errorBorder,
              errorText: widget.errorMessage,
              errorStyle: const TextStyle(height: 0.1, color: AppColors.transparent, fontSize: 0),
              // Ícone para alternar a visibilidade da senha
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.estiloLabel,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}