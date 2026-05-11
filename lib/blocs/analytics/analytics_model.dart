// ── Analytics Model ───────────────────────────────────────────────────────
// TODO Sprint 4: replace mock data with real API calls per user.

class MonthlySpend {
  final String month;   // e.g. "Jan"
  final double amount;
  const MonthlySpend(this.month, this.amount);
}

class CategorySpend {
  final String category;
  final double amount;
  final String color; // hex string for painting
  const CategorySpend(this.category, this.amount, this.color);
}

class AnalyticsData {
  final List<MonthlySpend> monthly;
  final List<CategorySpend> byCategory;
  final double totalThisMonth;
  final double totalLastMonth;
  final double avgMonthly;

  const AnalyticsData({
    required this.monthly,
    required this.byCategory,
    required this.totalThisMonth,
    required this.totalLastMonth,
    required this.avgMonthly,
  });

  double get trendPercent {
    if (totalLastMonth == 0) return 0;
    return ((totalThisMonth - totalLastMonth) / totalLastMonth) * 100;
  }
}

AnalyticsData mockAnalytics() => const AnalyticsData(
      totalThisMonth: 84.94,
      totalLastMonth: 72.45,
      avgMonthly: 78.20,
      monthly: [
        MonthlySpend('Jul', 65.40),
        MonthlySpend('Aug', 70.20),
        MonthlySpend('Sep', 58.90),
        MonthlySpend('Oct', 72.45),
        MonthlySpend('Nov', 80.10),
        MonthlySpend('Dec', 84.94),
      ],
      byCategory: [
        CategorySpend('Entertainment', 35.96, '#1DD8E8'),
        CategorySpend('Music',         19.98, '#FF5A14'),
        CategorySpend('Productivity',  21.98, '#A855F7'),
        CategorySpend('Cloud',          4.47, '#22C55E'),
        CategorySpend('Developer',      4.00, '#F59E0B'),
      ],
    );