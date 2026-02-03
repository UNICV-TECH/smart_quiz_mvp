import 'package:flutter/material.dart';

class Preview {
  const Preview({required String name});
}

@Preview(name: 'Select com Pesquisa')
Widget defaultInputSelectPreview() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ExamplePage(),
  );
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ExamplePage(),
    );
  }
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  String? _selectedValue;
  String? _error;

  final List<SelectOption> _options = const [
    SelectOption(value: '1', label: 'Opção 1'),
    SelectOption(value: '2', label: 'Opção 2'),
    SelectOption(value: '3', label: 'Opção 3'),
    SelectOption(value: '4', label: 'Opção 4'),
    SelectOption(value: '5', label: 'Opção 5'),
    SelectOption(value: '6', label: 'Opção com texto longo para exemplo'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select com Pesquisa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectPesquisa(
              label: 'Selecione uma opção',
              options: _options,
              value: _selectedValue,
              required: true,
              placeholder: 'Clique para selecionar',
              onChanged: (value) {
                setState(() {
                  _selectedValue = value;
                  _error = null;
                });
              },
              errorText: _error,
            ),
          ],
        ),
      ),
    );
  }
}

class SelectOption {
  final String value;
  final String label;

  const SelectOption({required this.value, required this.label});
}

class SelectPesquisa extends StatefulWidget {
  final String label;
  final List<SelectOption> options;
  final String? value;
  final bool required;
  final String? placeholder;
  final ValueChanged<String?> onChanged;
  final String? errorText;
  final bool enabled;

  const SelectPesquisa({
    super.key,
    required this.label,
    required this.options,
    required this.onChanged,
    this.value,
    this.required = false,
    this.placeholder,
    this.errorText,
    this.enabled = true,
  });

  @override
  State<SelectPesquisa> createState() => _SelectPesquisaState();
}

class _SelectPesquisaState extends State<SelectPesquisa> {
  String _searchTerm = '';

  String? get _selectedLabel {
    final match = widget.options.firstWhere(
      (option) => option.value == widget.value,
      orElse: () => const SelectOption(value: '', label: ''),
    );
    return match.label.isEmpty ? null : match.label;
  }

  void _openSelectModal() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = widget.options.where((option) {
              if (_searchTerm.isEmpty) return true;
              return option.label
                  .toLowerCase()
                  .contains(_searchTerm.toLowerCase());
            }).toList();

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Pesquisar',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setModalState(() {
                          _searchTerm = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final option = filtered[index];
                          final selected = option.value == widget.value;

                          return ListTile(
                            title: Text(option.label),
                            trailing: selected
                                ? const Icon(Icons.check, color: Colors.green)
                                : null,
                            onTap: () {
                              widget.onChanged(option.value);
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (widget.required)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text(
                  '*',
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: widget.enabled ? _openSelectModal : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasError ? Colors.red : Colors.grey.shade400,
              ),
              color: widget.enabled ? Colors.white : Colors.grey.shade100,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedLabel ?? (widget.placeholder ?? 'Selecionar'),
                    style: TextStyle(
                      color: _selectedLabel != null
                          ? Colors.black87
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              ],
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            widget.errorText!,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
      ],
    );
  }
}
