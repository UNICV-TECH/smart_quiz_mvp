import 'package:flutter/material.dart';

class AvatarWithMedal extends StatelessWidget {
  const AvatarWithMedal({
    super.key,
    this.avatarUrl,
    this.medalAsset,
    this.size = 48,
  });

  final String? avatarUrl;
  final String? medalAsset;
  final double size;

  @override
  Widget build(BuildContext context) {
    // Add extra padding to accommodate medal overflow
    final totalSize = medalAsset != null ? size + 4 : size;
    return SizedBox(
      width: totalSize,
      height: totalSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Avatar
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: const Color(0xFF3B5C34),
              shape: BoxShape.circle,
              image: avatarUrl != null && avatarUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: avatarUrl == null || avatarUrl!.isEmpty
                ? Icon(
                    Icons.person,
                    size: size * 0.55,
                    color: Colors.white,
                  )
                : null,
          ),

          // Medal overlay (bottom-right)
          if (medalAsset != null)
            Positioned(
              bottom: -2,
              right: -2,
              child: Image.asset(
                medalAsset!,
                width: size * 0.5,
                height: size * 0.5,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.military_tech,
                  size: size * 0.45,
                  color: const Color(0xFFFFA000),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
