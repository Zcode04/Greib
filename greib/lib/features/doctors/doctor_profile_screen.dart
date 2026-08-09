import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/mock_data/mock_data.dart';
import '../../core/theme/design_tokens.dart';
import '../../shared_widgets/app_button.dart';
import '../../shared_widgets/header.dart';

class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key});

  DoctorProfile _resolveDoctor(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is DoctorProfile) return args;
    return MockData.mockDoctors.first;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final doctor = _resolveDoctor(context);
    final specialtyColor = MockData.getSpecialtyColor(doctor.specialty);
    final bool isAvailable = doctor.isAvailableNow;

    // بيانات تقييمات وهمية
    final reviews = [
      {
        'user': 'محمد أحمد',
        'rating': 5,
        'comment': 'دكتور ممتاز، أهتمام جعلية وشرح واضح للوضعية',
        'time': 'منذ أسبوع',
      },
      {
        'user': 'سارة علي',
        'rating': 4,
        'comment': 'استشارة رائعة، سأعود بالمتابعة في المواعيد القادمة',
        'time': 'منذ شهرين',
      },
      {
        'user': 'فاطمة خالد',
        'rating': 5,
        'comment': 'أفضل طبيب باطنة جربته، أنصح الجميع به',
        'time': 'منذ 3 أيام',
      },
    ];

    return Scaffold(
      appBar: const Header(
        title: 'بروفايل الطبيب',
        showBackButton: true,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AppButton(
            label: 'حجز استشارة',
            icon: LucideIcons.calendar,
            color: const Color(0xFF0F5132),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم حجز استشارة مع ${doctor.name} بنجاح ✅'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- رأس البروفايل (Header): صورة + اسم + تخصص + مستشفى ----
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // صورة الطبيب الدائرية
                  CircleAvatar(
                    radius: 52,
                    backgroundColor:
                        specialtyColor.withValues(alpha: isDark ? 0.18 : 0.14),
                    backgroundImage: NetworkImage(doctor.avatar),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // اسم الطبيب - كبير وواضح
                  Text(
                    doctor.name,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // التخصص - لون accentPrimary المميز
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.accentPrimary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadii.full),
                    ),
                    child: Text(
                      doctor.specialty,
                      style: TextStyle(
                        color: AppColors.accentPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // اسم المستشفى مع أيقونة مستشفى - نص ثانوي
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.building2,
                        size: 16,
                        color: isDark
                            ? AppColors.textSecondary
                            : AppColors.lightTextSecondary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: Text(
                          doctor.hospitalName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textSecondary
                                : AppColors.lightTextSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ---- شريط التقييم ----
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.star,
                    size: 16, color: Color(0xFFD4A853)),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  doctor.rating.toStringAsFixed(1),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '(${reviews.length} تقييمات)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.textMuted
                        : AppColors.lightTextTertiary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // ---- شريط التوافر + العيادة ----
            Row(
              children: [
                // شارة التوافر
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: isAvailable
                        ? const Color(0xFF0F5132).withValues(alpha: 0.1)
                        : AppColors.textMuted.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadii.full),
                    border: Border.all(
                      color: isAvailable
                          ? const Color(0xFF0F5132).withValues(alpha: 0.3)
                          : AppColors.textMuted.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isAvailable
                              ? AppColors.success
                              : AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        isAvailable ? 'متوفر الآن' : 'غير متاح الآن',
                        style: TextStyle(
                          color: isAvailable
                              ? const Color(0xFF0F5132)
                              : AppColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // اسم المستشفى
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.building2,
                        size: 14,
                        color: isDark
                            ? AppColors.textMuted
                            : AppColors.lightTextTertiary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          doctor.hospitalName,
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textSecondary
                                : AppColors.lightTextSecondary,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // ---- بطاقة التفاصيل ----
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تفاصيل الطبيب',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _infoRow(context, LucideIcons.briefcase,
                        'سنوات الخبرة', '${doctor.yearsOfExperience} سنة'),
                    const SizedBox(height: AppSpacing.sm),
                    _infoRow(context, LucideIcons.wallet,
                        'رسوم الاستشارة', '${doctor.consultationFee.toInt()} درهم'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ---- النبذة الطبية ----
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'نبذة طبية',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'د. ${doctor.name} متخصص ${doctor.specialty} لديه ${doctor.yearsOfExperience} سنة من الخبرة العملية في ${doctor.hospitalName}. '
                      'يدعم أفراد العائلة في جميع الأعمار ويستخدم أحدث التقنيات التشخيصية.',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSecondary
                            : AppColors.lightTextSecondary,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ---- التقييمات ----
            Text(
              'التقييمات',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            ...reviews.map((review) => _reviewCard(review, isDark)),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String label,
      String value) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.accentPrimary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
          child: Icon(icon, size: 20, color: AppColors.accentPrimary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isDark
                      ? AppColors.textMuted
                      : AppColors.lightTextTertiary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                value,
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _reviewCard(Map<String, dynamic> review, bool isDark) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.accentPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadii.full),
                  ),
                  child: Icon(LucideIcons.user,
                      color: AppColors.accentPrimary, size: 20),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review['user'] as String,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textPrimary
                              : AppColors.lightText,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < (review['rating'] as int)
                                  ? LucideIcons.star
                                  : LucideIcons.star,
                              size: 12,
                              color: const Color(0xFFD4A853),
                            );
                          }),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            review['time'] as String,
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
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(review['comment'] as String),
          ],
        ),
      ),
    );
  }
}
