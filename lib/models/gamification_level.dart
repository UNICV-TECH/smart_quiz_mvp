enum GamificationLevel {
  iniciante(
    label: 'Iniciante',
    minPoints: 0,
    maxPoints: 100,
    medalAsset: 'assets/images/medal_iniciante.png',
  ),
  explorador(
    label: 'Explorador',
    minPoints: 101,
    maxPoints: 200,
    medalAsset: 'assets/images/medal_explorador.png',
  ),
  mestreDoConteudo(
    label: 'Mestre do Conteúdo',
    minPoints: 201,
    maxPoints: 300,
    medalAsset: 'assets/images/medal_mestre.png',
  ),
  lendario(
    label: 'Lendário',
    minPoints: 301,
    maxPoints: double.infinity,
    medalAsset: 'assets/images/medal_lendario.png',
  );

  const GamificationLevel({
    required this.label,
    required this.minPoints,
    required this.maxPoints,
    required this.medalAsset,
  });

  final String label;
  final double minPoints;
  final double maxPoints;
  final String medalAsset;

  static GamificationLevel fromPoints(double points) {
    if (points >= 301) return GamificationLevel.lendario;
    if (points >= 201) return GamificationLevel.mestreDoConteudo;
    if (points >= 101) return GamificationLevel.explorador;
    return GamificationLevel.iniciante;
  }

  double progressInLevel(double points) {
    if (this == GamificationLevel.lendario) return 1.0;
    final range = maxPoints - minPoints;
    if (range <= 0) return 1.0;
    final progress = (points - minPoints) / range;
    return progress.clamp(0.0, 1.0);
  }

  String pointsLabel(double points) {
    if (this == GamificationLevel.lendario) {
      return '${points.toStringAsFixed(0)} pts — Nível máximo!';
    }
    return '${points.toStringAsFixed(0)} / ${maxPoints.toStringAsFixed(0)} pts';
  }
}
