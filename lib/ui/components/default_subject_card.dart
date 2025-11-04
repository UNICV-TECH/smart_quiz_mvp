import 'package:flutter/material.dart';
import 'package:unicv_tech_mvp/ui/theme/app_color.dart';

class SubjectCard extends StatefulWidget {
  const SubjectCard({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.isSelected = false,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
  });

  final Widget icon;
  final String title;
  final VoidCallback? onTap;
  final bool isSelected;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  @override
  State<SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<SubjectCard> {
  bool _isHovering = false;

  void _handleHover(bool hovering) {
    if (!mounted) return;
    setState(() => _isHovering = hovering);
  }

  @override
  Widget build(BuildContext context) {
    final bool highlight = widget.isSelected || _isHovering;
    final Color backgroundColor =
        highlight ? AppColors.white : AppColors.webNeutral100;
    final Color borderColor =
        highlight ? AppColors.green : AppColors.webNeutral200;
    final Color textColor =
        widget.isSelected ? AppColors.green : AppColors.secondaryDark;
    const double iconSize = 44;
    const double iconGap = 16;
    const double horizontalPadding = iconSize + iconGap;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(color: borderColor, width: highlight ? 1.4 : 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              offset: const Offset(0, 6),
              blurRadius: highlight ? 14 : 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              splashColor: AppColors.green.withValues(alpha: 0.1),
              highlightColor: AppColors.green.withValues(alpha: 0.05),
              child: Padding(
                padding: widget.padding,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        height: iconSize,
                        width: iconSize,
                        child: Center(child: widget.icon),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: Text(
                        widget.title,
                        textAlign: TextAlign.left,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: widget.isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: textColor,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SubjectCardData {
  const SubjectCardData({
    required this.id,
    required this.icon,
    required this.title,
    this.onTap,
  });

  final String id;
  final Widget icon;
  final String title;
  final VoidCallback? onTap;
}

class SubjectCardList extends StatefulWidget {
  const SubjectCardList({
    super.key,
    required this.subjects,
    this.selectedSubjectId,
    this.onSubjectSelected,
    this.padding = EdgeInsets.zero,
    this.spacing = 12,
  });

  final List<SubjectCardData> subjects;
  final String? selectedSubjectId;
  final ValueChanged<String>? onSubjectSelected;
  final EdgeInsetsGeometry padding;
  final double spacing;

  @override
  State<SubjectCardList> createState() => _SubjectCardListState();
}

class _SubjectCardListState extends State<SubjectCardList> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: _controller,
      padding: widget.padding,
      physics: const BouncingScrollPhysics(),
      itemCount: widget.subjects.length,
      itemBuilder: (context, index) {
        final subject = widget.subjects[index];
        return SubjectCard(
          icon: subject.icon,
          title: subject.title,
          isSelected: widget.selectedSubjectId == subject.id,
          onTap: () {
            subject.onTap?.call();
            if (widget.onSubjectSelected != null) {
              widget.onSubjectSelected!(subject.id);
            }
          },
        );
      },
      separatorBuilder: (_, __) => SizedBox(height: widget.spacing),
    );
  }
}
