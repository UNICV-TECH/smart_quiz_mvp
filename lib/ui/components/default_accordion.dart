import 'package:flutter/material.dart';
import '../theme/app_color.dart';

class DefaultAccordion extends StatefulWidget {
  final String title;
  final String content;
  final IconData? icon;
  final Color? titleColor;
  final Color? contentColor;
  final Color? backgroundColor;
  final Color? iconColor;

  const DefaultAccordion({
    super.key,
    required this.title,
    required this.content,
    this.icon,
    this.titleColor,
    this.contentColor,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  State<DefaultAccordion> createState() => _DefaultAccordionState();
}

class _DefaultAccordionState extends State<DefaultAccordion> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppColors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: AppColors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          leading: widget.icon != null
              ? Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (widget.iconColor ?? AppColors.green)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.iconColor ?? AppColors.green,
                    size: 24,
                  ),
                )
              : null,
          title: Text(
            widget.title,
            style: TextStyle(
              color: widget.titleColor ?? AppColors.primaryDark,
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          iconColor: widget.iconColor ?? AppColors.green,
          collapsedIconColor: widget.iconColor ?? AppColors.green,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.content,
                style: TextStyle(
                  color: widget.contentColor ?? AppColors.secondaryDark,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
