import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/mock_data/mock_data.dart';
import '../../core/theme/design_tokens.dart';
import '../../shared_widgets/app_button.dart';
import '../../shared_widgets/detail_page_template.dart';

// قالب صفحة خدمة موحد لجميع الخدمات الست
class ServiceTemplateScreen extends StatelessWidget {
  final ServiceCategory service;

  const ServiceTemplateScreen({
    super.key,
    required this.service,
  });

  // بيانات وهمية لكل خدمة
  List<Map<String, String>> get _demoItems {
    switch (service.id) {
      case 'food':
        return [
          {'name': 'مطعم المندي الملكي', 'desc': 'برياني، مندي، كبسة', 'price': '٤٥ درهم', 'time': '٢٥ دقيقة', 'rating': '٤.٨'},
          {'name': 'شاورما العربي', 'desc': 'شاورما، مشاوي', 'price': '٣٠ درهم', 'time': '١٥ دقيقة', 'rating': '٤.٦'},
          {'name': 'بيتزا هت', 'desc': 'بيتزا، باستا', 'price': '٥٥ درهم', 'time': '٣٠ دقيقة', 'rating': '٤.٤'},
          {'name': 'برجر برجر', 'desc': 'برجر، بطاطس', 'price': '٣٥ درهم', 'time': '٢٠ دقيقة', 'rating': '٤.٧'},
        ];
      case 'pharmacy':
        return [
          {'name': 'صيدلية أستر', 'desc': 'أدوية ومستلزمات طبية', 'price': 'متاح', 'time': '٢٠ دقيقة', 'rating': '٤.٩'},
          {'name': 'صيدلية دبي', 'desc': 'أدوية ووصفات', 'price': 'متاح', 'time': '١٥ دقيقة', 'rating': '٤.٧'},
          {'name': 'صيدلية الحياة', 'desc': 'فيتامينات ومكملات', 'price': 'متاح', 'time': '٢٥ دقيقة', 'rating': '٤.٥'},
        ];
      case 'courier':
        return [
          {'name': 'توصيل سريع', 'desc': 'توصيل خلال ساعة', 'price': '٢٥ درهم', 'time': '٦٠ دقيقة', 'rating': '٤.٦'},
          {'name': 'توصيل قياسي', 'desc': 'توصيل خلال ٤ ساعات', 'price': '١٥ درهم', 'time': '٢٤٠ دقيقة', 'rating': '٤.٣'},
          {'name': 'توصيل طرود كبيرة', 'desc': 'أثاث ومعدات', 'price': 'يُحدد لاحقاً', 'time': '٢٤ ساعة', 'rating': '٤.١'},
        ];
      case 'ride':
        return [
          {'name': 'سيارة عائلية', 'desc': 'حتى ٤ ركاب', 'price': '٤٠ درهم', 'time': '٥ دقائق', 'rating': '٤.٨'},
          {'name': 'سيارة اقتصادية', 'desc': 'حتى ٣ ركاب', 'price': '٢٥ درهم', 'time': '٣ دقائق', 'rating': '٤.٥'},
          {'name': 'فخامة', 'desc': 'سيارة راقية', 'price': '٧٥ درهم', 'time': '١٠ دقائق', 'rating': '٤.٩'},
        ];
      case 'shopping':
        return [
          {'name': 'سوبر ماركت كارفور', 'desc': 'مواد غذائية', 'price': 'دقيقة', 'time': '٣٠ دقيقة', 'rating': '٤.٧'},
          {'name': 'لولو هايبر ماركت', 'desc': 'كل المقاضي', 'price': 'دقيقة', 'time': '٢٥ دقيقة', 'rating': '٤.٦'},
          {'name': 'ميني مول', 'desc': 'مقاضي سريعة', 'price': 'دقيقة', 'time': '١٥ دقيقة', 'rating': '٤.٤'},
        ];
      case 'tourism':
        return [
          {'name': 'جولة برج خليفة', 'desc': 'أعلى برج في العالم', 'price': '١٥٠ درهم', 'time': 'ساعتان', 'rating': '٤.٩'},
          {'name': 'سفاري الصحراء', 'desc': 'مغامرة رملية', 'price': '٢٠٠ درهم', 'time': '٤ ساعات', 'rating': '٤.٨'},
          {'name': 'جولة المتاحف', 'desc': 'متحف المستقبل', 'price': '١٢٠ درهم', 'time': '٣ ساعات', 'rating': '٤.٧'},
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = _demoItems;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // الخلفية مع توهج بلون الخدمة
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [
                          service.color.withValues(alpha: 0.06),
                          AppColors.backgroundPrimary,
                          AppColors.backgroundPrimary,
                        ]
                      : [
                          service.color.withValues(alpha: 0.04),
                          AppColors.lightBackground,
                          AppColors.lightBackground,
                        ],
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 180,
                  pinned: true,
                  backgroundColor: isDark
                      ? AppColors.backgroundPrimary
                      : AppColors.lightBackground,
                  leading: Container(
                    margin: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceCard.withValues(alpha: 0.9)
                          : AppColors.lightSurface.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.outline : AppColors.lightOutline,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(LucideIcons.chevronLeft, size: 18),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            service.color.withValues(alpha: 0.2),
                            service.color.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(AppRadii.xxl),
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceCard
                                : AppColors.lightSurface,
                            borderRadius: BorderRadius.circular(AppRadii.xxl),
                            border: Border.all(
                              color: service.color.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                            boxShadow: AppShadows.glowGreen,
                          ),
                          child: Icon(
                            MockData.getIconByName(service.iconName),
                            size: 48,
                            color: service.color,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.title,
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          service.subtitle,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        Text(
                          'الخيارات المتاحة',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        ...items.map((item) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailPageTemplate(
                                    title: item['name']!,
                                    subtitle: item['desc']!,
                                    icon: MockData.getIconByName(service.iconName),
                                    accentColor: service.color,
                                    price: item['price'],
                                    deliveryTime: item['time'],
                                    rating: item['rating'],
                                    description:
                                        '${item['name']} - ${item['desc']}. متوفر الآن عبر گريب منك.',
                                    primaryActionLabel: 'اطلب الآن',
                                    secondaryActionLabel: 'أضف للمفضلة',
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.surfaceCard
                                    : AppColors.lightSurface,
                                borderRadius: BorderRadius.circular(AppRadii.xl),
                                border: Border.all(
                                  color: service.color.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: service.color.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(AppRadii.md),
                                    ),
                                    child: Icon(
                                      MockData.getIconByName(service.iconName),
                                      color: service.color,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['name']!,
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        Text(
                                          item['desc']!,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(height: AppSpacing.sm),
                                        Row(
                                          children: [
                                            Icon(LucideIcons.star, size: 14, color: AppColors.warning),
                                            const SizedBox(width: AppSpacing.xs),
                                            Text(
                                              item['rating']!,
                                              style: theme.textTheme.labelMedium,
                                            ),
                                            const SizedBox(width: AppSpacing.md),
                                            Icon(LucideIcons.clock, size: 14, color: AppColors.info),
                                            const SizedBox(width: AppSpacing.xs),
                                            Text(
                                              item['time']!,
                                              style: theme.textTheme.labelMedium,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        item['price']!,
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          color: AppColors.accentPrimary,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.sm),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.md,
                                          vertical: AppSpacing.xs,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(255, 224, 246, 190),
                                          borderRadius: BorderRadius.circular(AppRadii.full),
                                        ),
                                        child: const Text(
                                          'اطلب الآن',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: AppSpacing.lg),

                        // زر إنشاء طلب جديد لهذه الخدمة
                        AppButton(
                          label: 'اطلب من ${service.title}',
                          icon: LucideIcons.shoppingCart,
                          color: service.color,
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => _buildCreateOrderSheet(context, theme),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // نافذة إنشاء طلب
  Widget _buildCreateOrderSheet(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'طلب جديد - ${service.title}',
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          TextField(
            decoration: const InputDecoration(
              labelText: 'وصف الطلب',
              hintText: 'اكتب تفاصيل طلبك هنا...',
              prefixIcon: Icon(LucideIcons.pencil),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            decoration: const InputDecoration(
              labelText: 'موقع التوصيل',
              prefixIcon: Icon(LucideIcons.mapPin),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: 'إرسال الطلب',
            icon: LucideIcons.send,
            color: service.color,
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم إرسال طلبك بنجاح ✅'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}