import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:math';
import '../../core/constants/app_colors.dart';
import '../../core/models/match_record.dart';
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
  late final List<Widget> _screens;

  // Daily Challenge Data
  String _dailyTopic = "";
  String _dailyPersona = "";
  String _dailyStance = "";

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
    _generateDailyChallenge();
    _screens = [
      _HomeDashboard(
        onViewAll: () => setState(() => _currentIndex = 2),
        dailyTopic: _dailyTopic,
        dailyPersona: _dailyPersona,
        dailyStance: _dailyStance,
      ),
      const LeaguesScreen(),
      const HistoryScreen(),
      const ProfileScreen(),
    ];
  }

  void _generateDailyChallenge() {
    final random = Random();
    _dailyTopic = _topics[random.nextInt(_topics.length)];
    _dailyPersona = _personas[random.nextInt(_personas.length)];
    _dailyStance = _stances[random.nextInt(_stances.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 24, left: 32, right: 32),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.9),
        border: const Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(Icons.home, 'HOME', index: 0),
          _buildNavItem(Icons.emoji_events_outlined, 'LEAGUES', index: 1),
          _buildNavItem(Icons.history, 'HISTORY', index: 2),
          _buildNavItem(Icons.person_outline, 'PROFILE', index: 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, {required int index}) {
    final bool isSelected = _currentIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.accent : AppColors.secondaryText,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.publicSans(
              color: isSelected ? AppColors.accent : AppColors.secondaryText,
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
          style: GoogleFonts.publicSans(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.accent,
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
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.gavel, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'DEBATEME',
              style: GoogleFonts.publicSans(
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
              icon: const Icon(Icons.notifications_none, color: AppColors.secondaryText),
              onPressed: () => _showComingSoon(context),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _showComingSoon(context),
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.surface,
                child: Icon(Icons.person, color: AppColors.secondaryText),
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
                    style: GoogleFonts.publicSans(
                      color: AppColors.primaryText,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Elo: $elo',
                      style: GoogleFonts.publicSans(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.circle, size: 4, color: AppColors.secondaryText),
                    const SizedBox(width: 8),
                    Text(
                      'Top 2% Globally',
                      style: GoogleFonts.publicSans(
                        color: AppColors.secondaryText,
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
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Text(
                  'Edit Profile',
                  style: GoogleFonts.publicSans(
                    color: AppColors.primaryText,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Edit Profile Name',
          style: GoogleFonts.publicSans(color: AppColors.primaryText, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: GoogleFonts.publicSans(color: AppColors.primaryText),
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: GoogleFonts.publicSans(color: AppColors.secondaryText),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.divider)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.accent)),
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
            child: Text('CANCEL', style: GoogleFonts.publicSans(color: AppColors.secondaryText)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Hive.box('user_settings').put('username', controller.text.trim());
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('SAVE', style: GoogleFonts.publicSans(fontWeight: FontWeight.bold)),
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
          style: GoogleFonts.publicSans(
            color: AppColors.secondaryText,
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
                color: Colors.greenAccent,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Active Streaks',
                streak.toString(),
                showGraph: true,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, {String trend = '', IconData icon = Icons.trending_up, Color color = AppColors.accent, bool showGraph = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.publicSans(
              color: AppColors.secondaryText,
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
                    style: GoogleFonts.publicSans(
                      color: AppColors.primaryText,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (trend.isNotEmpty)
                    Row(
                      children: [
                        Icon(icon, size: 14, color: Colors.greenAccent),
                        const SizedBox(width: 4),
                        Text(
                          trend,
                          style: GoogleFonts.publicSans(
                            color: Colors.greenAccent,
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

  Widget buildDailyChallenge(BuildContext context, {required String topic, required String persona, required String stance}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
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
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 12, color: AppColors.accent),
                    const SizedBox(width: 4),
                    Text(
                      'ENDS IN 04:22:15',
                      style: GoogleFonts.publicSans(
                        color: AppColors.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.bolt, color: AppColors.accent, size: 20),
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
                      style: GoogleFonts.publicSans(
                        color: AppColors.primaryText,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildChallengeLabel('STANCE'),
                    const SizedBox(height: 4),
                    Text(
                      'Defend $stance stance',
                      style: GoogleFonts.publicSans(
                        color: stance == "PRO" ? Colors.greenAccent : Colors.redAccent,
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
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.psychology, color: AppColors.accent, size: 24),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            persona.split(' ').last,
                            style: GoogleFonts.publicSans(
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
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ArenaScreen(
                      topic: topic,
                      userStance: '$stance-Debater',
                      opponentPersona: persona,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: AppColors.accent,
                side: const BorderSide(color: AppColors.accent, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'ACCEPT CHALLENGE',
                style: GoogleFonts.publicSans(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.publicSans(
        color: AppColors.secondaryText,
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
          style: GoogleFonts.publicSans(
            color: AppColors.secondaryText,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PreGameScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4800), // Vibrant Red-Orange
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, size: 24, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  'START CUSTOM MATCH',
                  style: GoogleFonts.publicSans(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
              style: GoogleFonts.publicSans(
                color: AppColors.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                'View All',
                style: GoogleFonts.publicSans(
                  color: AppColors.accent,
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
                style: GoogleFonts.publicSans(color: AppColors.secondaryText),
              ),
            ),
          )
        else
          Column(
            children: matches.map((m) {
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
                      ? Colors.green 
                      : (record.result == 'Draw' ? Colors.orange : Colors.redAccent),
                  '${record.result == 'Victory' ? "+" : (record.result == 'Defeat' ? "-" : "")}${record.eloChange}',
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildActivityTile(String title, String subtitle, IconData icon, Color color, String eloChange, {double opacity = 1.0}) {
    return Opacity(
      opacity: opacity,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
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
                    style: GoogleFonts.publicSans(
                      color: AppColors.primaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.publicSans(
                      color: AppColors.secondaryText,
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
                  style: GoogleFonts.publicSans(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'ELO',
                  style: GoogleFonts.publicSans(
                    color: AppColors.secondaryText.withOpacity(0.5),
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
  final String dailyTopic;
  final String dailyPersona;
  final String dailyStance;

  const _HomeDashboard({
    required this.onViewAll,
    required this.dailyTopic,
    required this.dailyPersona,
    required this.dailyStance,
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
          child: SingleChildScrollView(
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
                ),
                const SizedBox(height: 32),
                homeState.buildCustomMatchSection(context),
                const SizedBox(height: 32),
                homeState.buildActivityFeed(context, box, onViewAll),
                const SizedBox(height: 100), // Space for bottom nav
              ],
            ),
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
        style: GoogleFonts.publicSans(
          color: AppColors.secondaryText,
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
