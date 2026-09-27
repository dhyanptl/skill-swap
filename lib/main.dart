import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/sample_data.dart';
import 'models/skill.dart';
import 'models/student.dart';

void main() {
  runApp(const SkillSwapApp());
}

const List<String> profileSkillOptions = [
  'Flutter',
  'Dart',
  'JavaScript',
  'Web Development',
  'n8n Agentic Automation',
  'Claude Ecosystem',
  'UI/UX Design',
  'Python',
  'Photography',
  'AI Agents',
];

class SkillSwapApp extends StatelessWidget {
  const SkillSwapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SkillSwap',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF5F5F3),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF171717),
          onPrimary: Colors.white,
          surface: Color(0xFFF5F5F3),
          onSurface: Color(0xFF171717),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFFF9F9F7),
          indicatorColor: const Color(0xFFE6E6E3),
          elevation: 0,
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4A4A4A),
            ),
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const String _nameKey = 'profile_name';
  static const String _teachKey = 'profile_teach';
  static const String _learnKey = 'profile_learn';
  static const String _requestsKey = 'swap_requests';

  int _selectedIndex = 0;
  Skill? _selectedSkill;
  Student? _selectedStudent;
  bool _editingProfile = false;
  bool _loading = true;

  String _profileName = 'Dhyan Patel';

  List<String> _myTeach = [
    'Flutter',
    'Dart',
    'JavaScript',
    'n8n Agentic Automation',
  ];

  List<String> _myLearn = ['Claude Ecosystem', 'AI Agents'];

  List<String> _requests = [];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _profileName = prefs.getString(_nameKey) ?? 'Dhyan Patel';

      _myTeach =
          prefs.getStringList(_teachKey) ??
          ['Flutter', 'Dart', 'JavaScript', 'n8n Agentic Automation'];

      _myLearn =
          prefs.getStringList(_learnKey) ?? ['Claude Ecosystem', 'AI Agents'];

      _requests = prefs.getStringList(_requestsKey) ?? [];
      _loading = false;
    });
  }

  Future<void> _saveProfile(
    String name,
    List<String> teach,
    List<String> learn,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_nameKey, name);
    await prefs.setStringList(_teachKey, teach);
    await prefs.setStringList(_learnKey, learn);

    if (!mounted) return;

    setState(() {
      _profileName = name;
      _myTeach = List.from(teach);
      _myLearn = List.from(learn);
      _editingProfile = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile saved'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _sendRequest(Student student) async {
    if (_requests.contains(student.name)) {
      return;
    }

    final updatedRequests = [..._requests, student.name];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_requestsKey, updatedRequests);

    if (!mounted) return;

    setState(() {
      _requests = updatedRequests;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Skill swap request sent to ${student.name}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openSkill(Skill skill) {
    setState(() {
      _selectedSkill = skill;
      _selectedStudent = null;
      _editingProfile = false;
    });
  }

  void _openStudent(Student student) {
    setState(() {
      _selectedStudent = student;
    });
  }

  void _closeStudent() {
    setState(() {
      _selectedStudent = null;
    });
  }

  void _closeSkill() {
    setState(() {
      _selectedSkill = null;
      _selectedStudent = null;
    });
  }

  void _openEditProfile() {
    setState(() {
      _editingProfile = true;
      _selectedSkill = null;
      _selectedStudent = null;
    });
  }

  void _closeEditProfile() {
    setState(() {
      _editingProfile = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Material(child: Center(child: CircularProgressIndicator()));
    }

    Widget body;

    if (_editingProfile) {
      body = EditProfileScreen(
        name: _profileName,
        teachSkills: _myTeach,
        learnSkills: _myLearn,
        onBack: _closeEditProfile,
        onSave: _saveProfile,
      );
    } else if (_selectedStudent != null) {
      body = StudentDetailsScreen(
        student: _selectedStudent!,
        requestSent: _requests.contains(_selectedStudent!.name),
        onBack: _closeStudent,
        onRequest: () => _sendRequest(_selectedStudent!),
      );
    } else if (_selectedSkill != null) {
      body = SkillStudentsScreen(
        skill: _selectedSkill!,
        onBack: _closeSkill,
        onStudentTap: _openStudent,
      );
    } else if (_selectedIndex == 0) {
      body = HomeScreen(onSkillTap: _openSkill);
    } else {
      body = ProfileScreen(
        name: _profileName,
        teachSkills: _myTeach,
        learnSkills: _myLearn,
        requests: _requests,
        onEdit: _openEditProfile,
      );
    }

    final showNavigation =
        _selectedSkill == null && _selectedStudent == null && !_editingProfile;

    return Scaffold(
      body: body,
      bottomNavigationBar: showNavigation
          ? NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.explore_outlined),
                  selectedIcon: Icon(Icons.explore),
                  label: 'Explore',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            )
          : null,
    );
  }
}

class HomeScreen extends StatefulWidget {
  final Function(Skill) onSkillTap;

  const HomeScreen({super.key, required this.onSkillTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Skill> get filteredSkills {
    final query = _query.trim().toLowerCase();

    if (query.isEmpty) {
      return skills;
    }

    return skills.where((skill) {
      return skill.name.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8F8F6), Color(0xFFF1F1EF)],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SkillSwap',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: Color(0xFF151515),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Learn something. Teach something.',
                    style: TextStyle(fontSize: 16, color: Color(0xFF777777)),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _query = value;
                      });
                    },
                    style: const TextStyle(color: Color(0xFF1A1A1A)),
                    cursorColor: const Color(0xFF171717),
                    decoration: InputDecoration(
                      hintText: 'Search for a skill...',
                      hintStyle: const TextStyle(color: Color(0xFF969696)),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF767676),
                      ),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _query = '';
                                });
                              },
                              icon: const Icon(
                                Icons.close,
                                color: Color(0xFF767676),
                              ),
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFE4E4E1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFE4E4E1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFF6C6C6C),
                          width: 1.2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2A2A2A), Color(0xFF101010)],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x18000000),
                          blurRadius: 18,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.10),
                            ),
                          ),
                          child: const Icon(
                            Icons.swap_horiz_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 18),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Exchange Skills',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Find students who can teach what you want to learn.',
                                style: TextStyle(
                                  color: Color(0xFFBDBDBD),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Color(0xFFD0D0D0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    _query.isEmpty ? 'Popular Skills' : 'Search Results',
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF171717),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _query.isEmpty
                        ? 'Explore skills students are sharing'
                        : '${filteredSkills.length} matching ${filteredSkills.length == 1 ? 'skill' : 'skills'}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF808080),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (filteredSkills.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 40,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE2E2DF)),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 36,
                            color: Color(0xFF888888),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No skills found',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333),
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Try searching for another skill.',
                            style: TextStyle(color: Color(0xFF888888)),
                          ),
                        ],
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredSkills.length,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 320,
                            mainAxisExtent: 125,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                          ),
                      itemBuilder: (context, index) {
                        final skill = filteredSkills[index];

                        final studentCount = students
                            .where(
                              (student) =>
                                  student.canTeach.contains(skill.name),
                            )
                            .length;

                        return SkillPreviewCard(
                          skill: skill,
                          users:
                              '$studentCount ${studentCount == 1 ? 'student' : 'students'}',
                          index: index,
                          onTap: () => widget.onSkillTap(skill),
                        );
                      },
                    ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE4E4E1)),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          color: Color(0xFF3B3B3B),
                          size: 28,
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Have a skill to share?',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Color(0xFF202020),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Add your skills to your profile and help another student learn.',
                                style: TextStyle(
                                  color: Color(0xFF858585),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Color(0xFF777777),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SkillPreviewCard extends StatelessWidget {
  final Skill skill;
  final String users;
  final int index;
  final VoidCallback onTap;

  const SkillPreviewCard({
    super.key,
    required this.skill,
    required this.users,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 250 + (index * 60)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFF1F1EF)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E2DF)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF333333), Color(0xFF111111)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(skill.icon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          skill.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF202020),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          users,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF808080),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Color(0xFF8A8A8A),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SkillStudentsScreen extends StatelessWidget {
  final Skill skill;
  final VoidCallback onBack;
  final Function(Student) onStudentTap;

  const SkillStudentsScreen({
    super.key,
    required this.skill,
    required this.onBack,
    required this.onStudentTap,
  });

  List<Student> get matchingStudents {
    return students
        .where((student) => student.canTeach.contains(skill.name))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8F8F6), Color(0xFFF1F1EF)],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: onBack,
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back),
                          SizedBox(width: 8),
                          Text('Back'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    skill.name,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF171717),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${matchingStudents.length} ${matchingStudents.length == 1 ? 'student' : 'students'} can teach ${skill.name}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF7A7A7A),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (matchingStudents.isEmpty)
                    const Text(
                      'No students found.',
                      style: TextStyle(fontSize: 16, color: Color(0xFF777777)),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: matchingStudents.length,
                      separatorBuilder: (_, _) {
                        return const SizedBox(height: 14);
                      },
                      itemBuilder: (context, index) {
                        final student = matchingStudents[index];

                        return StudentCard(
                          student: student,
                          onTap: () => onStudentTap(student),
                          index: index,
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback onTap;
  final int index;

  const StudentCard({
    super.key,
    required this.student,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 250 + (index * 70)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E2DF)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF333333), Color(0xFF111111)],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      student.name.substring(0, 1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF202020),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        student.level,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7A7A7A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: student.canTeach.map((skill) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F0EE),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              skill,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF555555),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Color(0xFF888888),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StudentDetailsScreen extends StatelessWidget {
  final Student student;
  final bool requestSent;
  final VoidCallback onBack;
  final Future<void> Function() onRequest;

  const StudentDetailsScreen({
    super.key,
    required this.student,
    required this.requestSent,
    required this.onBack,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8F8F6), Color(0xFFF1F1EF)],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: onBack,
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back),
                          SizedBox(width: 8),
                          Text('Back'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2A2A2A), Color(0xFF101010)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 82,
                              height: 82,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.14),
                                ),
                              ),
                            ),
                            Text(
                              student.name.substring(0, 1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          student.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          student.level,
                          style: const TextStyle(
                            color: Color(0xFFBDBDBD),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ProfileSection(
                    title: 'Skills I Can Teach',
                    skills: student.canTeach,
                  ),
                  const SizedBox(height: 14),
                  ProfileSection(
                    title: 'Skills I Want to Learn',
                    skills: student.wantsToLearn,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: requestSent
                          ? null
                          : () async {
                              await onRequest();
                            },
                      icon: Icon(
                        requestSent
                            ? Icons.check_rounded
                            : Icons.swap_horiz_rounded,
                      ),
                      label: Text(
                        requestSent ? 'Request Sent' : 'Request Skill Swap',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF171717),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFE4E4E1),
                        disabledForegroundColor: const Color(0xFF777777),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileSection extends StatelessWidget {
  final String title;
  final List<String> skills;

  const ProfileSection({super.key, required this.title, required this.skills});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E2DF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFF202020),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills.map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0EE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  skill,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF555555),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  final String name;
  final List<String> teachSkills;
  final List<String> learnSkills;
  final List<String> requests;
  final VoidCallback onEdit;

  const ProfileScreen({
    super.key,
    required this.name,
    required this.teachSkills,
    required this.learnSkills,
    required this.requests,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8F8F6), Color(0xFFF1F1EF)],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFD5D5D2),
                            width: 2,
                          ),
                        ),
                        child: const CircleAvatar(
                          radius: 42,
                          backgroundColor: Color(0xFF242424),
                          child: Icon(
                            Icons.person,
                            color: Color(0xFFD9D9D9),
                            size: 42,
                          ),
                        ),
                      ),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            onTap: onEdit,
                            borderRadius: BorderRadius.circular(20),
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.edit_outlined,
                                size: 17,
                                color: Color(0xFF3D3D3D),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF171717),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Student',
                    style: TextStyle(color: Color(0xFF858585)),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit Profile'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ProfileSection(
                    title: 'Skills I Can Teach',
                    skills: teachSkills,
                  ),
                  const SizedBox(height: 16),
                  ProfileSection(
                    title: 'Skills I Want to Learn',
                    skills: learnSkills,
                  ),
                  const SizedBox(height: 16),
                  _RequestsCard(requests: requests),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RequestsCard extends StatelessWidget {
  final List<String> requests;

  const _RequestsCard({required this.requests});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E2DF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.swap_horiz_rounded,
                size: 21,
                color: Color(0xFF444444),
              ),
              SizedBox(width: 8),
              Text(
                'My Requests',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF202020),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (requests.isEmpty)
            const Text(
              'No skill swap requests yet.',
              style: TextStyle(color: Color(0xFF858585), fontSize: 14),
            )
          else
            Column(
              children: requests.map((request) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 20,
                        color: Color(0xFF555555),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Request sent to $request',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF555555),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  final String name;
  final List<String> teachSkills;
  final List<String> learnSkills;
  final VoidCallback onBack;
  final Future<void> Function(
    String name,
    List<String> teach,
    List<String> learn,
  )
  onSave;

  const EditProfileScreen({
    super.key,
    required this.name,
    required this.teachSkills,
    required this.learnSkills,
    required this.onBack,
    required this.onSave,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late List<String> _teachSkills;
  late List<String> _learnSkills;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _teachSkills = List.from(widget.teachSkills);
    _learnSkills = List.from(widget.learnSkills);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _toggleSkill(String skill, bool selected, List<String> target) {
    setState(() {
      if (selected) {
        if (!target.contains(skill)) {
          target.add(skill);
        }
      } else {
        target.remove(skill);
      }
    });
  }

  Future<void> _addCustomSkill(bool teach) async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(teach ? 'Add teaching skill' : 'Add learning skill'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter skill name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final value = controller.text.trim();

                if (value.isNotEmpty) {
                  Navigator.pop(context, value);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result == null || result.trim().isEmpty) return;

    setState(() {
      final target = teach ? _teachSkills : _learnSkills;

      if (!target.contains(result.trim())) {
        target.add(result.trim());
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await widget.onSave(
      _nameController.text.trim(),
      _teachSkills,
      _learnSkills,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8F8F6), Color(0xFFF1F1EF)],
        ),
      ),
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: widget.onBack,
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_back),
                            SizedBox(width: 8),
                            Text('Back'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF171717),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Update your skills and learning interests.',
                      style: TextStyle(color: Color(0xFF7A7A7A), fontSize: 15),
                    ),
                    const SizedBox(height: 26),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        prefixIcon: const Icon(Icons.person_outline),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 28),
                    _SkillEditorSection(
                      title: 'Skills I Can Teach',
                      selectedSkills: _teachSkills,
                      onToggle: (skill, selected) {
                        _toggleSkill(skill, selected, _teachSkills);
                      },
                      onAdd: () => _addCustomSkill(true),
                    ),
                    const SizedBox(height: 24),
                    _SkillEditorSection(
                      title: 'Skills I Want to Learn',
                      selectedSkills: _learnSkills,
                      onToggle: (skill, selected) {
                        _toggleSkill(skill, selected, _learnSkills);
                      },
                      onAdd: () => _addCustomSkill(false),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: _save,
                        icon: const Icon(Icons.check_rounded),
                        label: const Text(
                          'Save Profile',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF171717),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SkillEditorSection extends StatelessWidget {
  final String title;
  final List<String> selectedSkills;
  final Function(String skill, bool selected) onToggle;
  final VoidCallback onAdd;

  const _SkillEditorSection({
    required this.title,
    required this.selectedSkills,
    required this.onToggle,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final options = {...profileSkillOptions, ...selectedSkills}.toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E2DF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF202020),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Select the skills that apply.',
            style: TextStyle(fontSize: 13, color: Color(0xFF858585)),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((skill) {
              return FilterChip(
                label: Text(skill),
                selected: selectedSkills.contains(skill),
                onSelected: (selected) {
                  onToggle(skill, selected);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add another skill'),
          ),
        ],
      ),
    );
  }
}
