import 'package:flutter/material.dart';
import 'package:unicv_tech_mvp/ui/theme/app_color.dart';

class Preview {
  const Preview({required String name, Size? size});
}

@Preview(name: 'Lista de Seleção de Questões', size: Size(450, 800))
Widget questionSelectionListPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      appBar: AppBar(
        title: const Text('Seleção de Questões'),
        backgroundColor: AppColors.green,
        foregroundColor: AppColors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: QuestionSelectionList(
          items: _previewQuestions,
          selectionMode: QuestionSelectionMode.multiple,
          initialSelectedIds: const {'q1'},
          onSelectionChanged: (selectedIds) {
            debugPrint('Questões selecionadas: $selectedIds');
          },
        ),
      ),
    ),
  );
}

final List<QuestionListItemData> _previewQuestions = [
  QuestionListItemData(
    id: 'q1',
    enunciation:
        'Qual é a definição correta de Programação Orientada a Objetos?',
    content: 'POO',
    subject: 'Algoritmos',
    professor: 'Prof. João Lima',
    semester: '1º semestre',
    year: '2024',
  ),
  QuestionListItemData(
    id: 'q2',
    enunciation:
        'Em uma matriz A de ordem 3x3, qual é o determinante se todos os elementos da diagonal principal são iguais a 2 e os demais são zero?',
    content: 'Matrizes',
    subject: 'Cálculo I',
    professor: 'Profa. Maria Clara',
    semester: '1º semestre',
    year: '2024',
  ),
  QuestionListItemData(
    id: 'q3',
    enunciation: 'O que caracteriza um número complexo na forma algébrica?',
    content: 'Números Complexos',
    subject: 'Cálculo I',
    professor: 'Profa. Maria Clara',
    semester: '2º semestre',
    year: '2024',
  ),
  QuestionListItemData(
    id: 'q4',
    enunciation:
        'Qual é a principal diferença entre herança e composição em POO?',
    content: 'POO',
    subject: 'Algoritmos',
    professor: 'Prof. João Lima',
    semester: '2º semestre',
    year: '2025',
  ),
];

enum QuestionSelectionMode { single, multiple }

class QuestionListItemData {
  const QuestionListItemData({
    required this.id,
    required this.enunciation,
    required this.content,
    required this.subject,
    required this.professor,
    required this.semester,
    required this.year,
  });

  final String id;
  final String enunciation;
  final String content;
  final String subject;
  final String professor;
  final String semester;
  final String year;

  Map<String, String> get tagMap => {
        'Conteúdo': content,
        'Matéria': subject,
        'Professor': professor,
        'Semestre': semester,
        'Ano': year,
      };
}

class QuestionSelectionList extends StatefulWidget {
  const QuestionSelectionList({
    super.key,
    required this.items,
    this.selectionMode = QuestionSelectionMode.multiple,
    this.initialSelectedIds = const <String>{},
    this.onSelectionChanged,
  });

  final List<QuestionListItemData> items;
  final QuestionSelectionMode selectionMode;
  final Set<String> initialSelectedIds;
  final ValueChanged<Set<String>>? onSelectionChanged;

  @override
  State<QuestionSelectionList> createState() => _QuestionSelectionListState();
}

class _QuestionSelectionListState extends State<QuestionSelectionList> {
  final TextEditingController _searchController = TextEditingController();
  final Map<String, Set<String>> _selectedFilters = {
    'Conteúdo': <String>{},
    'Matéria': <String>{},
    'Professor': <String>{},
    'Semestre': <String>{},
    'Ano': <String>{},
  };

  late Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = {...widget.initialSelectedIds};
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSelection(String id) {
    setState(() {
      if (widget.selectionMode == QuestionSelectionMode.single) {
        _selectedIds = {id};
      } else {
        if (_selectedIds.contains(id)) {
          _selectedIds.remove(id);
        } else {
          _selectedIds.add(id);
        }
      }
    });
    widget.onSelectionChanged?.call(_selectedIds);
  }

  void _updateFilter(String category, String value, bool selected) {
    setState(() {
      final filters = _selectedFilters[category];
      if (filters == null) return;
      if (selected) {
        filters.add(value);
      } else {
        filters.remove(value);
      }
    });
  }

  List<QuestionListItemData> _applyFilters(List<QuestionListItemData> items) {
    final query = _searchController.text.trim().toLowerCase();

    return items.where((item) {
      final matchesQuery = query.isEmpty ||
          item.enunciation.toLowerCase().contains(query) ||
          item.tagMap.values
              .any((value) => value.toLowerCase().contains(query));

      if (!matchesQuery) return false;

      for (final entry in _selectedFilters.entries) {
        final selectedValues = entry.value;
        if (selectedValues.isEmpty) continue;

        final itemValue = item.tagMap[entry.key] ?? '';
        if (!selectedValues.contains(itemValue)) return false;
      }

      return true;
    }).toList(growable: false);
  }

