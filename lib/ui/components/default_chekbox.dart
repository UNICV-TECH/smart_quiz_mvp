import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unicv_tech_mvp/ui/theme/app_color.dart';

// Constante para o tamanho do container de preview
const Size defaultPreviewSize = Size(300, 250);
// Preview do componente com a primeira opção selecionada
@Preview(
  name: 'Caixa de Seleção - Padrão',
  size: defaultPreviewSize,
  brightness: Brightness.light,
)
Widget selectionBoxDefaultPreview() {
  return Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SelectionBox(
          options: const ['Fácil', 'Médio', 'Difícil'],
          initialOption: 'Fácil',
          onOptionSelected: (option) {
            debugPrint("Selecione a opção: $option");
          },
        ),
      ),
    ),
  );
}
// Preview do componente com outra opção selecionada
@Preview(
  name: 'Caixa de Seleção - "Quantidade" ',
  size: defaultPreviewSize,
  brightness: Brightness.light,
)
Widget selectionBoxQuantityPreview() {
  return Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SelectionBox(
          options: const ['5', '10', '15', '20'],
          initialOption: '15',
          onOptionSelected: (option) {
            debugPrint("Selecione a opção: $option");
          },
        ),
      ),
    ),
  );
}
// Preview com opções customizadas
@Preview(
  name: 'Caixa de Seleção - Opções customizadas',
  size: defaultPreviewSize,
  brightness: Brightness.light,
)
Widget selectionBoxCustomPreview() {
  return Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SelectionBox(
          options: const ['Iniciante', 'Intermediário', 'Avançado'],
          initialOption: 'Intermediário',
          onOptionSelected: (option) {
            debugPrint("Selecione a opção: $option");
          },
        ),
      ),
    ),
  );
}
// Classe de anotação para o preview
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
// Classe principal do componente de seleção
class SelectionBox extends StatefulWidget {
  final List<String> options;
  final ValueChanged<String> onOptionSelected;
  final String? initialOption;
  const SelectionBox({
    super.key,
    required this.options,
    required this.onOptionSelected,
    this.initialOption,
  });
  @override
  State<SelectionBox> createState() => _SelectionBoxState();
}
// Estado do componente
class _SelectionBoxState extends State<SelectionBox> {
  String? _currentlySelectedOption;
  @override
  void initState() {
    super.initState();
    // Valida se a opção inicial existe na lista antes de setar
    if (widget.initialOption != null &&
        widget.options.contains(widget.initialOption)) {
      _currentlySelectedOption = widget.initialOption;
    }
  }
  // Constrói um item da lista de seleção
  Widget _buildSelectionOptionItem(String optionText) {
    final bool isSelected = _currentlySelectedOption == optionText;
    final Color iconColor = isSelected ? AppColors.white : AppColors.transparent;
    final Color iconBackgroundColor =
        isSelected ? AppColors.green : AppColors.transparent;
    final Color borderColor =
        isSelected ? AppColors.green : AppColors.checklistUnselectedBorder;
    final Color textColor =
        isSelected ? AppColors.green : AppColors.checklistUnselectedText;
    final FontWeight fontWeight =
        isSelected ? FontWeight.bold : FontWeight.normal;
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        key: ValueKey(optionText),
        borderRadius: BorderRadius.circular(8.0),
        onTap: () {
          setState(() {
            _currentlySelectedOption = optionText;
          });
          widget.onOptionSelected(optionText);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Container(
                width: 24.07,
                height: 24.07,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  border: Border.all(color: borderColor, width: 1.5),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Center(
                  child: Icon(
                    Icons.check_rounded,
                    color: iconColor,
                    size: 20.0,
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              Text(
                optionText,
                style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                    fontSize: 16,
                    color: textColor,
                    fontWeight: fontWeight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.options
          .map((option) => _buildSelectionOptionItem(option))
          .toList(),
    );
  }
}