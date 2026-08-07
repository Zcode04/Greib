import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/mock_data/mock_data.dart';
import '../../core/permissions/permissions.dart';
import '../../shared_widgets/app_button.dart';

class ProfileWidget extends StatefulWidget {
  final AppUserProfile profile;
  final bool isEditable;

  const ProfileWidget({
    super.key,
    required this.profile,
    this.isEditable = true,
  });

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _emailController = TextEditingController(text: widget.profile.email);
    _addressController = TextEditingController(text: widget.profile.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roleEnum = PermissionService.roleFromString(widget.profile.role);

    return Card(
      margin: const EdgeInsets.all(AppSpacing.lg),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      (roleEnum != null ? PermissionService.roleColor(roleEnum) : AppColors.primary)
                          .withValues(alpha: 0.2),
                      (roleEnum != null ? PermissionService.roleColor(roleEnum) : AppColors.primary)
                          .withValues(alpha: 0.08),
                    ],
                  ),
                ),
                child: Icon(
                  roleEnum != null ? PermissionService.roleIcon(roleEnum) : LucideIcons.user,
                  size: 48,
                  color: roleEnum != null ? PermissionService.roleColor(roleEnum) : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Center(
              child: Text(
                widget.profile.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: (roleEnum != null ? PermissionService.roleColor(roleEnum) : AppColors.primary)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadii.full),
                ),
                child: Text(
                  roleEnum != null ? PermissionService.roleLabel(roleEnum) : 'مستخدم',
                  style: TextStyle(
                    color: roleEnum != null ? PermissionService.roleColor(roleEnum) : AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            if (_isEditing) ...[
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم',
                  prefixIcon: Icon(LucideIcons.user),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  prefixIcon: Icon(LucideIcons.phone),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: Icon(LucideIcons.mail),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'العنوان',
                  prefixIcon: Icon(LucideIcons.mapPin),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'حفظ',
                      icon: LucideIcons.save,
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم حفظ التغييرات بنجاح ✅')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      label: 'إلغاء',
                      icon: LucideIcons.x,
                      isOutlined: true,
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                          _nameController.text = widget.profile.name;
                          _phoneController.text = widget.profile.phone;
                          _emailController.text = widget.profile.email;
                          _addressController.text = widget.profile.address ?? '';
                        });
                      },
                    ),
                  ),
                ],
              ),
            ] else ...[
              _buildInfoRow(context, LucideIcons.user, 'الاسم', widget.profile.name),
              _buildInfoRow(context, LucideIcons.phone, 'الهاتف', widget.profile.phone),
              _buildInfoRow(context, LucideIcons.mail, 'البريد', widget.profile.email),
              if (widget.profile.address != null)
                _buildInfoRow(context, LucideIcons.mapPin, 'العنوان', widget.profile.address!),
              const SizedBox(height: AppSpacing.xl),
              if (widget.isEditable)
                AppButton(
                  label: 'تعديل البيانات',
                  icon: LucideIcons.pencil,
                  onPressed: () => setState(() {
                    _isEditing = true;
                  }),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodySmall),
                const SizedBox(height: AppSpacing.xs),
                Text(value, style: theme.textTheme.titleMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = MockData.demoProfiles.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('البروفايل'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileWidget(profile: profile),
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: AppButton(
                label: 'تسجيل الخروج',
                icon: LucideIcons.logOut,
                color: AppColors.error,
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
