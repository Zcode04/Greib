import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../features/auth/mock_auth.dart';
import '../../../../core/permissions/permissions.dart';

class QuickActions extends StatelessWidget {
  final UserRole? role;

  const QuickActions({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        if (role == UserRole.admin)
          _chip(context, LucideIcons.shieldCheck, 'لوحة المشرفين',
              context.iconColors.error, () => context.push('/admin_dashboard')),
        if (role == UserRole.agent)
          _chip(context, LucideIcons.bike, 'لوحة الوكيل',
              context.iconColors.warning, () => context.push('/agent_dashboard')),
        if (role == UserRole.admin || role == UserRole.agent)
          _chip(context, LucideIcons.package, 'طلباتي',
              context.iconColors.info, () => context.push('/orders')),
        _chip(context, LucideIcons.search, 'البحث', context.accentColor,
            () => context.push('/search')),
        _chip(context, LucideIcons.settings, 'الإعدادات',
            context.textColors.secondary, () => context.push('/settings')),
        _chip(context, LucideIcons.logOut, 'تسجيل الخروج',
            context.textColors.tertiary, () {
          AuthService.instance.logout();
          context.go('/login');
        }),
      ],
    );
  }

  Widget _chip(BuildContext context, IconData icon, String label,
      Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: context.textColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
