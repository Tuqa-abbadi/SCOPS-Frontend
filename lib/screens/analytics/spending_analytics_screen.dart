import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../../blocs/analytics/analytics_model.dart';

// ── Spending Analytics Screen ─────────────────────────────────────────────
// Pure Flutter CustomPainter charts — no external chart package needed.
// TODO Sprint 4: replace mockAnalytics() with real API data per user.

class SpendingAnalyticsScreen extends StatefulWidget {
  const SpendingAnalyticsScreen({
    super.key,
    this.data,
    this.embedded = false,
    this.padding = const EdgeInsets.fromLTRB(20, 16, 20, 32),
  });

  final AnalyticsData? data;
  final bool embedded;
  final EdgeInsetsGeometry padding;

  @override
  State<SpendingAnalyticsScreen> createState() =>
      _SpendingAnalyticsScreenState();
}

class SpendingAnalyticsView extends SpendingAnalyticsScreen {
  const SpendingAnalyticsView({
    super.key,
    super.data,
    super.padding = EdgeInsets.zero,
  }) : super(embedded: true);
}

class _SpendingAnalyticsScreenState extends State<SpendingAnalyticsScreen>
    with TickerProviderStateMixin {
  late AnimationController _barCtrl;
  late AnimationController _donutCtrl;
  late Animation<double> _barAnim;
  late Animation<double> _donutAnim;
  int? _selectedBar;
  int? _selectedSlice;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _bg => _isDark ? Color(0xFF020812) : AppColors.lightBackground;
  Color get _card => _isDark ? Color(0xFF07111C) : AppColors.lightSurface;
  static const _cyan = Color(0xFF18E8F2);
  static const _orange = Color(0xFFFF5A14);
  Color get _white => _isDark ? Colors.white : AppColors.lightTextPrimary;
  Color get _muted =>
      _isDark ? Color(0xFF9BA4B0) : AppColors.lightTextSecondary;

  @override
  void initState() {
    super.initState();
    _barCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 900),
    );
    _donutCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1100),
    );
    _barAnim = CurvedAnimation(parent: _barCtrl, curve: Curves.easeOutCubic);
    _donutAnim = CurvedAnimation(
      parent: _donutCtrl,
      curve: Curves.easeOutCubic,
    );
    _barCtrl.forward();
    Future.delayed(Duration(milliseconds: 200), () => _donutCtrl.forward());
  }

  @override
  void dispose() {
    _barCtrl.dispose();
    _donutCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data ?? mockAnalytics();
    final trend = data.trendPercent;
    final trendUp = trend >= 0;

    final content = Padding(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Analytics',
                style: TextStyle(
                  color: _white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Text(
                  'Last 6 months',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            'Spending overview and insights',
            style: TextStyle(color: _muted, fontSize: 13),
          ),
          SizedBox(height: 24),

          // KPI row
          Row(
            children: [
              _kpiCard(
                '\$${data.totalThisMonth.toStringAsFixed(2)}',
                'This Month',
                _cyan,
              ),
              SizedBox(width: 12),
              _kpiCard(
                '\$${data.avgMonthly.toStringAsFixed(2)}',
                'Monthly Avg',
                _muted,
              ),
              SizedBox(width: 12),
              _kpiTrendCard(trend, trendUp),
            ],
          ),
          SizedBox(height: 28),

          // ── Bar Chart ────────────────────────────────────────────────
          _sectionTitle('Monthly Spend'),
          SizedBox(height: 14),
          Container(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 180,
                  child: AnimatedBuilder(
                    animation: _barAnim,
                    builder: (_, __) => GestureDetector(
                      onTapDown: (d) {
                        final box = context.findRenderObject() as RenderBox?;
                        if (box == null) return;
                        final w = box.size.width - 40 - 32;
                        final barW = w / data.monthly.length;
                        final idx = (d.localPosition.dx / barW).floor().clamp(
                          0,
                          data.monthly.length - 1,
                        );
                        setState(() => _selectedBar = idx);
                      },
                      child: CustomPaint(
                        size: Size(double.infinity, 180),
                        painter: _BarChartPainter(
                          data: data.monthly,
                          progress: _barAnim.value,
                          selected: _selectedBar,
                          cyan: _cyan,
                          orange: _orange,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_selectedBar != null) ...[
                  SizedBox(height: 12),
                  Text(
                    '${data.monthly[_selectedBar!].month}: \$${data.monthly[_selectedBar!].amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: _cyan,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 28),

          // ── Trend Line ───────────────────────────────────────────────
          _sectionTitle('Spend Trend'),
          SizedBox(height: 14),
          Container(
            height: 120,
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: AnimatedBuilder(
              animation: _barAnim,
              builder: (_, __) => CustomPaint(
                size: Size(double.infinity, 90),
                painter: _TrendLinePainter(
                  data: data.monthly,
                  progress: _barAnim.value,
                  cyan: _cyan,
                  orange: _orange,
                ),
              ),
            ),
          ),
          SizedBox(height: 28),

          // ── Donut Chart ──────────────────────────────────────────────
          _sectionTitle('By Category'),
          SizedBox(height: 14),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Donut
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: AnimatedBuilder(
                        animation: _donutAnim,
                        builder: (_, __) => GestureDetector(
                          onTapDown: (d) {
                            // rough slice detection by angle from center
                            final center = const Offset(75, 75);
                            final angle = math.atan2(
                              d.localPosition.dy - center.dy,
                              d.localPosition.dx - center.dx,
                            );
                            final total = data.byCategory.fold(
                              0.0,
                              (s, c) => s + c.amount,
                            );
                            double cumAngle = -math.pi / 2;
                            for (int i = 0; i < data.byCategory.length; i++) {
                              final sweep =
                                  (data.byCategory[i].amount / total) *
                                  2 *
                                  math.pi;
                              if (angle >= cumAngle &&
                                  angle <= cumAngle + sweep) {
                                setState(() => _selectedSlice = i);
                                break;
                              }
                              cumAngle += sweep;
                            }
                          },
                          child: CustomPaint(
                            painter: _DonutPainter(
                              categories: data.byCategory,
                              progress: _donutAnim.value,
                              selected: _selectedSlice,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    // Legend
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: data.byCategory.asMap().entries.map((e) {
                          final isSelected = _selectedSlice == e.key;
                          final color = _hexColor(e.value.color);
                          final total = data.byCategory.fold(
                            0.0,
                            (s, c) => s + c.amount,
                          );
                          final pct = (e.value.amount / total * 100)
                              .toStringAsFixed(0);
                          return AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            margin: EdgeInsets.only(bottom: 8),
                            padding: EdgeInsets.symmetric(
                              horizontal: isSelected ? 8 : 0,
                              vertical: isSelected ? 4 : 0,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? color.withOpacity(0.10)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: color,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    e.value.category,
                                    style: TextStyle(
                                      color: isSelected ? _white : _muted,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  '$pct%',
                                  style: TextStyle(
                                    color: isSelected ? color : _muted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                if (_selectedSlice != null) ...[
                  SizedBox(height: 14),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: _hexColor(
                        data.byCategory[_selectedSlice!].color,
                      ).withOpacity(0.10),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _hexColor(
                          data.byCategory[_selectedSlice!].color,
                        ).withOpacity(0.30),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          data.byCategory[_selectedSlice!].category,
                          style: TextStyle(
                            color: _hexColor(
                              data.byCategory[_selectedSlice!].color,
                            ),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          '\$${data.byCategory[_selectedSlice!].amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: _white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    if (widget.embedded) return content;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(child: SingleChildScrollView(child: content)),
    );
  }

  Widget _sectionTitle(String t) => Text(
    t,
    style: TextStyle(color: _white, fontSize: 18, fontWeight: FontWeight.w800),
  );

  Widget _kpiCard(String val, String label, Color color) => Expanded(
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.20)),
      ),
      child: Column(
        children: [
          Text(
            val,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 4),
          Text(label, style: TextStyle(color: _muted, fontSize: 10)),
        ],
      ),
    ),
  );

  Widget _kpiTrendCard(double trend, bool up) => Expanded(
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: (up ? _orange : Color(0xFF22C55E)).withOpacity(0.25),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                up ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                color: up ? _orange : Color(0xFF22C55E),
                size: 16,
              ),
              SizedBox(width: 4),
              Text(
                '${trend.abs().toStringAsFixed(1)}%',
                style: TextStyle(
                  color: up ? _orange : Color(0xFF22C55E),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text('vs Last Month', style: TextStyle(color: _muted, fontSize: 10)),
        ],
      ),
    ),
  );

  Color _hexColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}

// ── Bar Chart Painter ─────────────────────────────────────────────────────
class _BarChartPainter extends CustomPainter {
  final List<MonthlySpend> data;
  final double progress;
  final int? selected;
  final Color cyan;
  final Color orange;

  _BarChartPainter({
    required this.data,
    required this.progress,
    required this.selected,
    required this.cyan,
    required this.orange,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final maxVal = data.map((d) => d.amount).reduce(math.max);
    final barW = size.width / data.length;
    final padX = barW * 0.2;
    final labelH = 20.0;
    final chartH = size.height - labelH;

    for (int i = 0; i < data.length; i++) {
      final pct = maxVal <= 0 ? 0.0 : data[i].amount / maxVal;
      final barH = chartH * pct * progress;
      final left = i * barW + padX;
      final right = (i + 1) * barW - padX;
      final top = chartH - barH;
      final isSelected = selected == i;

      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isSelected
              ? [orange, orange.withOpacity(0.6)]
              : [cyan.withOpacity(0.85), cyan.withOpacity(0.3)],
        ).createShader(Rect.fromLTRB(left, top, right, chartH));

      final rRect = RRect.fromRectAndCorners(
        Rect.fromLTRB(left, top, right, chartH),
        topLeft: Radius.circular(8),
        topRight: Radius.circular(8),
      );
      canvas.drawRRect(rRect, paint);

      // Label
      final tp = TextPainter(
        text: TextSpan(
          text: data[i].month,
          style: TextStyle(
            color: isSelected ? orange : Colors.white.withOpacity(0.45),
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset((left + right) / 2 - tp.width / 2, chartH + 4));
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter old) =>
      old.progress != progress || old.selected != selected;
}

// ── Trend Line Painter ────────────────────────────────────────────────────
class _TrendLinePainter extends CustomPainter {
  final List<MonthlySpend> data;
  final double progress;
  final Color cyan;
  final Color orange;

  _TrendLinePainter({
    required this.data,
    required this.progress,
    required this.cyan,
    required this.orange,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final maxVal = data.map((d) => d.amount).reduce(math.max);
    final minVal = data.map((d) => d.amount).reduce(math.min);
    final range = (maxVal - minVal).clamp(1.0, double.infinity);

    List<Offset> pts = [];
    for (int i = 0; i < data.length; i++) {
      final x = i / (data.length - 1) * size.width;
      final y =
          size.height -
          ((data[i].amount - minVal) / range) * size.height * 0.8 -
          size.height * 0.1;
      pts.add(Offset(x, y));
    }

    // Visible points up to progress
    final visibleCount = (pts.length * progress).ceil().clamp(2, pts.length);
    final visiblePts = pts.sublist(0, visibleCount);

    // Fill area
    final fillPath = Path();
    fillPath.moveTo(visiblePts.first.dx, size.height);
    for (final p in visiblePts) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(visiblePts.last.dx, size.height);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [cyan.withOpacity(0.20), Colors.transparent],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Line
    final linePath = Path();
    linePath.moveTo(visiblePts.first.dx, visiblePts.first.dy);
    for (int i = 1; i < visiblePts.length; i++) {
      final prev = visiblePts[i - 1];
      final curr = visiblePts[i];
      final cp1 = Offset((prev.dx + curr.dx) / 2, prev.dy);
      final cp2 = Offset((prev.dx + curr.dx) / 2, curr.dy);
      linePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, curr.dx, curr.dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = cyan
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Dots
    for (final p in visiblePts) {
      canvas.drawCircle(p, 4, Paint()..color = cyan);
      canvas.drawCircle(p, 2.5, Paint()..color = const Color(0xFF020812));
    }
  }

  @override
  bool shouldRepaint(covariant _TrendLinePainter old) =>
      old.progress != progress;
}

// ── Donut Chart Painter ───────────────────────────────────────────────────
class _DonutPainter extends CustomPainter {
  final List<CategorySpend> categories;
  final double progress;
  final int? selected;

  _DonutPainter({
    required this.categories,
    required this.progress,
    required this.selected,
  });

  Color _hexColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final total = categories.fold(0.0, (s, c) => s + c.amount);
    if (total <= 0) return;
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    const innerR = 0.58;
    const gap = 0.03;

    double startAngle = -math.pi / 2;

    for (int i = 0; i < categories.length; i++) {
      final sweep = (categories[i].amount / total) * 2 * math.pi * progress;
      final color = _hexColor(categories[i].color);
      final isSelected = selected == i;

      final paint = Paint()
        ..color = isSelected ? color : color.withOpacity(0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected
            ? radius * (1 - innerR) + 8
            : radius * (1 - innerR)
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: radius * (innerR + (1 - innerR) / 2),
        ),
        startAngle + gap,
        sweep - gap * 2,
        false,
        paint,
      );
      startAngle += sweep;
    }

    // Center text
    if (progress > 0.8) {
      final tp = TextPainter(
        text: TextSpan(
          children: [
            TextSpan(
              text: selected != null
                  ? '\$${categories[selected!].amount.toStringAsFixed(0)}'
                  : '\$${total.toStringAsFixed(0)}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();
      tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2 + 6));

      final label = TextPainter(
        text: TextSpan(
          text: selected != null ? categories[selected!].category : 'Total',
          style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 9),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();
      label.paint(canvas, center - Offset(label.width / 2, -10));
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.progress != progress || old.selected != selected;
}
