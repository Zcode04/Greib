import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';
import '../../shared_widgets/app_button.dart';

class PromoCodesScreen extends StatefulWidget {
  const PromoCodesScreen({super.key});

  @override
  State<PromoCodesScreen> createState() => _PromoCodesScreenState();
}

class _PromoCodesScreenState extends State<PromoCodesScreen> {
  final TextEditingController _codeController = TextEditingController();
  final List<Map<String, String>> _appliedCodes = [];
  final List<Map<String, String>> _availableCodes = [
    {'code': 'GREIB10', 'discount': '10%', 'desc': 'خصم 10% على أول طلب'},
    {'code': 'WELCOME20', 'discount': '20%', 'desc': 'خصم 20% للعملاء الجدد'},
    {'code': 'GOLD50', 'discount': '50 درهم', 'desc': 'خصم 50 درهم للأعضاء الذهبيين'},
  ];

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('أكواد الخصم'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'أدخل كود الخصم',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      hintText: 'مثال: GREIB10',
                      prefixIcon: Icon(Icons.local_offer),
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                AppButton(
                  label: 'تطبيق',
                  type: ButtonType.primary,
                  isFullWidth: false,
                  onPressed: _applyCode,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            Text(
              'أكواد متاحة',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.md),

            ..._availableCodes.map((code) {
              final isApplied = _appliedCodes.any((c) => c['code'] == code['code']);
              return Card(
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(AppSpacing.md),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Icon(
                      Icons.local_offer,
                      color: AppColors.secondaryDark,
                      size: 24,
                    ),
                  ),
                  title: Text(code['code']!),
                  subtitle: Text(code['desc']!),
                  trailing: isApplied
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadii.sm),
                          ),
                          child: Text(
                            'مطبق',
                            style: TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        )
                      : TextButton(
                          onPressed: () {
                            _codeController.text = code['code']!;
                            _applyCode();
                          },
                          child: Text(
                            'تطبيق',
                            style: TextStyle(color: AppColors.secondaryDark),
                          ),
                        ),
                ),
              );
            }),

            if (_appliedCodes.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              Text(
                'الأكواد المطبقة',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.md),
              ..._appliedCodes.map((code) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(AppSpacing.md),
                    leading: const Icon(Icons.check_circle, color: AppColors.success),
                    title: Text(code['code']!),
                    subtitle: Text(code['discount']!),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: AppColors.error),
                      onPressed: () {
                        setState(() {
                          _appliedCodes.remove(code);
                        });
                      },
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  void _applyCode() {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    final found = _availableCodes.firstWhere(
      (c) => c['code'] == code,
      orElse: () => {},
    );

    if (found.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('كود خصم غير صالح'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      if (!_appliedCodes.any((c) => c['code'] == code)) {
        _appliedCodes.add(found);
      }
      _codeController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تطبيق كود الخصم: ${found['discount']}'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
