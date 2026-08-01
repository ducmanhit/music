import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_music/utils/app_theme.dart';
import 'package:offline_music/widgets/app_modal.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('selection sheet fits a compact phone viewport', (tester) async {
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
                  title: 'Sắp xếp bài hát',
                  options: const [
                    AppSelectionOption(value: 1, title: 'Tên bài hát', icon: Icons.sort_by_alpha),
                    AppSelectionOption(value: 2, title: 'Nghệ sĩ', icon: Icons.person_outline),
                    AppSelectionOption(value: 3, title: 'Ngày thêm', icon: Icons.schedule),
                    AppSelectionOption(value: 4, title: 'Thời lượng', icon: Icons.timer_outlined),
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

    expect(find.text('Sắp xếp bài hát'), findsOneWidget);
    expect(find.text('Tên bài hát'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('text prompt trims and returns a non-empty value', (tester) async {
    String? result;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildDarkTheme(),
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
    await tester.enterText(find.byType(TextField), '  Chill tối  ');
    await tester.pump();
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();

    expect(result, 'Chill tối');
    expect(tester.takeException(), isNull);
  });
}
