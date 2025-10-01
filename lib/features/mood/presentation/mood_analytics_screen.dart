import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../l10n/app_localizations.dart';
import '../data/mood_models.dart';
import '../data/detailed_mood_repository.dart';

class MoodAnalyticsScreen extends StatefulWidget {
  const MoodAnalyticsScreen({super.key});

  @override
  State<MoodAnalyticsScreen> createState() => _MoodAnalyticsScreenState();
}

class _MoodAnalyticsScreenState extends State<MoodAnalyticsScreen>
    with TickerProviderStateMixin {
  final DetailedMoodRepository _repository = DetailedMoodRepository();

  late TabController _tabController;
  List<MoodEntry> _recentEntries = [];
  MoodStatistics? _statistics;
  List<DailyMoodData> _trendData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final entries = await _repository.getAllMoodEntries();
      final stats = await _repository.getMoodStatistics();
      final trend = await _repository.getDailyMoodTrend();

      setState(() {
        _recentEntries = entries.take(20).toList();
        _statistics = stats;
        _trendData = trend;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.moodAnalytics ?? 'Mood Analytics'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.overview ?? 'Overview'),
            Tab(text: l10n.trends ?? 'Trends'),
            Tab(text: l10n.history ?? 'History'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(theme, l10n),
                _buildTrendsTab(theme, l10n),
                _buildHistoryTab(theme, l10n),
              ],
            ),
    );
  }

  Widget _buildOverviewTab(ThemeData theme, AppLocalizations l10n) {
    if (_statistics == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mood, size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              l10n.noMoodData ?? 'No mood data yet',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.startTrackingMood ??
                  'Start tracking your mood to see analytics',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: l10n.totalEntries ?? 'Total Entries',
                  value: _statistics!.totalEntries.toString(),
                  icon: Icons.event_note,
                  color: Colors.blue,
                  theme: theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  title: l10n.averageMood ?? 'Average Mood',
                  value: _statistics!.averageMoodScore.toStringAsFixed(1),
                  icon: Icons.trending_up,
                  color: _getMoodColor(_statistics!.averageMoodScore),
                  theme: theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Mood Distribution
          Text(
            l10n.moodDistribution ?? 'Mood Distribution',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(height: 200, child: _buildMoodDistributionChart(theme)),
          const SizedBox(height: 24),

          // Top Categories
          Text(
            l10n.topCategories ?? 'Top Categories',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildTopCategoriesCard(theme, l10n),
        ],
      ),
    );
  }

  Widget _buildTrendsTab(ThemeData theme, AppLocalizations l10n) {
    if (_trendData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.trending_up, size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              l10n.noTrendData ?? 'Not enough data for trends',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.moodTrend ?? 'Mood Trend (Last 30 Days)',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: _buildTrendChart(theme),
          ),
          const SizedBox(height: 24),
          _buildTrendInsights(theme, l10n),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(ThemeData theme, AppLocalizations l10n) {
    if (_recentEntries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              l10n.noHistory ?? 'No mood history',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _recentEntries.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = _recentEntries[index];
        return _buildHistoryCard(entry, theme, l10n);
      },
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMoodDistributionChart(ThemeData theme) {
    if (_statistics == null || _statistics!.moodDistribution.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final sections = _statistics!.moodDistribution.entries.map((entry) {
      final mood = entry.key;
      final count = entry.value;
      final percentage = (count / _statistics!.totalEntries) * 100;

      return PieChartSectionData(
        color: _getMoodColor(mood.index + 1.0),
        value: percentage,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return PieChart(
      PieChartData(sections: sections, centerSpaceRadius: 40, sectionsSpace: 2),
    );
  }

  Widget _buildTopCategoriesCard(ThemeData theme, AppLocalizations l10n) {
    if (_statistics == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryRow(
            l10n.mostCommonMood ?? 'Most Common Mood',
            _getMoodTitle(_statistics!.mostCommonMood, l10n),
            _getMoodIcon(_statistics!.mostCommonMood),
            _getMoodColor(_statistics!.mostCommonMood.index + 1.0),
            theme,
          ),
          const Divider(),
          _buildCategoryRow(
            l10n.mostCommonEmotion ?? 'Most Common Emotion',
            _getSubEmotionTitle(_statistics!.mostCommonSubEmotion, l10n),
            _getSubEmotionIcon(_statistics!.mostCommonSubEmotion),
            theme.colorScheme.primary,
            theme,
          ),
          const Divider(),
          _buildCategoryRow(
            l10n.mostCommonReason ?? 'Most Common Reason',
            _getReasonTitle(_statistics!.mostCommonReason, l10n),
            _getReasonIcon(_statistics!.mostCommonReason),
            theme.colorScheme.secondary,
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(
    String label,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart(ThemeData theme) {
    if (_trendData.isEmpty) return const Center(child: Text('No data'));

    final spots = _trendData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.averageMoodScore);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: theme.textTheme.bodySmall,
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _trendData.length > 10 ? _trendData.length / 5 : 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < _trendData.length) {
                  final date = _trendData[index].date;
                  return Text(
                    '${date.day}/${date.month}',
                    style: theme.textTheme.bodySmall,
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        ),
        minX: 0,
        maxX: (_trendData.length - 1).toDouble(),
        minY: 1,
        maxY: 5,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: theme.colorScheme.primary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: theme.colorScheme.primary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendInsights(ThemeData theme, AppLocalizations l10n) {
    if (_trendData.length < 2) return const SizedBox.shrink();

    final recentAverage =
        _trendData
            .take(7)
            .fold<double>(0, (sum, data) => sum + data.averageMoodScore) /
        7;
    final olderAverage =
        _trendData
            .skip(7)
            .take(7)
            .fold<double>(0, (sum, data) => sum + data.averageMoodScore) /
        7;

    final trend = recentAverage - olderAverage;
    final isImproving = trend > 0.1;
    final isWorsening = trend < -0.1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.insights ?? 'Insights',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                isImproving
                    ? Icons.trending_up
                    : isWorsening
                    ? Icons.trending_down
                    : Icons.trending_flat,
                color: isImproving
                    ? Colors.green
                    : isWorsening
                    ? Colors.red
                    : Colors.grey,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isImproving
                      ? (l10n.moodImproving ?? 'Your mood is improving!')
                      : isWorsening
                      ? (l10n.moodDeclining ??
                            'Your mood seems to be declining')
                      : (l10n.moodStable ?? 'Your mood is relatively stable'),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
    MoodEntry entry,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getMoodColor(entry.mood.index + 1.0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getMoodIcon(entry.mood),
                  color: _getMoodColor(entry.mood.index + 1.0),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getMoodTitle(entry.mood, l10n),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatDateTime(entry.timestamp),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (entry.journalText.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              entry.journalText,
              style: theme.textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              _buildTag(_getSubEmotionTitle(entry.subEmotion, l10n), theme),
              const SizedBox(width: 8),
              _buildTag(_getReasonTitle(entry.reason, l10n), theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  // Helper methods
  Color _getMoodColor(double moodScore) {
    if (moodScore <= 1.5) return Colors.red;
    if (moodScore <= 2.5) return Colors.orange;
    if (moodScore <= 3.5) return Colors.blue;
    if (moodScore <= 4.5) return Colors.green;
    return Colors.purple;
  }

  IconData _getMoodIcon(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.terrible:
        return Icons.sentiment_very_dissatisfied;
      case MoodLevel.bad:
        return Icons.sentiment_dissatisfied;
      case MoodLevel.neutral:
        return Icons.sentiment_neutral;
      case MoodLevel.good:
        return Icons.sentiment_satisfied;
      case MoodLevel.excellent:
        return Icons.sentiment_very_satisfied;
    }
  }

  String _getMoodTitle(MoodLevel mood, AppLocalizations l10n) {
    switch (mood) {
      case MoodLevel.terrible:
        return l10n.moodTerrible;
      case MoodLevel.bad:
        return l10n.moodBad;
      case MoodLevel.neutral:
        return l10n.moodNeutral;
      case MoodLevel.good:
        return l10n.moodGood;
      case MoodLevel.excellent:
        return l10n.moodExcellent;
    }
  }

  IconData _getSubEmotionIcon(SubEmotion subEmotion) {
    // Same mapping as in other screens
    switch (subEmotion) {
      case SubEmotion.exhausted:
        return Icons.battery_0_bar;
      case SubEmotion.helpless:
        return Icons.help_outline;
      case SubEmotion.hopeless:
        return Icons.cloud_off;
      case SubEmotion.hurt:
        return Icons.favorite_border;
      case SubEmotion.drained:
        return Icons.water_drop_outlined;
      case SubEmotion.angry:
        return Icons.flash_on;
      case SubEmotion.sad:
        return Icons.sentiment_dissatisfied;
      case SubEmotion.anxious:
        return Icons.psychology;
      case SubEmotion.stressed:
        return Icons.speed;
      case SubEmotion.demoralized:
        return Icons.trending_down;
      case SubEmotion.indecisive:
        return Icons.shuffle;
      case SubEmotion.tired:
        return Icons.bedtime;
      case SubEmotion.ordinary:
        return Icons.remove;
      case SubEmotion.calm:
        return Icons.spa;
      case SubEmotion.empty:
        return Icons.crop_free;
      case SubEmotion.happy:
        return Icons.sentiment_satisfied;
      case SubEmotion.cheerful:
        return Icons.emoji_emotions;
      case SubEmotion.excited:
        return Icons.celebration;
      case SubEmotion.enthusiastic:
        return Icons.local_fire_department;
      case SubEmotion.determined:
        return Icons.flag;
      case SubEmotion.motivated:
        return Icons.trending_up;
      case SubEmotion.amazing:
        return Icons.auto_awesome;
      case SubEmotion.energetic:
        return Icons.bolt;
      case SubEmotion.peaceful:
        return Icons.self_improvement;
      case SubEmotion.grateful:
        return Icons.favorite;
      case SubEmotion.loving:
        return Icons.volunteer_activism;
    }
  }

  String _getSubEmotionTitle(SubEmotion subEmotion, AppLocalizations l10n) {
    switch (subEmotion) {
      case SubEmotion.exhausted:
        return l10n.subEmotionExhausted;
      case SubEmotion.helpless:
        return l10n.subEmotionHelpless;
      case SubEmotion.hopeless:
        return l10n.subEmotionHopeless;
      case SubEmotion.hurt:
        return l10n.subEmotionHurt;
      case SubEmotion.drained:
        return l10n.subEmotionDrained;
      case SubEmotion.angry:
        return l10n.subEmotionAngry;
      case SubEmotion.sad:
        return l10n.subEmotionSad;
      case SubEmotion.anxious:
        return l10n.subEmotionAnxious;
      case SubEmotion.stressed:
        return l10n.subEmotionStressed;
      case SubEmotion.demoralized:
        return l10n.subEmotionDemoralized;
      case SubEmotion.indecisive:
        return l10n.subEmotionIndecisive;
      case SubEmotion.tired:
        return l10n.subEmotionTired;
      case SubEmotion.ordinary:
        return l10n.subEmotionOrdinary;
      case SubEmotion.calm:
        return l10n.subEmotionCalm;
      case SubEmotion.empty:
        return l10n.subEmotionEmpty;
      case SubEmotion.happy:
        return l10n.subEmotionHappy;
      case SubEmotion.cheerful:
        return l10n.subEmotionCheerful;
      case SubEmotion.excited:
        return l10n.subEmotionExcited;
      case SubEmotion.enthusiastic:
        return l10n.subEmotionEnthusiastic;
      case SubEmotion.determined:
        return l10n.subEmotionDetermined;
      case SubEmotion.motivated:
        return l10n.subEmotionMotivated;
      case SubEmotion.amazing:
        return l10n.subEmotionAmazing;
      case SubEmotion.energetic:
        return l10n.subEmotionEnergetic;
      case SubEmotion.peaceful:
        return l10n.subEmotionPeaceful;
      case SubEmotion.grateful:
        return l10n.subEmotionGrateful;
      case SubEmotion.loving:
        return l10n.subEmotionLoving;
    }
  }

  IconData _getReasonIcon(ReasonCategory reason) {
    switch (reason) {
      case ReasonCategory.academic:
        return Icons.school;
      case ReasonCategory.work:
        return Icons.work;
      case ReasonCategory.relationship:
        return Icons.favorite;
      case ReasonCategory.finance:
        return Icons.attach_money;
      case ReasonCategory.health:
        return Icons.health_and_safety;
      case ReasonCategory.social:
        return Icons.people;
      case ReasonCategory.personalGrowth:
        return Icons.psychology;
      case ReasonCategory.weather:
        return Icons.wb_sunny;
      case ReasonCategory.other:
        return Icons.more_horiz;
    }
  }

  String _getReasonTitle(ReasonCategory reason, AppLocalizations l10n) {
    switch (reason) {
      case ReasonCategory.academic:
        return l10n.reasonAcademic;
      case ReasonCategory.work:
        return l10n.reasonWork;
      case ReasonCategory.relationship:
        return l10n.reasonRelationship;
      case ReasonCategory.finance:
        return l10n.reasonFinance;
      case ReasonCategory.health:
        return l10n.reasonHealth;
      case ReasonCategory.social:
        return l10n.reasonSocial;
      case ReasonCategory.personalGrowth:
        return l10n.reasonPersonalGrowth;
      case ReasonCategory.weather:
        return l10n.reasonWeather;
      case ReasonCategory.other:
        return l10n.reasonOther;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today ${_formatTime(dateTime)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${_formatTime(dateTime)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