  Map<String, List<String>> _availableFilters() {
    final Map<String, Set<String>> collected = {
      'Conteúdo': <String>{},
      'Matéria': <String>{},
      'Professor': <String>{},
      'Semestre': <String>{},
      'Ano': <String>{},
    };

    for (final item in widget.items) {
      item.tagMap.forEach((key, value) {
        if (value.trim().isEmpty) return;
        collected[key]?.add(value);
      });
    }

    return collected.map((key, value) {
      final list = value.toList()..sort();
      return MapEntry(key, list);
    });
  }

  @override
  Widget build(BuildContext context) {
    final filters = _availableFilters();
    final filteredItems = _applyFilters(widget.items);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SearchField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        _FilterSection(
          filters: filters,
          selectedFilters: _selectedFilters,
          onFilterChanged: _updateFilter,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: filteredItems.isEmpty
              ? _EmptyState()
              : ListView.builder(
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    final isSelected = _selectedIds.contains(item.id);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: QuestionSelectionListItem(
                        key: ValueKey(item.id),
                        item: item,
                        isSelected: isSelected,
                        selectionMode: widget.selectionMode,
                        onSelectionChanged: _toggleSelection,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class QuestionSelectionListItem extends StatefulWidget {
  const QuestionSelectionListItem({
    super.key,
    required this.item,
    required this.isSelected,
    required this.selectionMode,
    required this.onSelectionChanged,
  });

  final QuestionListItemData item;
  final bool isSelected;
  final QuestionSelectionMode selectionMode;
  final ValueChanged<String> onSelectionChanged;

  @override
  State<QuestionSelectionListItem> createState() =>
      _QuestionSelectionListItemState();
}

class _QuestionSelectionListItemState extends State<QuestionSelectionListItem> {
  bool _expanded = false;

  void _toggleExpanded() {
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final highlightColor = AppColors.green.withValues(alpha: 0.08);
    final borderColor =
        widget.isSelected ? AppColors.green : AppColors.webNeutral200;

    return Semantics(
      container: true,
      selected: widget.isSelected,
      label: 'Questão com enunciado e tags informativas',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _toggleExpanded,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: widget.isSelected ? highlightColor : AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SelectionControl(
                  selectionMode: widget.selectionMode,
                  isSelected: widget.isSelected,
                  onChanged: () => widget.onSelectionChanged(widget.item.id),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.enunciation,
                        maxLines: _expanded ? null : 2,
                        overflow: _expanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.item.tagMap.entries
                            .where((entry) => entry.value.trim().isNotEmpty)
                            .map((entry) => _TagChip(
                                  label: '${entry.key}: ${entry.value}',
                                ))
                            .toList(growable: false),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.webNeutral500,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectionControl extends StatelessWidget {
  const _SelectionControl({
    required this.selectionMode,
    required this.isSelected,
    required this.onChanged,
  });

  final QuestionSelectionMode selectionMode;
  final bool isSelected;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    if (selectionMode == QuestionSelectionMode.single) {
      return Radio<bool>(
        value: true,
        groupValue: isSelected,
        onChanged: (_) => onChanged(),
        activeColor: AppColors.green,
      );
    }

    return Checkbox(
      value: isSelected,
      onChanged: (_) => onChanged(),
      activeColor: AppColors.green,
      checkColor: AppColors.white,
      side: BorderSide(color: AppColors.webNeutral400),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.green.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.green,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.filters,
    required this.selectedFilters,
    required this.onFilterChanged,
  });

  final Map<String, List<String>> filters;
  final Map<String, Set<String>> selectedFilters;
  final void Function(String category, String value, bool selected)
      onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: filters.entries.map((entry) {
        if (entry.value.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.webNeutral700,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: entry.value.map((value) {
                  final selected =
                      selectedFilters[entry.key]?.contains(value) ?? false;

                  return FilterChip(
                    label: Text(value),
                    selected: selected,
                    onSelected: (valueSelected) =>
                        onFilterChanged(entry.key, value, valueSelected),
                    selectedColor: AppColors.green.withValues(alpha: 0.18),
                    backgroundColor: AppColors.webNeutral100,
                    checkmarkColor: AppColors.green,
                    labelStyle: TextStyle(
                      color:
                          selected ? AppColors.green : AppColors.webNeutral700,
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(
                      color:
                          selected ? AppColors.green : AppColors.webNeutral300,
                    ),
                  );
                }).toList(growable: false),
              ),
            ],
          ),
        );
      }).toList(growable: false),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Pesquisar enunciado ou tags...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.webNeutral300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.webNeutral300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.green, width: 1.5),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Nenhuma questão encontrada com os filtros atuais.',
        style: TextStyle(
          color: AppColors.webNeutral600,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
