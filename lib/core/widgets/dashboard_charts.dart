import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/design_tokens.dart';

class ChartColors {
  static const List<Color> gradientStart = [
    Color(0xFF0077B6), // Deep blue
    Color(0xFF00B4D8), // Cyan
    Color(0xFF90E0EF), // Light cyan
    Color(0xFFCAF0F8), // Very light cyan
  ];
  static const List<Color> gradientEnd = [
    Color(0xFF001D3D), // Navy
    Color(0xFF003566), // Dark blue
    Color(0xFF0077B6), // Deep blue
    Color(0xFF0096C7), // Medium blue
  ];
  static const Color lineColor = Color(0xFF0077B6);
  static const Color barColor = Color(0xFF0077B6);
  static const Color barBackground = Color(0xFFE0F7FA);
  static const Color gridColor = Color(0xFFB3E5FC);
  static const Color textColor = Color(0xFF023E8A);
  static const Color positiveColor = Color(0xFF2E7D32);
  static const Color negativeColor = Color(0xFFC62828);
}

class ChartFilterChips extends StatelessWidget {
  const ChartFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    this.filters = const ['7D', '30D', '90D', '1Y'],
  });

  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final List<String> filters;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = filter == selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(right: DesignTokens.spacingSm),
            child: FilterChip(
              label: Text(
                filter,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.white : ChartColors.textColor,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => onFilterChanged(filter),
              backgroundColor: Colors.white,
              selectedColor: ChartColors.lineColor,
              checkmarkColor: Colors.white,
              side: BorderSide(
                color: isSelected ? ChartColors.lineColor : ChartColors.gridColor,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spacingMd,
                vertical: DesignTokens.spacingXs,
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class SalesTrendChart extends StatefulWidget {
  const SalesTrendChart({
    super.key,
    required this.data,
    this.height = 220,
    this.showTitle = true,
  });

  final List<FlSpot> data;
  final double height;
  final bool showTitle;

  @override
  State<SalesTrendChart> createState() => _SalesTrendChartState();
}

class _SalesTrendChartState extends State<SalesTrendChart> {
  String _selectedFilter = '7D';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = widget.data;
    final minY = data.isEmpty
        ? 0.0
        : data.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    final maxY = data.isEmpty
        ? 100.0
        : data.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    final interval = ((maxY - minY) / 4).ceilToDouble().clamp(1.0, double.infinity);

    return SizedBox(
      height: widget.height,
      child: Card(
        elevation: DesignTokens.elevationLevel1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        ),
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showTitle) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sales Trend',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    ChartFilterChips(
                      selectedFilter: _selectedFilter,
                      onFilterChanged: (f) => setState(() => _selectedFilter = f),
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.spacingMd),
              ],
              Expanded(
                child: data.isEmpty
                    ? Center(
                        child: Text(
                          'No data',
                          style: GoogleFonts.inter(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.4),
                          ),
                        ),
                      )
                    : LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: interval,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: ChartColors.gridColor,
                              strokeWidth: 1,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 55,
                                interval: interval,
                                getTitlesWidget: (value, meta) => Padding(
                                  padding: const EdgeInsets.only(
                                      right: DesignTokens.spacingSm),
                                  child: Text(
                                    _formatNumber(value),
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: ChartColors.textColor
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index < 0 ||
                                      index >= data.length) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        top: DesignTokens.spacingXs),
                                    child: Text(
                                      _shortDay(index),
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        color: ChartColors.textColor
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          minX: 0,
                          maxX: (data.length - 1).toDouble(),
                          minY: minY - interval * 0.2,
                          maxY: maxY + interval * 0.2,
                          lineTouchData: LineTouchData(
                            enabled: true,
                            touchTooltipData: LineTouchTooltipData(
                              tooltipRoundedRadius: DesignTokens.radiusMd,
                              getTooltipItems: (spots) => spots.map((spot) {
                                return LineTooltipItem(
                                  _formatCurrency(spot.y),
                                  GoogleFonts.inter(
                                    color: ChartColors.lineColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: data,
                              isCurved: true,
                              curveSmoothness: 0.35,
                              color: ChartColors.lineColor,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, bar, index) =>
                                    FlDotCirclePainter(
                                  radius: 5,
                                  color: ChartColors.lineColor,
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                ),
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    ChartColors.gradientStart[0].withValues(alpha: 0.3),
                                    ChartColors.gradientEnd[0].withValues(alpha: 0.05),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }

  String _formatCurrency(double value) {
    return 'XAF ${_formatNumber(value)}';
  }

  String _shortDay(int index) {
    final now = DateTime.now();
    final day = now.subtract(Duration(days: 6 - index));
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[day.weekday - 1];
  }
}

class StaffPerformanceChart extends StatefulWidget {
  const StaffPerformanceChart({
    super.key,
    required this.labels,
    required this.values,
    this.height = 220,
  });

  final List<String> labels;
  final List<double> values;
  final double height;

  @override
  State<StaffPerformanceChart> createState() => _StaffPerformanceChartState();
}

class _StaffPerformanceChartState extends State<StaffPerformanceChart> {
  String _selectedFilter = '7D';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labels = widget.labels;
    final values = widget.values;
    final maxY = values.isEmpty
        ? 100.0
        : values.reduce((a, b) => a > b ? a : b);
    final interval = ((maxY) / 4).ceilToDouble().clamp(1.0, double.infinity);

    return SizedBox(
      height: widget.height,
      child: Card(
        elevation: DesignTokens.elevationLevel1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        ),
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sales by Staff',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  ChartFilterChips(
                    selectedFilter: _selectedFilter,
                    onFilterChanged: (f) => setState(() => _selectedFilter = f),
                    filters: const ['7D', '30D', 'All'],
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.spacingMd),
              Expanded(
                child: values.isEmpty
                    ? Center(
                        child: Text(
                          'No data',
                          style: GoogleFonts.inter(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.4),
                          ),
                        ),
                      )
                    : BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: maxY + interval,
                          minY: 0,
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: interval,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: ChartColors.gridColor,
                              strokeWidth: 1,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 55,
                                interval: interval,
                                getTitlesWidget: (value, meta) => Padding(
                                  padding: const EdgeInsets.only(
                                      right: DesignTokens.spacingSm),
                                  child: Text(
                                    _formatNumber(value),
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: ChartColors.textColor
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 45,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index < 0 || index >= labels.length) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        top: DesignTokens.spacingXs),
                                    child: Text(
                                      _truncate(labels[index], 10),
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        color: ChartColors.textColor
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              tooltipRoundedRadius: DesignTokens.radiusMd,
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                return BarTooltipItem(
                                  _formatCurrency(rod.toY),
                                  GoogleFonts.inter(
                                    color: ChartColors.barColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                );
                              },
                            ),
                          ),
                          barGroups: List.generate(labels.length, (i) {
                            return BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: values[i],
                                  color: ChartColors.barColor,
                                  width: 32,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(DesignTokens.radiusSm),
                                  ),
                                  backDrawRodData: BackgroundBarChartRodData(
                                    show: true,
                                    toY: maxY + interval,
                                    color: ChartColors.barBackground,
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }

  String _formatCurrency(double value) {
    return 'XAF ${_formatNumber(value)}';
  }

  String _truncate(String s, int max) {
    return s.length <= max ? s : '${s.substring(0, max)}…';
  }
}