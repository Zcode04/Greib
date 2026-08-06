import 'package:flutter/material.dart';
import '../core/mock_data/mock_data.dart';
import '../core/permissions/permissions.dart';
import 'app_button.dart';

// مكوّن موحّد لعرض وتعديل بيانات المستخدم لأي نوع حساب
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
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // صورة البروفايل
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (roleEnum != null ? PermissionService.roleColor(roleEnum) : theme.colorScheme.primary).withValues(alpha: 0.15),
                ),
                child: Icon(
                  roleEnum != null ? PermissionService.roleIcon(roleEnum) : Icons.person,
                  size: 48,
                  color: roleEnum != null ? PermissionService.roleColor(roleEnum) : theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // الاسم
            Center(
              child: Text(
                widget.profile.name,
                style: theme.textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 4),

            // الدور
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: (roleEnum != null ? PermissionService.roleColor(roleEnum) : theme.colorScheme.primary).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  roleEnum != null ? PermissionService.roleLabel(roleEnum) : 'مستخدم',
                  style: TextStyle(
                    color: roleEnum != null ? PermissionService.roleColor(roleEnum) : theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // حقول البيانات
            if (_isEditing) ...[
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'العنوان',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'حفظ',
                      icon: Icons.save,
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: 'إلغاء',
                      icon: Icons.close,
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
              // عرض البيانات
              _buildInfoRow(theme, Icons.person_outline, 'الاسم', widget.profile.name),
              _buildInfoRow(theme, Icons.phone_outlined, 'الهاتف', widget.profile.phone),
              _buildInfoRow(theme, Icons.email_outlined, 'البريد', widget.profile.email),
              if (widget.profile.address != null)
                _buildInfoRow(theme, Icons.location_on_outlined, 'العنوان', widget.profile.address!),
              if (widget.isEditable) ...[
                const SizedBox(height: 20),
                AppButton(
                  label: 'تعديل البيانات',
                  icon: Icons.edit,
                  onPressed: () => setState(() {
                    _isEditing = true;
                  }),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(value, style: theme.textTheme.titleMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// شاشة البروفايل الكاملة
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // الحصول على البروفايل من البيانات الوهمية
    final profile = MockData.demoProfiles.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('البروفايل'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileWidget(profile: profile),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppButton(
                label: 'تسجيل الخروج',
                icon: Icons.logout,
                color: theme.colorScheme.error,
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