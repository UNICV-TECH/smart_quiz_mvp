import 'package:flutter/material.dart';

enum BotaoTipo { primario, secundario }
class DefaultScorecard extends StatelessWidget {
  final IconData icon;
  final int score;
  final Color? iconColor;
  final Color? scoreColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? iconSize;
  final double? fontSize;
  final VoidCallback? onTap;

  const DefaultScorecard({
    super.key,
    required this.icon,
    required this.score,
    this.iconColor,
    this.scoreColor,
    this.backgroundColor,
    this.borderColor,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.iconSize,
    this.fontSize,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double finalIconSize = iconSize ?? 32.0;
    final double clampedIconSize = finalIconSize.clamp(24.0, 40.0);

    final double finalFontSize = fontSize ?? (clampedIconSize * 0.8);

    return Container(
      width: width,
      height: height ?? 80,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Card(
        elevation: 0,
        color: backgroundColor ?? Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: borderColor ?? Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: padding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: clampedIconSize,
                  color: iconColor ?? Colors.grey[600],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    score.toString(),
                    style: TextStyle(
                      fontSize: finalFontSize,
                      fontWeight: FontWeight.bold,
                      color: scoreColor ?? Colors.grey[800],
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}