import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/app_theme.dart';

class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.child,
    this.safeTop = true,
    this.safeBottom = false,
    this.backgroundColor,
  });

  final Widget child;
  final bool safeTop;
  final bool safeBottom;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor ?? context.tokens.background,
      child: SafeArea(
        top: safeTop,
        bottom: safeBottom,
        child: child,
      ),
    );
  }
}

class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    required this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
    this.enabled = true,
    this.behavior = HitTestBehavior.opaque,
  });

  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;
  final bool enabled;
  final HitTestBehavior behavior;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool pressed = false;

  void _setPressed(bool value) {
    if (!mounted || pressed == value) return;
    setState(() => pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled && widget.onTap != null;
    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: enabled ? (_) => _setPressed(true) : null,
      onTapCancel: enabled ? () => _setPressed(false) : null,
      onTapUp: enabled ? (_) => _setPressed(false) : null,
      onTap: enabled
          ? () {
              HapticFeedback.selectionClick();
              widget.onTap?.call();
            }
          : null,
      child: AnimatedScale(
        scale: pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

class RoundedSurface extends StatelessWidget {
  const RoundedSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 26,
    this.color,
    this.borderColor,
    this.onTap,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  final Color? borderColor;
  final VoidCallback? onTap;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: color ?? context.tokens.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor ?? context.tokens.border),
    );
    final content = Container(
      decoration: decoration,
      padding: padding,
      clipBehavior: clipBehavior,
      child: child,
    );
    if (onTap == null) return content;
    return PressableScale(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: content,
    );
  }
}

class SurfaceCard extends RoundedSurface {
  const SurfaceCard({
    super.key,
    required super.child,
    super.padding = const EdgeInsets.all(18),
    super.radius = 26,
    super.color,
    super.borderColor,
    super.onTap,
    super.clipBehavior = Clip.antiAlias,
  });
}

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.subtitle,
    this.actions = const [],
    this.padding = const EdgeInsets.fromLTRB(20, 20, 20, 18),
  });

  final String title;
  final String? eyebrow;
  final String? subtitle;
  final List<Widget> actions;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eyebrow != null && eyebrow!.trim().isNotEmpty) ...[
                  Text(
                    eyebrow!.toUpperCase(),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: context.tokens.textTertiary,
                          letterSpacing: 1.15,
                        ),
                  ),
                  const SizedBox(height: 6),
                ],
                Text(title, style: Theme.of(context).textTheme.displaySmall),
                if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                  const SizedBox(height: 7),
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(width: 14),
            Wrap(spacing: 8, children: actions),
          ],
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(20, 28, 20, 12),
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
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
    );
  }
}

class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 42,
    this.iconSize = 21,
    this.selected = false,
    this.danger = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final double iconSize;
  final bool selected;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final foreground = danger
        ? context.tokens.danger
        : selected
            ? context.tokens.accentText
            : context.tokens.textPrimary;
    final background = danger
        ? context.tokens.danger.withValues(alpha: 0.11)
        : selected
            ? context.tokens.accent
            : context.tokens.surface;

    final button = SizedBox.square(
      dimension: size,
      child: Material(
        color: background,
        shape: CircleBorder(side: BorderSide(color: context.tokens.border)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Icon(icon, size: iconSize, color: foreground),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

class FlatIconButton extends CircleIconButton {
  const FlatIconButton({
    super.key,
    required super.icon,
    required super.onPressed,
    super.tooltip,
    super.size = 42,
    super.iconSize = 21,
    super.selected = false,
    super.danger = false,
  });
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final button = icon == null
        ? FilledButton(onPressed: onPressed, child: Text(label))
        : FilledButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 20),
            label: Text(label),
          );
    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final button = icon == null
        ? OutlinedButton(onPressed: onPressed, child: Text(label))
        : OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 20),
            label: Text(label),
          );
    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.hintText = 'Tìm kiếm',
    this.autofocus = false,
    this.focusNode,
    this.trailing,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String hintText;
  final bool autofocus;
  final FocusNode? focusNode;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: trailing,
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? 20 : 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: compact ? 58 : 72,
                height: compact ? 58 : 72,
                decoration: BoxDecoration(
                  color: context.tokens.surfaceHigh,
                  borderRadius: BorderRadius.circular(compact ? 19 : 24),
                  border: Border.all(color: context.tokens.border),
                ),
                child: Icon(
                  icon,
                  size: compact ? 27 : 34,
                  color: context.tokens.textSecondary,
                ),
              ),
              SizedBox(height: compact ? 16 : 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 7),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (action != null) ...[
                const SizedBox(height: 20),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.destructive = false,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool destructive;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final foreground = destructive
        ? context.tokens.danger
        : context.tokens.textPrimary;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 58),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              child: Row(
                children: [
                  SizedBox.square(
                    dimension: 34,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: destructive
                            ? context.tokens.danger.withValues(alpha: 0.1)
                            : context.tokens.surfaceHigh,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(
                        icon,
                        size: 19,
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
                  const SizedBox(width: 10),
                  trailing ??
                      (onTap == null
                          ? const SizedBox.shrink()
                          : Icon(
                              Icons.chevron_right_rounded,
                              color: context.tokens.textTertiary,
                              size: 21,
                            )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GroupDivider extends StatelessWidget {
  const GroupDivider({super.key, this.indent = 63});

  final double indent;

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, indent: indent, endIndent: 16);
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    this.icon,
    this.active = false,
  });

  final String label;
  final IconData? icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: active ? context.tokens.accent : context.tokens.surfaceHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.tokens.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 15,
              color: active
                  ? context.tokens.accentText
                  : context.tokens.textSecondary,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: active
                      ? context.tokens.accentText
                      : context.tokens.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
