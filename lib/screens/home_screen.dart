import 'package:flutter/material.dart';
import '../data/sample_lessons.dart';
import '../models/lesson.dart';
import '../theme/neumorphic.dart';
import '../widgets/lesson_card.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCourse = 'Semua';

  List<String> get _courses {
    final courses = sampleLessons.map((l) => l.course).toSet().toList();
    courses.insert(0, 'Semua');
    return courses;
  }

  List<Lesson> get _lessons {
    if (_selectedCourse == 'Semua') return sampleLessons;
    return sampleLessons.where((l) => l.course == _selectedCourse).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Reflections',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Shaikh Abdurrahman Umar Bagarawa',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ClipOval(
                    child: Image.asset(
                      'assets/images/scholar_bagarawa.png',
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const NeumorphicCircleButton(
                          icon: Icons.person_outline,
                          size: 48,
                          iconSize: 22,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Course filter chips - horizontal scrollable
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _courses.length,
                itemBuilder: (context, index) {
                  final course = _courses[index];
                  final selected = _selectedCourse == course;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCourse = course),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: AppColors.shadowDark.withOpacity(0.5),
                                    offset: const Offset(3, 3),
                                    blurRadius: 8,
                                  ),
                                  const BoxShadow(
                                    color: AppColors.shadowLight,
                                    offset: Offset(-3, -3),
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          course,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            color: selected ? AppColors.accent : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Lessons count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    '${_lessons.length} Pelajaran',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Lessons list
            Expanded(
              child: _lessons.isEmpty
                  ? const Center(
                      child: Text('Tidak ada pelajaran.',
                          style: TextStyle(color: AppColors.textSecondary)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 24),
                      itemCount: _lessons.length,
                      itemBuilder: (context, index) {
                        final lesson = _lessons[index];
                        return LessonCard(
                          lesson: lesson,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => PlayerScreen(lesson: lesson)),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
