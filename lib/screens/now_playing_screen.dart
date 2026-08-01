import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../widgets/waveform_seek_bar.dart'; 

class NowPlayingScreen extends StatelessWidget {
  final dynamic playerController; 

  const NowPlayingScreen({Key? key, required this.playerController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentSong = playerController.currentSong;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Now Playing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.queue_music_rounded, size: 22),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: double.infinity,
                aspectRatio: 1.0,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.surfaceBorder, width: 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: currentSong?.artworkUrl != null
                      ? Image.network(currentSong.artworkUrl, fit: BoxFit.cover)
                      : const Icon(Icons.music_note_rounded, size: 80, color: AppColors.textMuted),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite_border_rounded, color: AppColors.textSecondary),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          currentSong?.title ?? 'Unsayable',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          currentSong?.artist ?? 'Brambles',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz_rounded, color: AppColors.textSecondary),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const WaveformSeekBar(), 
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shuffle_rounded, color: AppColors.textMuted, size: 22),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_previous_rounded, color: AppColors.textPrimary, size: 32),
                    onPressed: playerController.previous,
                  ),
                  GestureDetector(
                    onTap: playerController.togglePlay,
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        playerController.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: AppColors.primaryDark,
                        size: 34,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next_rounded, color: AppColors.textPrimary, size: 32),
                    onPressed: playerController.next,
                  ),
                  IconButton(
                    icon: const Icon(Icons.repeat_rounded, color: AppColors.textMuted, size: 22),
                    onPressed: () {},
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
