import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/wifi_transfer_service.dart';
import '../utils/app_theme.dart';

class WifiTransferScreen extends StatelessWidget {
  const WifiTransferScreen({super.key, required this.service});

  final WifiTransferService service;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Truyền nhạc qua Wi‑Fi')),
      body: AnimatedBuilder(
        animation: service,
        builder: (context, _) {
          final url = service.url;
          return ListView(
            padding: const EdgeInsets.all(22),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.line),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(
                      service.isRunning ? Icons.wifi_tethering_rounded : Icons.wifi_off_rounded,
                      color: service.isRunning ? AppColors.accent : AppColors.muted,
                      size: 54,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      service.isRunning ? 'Máy chủ đang hoạt động' : 'Máy chủ đang tắt',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Kết nối iPhone và máy tính vào cùng một mạng Wi‑Fi. Sau đó mở địa chỉ bên dưới bằng trình duyệt trên máy tính.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.muted, height: 1.5),
                    ),
                    if (url != null) ...[
                      const SizedBox(height: 22),
                      InkWell(
                        onTap: () async {
                          await Clipboard.setData(ClipboardData(text: url));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đã sao chép địa chỉ.')),
                            );
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.search,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  url,
                                  style: const TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const Icon(Icons.copy_rounded, color: AppColors.muted),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: service.isRunning
                          ? OutlinedButton.icon(
                              onPressed: service.busy ? null : service.stop,
                              icon: const Icon(Icons.stop_circle_outlined),
                              label: const Text('Tắt truyền Wi‑Fi'),
                            )
                          : FilledButton.icon(
                              onPressed: service.busy
                                  ? null
                                  : () async {
                                      try {
                                        await service.start();
                                      } catch (_) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                service.lastMessage ?? 'Không thể bật máy chủ.',
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                              icon: service.busy
                                  ? const SizedBox.square(
                                      dimension: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.play_arrow_rounded),
                              label: const Text('Bật truyền Wi‑Fi'),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('CÁCH SỬ DỤNG', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
              const SizedBox(height: 12),
              const _Step(number: '1', text: 'Bật truyền Wi‑Fi trên iPhone.'),
              const _Step(number: '2', text: 'Nhập địa chỉ hiển thị vào Chrome, Edge hoặc Safari trên máy tính.'),
              const _Step(number: '3', text: 'Chọn nhiều file nhạc và nhấn “Tải vào thư viện”.'),
              const _Step(number: '4', text: 'Giữ màn hình này mở trong lúc tải file.'),
              if (service.lastMessage != null) ...[
                const SizedBox(height: 18),
                Text(service.lastMessage!, style: const TextStyle(color: AppColors.muted)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text});
  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: AppColors.accentDark, shape: BoxShape.circle),
            child: Text(number, style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 13),
          Expanded(child: Text(text, style: const TextStyle(height: 1.45))),
        ],
      ),
    );
  }
}
