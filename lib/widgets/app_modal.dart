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
    barrierColor: Colors.black.withValues(alpha: .42),
    elevation: 0,
    builder: (sheetContext) {
      final media = MediaQuery.of(sheetContext);
      final availableHeight = (media.size.height - media.viewInsets.bottom)
          .clamp(220.0, media.size.height)
          .toDouble();
      return AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 680,
              maxHeight: availableHeight * .90,
            ),
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
    this.radius = 26,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.tokens.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
        side: BorderSide(color: context.tokens.border),
      ),
      child: Padding(padding: padding, child: child),
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
    this.padding = const EdgeInsets.fromLTRB(20, 10, 16, 14),
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showHandle;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showHandle) ...[
            const Center(child: AppSheetHandle()),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        subtitle!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.tokens.textMuted,
                        ),
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

class AppSheetHandle extends StatelessWidget {
  const AppSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 4,
      decoration: BoxDecoration(
        color: context.tokens.surfaceStrong,
        borderRadius: BorderRadius.circular(99),
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
    final primary = Theme.of(context).colorScheme.primary;
    final foreground = destructive
        ? context.tokens.danger
        : Theme.of(context).colorScheme.onSurface;
    return Opacity(
      opacity: enabled ? 1 : .45,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled && onTap != null
              ? () {
                  if (destructive) {
                    HapticFeedback.mediumImpact();
                  } else {
                    HapticFeedback.selectionClick();
                  }
                  onTap!();
                }
              : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: destructive
                          ? context.tokens.danger.withValues(alpha: .10)
                          : selected
                              ? context.tokens.accentSoft
                              : context.tokens.surfaceMuted,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 21,
                      color: destructive
                          ? context.tokens.danger
                          : selected
                              ? primary
                              : context.tokens.textMuted,
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
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: foreground,
                          ),
                        ),
                        if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            subtitle!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context.tokens.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  trailing ??
                      Icon(
                        selected ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
                        color: selected ? primary : context.tokens.textFaint,
                        size: selected ? 22 : 21,
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
    return Divider(height: 1, indent: indent, endIndent: 18);
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
    barrierColor: Colors.black.withValues(alpha: .46),
    builder: (dialogContext) => AppAlertDialog(
      title: title,
      message: message,
      actions: [
        AppDialogAction(
          label: cancelLabel,
          onPressed: () => Navigator.pop(dialogContext, false),
        ),
        AppDialogAction(
          label: confirmLabel,
          destructive: destructive,
          emphasized: true,
          onPressed: () => Navigator.pop(dialogContext, true),
        ),
      ],
    ),
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
}) async {
  FocusManager.instance.primaryFocus?.unfocus();
  final controller = TextEditingController(text: initialValue);
  final focusNode = FocusNode();
  try {
    return await showDialog<String>(
      context: context,
      useRootNavigator: true,
      barrierColor: Colors.black.withValues(alpha: .46),
      builder: (dialogContext) => _TextPromptDialog(
        title: title,
        message: message,
        placeholder: placeholder,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        maxLength: maxLength,
        controller: controller,
        focusNode: focusNode,
      ),
    );
  } finally {
    controller.dispose();
    focusNode.dispose();
  }
}

class _TextPromptDialog extends StatefulWidget {
  const _TextPromptDialog({
    required this.title,
    required this.placeholder,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.maxLength,
    required this.controller,
    required this.focusNode,
    this.message,
  });

  final String title;
  final String? message;
  final String placeholder;
  final String confirmLabel;
  final String cancelLabel;
  final int maxLength;
  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  State<_TextPromptDialog> createState() => _TextPromptDialogState();
}

class _TextPromptDialogState extends State<_TextPromptDialog> {
  bool get _valid => widget.controller.text.trim().isNotEmpty;

  void _submit() {
    final value = widget.controller.text.trim();
    if (value.isEmpty) return;
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return AppAlertDialog(
      title: widget.title,
      message: widget.message,
      content: Padding(
        padding: const EdgeInsets.fromLTRB(20, 2, 20, 18),
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          autofocus: true,
          maxLength: widget.maxLength,
          textInputAction: TextInputAction.done,
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            hintText: widget.placeholder,
            counterText: '',
          ),
        ),
      ),
      actions: [
        AppDialogAction(
          label: widget.cancelLabel,
          onPressed: () => Navigator.pop(context),
        ),
        AppDialogAction(
          label: widget.confirmLabel,
          enabled: _valid,
          emphasized: true,
          onPressed: _valid ? _submit : null,
        ),
      ],
    );
  }
}

class AppAlertDialog extends StatelessWidget {
  const AppAlertDialog({
    super.key,
    required this.title,
    required this.actions,
    this.message,
    this.content,
  });

  final String title;
  final String? message;
  final Widget? content;
  final List<AppDialogAction> actions;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Dialog(
      insetPadding: EdgeInsets.fromLTRB(
        20,
        media.padding.top + 20,
        20,
        media.viewInsets.bottom + media.padding.bottom + 20,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(22, 22, 22, content == null ? 20 : 12),
                child: Column(
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (message != null && message!.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        message!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.tokens.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (content != null) content!,
              const Divider(height: 1),
              if (actions.length <= 2)
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var index = 0; index < actions.length; index++) ...[
                        Expanded(child: actions[index]),
                        if (index < actions.length - 1)
                          const VerticalDivider(width: 1),
                      ],
                    ],
                  ),
                )
              else
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var index = 0; index < actions.length; index++) ...[
                      SizedBox(width: double.infinity, child: actions[index]),
                      if (index < actions.length - 1) const Divider(height: 1),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppDialogAction extends StatelessWidget {
  const AppDialogAction({
    super.key,
    required this.label,
    required this.onPressed,
    this.destructive = false,
    this.emphasized = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool destructive;
  final bool emphasized;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final foreground = destructive ? context.tokens.danger : primary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled && onPressed != null
            ? () {
                if (destructive) {
                  HapticFeedback.mediumImpact();
                } else {
                  HapticFeedback.selectionClick();
                }
                onPressed!();
              }
            : null,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 52),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: enabled ? foreground : context.tokens.textFaint,
                  fontSize: 15.5,
                  fontWeight: emphasized ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
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
            padding: const EdgeInsets.only(bottom: 12),
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
