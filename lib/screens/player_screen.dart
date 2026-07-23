import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../data/sample_lessons.dart';
import '../models/lesson.dart';
import '../services/ads_service.dart';
import '../theme/neumorphic.dart';

class PlayerScreen extends StatefulWidget {
  final Lesson lesson;
  const PlayerScreen({super.key, required this.lesson});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final _player = AudioPlayer();
  bool _hasShownCompletionPrompt = false;
  late List<Lesson> _courseLessons;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _courseLessons = sampleLessons.where((l) => l.course == widget.lesson.course).toList();
    _currentIndex = _courseLessons.indexWhere((l) => l.id == widget.lesson.id);
    if (_currentIndex == -1) _currentIndex = 0;
    _load();

    // Detect natural completion to trigger the reflection prompt.
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed &&
          !_hasShownCompletionPrompt) {
        _hasShownCompletionPrompt = true;
        _onLessonFinished();
      }
    });
  }

  Future<void> _load() async {
    try {
      await _player.setAsset(widget.lesson.audioAssetPath);
      await _player.play();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load audio: $e')),
        );
      }
    }
  }

  void _playLesson(Lesson lesson) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => PlayerScreen(lesson: lesson)),
    );
  }

  void _playNext() {
    if (_currentIndex < _courseLessons.length - 1) {
      _playLesson(_courseLessons[_currentIndex + 1]);
    }
  }

  void _playPrevious() {
    if (_currentIndex > 0) {
      _playLesson(_courseLessons[_currentIndex - 1]);
    } else {
      _player.seek(Duration.zero);
    }
  }

  Future<void> _onLessonFinished() async {
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.background,
        title: const Text('One thing to carry with you',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const TextField(
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Optional — jot down one takeaway...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Skip'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.accent),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    // Natural break point only — never during playback. Silently does
    // nothing if no ad has finished preloading in the background yet.
    await AdsService.instance.showInterstitialIfReady();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Column(
            children: [
              // Top row: music icon (left) + share icon (right)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  NeumorphicCircleButton(
                    icon: Icons.music_note_outlined,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  NeumorphicCircleButton(
                    icon: Icons.share_outlined,
                    onTap: () {
                      // Hook up share_plus here if you want real sharing.
                    },
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Circular artwork
              Neumorphic(
                width: 220,
                height: 220,
                borderRadius: 110,
                style: NeuStyle.raised,
                intensity: 1.3,
                child: Center(
                  child: lesson.arabicLabel != null
                      ? Text(
                          lesson.arabicLabel!,
                          style: const TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                          ),
                        )
                      : Icon(Icons.menu_book_outlined,
                          size: 72, color: AppColors.accent),
                ),
              ),

              const SizedBox(height: 32),

              // Scholar photo + Title + Course + Subtitle
              Column(
                children: [
                  if (lesson.scholarPhotoPath != null)
                    ClipOval(
                      child: Image.asset(
                        lesson.scholarPhotoPath!,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person, color: AppColors.accent, size: 32),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    lesson.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  if (lesson.course.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        lesson.course,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    'Ustadz : ${lesson.scholarName}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              const Spacer(),

              // Progress bar - pressed/carved track with raised green fill
              StreamBuilder<Duration?>(
                stream: _player.durationStream,
                builder: (context, snapshot) {
                  final duration = snapshot.data ?? lesson.duration;
                  return StreamBuilder<Duration>(
                    stream: _player.positionStream,
                    builder: (context, posSnapshot) {
                      final position = posSnapshot.data ?? Duration.zero;
                      final totalMs =
                          duration.inMilliseconds.clamp(1, double.infinity).toInt();
                      final fraction =
                          (position.inMilliseconds / totalMs).clamp(0.0, 1.0);

                      return Column(
                        children: [
                          GestureDetector(
                            onTapDown: (details) {
                              final box = context.findRenderObject() as RenderBox;
                              final localX =
                                  box.globalToLocal(details.globalPosition).dx;
                              final ratio =
                                  (localX / box.size.width).clamp(0.0, 1.0);
                              _player.seek(
                                  Duration(milliseconds: (totalMs * ratio).toInt()));
                            },
                            child: Neumorphic(
                              height: 20,
                              borderRadius: 12,
                              style: NeuStyle.pressed,
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: fraction,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.accent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatDuration(position),
                                  style: const TextStyle(
                                      color: AppColors.textSecondary, fontSize: 12)),
                              Text(_formatDuration(duration),
                                  style: const TextStyle(
                                      color: AppColors.textSecondary, fontSize: 12)),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 28),

              // Transport controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  NeumorphicCircleButton(
                    icon: Icons.skip_previous_rounded,
                    size: 64,
                    iconSize: 28,
                    onTap: _playPrevious,
                  ),
                  StreamBuilder<PlayerState>(
                    stream: _player.playerStateStream,
                    builder: (context, snapshot) {
                      final playing = snapshot.data?.playing ?? false;
                      return NeumorphicCircleButton(
                        icon: playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 84,
                        iconSize: 40,
                        onTap: () => playing ? _player.pause() : _player.play(),
                      );
                    },
                  ),
                  NeumorphicCircleButton(
                    icon: Icons.skip_next_rounded,
                    size: 64,
                    iconSize: 28,
                    onTap: _currentIndex < _courseLessons.length - 1 ? _playNext : null,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Track position indicator
              Text(
                '${_currentIndex + 1} / ${_courseLessons.length}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),

              // Watermark / attribution chip
              Neumorphic(
                borderRadius: 20,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Text(
                  'Created by : your_app_name',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
