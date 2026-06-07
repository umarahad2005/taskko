/// Ranks earned from total points (SRS FR-8.2): Rookie → Pro → Elite → Legend.
enum Rank {
  rookie('Rookie', 0),
  pro('Pro', 1000),
  elite('Elite', 1560),
  legend('Legend', 3000);

  const Rank(this.label, this.threshold);

  /// Minimum points required to hold this rank.
  final int threshold;
  final String label;

  /// The rank a given point total currently maps to.
  static Rank forPoints(int points) {
    var result = Rank.rookie;
    for (final r in Rank.values) {
      if (points >= r.threshold) result = r;
    }
    return result;
  }

  /// The next rank up, or null if already at the top.
  Rank? get next {
    final i = index;
    return i + 1 < Rank.values.length ? Rank.values[i + 1] : null;
  }
}
