import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_music/utils/app_theme.dart';
import 'package:offline_music/widgets/app_modal.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('selection sheet fits a compact iPhone viewport', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => showAppSelectionSheet<int>(
                  context: context,
                  title: 'Hẹn giờ tắt nhạc',
                  options: const [
                    AppSelectionOption(
                      value: 10,
                      title: '10 phút',
                      icon: CupertinoIcons.timer,
                    ),
                    AppSelectionOption(
                      value: 20,
                      title: '20 phút',
                      icon: CupertinoIcons.timer,
                    ),
                    AppSelectionOption(
                      value: 30,
                      title: '30 phút',
                      icon: CupertinoIcons.timer,
                    ),
                    AppSelectionOption(
                      value: 45,
                      title: '45 phút',
                      icon: CupertinoIcons.timer,
                    ),
                    AppSelectionOption(
                      value: 60,
                      title: '60 phút',
                      icon: CupertinoIcons.timer,
                    ),
                  ],
                ),
                child: const Text('Mở'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Mở'));
    await tester.pumpAndSettle();

    expect(find.text('Hẹn giờ tắt nhạc'), findsOneWidget);
    expect(find.text('10 phút'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('text prompt returns a trimmed non-empty value', (tester) async {
    String? result;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () async {
                  result = await showAppTextPrompt(
                    context: context,
                    title: 'Tạo playlist',
                    placeholder: 'Tên playlist',
                  );
                },
                child: const Text('Tạo'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Tạo'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '  Chill  ');
    await tester.pump();
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();

    expect(result, 'Chill');
    expect(tester.takeException(), isNull);
  });
}
