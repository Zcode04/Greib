import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/mock_data/mock_data.dart';
import '../../core/theme/design_tokens.dart';
import '../../shared_widgets/header.dart';

class DoctorsListScreen extends StatefulWidget {
  const DoctorsListScreen({super.key});

  @override
  State<DoctorsListScreen> createState() => _DoctorsListScreenState();
}

class _DoctorsListScreenState extends State<DoctorsListScreen> {
  String _selectedSpecialty = 'الكل';

  static const List<String> _specialties = [
    'الكل',
    'باطنة',
    'أطفال',
    'أسنان',
    'جلدية',
    'نساء وولادة',
    'عظام',
    'قلب',
    'طب الأسرة',
  ];

  List<DoctorProfile> get _filteredDoctors {
    if (_selectedSpecialty == 'الكل') return MockData.mockDoctors;
    return MockData.mockDoctors
        .where((d) => d.specialty == _selectedSpecialty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: const Header(
        title: 'الأطباء',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // شريط تصفية بالتخصص
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _specialties.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, i) {
                  final spec = _specialties[i];
                  final bool isSelected = _selectedSpecialty == spec;
                  final color = MockData.getSpecialtyColor(
                      spec == 'الكل' ? '' : spec);
                  return ChoiceChip(
                    label: Text(spec),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedSpecialty = spec);
                    },
                    backgroundColor: isDark
                        ? AppColors.surfaceVariant
                        : AppColors.lightSurfaceVariant,
                    selectedColor: color.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? color
                          : (isDark
                              ? AppColors.textSecondary
                              : AppColors.lightTextSecondary),
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? color
                          : (isDark ? AppColors.outline : AppColors.lightOutline),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.full),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // قائمة الأطباء
            Text(
              '${_filteredDoctors.length} طبيب',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.textMuted
                    : AppColors.lightTextTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            ..._filteredDoctors.map((doctor) => _doctorCard(doctor, isDark)),
          ],
        ),
      ),
    );
  }

  Widget _doctorCard(DoctorProfile doctor, bool isDark) {
    final specialtyColor = MockData.getSpecialtyColor(doctor.specialty);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.md),
          onTap: () => Navigator.pushNamed(
            context,
            '/doctor_profile',
            arguments: doctor,
          ),
          child: Row(
            children: [
              // الصورة الدائرية
              CircleAvatar(
                radius: 28,
                backgroundColor:
                    specialtyColor.withValues(alpha: isDark ? 0.15 : 0.12),
                backgroundImage: NetworkImage(doctor.avatar),
              ),
              const SizedBox(width: AppSpacing.md),

              // البيانات النصية
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textPrimary
                            : AppColors.lightText,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      doctor.specialty,
                      style: TextStyle(
                        color: specialtyColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      doctor.hospitalName,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textMuted
                            : AppColors.lightTextTertiary,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        const Icon(LucideIcons.star,
                            size: 14, color: Color(0xFFD4A853)),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          doctor.rating.toStringAsFixed(1),
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textPrimary
                                : AppColors.lightText,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          '${doctor.yearsOfExperience} سنة خبرة',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textMuted
                                : AppColors.lightTextTertiary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                )),
              // زر التوافر
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: doctor.isAvailableNow
                      ? const Color(0xFF0F5132).withValues(alpha: 0.1)
                      : AppColors.textMuted.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Text(
                  doctor.isAvailableNow ? 'متوفر الآن' : 'غير متاح',
                  style: TextStyle(
                    color: doctor.isAvailableNow
                        ? const Color(0xFF0F5132)
                        : AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
