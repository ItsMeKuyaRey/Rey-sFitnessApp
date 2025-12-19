// FIXED: COUNTDOWN AUDIO NOW WORKS PERFECTLY!
import 'dart:async';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

class WorkoutPlayerScreen extends StatefulWidget {
  final Map<String, dynamic> workout;
  const WorkoutPlayerScreen({super.key, required this.workout});

  @override
  State<WorkoutPlayerScreen> createState() => _WorkoutPlayerScreenState();
}

bool _isNetworkVideo(String path) {
  return path.startsWith('http://') || path.startsWith('https://');
}

class _WorkoutPlayerScreenState extends State<WorkoutPlayerScreen> {
  late AudioPlayer _musicPlayer;
  late AudioPlayer _countdownPlayer;
  late ConfettiController _confettiController;
  VideoPlayerController? _videoController;
  int currentExerciseIndex = 0;
  bool isPaused = false;
  bool isCountdown = false;
  int countdown = 3;
  Timer? _timer;
  int remainingTime = 0;
  bool isVideoLoaded = false;
  bool isLoadingVideo = false;

  @override
  void initState() {
    super.initState();
    _initPlayers();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _startWorkout();
  }

  void _initPlayers() {
    _musicPlayer = AudioPlayer();
    _countdownPlayer = AudioPlayer();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));

    // Load background music
    _musicPlayer.setUrl('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3').then((_) {
      _musicPlayer.setLoopMode(LoopMode.one);
      _musicPlayer.play();
    }).catchError((e) {
      print("Music error: $e");
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _videoController?.pause();
    _videoController?.dispose();
    _musicPlayer.dispose();
    _countdownPlayer.dispose();
    _confettiController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  Future<void> _initVideoController(String videoPath, {required bool isAsset}) async {
    if (!mounted) return;

    setState(() {
      isLoadingVideo = true;
      isVideoLoaded = false;
    });

    // Dispose previous controller
    await _videoController?.pause();
    await _videoController?.dispose();
    _videoController = null;

    try {
      print("🎥 Loading video: $videoPath (isAsset: $isAsset)");

      _videoController = isAsset
          ? VideoPlayerController.asset(videoPath)
          : VideoPlayerController.networkUrl(Uri.parse(videoPath));

      await _videoController!.initialize();

      if (mounted) {
        _videoController!
          ..setLooping(true)
          ..setVolume(0) // Mute video so it doesn't interfere with music
          ..play();

        setState(() {
          isVideoLoaded = true;
          isLoadingVideo = false;
        });
        print("✅ Video loaded successfully!");
      }
    } catch (e) {
      print("❌ Video error for $videoPath: $e");
      if (mounted) {
        setState(() {
          isVideoLoaded = false;
          isLoadingVideo = false;
        });
      }
    }
  }

  void _startWorkout() {
    if (currentExerciseIndex < widget.workout['exercises'].length) {
      _startCountdown();
    } else {
      _endWorkout();
    }
  }

  void _startCountdown() async {
    setState(() {
      isCountdown = true;
      isVideoLoaded = false;
    });

    // PRELOAD the countdown sound first (don't play yet)
    try {
      print("🔊 Preloading countdown sound...");
      await _countdownPlayer.stop();
      await _countdownPlayer.setAsset('assets/sounds/mariostart.mp3');
      await _countdownPlayer.setVolume(1.0);
      print("✅ Countdown sound ready!");
    } catch (e) {
      print("❌ Countdown sound error: $e");
    }

    // SYNCHRONIZED countdown animation and sound
    countdown = 3;

    // Start playing sound RIGHT when we show "3"
    _countdownPlayer.play().catchError((e) => print("Play error: $e"));

    // Show 3, 2, 1
    for (int i = 3; i > 0; i--) {
      if (!mounted) return;
      setState(() => countdown = i);
      HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(seconds: 1));
    }

    // Show GO!
    if (!mounted) return;
    setState(() => countdown = 0);
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    setState(() => isCountdown = false);

    // Load video for current exercise
    final exercise = widget.workout['exercises'][currentExerciseIndex];
    if (exercise['animationType'] == 'video') {
      final String videoPath = exercise['animation'];
      await _initVideoController(
        videoPath,
        isAsset: !_isNetworkVideo(videoPath),
      );
    }

    _startExercise();
  }

  void _startExercise() {
    final exercise = widget.workout['exercises'][currentExerciseIndex];

    // Calculate remaining time
    if (exercise['duration'] != null) {
      remainingTime = exercise['duration'];
    } else if (exercise['hold'] != null) {
      remainingTime = exercise['hold'];
    } else {
      remainingTime = (exercise['reps'] as int) * 4;
    }

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (isPaused) return;

      if (remainingTime > 0) {
        setState(() => remainingTime--);
      } else {
        timer.cancel();
        HapticFeedback.mediumImpact();
        currentExerciseIndex++;

        if (currentExerciseIndex < widget.workout['exercises'].length) {
          _startWorkout();
        } else {
          _endWorkout();
        }
      }
    });
  }

  void _togglePause() {
    setState(() => isPaused = !isPaused);
    if (isPaused) {
      _musicPlayer.pause().catchError((e) {});
      _videoController?.pause();
    } else {
      _musicPlayer.play().catchError((e) {});
      _videoController?.play();
    }
  }

  void _endWorkout() {
    _musicPlayer.stop();
    _videoController?.pause();
    _videoController?.dispose();
    _confettiController.play();

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "🎉 Workout Complete!",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Amazing job! You crushed it!",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text(
              "Done",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (isLoadingVideo) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                "Loading video...",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    if (isVideoLoaded && _videoController != null && _videoController!.value.isInitialized) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),
        ),
      );
    }

    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Icon(Icons.fitness_center, size: 80, color: Colors.white38),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exercise = currentExerciseIndex < widget.workout['exercises'].length
        ? widget.workout['exercises'][currentExerciseIndex]
        : null;
    final bool isRepBased = exercise?['reps'] != null;
    final int currentRep = isRepBased ? ((exercise!['reps'] as int) * 4 - remainingTime) ~/ 4 + 1 : 0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF6A1B9A), Color(0xFF1A1A1A)],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          widget.workout['title'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isPaused ? Icons.play_arrow : Icons.pause,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: _togglePause,
                      ),
                    ],
                  ),
                ),

                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: currentExerciseIndex / widget.workout['exercises'].length,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      color: const Color(0xFFFF6B35),
                      minHeight: 8,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Exercise Name
                if (exercise != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      exercise['name'],
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 20),

                // Rep/Time Counter
                if (exercise != null && !isCountdown)
                  Text(
                    isRepBased ? "Rep $currentRep of ${exercise['reps']}" : "${remainingTime}s",
                    style: TextStyle(
                      fontSize: isRepBased ? 52 : 72,
                      fontWeight: FontWeight.bold,
                      color: isRepBased ? const Color(0xFFFF6B35) : const Color(0xFF00E676),
                      shadows: const [
                        Shadow(
                          color: Colors.black87,
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        )
                      ],
                    ),
                  ),

                const SizedBox(height: 30),

                // Main Content Area - Video or Countdown
                Expanded(
                  child: Center(
                    child: isCountdown
                        ? AnimatedScale(
                      scale: countdown > 0 ? 2.0 : 1.5,
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        countdown == 0 ? "GO!" : "$countdown",
                        style: TextStyle(
                          fontSize: countdown == 0 ? 120 : 180,
                          fontWeight: FontWeight.w900,
                          color: countdown == 0 ? const Color(0xFF00E676) : Colors.white,
                          shadows: const [
                            Shadow(
                              color: Colors.black87,
                              blurRadius: 30,
                              offset: Offset(0, 10),
                            )
                          ],
                        ),
                      ),
                    )
                        : (exercise != null && exercise['animationType'] == 'video')
                        ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildVideoPlayer(),
                    )
                        : const Text(
                      "Workout Complete! 🎉",
                      style: TextStyle(
                        fontSize: 36,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Set Indicators (for rep-based exercises)
                if (exercise != null && isRepBased)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        exercise['sets'],
                            (i) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i == 0 ? const Color(0xFFFF6B35) : Colors.white38,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Next Exercise Button
                if (!isCountdown && exercise != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        _timer?.cancel();
                        currentExerciseIndex++;
                        _startWorkout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                        shadowColor: const Color(0xFFFF6B35).withOpacity(0.5),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Next Exercise",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.arrow_forward, size: 24),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.purple,
                Colors.pink,
                Colors.cyan,
                Colors.orange,
                Colors.green
              ],
              numberOfParticles: 30,
            ),
          ),
        ],
      ),
    );
  }
}