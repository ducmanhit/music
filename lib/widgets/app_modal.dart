import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/app_theme.dart';

/// Opens one consistent, keyboard-safe and Safe Area-aware sheet.
///
/// Every popup in the app should use this helper so spacing, animation,
/// dismiss behavior and surface treatment remain identical.
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
    isScrollControlled: true,
    useSafeArea: false,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x24000000),
    elevation: 0,
    clipBehavior: Clip.none,
    builder: (sheetContext) {
      final media = MediaQuery.of(sheetContext);
      final maxHeight = (media.size.height -
              media.padding.top -
              media.padding.bottom -
              media.viewInsets.bottom -
              12)
          .clamp(160.0, media.size.height)
          .toDouble();
      return AnimatedPadding(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 620, maxHeight: maxHeight),
              child: AppSheetSurface(child: builder(sheetContext)),
            ),
          ),
        ),
      );
    },
  );
}

/// Flat iOS-style sheet surface. It keeps a small amount of backdrop blur,
/// but deliberately avoids shine, gradients, fake reflections and heavy
/// shadows that can make popup edges look dirty or unstable.
class AppSheetSurface extends StatelessWidget {
  const AppSheetSurface({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.radius = 28,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Material(
          color: const Color(0xF7FFFFFF),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
            side: const BorderSide(color: Color(0x1A3C3C43), width: .65),
          ),
          child: Padding(padding: padding, child: child),
        ),
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
    this.padding = const EdgeInsets.fromLTRB(20, 10, 14, 12),
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
            const SizedBox(height: 15),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontFamily: '.SF Pro Display',
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -.55,
                        height: 1.12,
                      ),
                    ),
                    if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        subtitle!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 13.5,
                          height: 1.35,
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
      width: 36,
      height: 5,
      decoration: BoxDecoration(
        color: const Color(0x493C3C43),
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
    final foreground = destructive ? AppColors.danger : AppColors.text;
    return Opacity(
      opacity: enabled ? 1 : .42,
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
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.accent.withValues(alpha: .05),
          highlightColor: const Color(0x0A3C3C43),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 62),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: destructive
                          ? AppColors.danger.withValues(alpha: .09)
                          : const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: destructive
                          ? AppColors.danger
                          : selected
                              ? AppColors.accent
                              : AppColors.graphite,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: foreground,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -.18,
                          ),
                        ),
                        if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 13,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  trailing ??
                      Icon(
                        selected
                            ? CupertinoIcons.check_mark_circled_solid
                            : CupertinoIcons.chevron_forward,
                        size: selected ? 21 : 17,
                        color: selected ? AppColors.accent : AppColors.mutedSoft,
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
  const AppSheetDivider({super.key, this.indent = 62});

  final double indent;

  @override
  Widget build(BuildContext context) {
    return Divider(indent: indent, endIndent: 12, height: 1);
  }
}

Future<bool> showAppConfirmation({
  required BuildContext context,
  required String title,
  required String message,
  String cancelLabel = 'Hủy',
  String confirmLabel = 'Xác nhận',
  bool destructive = false,
}) async {
  FocusManager.instance.primaryFocus?.unfocus();
  final result = await showGeneralDialog<bool>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    barrierLabel: 'Đóng',
    barrierColor: const Color(0x30000000),
    transitionDuration: const Duration(milliseconds: 210),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: .96, end: 1).animate(curved),
          child: child,
        ),
      );
    },
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return _DialogHost(
        child: AppAlertDialog(
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
              emphasized: !destructive,
              onPressed: () => Navigator.pop(dialogContext, true),
            ),
          ],
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
  String initialValue = '',
  String placeholder = '',
  String cancelLabel = 'Hủy',
  String confirmLabel = 'Lưu',
  int maxLength = 80,
}) async {
  FocusManager.instance.primaryFocus?.unfocus();
  final controller = TextEditingController(text: initialValue);
  final focusNode = FocusNode();
  try {
    return await showGeneralDialog<String>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      barrierLabel: 'Đóng',
      barrierColor: const Color(0x30000000),
      transitionDuration: const Duration(milliseconds: 210),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: .96, end: 1).animate(curved),
            child: child,
          ),
        );
      },
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return _TextPromptDialog(
          controller: controller,
          focusNode: focusNode,
          title: title,
          message: message,
          placeholder: placeholder,
          cancelLabel: cancelLabel,
          confirmLabel: confirmLabel,
          maxLength: maxLength,
        );
      },
    );
  } finally {
    controller.dispose();
    focusNode.dispose();
  }
}

class _TextPromptDialog extends StatefulWidget {
  const _TextPromptDialog({
    required this.controller,
    required this.focusNode,
    required this.title,
    required this.placeholder,
    required this.cancelLabel,
    required this.confirmLabel,
    required this.maxLength,
    this.message,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String title;
  final String? message;
  final String placeholder;
  final String cancelLabel;
  final String confirmLabel;
  final int maxLength;

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
    return _DialogHost(
      child: AppAlertDialog(
        title: widget.title,
        message: widget.message,
        content: Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 16),
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            autofocus: true,
            maxLength: widget.maxLength,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            enableSuggestions: false,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: widget.placeholder,
              counterText: '',
              filled: true,
              fillColor: const Color(0xFFF2F2F7),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(
                  color: Color(0x163C3C43),
                  width: .7,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(
                  color: AppColors.accent,
                  width: 1,
                ),
              ),
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
      ),
    );
  }
}

class _DialogHost extends StatelessWidget {
  const _DialogHost({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Material(
      type: MaterialType.transparency,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.fromLTRB(
          20,
          media.padding.top + 16,
          20,
          media.viewInsets.bottom + media.padding.bottom + 16,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 350),
            child: child,
          ),
        ),
      ),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Material(
          color: const Color(0xFAFFFFFF),
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
            side: const BorderSide(color: Color(0x1A3C3C43), width: .65),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  22,
                  22,
                  22,
                  content == null ? 20 : 12,
                ),
                child: Column(
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontFamily: '.SF Pro Display',
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -.35,
                        height: 1.2,
                      ),
                    ),
                    if (message != null && message!.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        message!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 14,
                          height: 1.38,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (content != null) content!,
              const Divider(height: 1),
              LayoutBuilder(
                builder: (context, constraints) {
                  final textScale = MediaQuery.textScalerOf(context).scale(1);
                  final useVertical = textScale > 1.25 || actions.length > 2;
                  if (useVertical) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var index = 0; index < actions.length; index++) ...[
                          SizedBox(width: double.infinity, child: actions[index]),
                          if (index < actions.length - 1)
                            const Divider(height: 1),
                        ],
                      ],
                    );
                  }
                  return IntrinsicHeight(
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
                  );
                },
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
    final color = destructive ? AppColors.danger : AppColors.accent;
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
          constraints: const BoxConstraints(minHeight: 50),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: enabled ? color : AppColors.mutedSoft,
                  fontSize: 16,
                  fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: -.15,
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
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSheetHeader(title: title, subtitle: subtitle),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetContext).size.height * .62,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
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
    ),
  );
}
