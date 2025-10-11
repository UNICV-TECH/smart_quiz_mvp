import 'package:flutter/material.dart';
import 'package:unicv_tech_mvp/ui/theme/app_color.dart';

@Preview(name: 'Botão Próximo')
Widget avancarButtonPreview() {
  return Center(
    child: DefaultButtonForward(
      text: "Próximo",
      icon: Icons.arrow_forward_ios,
      onPressed: () {},
    ),
  );
}
class Preview {
  const Preview({required String name});
}
class DefaultButtonForward extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final double fontSize;
  const DefaultButtonForward({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.fontSize = 14,
  });
  @override
  State<DefaultButtonForward> createState() => _DefaultButtonForwardState();
}
class _DefaultButtonForwardState extends State<DefaultButtonForward> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: widget.onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.text,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
              fontSize: 16,
            ),
          ),
          if (widget.icon != null) ...[
            Icon(widget.icon, color: AppColors.primaryDark),
          ],
        ],
      ),
    );
  }
}