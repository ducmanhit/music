import 'dart:ui';
import 'package:flutter/material.dart';

class NowPlayingScreen extends StatelessWidget {
  final String coverUrl;
  final String songTitle;
  final String artistName;

  const NowPlayingScreen({
    Key? key,
    required this.coverUrl,
    required this.songTitle,
    required this.artistName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Cố định màn hình tuyệt đối, khắc phục lỗi trượt
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Lớp nền lấy từ ảnh bìa
          Image.network(
            coverUrl,
            fit: BoxFit.cover,
          ),
          
          // 2. Lớp Glassmorphism màu Titanium/Monochromatic (Không dùng gradient)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
            child: Container(
              color: const Color(0xFF1C1C1E).withOpacity(0.7), // Tone Titanium
            ),
          ),

          // 3. Nội dung chính
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Nút thu nhỏ màn hình
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 32),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Ảnh bìa với Hero Animation và Soft Drop Shadow
                  Hero(
                    tag: 'artwork',
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                        image: DecorationImage(
                          image: NetworkImage(coverUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Tiêu đề & Ca sĩ
                  Text(
                    songTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    artistName,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 16,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Thanh trượt (Slider) mỏng, tinh tế
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 2.0,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white.withOpacity(0.3),
                      thumbColor: Colors.white,
                    ),
                    child: Slider(
                      value: 0.3, // Demo value
                      onChanged: (val) {},
                    ),
                  ),
                  
                  // Cụm nút điều khiển nét mảnh
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous_outlined, color: Colors.white, size: 36),
                        onPressed: () {},
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 48),
                          onPressed: () {},
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next_outlined, color: Colors.white, size: 36),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  
                  const Spacer(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
