import 'package:flutter_test/flutter_test.dart';
import 'package:project/models/rank.dart';

void main() {
  group('Rank.forPoints (SRS FR-8.2)', () {
    test('maps point totals to the correct rank', () {
      expect(Rank.forPoints(0), Rank.rookie);
      expect(Rank.forPoints(999), Rank.rookie);
      expect(Rank.forPoints(1000), Rank.pro);
      expect(Rank.forPoints(1240), Rank.pro); // seeded demo user
      expect(Rank.forPoints(1560), Rank.elite);
      expect(Rank.forPoints(5000), Rank.legend);
    });

    test('next rank progression', () {
      expect(Rank.rookie.next, Rank.pro);
      expect(Rank.elite.next, Rank.legend);
      expect(Rank.legend.next, isNull);
    });
  });
}
