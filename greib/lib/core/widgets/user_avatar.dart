// ============================================================================
//  UserAvatar — صورة البروفايل الدائرية المشتركة.
//
//  تُستخدم في الهيدر وشريط الإجراءات وأي مكان يعرض صورة المستخدم،
//  فيبقى الشكل موحداً تلقائياً. تقرأ المسار من UserData (ملف المستخدم
//  المركزي) فتتحدّث فور تغيير الصورة؛ بلا صورة ⇒ أيقونة مستخدم هادئة.
// ============================================================================
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../extensions/context_extensions.dart';
import '../user/user_data.dart';

class UserAvatar extends StatelessWidget {
  /// القطر الكلي للدائرة (بما فيه الإطار).
  final double size;

  /// حجم أيقونة المستخدم الاحتياطية.
  final double iconSize;

  /// لون الإطار (الافتراضي: accent خفيف).
  final Color? borderColor;
  final double borderWidth;

  const UserAvatar({
    super.key,
    required this.size,
    required this.iconSize,
    this.borderColor,
    this.borderWidth = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final accent = context.accentColor;

    // ★ الاستماع للصورة فقط — أي تغيير يُعاد بناء الأفاتار وحده.
    final avatarPath =
        context.select<UserData, String?>((user) => user.avatarPath);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // ★ borderWidth = 0 ⇒ بلا إطار (لتجنّب إطارين متداخلين عندما يكون
        //   الأفاتار داخل زر له إطاره الخاص).
        border: borderWidth > 0
            ? Border.all(
                color: borderColor ?? accent.withValues(alpha: 0.35),
                width: borderWidth,
              )
            : null,
      ),
      padding: const EdgeInsets.all(1.5),
      child: ClipOval(
        child: avatarPath != null
            ? Image.file(
                File(avatarPath),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Icon(
                  LucideIcons.circleUserRound,
                  size: iconSize,
                  color: onSurface,
                ),
              )
            : Icon(
                LucideIcons.circleUserRound,
                size: iconSize,
                color: onSurface,
              ),
      ),
    );
  }
}
