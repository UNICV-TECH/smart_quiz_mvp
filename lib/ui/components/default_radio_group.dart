import 'package:flutter/material.dart';
import 'package:unicv_tech_mvp/ui/theme/app_color.dart';

class AlternativeSelectorVertical extends StatelessWidget {
  final List<String> labels; // Lista com textos das alternativas
  final String? selectedOption; //Item Selecionado
  final Function(String) onChanged;

  const AlternativeSelectorVertical({
    super.key,
    required this.labels,
    required this.selectedOption,
    required this.onChanged,
  });

  List<String> get _options => //Lista com a letras para cada alternativa
      List.generate(labels.length, (index) => String.fromCharCode(65 + index));

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(labels.length, (index) {
        final option = _options[index];
        final bool isSelected = option == selectedOption;

        return GestureDetector(
          onTap: () => onChanged(option),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.green : AppColors.webNeutral400
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    option,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    labels[index],
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}