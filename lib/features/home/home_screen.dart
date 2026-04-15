import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import '../../core/constants/app_colors.dart';
import '../../core/models/match_record.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/neon_button.dart';
import '../match_setup/pre_game_screen.dart';
import '../arena/arena_screen.dart';
import '../history/history_screen.dart';
import '../league/league_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late final PageController _pageController;

  // Daily Challenge Data
  String _dailyTopic = "";
  String _dailyPersona = "";
  String _dailyStance = "";
  int _dailyRounds = 5;

  final List<String> _topics = [
    "AI Replacing Human Art",
    "Universal Basic Income",
    "Social Media is Harmful",
    "Colonizing Mars",
    "Genetic Engineering",
  ];

  final List<String> _personas = [
    "The Aggressor",
    "The Comedian",
    "The Philosopher",
    "The Scientist",
    "The Skeptic",
  ];

  final List<String> _stances = ["PRO", "CON"];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _generateDailyChallenge();
  }

  void _generateDailyChallenge() {
    final previousTopic = _dailyTopic;
    final previousPersona = _dailyPersona;
    final previousStance = _dailyStance;
    final previousRounds = _dailyRounds;

    final random = Random();
    int attempts = 0;

    do {
      _dailyTopic = _topics[random.nextInt(_topics.length)];
      _dailyPersona = _personas[random.nextInt(_personas.length)];
      _dailyStance = _stances[random.nextInt(_stances.length)];
      _dailyRounds = random.nextInt(4) + 5;
      attempts++;
    } while (
        attempts < 6 &&
        _dailyTopic == previousTopic &&
        _dailyPersona == previousPersona &&
        _dailyStance == previousStance &&
        _dailyRounds == previousRounds);
  }

  void _refreshDailyChallenge() {
    setState(() {
      _generateDailyChallenge();
    });
  }

  void _onTabSelected(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _onPageChanged(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }

    if (index == 0) {
      _refreshDailyChallenge();
    }
  }

  void _openCustomMatch(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PreGameScreen()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          physics: const BouncingScrollPhysics(),
          children: [
            _HomeDashboard(
              onViewAll: () => _onTabSelected(2),
              onStartCustomMatch: () => _openCustomMatch(context),
              dailyTopic: _dailyTopic,
              dailyPersona: _dailyPersona,
              dailyStance: _dailyStance,
              dailyRounds: _dailyRounds,
            ),
            const LeaguesScreen(),
            const HistoryScreen(),
            const ProfileScreen(),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(context),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 24, left: 32, right: 32),
      decoration: BoxDecoration(
        color: AppColors.deepVoid.withOpacity(0.85),
        border: Border(
          top: BorderSide(color: AppColors.neonPurple.withOpacity(0.2)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(Icons.home_rounded, 'HOME', index: 0),
          _buildNavItem(Icons.emoji_events_outlined, 'LEAGUE', index: 1),
          _buildNavItem(Icons.history_rounded, 'HISTORY', index: 2),
          _buildNavItem(Icons.person_outline_rounded, 'PROFILE', index: 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, {required int index}) {
    final bool isSelected = _currentIndex == index;
    return InkWell(
      onTap: () {
        _onTabSelected(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isSelected ? AppColors.neonPurple.withOpacity(0.15) : Colors.transparent,
            ),
            child: Icon(
              icon,
              color: isSelected ? AppColors.neonPurple : AppColors.mutedText,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: isSelected ? AppColors.neonPurple : AppColors.mutedText,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Feature coming soon!',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.neonPurple,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 32,
              errorBuilder: (context, error, stackTrace) => Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.gavel, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'DEBATEME',
              style: GoogleFonts.spaceGrotesk(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w900,
                fontSize: 22,
                fontStyle: FontStyle.italic,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded, color: AppColors.mutedText),
              onPressed: () => _showComingSoon(context),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.accentGradient,
                ),
                padding: const EdgeInsets.all(2),
                child: const CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.surface,
                  child: Icon(Icons.person, color: AppColors.mutedText, size: 20),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildProfileHeader(BuildContext context, {required int elo}) {
    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box('user_settings').listenable(keys: ['username']),
      builder: (context, box, _) {
        final String name = box.get('username', defaultValue: 'Abdulrehman');
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _showEditProfileDialog(context),
                  child: Text(
                    name,
                    style: GoogleFonts.spaceGrotesk(
                      color: AppColors.primaryText,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => AppColors.accentGradient.createShader(bounds),
                      child: Text(
                        'Elo: $elo',
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.circle, size: 4, color: AppColors.mutedText),
                    const SizedBox(width: 8),
                    Text(
                      'Top 2% Globally',
                      style: GoogleFonts.outfit(
                        color: AppColors.mutedText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            GestureDetector(
              onTap: () => _showEditProfileDialog(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.neonPurple.withOpacity(0.5)),
                ),
                child: Text(
                  'Edit Profile',
                  style: GoogleFonts.outfit(
                    color: AppColors.neonPurple,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final controller = TextEditingController(
      text: Hive.box('user_settings').get('username', defaultValue: 'Abdulrehman'),
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        title: Text(
          'Edit Profile Name',
          style: GoogleFonts.spaceGrotesk(color: AppColors.primaryText, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: GoogleFonts.outfit(color: AppColors.primaryText),
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: GoogleFonts.outfit(color: AppColors.mutedText),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.divider)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neonPurple)),
          ),
          onSubmitted: (val) {
            if (val.trim().isNotEmpty) {
              Hive.box('user_settings').put('username', val.trim());
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: GoogleFonts.outfit(color: AppColors.mutedText)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Hive.box('user_settings').put('username', controller.text.trim());
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('SAVE', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget buildPerformanceHub({required String winRate, required int streak}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PERFORMANCE HUB',
          style: GoogleFonts.outfit(
            color: AppColors.mutedText,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Win Rate',
                winRate,
                trend: '+5.2%',
                icon: Icons.trending_up,
                color: AppColors.victory,
              ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Active Streaks',
                streak.toString(),
                showGraph: true,
                color: AppColors.electricBlue,
              ).animate().fadeIn(duration: 500.ms, delay: 150.ms).slideY(begin: 0.2),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value,
      {String trend = '', IconData icon = Icons.trending_up, Color color = AppColors.neonPurple, bool showGraph = false}) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              color: AppColors.mutedText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: GoogleFonts.spaceGrotesk(
                      color: AppColors.primaryText,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (trend.isNotEmpty)
                    Row(
                      children: [
                        Icon(icon, size: 14, color: color),
                        const SizedBox(width: 4),
                        Text(
                          trend,
                          style: GoogleFonts.outfit(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              if (showGraph)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(left: 16),
                    height: 48,
                    child: CustomPaint(
                      painter: SparklinePainter(color: color),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildDailyChallenge(BuildContext context,
      {required String topic, required String persona, required String stance, required int rounds}) {
    return GlassCard(
      borderColor: AppColors.electricBlue.withOpacity(0.3),
      boxShadow: [
        BoxShadow(
          color: AppColors.electricBlue.withOpacity(0.08),
          blurRadius: 30,
          spreadRadius: 0,
        ),
      ],
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.electricBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.electricBlue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer_outlined, size: 12, color: AppColors.electricBlue),
                    const SizedBox(width: 4),
                    Text(
                      'ENDS IN 04:22:15',
                      style: GoogleFonts.outfit(
                        color: AppColors.electricBlue,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) => AppColors.accentGradient.createShader(bounds),
                child: const Icon(Icons.bolt, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildChallengeLabel('TOPIC'),
                    const SizedBox(height: 8),
                    Text(
                      topic.toUpperCase(),
                      style: GoogleFonts.spaceGrotesk(
                        color: AppColors.primaryText,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '⚡ MATCH LENGTH: $rounds ROUNDS',
                      style: GoogleFonts.outfit(
                        color: AppColors.mutedText,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildChallengeLabel('STANCE'),
                    const SizedBox(height: 4),
                    Text(
                      'Defend $stance stance',
                      style: GoogleFonts.outfit(
                        color: stance == "PRO" ? AppColors.victory : AppColors.defeat,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildChallengeLabel('CHALLENGER'),
                    const SizedBox(height: 12),
                    Container(
                      width: 80,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.deepVoid.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.neonPurple.withOpacity(0.3)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: AppColors.accentGradient,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.psychology, color: Colors.white, size: 24),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            persona.split(' ').last,
                            style: GoogleFonts.outfit(
                              color: AppColors.primaryText,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          NeonButton(
            text: 'ACCEPT CHALLENGE',
            icon: Icons.bolt,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArenaScreen(
                    topic: topic,
                    userStance: '$stance-Debater',
                    opponentPersona: persona,
                    totalRounds: rounds,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.15);
  }

  Widget _buildChallengeLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        color: AppColors.mutedText,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget buildCustomMatchSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ARENA ACTIONS',
          style: GoogleFonts.outfit(
            color: AppColors.mutedText,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        NeonButton(
          text: 'START CUSTOM MATCH',
          icon: Icons.add,
          height: 64,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PreGameScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget buildStickyCustomMatchButton(BuildContext context, {required VoidCallback onPressed}) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      borderColor: AppColors.neonPurple.withOpacity(0.35),
      boxShadow: [
        BoxShadow(
          color: AppColors.neonPurple.withOpacity(0.12),
          blurRadius: 22,
          spreadRadius: 0,
        ),
      ],
      child: NeonButton(
        text: 'ENTER CUSTOM MATCH',
        icon: Icons.play_arrow_rounded,
        height: 58,
        onPressed: onPressed,
      ),
    );
  }

  Widget buildActivityFeed(BuildContext context, Box box, VoidCallback onViewAll) {
    final matches = box.values.toList().reversed.take(3).toList();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Activity Feed',
              style: GoogleFonts.spaceGrotesk(
                color: AppColors.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                'View All',
                style: GoogleFonts.outfit(
                  color: AppColors.neonPurple,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (matches.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                'No recent activity.',
                style: GoogleFonts.outfit(color: AppColors.mutedText),
              ),
            ),
          )
        else
          Column(
            children: matches.asMap().entries.map((entry) {
              final idx = entry.key;
              final m = entry.value;
              final record = MatchRecord.fromMap(m as Map<dynamic, dynamic>);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildActivityTile(
                  '${record.result} vs ${record.opponentPersona}',
                  '${record.topic} • ${_getTimeAgo(record.date)}',
                  record.result == 'Victory'
                      ? Icons.emoji_events
                      : (record.result == 'Draw' ? Icons.history : Icons.close),
                  record.result == 'Victory'
                      ? AppColors.victory
                      : (record.result == 'Draw' ? AppColors.draw : AppColors.defeat),
                  '${record.result == 'Victory' ? "+" : (record.result == 'Defeat' ? "-" : "")}${record.eloChange}',
                ).animate().fadeIn(duration: 400.ms, delay: (100 * idx).ms).slideX(begin: 0.1),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildActivityTile(String title, String subtitle, IconData icon, Color color, String eloChange,
      {double opacity = 1.0}) {
    return Opacity(
      opacity: opacity,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: AppColors.primaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      color: AppColors.mutedText,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  eloChange,
                  style: GoogleFonts.spaceGrotesk(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'ELO',
                  style: GoogleFonts.outfit(
                    color: AppColors.mutedText.withOpacity(0.5),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }
}

class _HomeDashboard extends StatelessWidget {
  final VoidCallback onViewAll;
  final VoidCallback onStartCustomMatch;
  final String dailyTopic;
  final String dailyPersona;
  final String dailyStance;
  final int dailyRounds;

  const _HomeDashboard({
    required this.onViewAll,
    required this.onStartCustomMatch,
    required this.dailyTopic,
    required this.dailyPersona,
    required this.dailyStance,
    required this.dailyRounds,
  });

  @override
  Widget build(BuildContext context) {
    final homeState = context.findAncestorStateOfType<_HomeScreenState>();
    if (homeState == null) return const SizedBox.shrink();

    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box('match_history').listenable(),
      builder: (context, box, _) {
        final matches = box.values.map((m) => MatchRecord.fromMap(m as Map<dynamic, dynamic>)).toList();

        // Calculations
        final int totalMatches = matches.length;
        final int totalWins = matches.where((m) => m.result == 'Victory').length;
        final String winRate = totalMatches == 0 ? '0%' : '${((totalWins / totalMatches) * 100).toInt()}%';

        int elo = 1000;
        int currentStreak = 0;

        // Elo calculation
        for (var m in matches) {
          elo += m.eloChange;
        }

        // Streak calculation (backwards)
        final reversedMatches = matches.reversed;
        for (var m in reversedMatches) {
          if (m.result == 'Victory') {
            currentStreak++;
          } else {
            break;
          }
        }

        return SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    homeState.buildTopBar(context),
                    const SizedBox(height: 32),
                    homeState.buildProfileHeader(context, elo: elo),
                    const SizedBox(height: 32),
                    homeState.buildPerformanceHub(winRate: winRate, streak: currentStreak),
                    const SizedBox(height: 32),
                    homeState.buildDailyChallenge(
                      context,
                      topic: dailyTopic,
                      persona: dailyPersona,
                      stance: dailyStance,
                      rounds: dailyRounds,
                    ),
                    const SizedBox(height: 32),
                    homeState.buildActivityFeed(context, box, onViewAll),
                    const SizedBox(height: 140),
                  ],
                ),
              ),
              Positioned(
                left: 24,
                right: 24,
                bottom: 8,
                child: homeState.buildStickyCustomMatchButton(
                  context,
                  onPressed: onStartCustomMatch,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ComingSoonScreen extends StatelessWidget {
  final String title;
  const ComingSoonScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$title COMING SOON',
        style: GoogleFonts.spaceGrotesk(
          color: AppColors.mutedText,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class SparklinePainter extends CustomPainter {
  final Color color;
  SparklinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    // A more natural looking sparkline
    path.moveTo(0, size.height * 0.7);
    path.cubicTo(
      size.width * 0.2, size.height * 0.8,
      size.width * 0.3, size.height * 0.4,
      size.width * 0.5, size.height * 0.6,
    );
    path.cubicTo(
      size.width * 0.7, size.height * 0.8,
      size.width * 0.8, size.height * 0.1,
      size.width, size.height * 0.3,
    );

    canvas.drawPath(path, paint);

    // Glow effect
    final glowPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawPath(path, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
