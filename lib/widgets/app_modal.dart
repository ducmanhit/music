import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/app_theme.dart';

Future<T?> showAppSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
  bool enableDrag = true,
  bool useRootNavigator = true,
}) {
  FocusManager.instance.primaryFocus?.unfocus();
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    useSafeArea: true,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    elevation: 0,
    builder: (sheetContext) {
      final media = MediaQuery.of(sheetContext);
      final maxHeight = media.size.height * 0.82;
      return AnimatedPadding(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 680, maxHeight: maxHeight),
            child: AppSheetSurface(child: builder(sheetContext)),
          ),
        ),
      );
    },
  );
}

class AppSheetSurface extends StatelessWidget {
  const AppSheetSurface({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.tokens.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class AppSheetHandle extends StatelessWidget {
  const AppSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 5,
      decoration: BoxDecoration(
        color: context.tokens.textTertiary.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class AppSheetHeader extends StatelessWidget {
  const AppSheetHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showHandle = true,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showHandle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showHandle) ...[
            const Center(child: AppSheetHandle()),
            const SizedBox(height: 18),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        subtitle!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 12),
                trailing!,
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class AppSheetAction extends StatelessWidget {
  const AppSheetAction({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailing,
    this.destructive = false,
    this.enabled = true,
    this.selected = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool destructive;
  final bool enabled;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final foreground = destructive
        ? context.tokens.danger
        : context.tokens.textPrimary;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: selected ? context.tokens.surfaceHigh : Colors.transparent,
        child: InkWell(
          onTap: enabled && onTap != null
              ? () {
                  destructive
                      ? HapticFeedback.mediumImpact()
                      : HapticFeedback.selectionClick();
                  onTap?.call();
                }
              : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 62),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
              child: Row(
                children: [
                  SizedBox.square(
                    dimension: 38,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: destructive
                            ? context.tokens.danger.withValues(alpha: 0.1)
                            : context.tokens.surfaceHigh,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: destructive
                            ? context.tokens.danger
                            : context.tokens.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: foreground),
                        ),
                        if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  trailing ??
                      Icon(
                        selected
                            ? Icons.check_circle_rounded
                            : Icons.chevron_right_rounded,
                        color: selected
                            ? context.tokens.textPrimary
                            : context.tokens.textTertiary,
                        size: selected ? 22 : 20,
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

class AppSheetDivider extends StatelessWidget {
  const AppSheetDivider({super.key, this.indent = 71});

  final double indent;

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, indent: indent, endIndent: 20);
  }
}

Future<bool> showAppConfirmation({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'Xác nhận',
  String cancelLabel = 'Hủy',
  bool destructive = false,
}) async {
  FocusManager.instance.primaryFocus?.unfocus();
  final result = await showDialog<bool>(
    context: context,
    useRootNavigator: true,
    barrierColor: Colors.black.withValues(alpha: 0.58),
    builder: (dialogContext) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(dialogContext).textTheme.titleLarge,
                ),
                const SizedBox(height: 9),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(dialogContext).textTheme.bodyMedium,
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: Text(cancelLabel),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          if (destructive) HapticFeedback.mediumImpact();
                          Navigator.pop(dialogContext, true);
                        },
                        style: destructive
                            ? FilledButton.styleFrom(
                                backgroundColor: context.tokens.danger,
                                foregroundColor: Colors.white,
                              )
                            : null,
                        child: Text(confirmLabel),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
  return result ?? false;
}

Future<String?> showAppTextPrompt({
  required BuildContext context,
  required String title,
  String? message,
  String placeholder = '',
  String initialValue = '',
  String confirmLabel = 'Lưu',
  String cancelLabel = 'Hủy',
  int maxLength = 80,
}) {
  return showAppSheet<String>(
    context: context,
    enableDrag: false,
    builder: (sheetContext) => _TextPromptSheet(
      title: title,
      message: message,
      placeholder: placeholder,
      initialValue: initialValue,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      maxLength: maxLength,
    ),
  );
}

class _TextPromptSheet extends StatefulWidget {
  const _TextPromptSheet({
    required this.title,
    required this.message,
    required this.placeholder,
    required this.initialValue,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.maxLength,
  });

  final String title;
  final String? message;
  final String placeholder;
  final String initialValue;
  final String confirmLabel;
  final String cancelLabel;
  final int maxLength;

  @override
  State<_TextPromptSheet> createState() => _TextPromptSheetState();
}

class _TextPromptSheetState extends State<_TextPromptSheet> {
  late final TextEditingController controller;
  late final FocusNode focusNode;
  String? errorText;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialValue);
    focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final value = controller.text.trim();
    if (value.isEmpty) {
      setState(() => errorText = 'Nội dung không được để trống.');
      return;
    }
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSheetHeader(
            title: widget.title,
            subtitle: widget.message,
          ),
          TextField(
            controller: controller,
            focusNode: focusNode,
            maxLength: widget.maxLength,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            onChanged: (_) {
              if (errorText != null) setState(() => errorText = null);
            },
            decoration: InputDecoration(
              hintText: widget.placeholder,
              errorText: errorText,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(widget.cancelLabel),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: _submit,
                  child: Text(widget.confirmLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AppSelectionOption<T> {
  const AppSelectionOption({
    required this.value,
    required this.title,
    required this.icon,
    this.subtitle,
    this.destructive = false,
  });

  final T value;
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool destructive;
}

Future<T?> showAppSelectionSheet<T>({
  required BuildContext context,
  required String title,
  required List<AppSelectionOption<T>> options,
  T? selectedValue,
  String? subtitle,
}) {
  return showAppSheet<T>(
    context: context,
    builder: (sheetContext) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppSheetHeader(title: title, subtitle: subtitle),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.only(
              bottom: MediaQuery.paddingOf(sheetContext).bottom + 12,
            ),
            itemCount: options.length,
            separatorBuilder: (_, __) => const AppSheetDivider(),
            itemBuilder: (context, index) {
              final option = options[index];
              return AppSheetAction(
                icon: option.icon,
                title: option.title,
                subtitle: option.subtitle,
                destructive: option.destructive,
                selected: option.value == selectedValue,
                onTap: () => Navigator.pop(sheetContext, option.value),
              );
            },
          ),
        ),
      ],
    ),
  );
}
