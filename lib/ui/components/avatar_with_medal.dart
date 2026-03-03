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
    final medalSize = size * 0.85;
    // Extra space so the medal overlay is not clipped by parent
    final totalSize = medalAsset != null ? size + medalSize * 0.3 : size;
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
              border: Border.all(
                color: Colors.white,
                width: size > 60 ? 3 : 2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x20000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
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
                    size: size * 0.5,
                    color: Colors.white,
                  )
                : null,
          ),

          // Medal overlay (bottom-right)
          if (medalAsset != null)
            Positioned(
              bottom: -4,
              right: -4,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x30000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Image.asset(
                  medalAsset!,
                  width: medalSize,
                  height: medalSize,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.military_tech,
                    size: medalSize * 0.85,
                    color: const Color(0xFFFFA000),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
