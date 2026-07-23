import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../theme/neumorphic.dart';

class LessonCard extends StatelessWidget {
  final Lesson lesson;
  final VoidCallback onTap;

  const LessonCard({super.key, required this.lesson, required this.onTap});

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  IconData get _timeIcon {
    switch (lesson.timeOfDay) {
      case LessonTime.morning:
        return Icons.wb_sunny_outlined;
      case LessonTime.night:
        return Icons.nightlight_outlined;
      case LessonTime.any:
        return Icons.headphones_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Neumorphic(
          borderRadius: 20,
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Neumorphic(
                width: 52,
                height: 52,
                borderRadius: 26,
                child: lesson.scholarPhotoPath != null
                    ? ClipOval(
                        child: Image.asset(
                          lesson.scholarPhotoPath!,
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return lesson.arabicLabel != null
                                ? Center(
                                    child: Text(
                                      lesson.arabicLabel!,
                                      style: const TextStyle(
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  )
                                : Icon(_timeIcon, color: AppColors.accent);
                          },
                        ),
                      )
                    : lesson.arabicLabel != null
                        ? Center(
                            child: Text(
                              lesson.arabicLabel!,
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          )
                        : Icon(_timeIcon, color: AppColors.accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lesson.course.isNotEmpty ? lesson.course : lesson.scholarName,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_formatDuration(lesson.duration)}',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              NeumorphicCircleButton(
                icon: Icons.play_arrow_rounded,
                size: 44,
                iconSize: 22,
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
