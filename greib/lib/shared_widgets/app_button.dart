import 'package:flutter/material.dart';
import '../core/theme/design_tokens.dart';

enum ButtonType { primary, secondary, ghost, danger }

class AppButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color? color;
  final ButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final bool isOutlined;

  const AppButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.color,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ??
        (type == ButtonType.danger
            ? AppColors.error
            : type == ButtonType.secondary
                ? AppColors.secondary
                : theme.colorScheme.primary);

    final isEnabled = onPressed != null && !isLoading;

    Widget child = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: type == ButtonType.ghost ? effectiveColor : Colors.white,
            ),
          )
        else ...[
          if (icon != null) ...[
            Icon(icon, size: 20, color: _textColor(type, effectiveColor)),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _textColor(type, effectiveColor),
            ),
          ),
        ],
      ],
    );

    if (type == ButtonType.ghost) {
      return SizedBox(
        width: isFullWidth ? double.infinity : null,
        child: TextButton(
          onPressed: isEnabled ? onPressed : null,
          style: TextButton.styleFrom(
            foregroundColor: effectiveColor,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.full),
            ),
          ),
          child: child,
        ),
      );
    }

    if (type == ButtonType.secondary || type == ButtonType.danger || isOutlined) {
      return SizedBox(
        width: isFullWidth ? double.infinity : null,
        child: OutlinedButton(
          onPressed: isEnabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            foregroundColor: effectiveColor,
            side: BorderSide(color: effectiveColor.withValues(alpha: 0.5), width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.full),
            ),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveColor,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.full),
          ),
          elevation: AppElevation.xs,
          shadowColor: effectiveColor.withValues(alpha: 0.3),
        ),
        child: child,
      ),
    );
  }

  Color _textColor(ButtonType type, Color color) {
    if (isOutlined) return color;
    if (type == ButtonType.primary) return Colors.white;
    if (type == ButtonType.danger) return Colors.white;
    return color;
  }
}

class IconButtonWidget extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final String? tooltip;
  final double size;

  const IconButtonWidget({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.tooltip,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
      icon: Icon(icon, color: color ?? theme.colorScheme.onSurface, size: size),
      onPressed: onPressed,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        padding: const EdgeInsets.all(AppSpacing.sm),
      ),
    );
  }
}
