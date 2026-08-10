import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/mock_data/mock_data.dart';
import '../../core/theme/design_tokens.dart';
import '../../shared_widgets/app_button.dart';

// شاشة خدمة مخصّصة لكل خدمة — تعرض صورة الخدمة + قائمة الخيارات المتاحة.
// تُستخدم لجميع الخدمات الجديدة (نقل، تكاسي، كهرباء...) بأسلوب احترافي موحّد.
class ServiceDetailScreen extends StatelessWidget {
  final ServiceCategory service;

  const ServiceDetailScreen({
    super.key,
    required this.service,
  });

  // بيانات وهمية لكل خدمة حسب المعرّف (id)
  List<Map<String, String>> get _items {
    switch (service.id) {
      case 'moving':
        return [
          {'name': 'نقل أثاث منزلي', 'desc': 'فك وتركيب وتغليف', 'price': '١٥٠ درهم', 'time': '٣ ساعات', 'rating': '٤.٧'},
          {'name': 'نقل مكاتب', 'desc': 'أجهزة ومعدات', 'price': '٣٠٠ درهم', 'time': '٥ ساعات', 'rating': '٤.٥'},
          {'name': 'توصيل قطع مفردة', 'desc': 'كنبة أو ثلاجة', 'price': '٦٠ درهم', 'time': 'ساعة', 'rating': '٤.٦'},
        ];
      case 'taxi':
        return [
          {'name': 'تاكسي اقتصادي', 'desc': 'حتى ٤ ركاب', 'price': '١٢ درهم', 'time': '٣ دقائق', 'rating': '٤.٥'},
          {'name': 'تاكسي فخم', 'desc': 'سيارة راقية', 'price': '٣٥ درهم', 'time': '٥ دقائق', 'rating': '٤.٨'},
          {'name': 'تاكسي ٧ ركاب', 'desc': 'عائلي كبير', 'price': '٢٠ درهم', 'time': '٦ دقائق', 'rating': '٤.٤'},
        ];
      case 'electricity':
        return [
          {'name': 'فني كهرباء منزلي', 'desc': 'تركيب وصيانة', 'price': '٨٠ درهم', 'time': '٤٥ دقيقة', 'rating': '٤.٧'},
          {'name': 'صيانة طوارئ', 'desc': 'أعطال فورية', 'price': '١٢٠ درهم', 'time': '٣٠ دقيقة', 'rating': '٤.٦'},
          {'name': 'تركيب إنارة', 'desc': 'ديكور وحدائق', 'price': '٩٠ درهم', 'time': 'ساعة', 'rating': '٤.٥'},
        ];
      case 'water':
        return [
          {'name': 'توصيل مياه ٥ جالون', 'desc': 'صافية ومعقمة', 'price': '٢٥ درهم', 'time': '٣٠ دقيقة', 'rating': '٤.٨'},
          {'name': 'صيانة خزان', 'desc': 'تنظيف وتعقيم', 'price': '١١٠ درهم', 'time': 'ساعتان', 'rating': '٤.٦'},
          {'name': 'تركيب فلتر', 'desc': 'مياه الشرب', 'price': '١٥٠ درهم', 'time': 'ساعة', 'rating': '٤.٧'},
        ];
      case 'laundry':
        return [
          {'name': 'غسيل وكيّ يومي', 'desc': 'ملابس عادية', 'price': '١٥ درهم/كغ', 'time': '٢٤ ساعة', 'rating': '٤.٦'},
          {'name': 'تنظيف جاف', 'desc': 'بدلات ومعاطف', 'price': '٢٥ درهم', 'time': '٤٨ ساعة', 'rating': '٤.٧'},
          {'name': 'غسيل سجاد', 'desc': 'بخار عميق', 'price': '٤٠ درهم', 'time': '٣ أيام', 'rating': '٤.٥'},
        ];
      case 'clothes':
        return [
          {'name': 'تفصيل ملابس', 'desc': 'حسب الطلب', 'price': '١٢٠ درهم', 'time': '٣ أيام', 'rating': '٤.٧'},
          {'name': 'تعديل وخياطة', 'desc': 'تضييق وتطويل', 'price': '٣٠ درهم', 'time': 'يوم', 'rating': '٤.٦'},
          {'name': 'تأجير زي رسمي', 'desc': 'مناسبات', 'price': '٢٠٠ درهم', 'time': 'يوم', 'rating': '٤.٤'},
        ];
      case 'phones':
        return [
          {'name': 'إصلاح شاشة', 'desc': 'كسر أو شرخ', 'price': '٢٥٠ درهم', 'time': 'ساعة', 'rating': '٤.٧'},
          {'name': 'استبدال بطارية', 'desc': 'أداء أفضل', 'price': '١٢٠ درهم', 'time': '٤٥ دقيقة', 'rating': '٤.٦'},
          {'name': 'صيانة مائية', 'desc': 'سقوط بالماء', 'price': '٣٠٠ درهم', 'time': 'ساعتان', 'rating': '٤.٥'},
        ];
      case 'devices':
        return [
          {'name': 'صيانة لابتوب', 'desc': 'برمجيات وعتاد', 'price': '١٨٠ درهم', 'time': 'يوم', 'rating': '٤.٧'},
          {'name': 'إصلاح تابلت', 'desc': 'شاشة وبطارية', 'price': '٢٢٠ درهم', 'time': 'يوم', 'rating': '٤.٦'},
          {'name': 'ترقية جهاز', 'desc': 'سرعة وأداء', 'price': '٣٥٠ درهم', 'time': 'يومان', 'rating': '٤.٥'},
        ];
      case 'appliances':
        return [
          {'name': 'تركيب ثلاجة', 'desc': 'توصيل وتشغيل', 'price': '٩٠ درهم', 'time': 'ساعة', 'rating': '٤.٧'},
          {'name': 'صيانة غسالة', 'desc': 'أعطال شائعة', 'price': '١١٠ درهم', 'time': 'ساعة', 'rating': '٤.٦'},
          {'name': 'إصلاح مكيف', 'desc': 'تبريد وتنظيف', 'price': '١٣٠ درهم', 'time': 'ساعة', 'rating': '٤.٥'},
        ];
      case 'office':
        return [
          {'name': 'تأجير طابعة', 'desc': 'شهرية', 'price': '١٥٠ درهم', 'time': 'يوم', 'rating': '٤.٦'},
          {'name': 'بيع أثاث مكتبي', 'desc': 'مكاتب وكراسي', 'price': '٤٠٠ درهم', 'time': 'يوم', 'rating': '٤.٥'},
          {'name': 'صيانة معدات', 'desc': 'دورية', 'price': '٢٠٠ درهم', 'time': 'يوم', 'rating': '٤.٤'},
        ];
      case 'delivery':
        return [
          {'name': 'توصيل سريع', 'desc': 'خلال ساعة', 'price': '٢٥ درهم', 'time': '٦٠ دقيقة', 'rating': '٤.٦'},
          {'name': 'توصيل قياسي', 'desc': 'خلال ٤ ساعات', 'price': '١٥ درهم', 'time': '٢٤٠ دقيقة', 'rating': '٤.٣'},
          {'name': 'توصيل طرود كبيرة', 'desc': 'أثاث ومعدات', 'price': 'يُحدد لاحقاً', 'time': '٢٤ ساعة', 'rating': '٤.١'},
        ];
      case 'estore':
        return [
          {'name': 'متجر إلكتروني ١', 'desc': 'إلكترونيات', 'price': 'تسوّق', 'time': '٢-٥ أيام', 'rating': '٤.٧'},
          {'name': 'متجر إلكتروني ٢', 'desc': 'أزياء', 'price': 'تسوّق', 'time': '٢-٥ أيام', 'rating': '٤.٦'},
          {'name': 'متجر إلكتروني ٣', 'desc': 'مستلزمات منزل', 'price': 'تسوّق', 'time': '٢-٥ أيام', 'rating': '٤.٥'},
        ];
      case 'travel':
        return [
          {'name': 'حجز طيران', 'desc': 'داخلي وخارجي', 'price': 'يُحدد', 'time': 'لحظي', 'rating': '٤.٨'},
          {'name': 'حجز فندق', 'desc': 'جميع الدرجات', 'price': 'يُحدد', 'time': 'لحظي', 'rating': '٤.٧'},
          {'name': 'باقة عطل', 'desc': 'طيران+إقامة', 'price': 'يُحدد', 'time': 'لحظي', 'rating': '٤.٦'},
        ];
      case 'tourism_extra':
        return [
          {'name': 'جولة سياحية', 'desc': 'مع مرشد', 'price': '١٢٠ درهم', 'time': '٣ ساعات', 'rating': '٤.٨'},
          {'name': 'رحلة صحراء', 'desc': 'مغامرة', 'price': '٢٠٠ درهم', 'time': '٤ ساعات', 'rating': '٤.٧'},
          {'name': 'تذكرة متحف', 'desc': 'فعاليات', 'price': '٨٠ درهم', 'time': 'يوم', 'rating': '٤.٦'},
        ];
      case 'medicine':
        return [
          {'name': 'صيدلية أستر', 'desc': 'أدوية ومستلزمات', 'price': 'متاح', 'time': '٢٠ دقيقة', 'rating': '٤.٩'},
          {'name': 'صيدلية دبي', 'desc': 'أدوية ووصفات', 'price': 'متاح', 'time': '١٥ دقيقة', 'rating': '٤.٧'},
          {'name': 'صيدلية الحياة', 'desc': 'فيتامينات', 'price': 'متاح', 'time': '٢٥ دقيقة', 'rating': '٤.٥'},
        ];
      case 'pharmacy_extra':
        return [
          {'name': 'صيدلية قريبة ١', 'desc': 'أدوية ووصفات', 'price': 'متاح', 'time': '١٠ دقائق', 'rating': '٤.٨'},
          {'name': 'صيدلية قريبة ٢', 'desc': 'مستلزمات طبية', 'price': 'متاح', 'time': '١٥ دقيقة', 'rating': '٤.٦'},
          {'name': 'صيدلية قريبة ٣', 'desc': 'فيتامينات', 'price': 'متاح', 'time': '٢٠ دقيقة', 'rating': '٤.٥'},
        ];
      case 'consult':
        return [
          {'name': 'استشارة باطنة', 'desc': 'عن بُعد', 'price': '١٢٠ درهم', 'time': '٣٠ دقيقة', 'rating': '٤.٨'},
          {'name': 'استشارة جلدية', 'desc': 'عن بُعد', 'price': '١٤٠ درهم', 'time': '٣٠ دقيقة', 'rating': '٤.٧'},
          {'name': 'استشارة تغذية', 'desc': 'عن بُعد', 'price': '١٠٠ درهم', 'time': '٣٠ دقيقة', 'rating': '٤.٦'},
        ];
      case 'freight':
        return [
          {'name': 'شحن محلي', 'desc': 'داخل الدولة', 'price': 'يُحدد', 'time': '٢-٣ أيام', 'rating': '٤.٦'},
          {'name': 'شحن خليجي', 'desc': 'دول الخليج', 'price': 'يُحدد', 'time': '٥-٧ أيام', 'rating': '٤.٥'},
          {'name': 'شحن دولي', 'desc': 'عالمي', 'price': 'يُحدد', 'time': '٧-١٤ يوم', 'rating': '٤.٤'},
        ];
      default:
        return const [
          {'name': 'خيار ١', 'desc': 'تفاصيل الخدمة', 'price': 'يُحدد', 'time': 'قريباً', 'rating': '٤.٥'},
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final items = _items;

    return Scaffold(
      body: Stack(
        children: [
          // خلفية بتوهج لون الخدمة
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [service.color.withValues(alpha: 0.06), AppColors.backgroundPrimary, AppColors.backgroundPrimary]
                      : [service.color.withValues(alpha: 0.04), AppColors.lightBackground, AppColors.lightBackground],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 220,
                  pinned: true,
                  backgroundColor: isDark ? AppColors.backgroundPrimary : AppColors.lightBackground,
                  leading: Container(
                    margin: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceCard.withValues(alpha: 0.9)
                          : AppColors.lightSurface.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      border: Border.all(color: isDark ? AppColors.outline : AppColors.lightOutline),
                    ),
                    child: IconButton(
                      icon: const Icon(LucideIcons.chevronLeft, size: 18),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildHeader(isDark),
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
                          style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          service.subtitle,
                          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          'الخيارات المتاحة',
                          style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ...items.map((item) => _itemCard(context, theme, item)),
                        const SizedBox(height: AppSpacing.lg),
                        AppButton(
                          label: 'اطلب من ${service.title}',
                          icon: LucideIcons.shoppingCart,
                          color: service.color,
                          onPressed: () => showModalBottomSheet(
                            context: context,
                            builder: (context) => _buildOrderSheet(context, theme),
                          ),
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

  // رأس الشاشة: صورة الخدمة + أيقونة احتياطية
  Widget _buildHeader(bool isDark) {
    final iconData = MockData.getIconByName(service.iconName);
    final image = service.imageUrl;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [service.color.withValues(alpha: 0.22), service.color.withValues(alpha: 0.05)],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppRadii.xxl)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // الصورة المميّزة للخدمة (إن وُجدت)
          if (image != null)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppRadii.xxl)),
                child: Image.network(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          // طبقة تعتيم خفيفة لقراءة أفضل
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    service.color.withValues(alpha: 0.45),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppRadii.xxl)),
              ),
            ),
          ),
          // أيقونة الخدمة دائرية فوق الصورة
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceCard.withValues(alpha: 0.92) : AppColors.lightSurface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(AppRadii.xxl),
              border: Border.all(color: service.color.withValues(alpha: 0.4), width: 1.5),
              boxShadow: AppShadows.glowGreen,
            ),
            child: Icon(iconData, size: 46, color: service.color),
          ),
        ],
      ),
    );
  }

  Widget _itemCard(BuildContext context, ThemeData theme, Map<String, String> item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceCard
            : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: service.color.withValues(alpha: 0.2), width: 1),
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
            child: Icon(MockData.getIconByName(service.iconName), color: service.color, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name']!, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSpacing.xs),
                Text(item['desc']!,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(LucideIcons.star, size: 14, color: AppColors.warning),
                    const SizedBox(width: AppSpacing.xs),
                    Text(item['rating']!, style: theme.textTheme.labelMedium),
                    const SizedBox(width: AppSpacing.md),
                    Icon(LucideIcons.clock, size: 14, color: AppColors.info),
                    const SizedBox(width: AppSpacing.xs),
                    Text(item['time']!, style: theme.textTheme.labelMedium),
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
              Text(item['price']!,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.accentPrimary,
                    fontWeight: FontWeight.w800,
                  )),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 224, 246, 190),
                  borderRadius: BorderRadius.circular(AppRadii.full),
                ),
                child: const Text('اطلب الآن',
                    style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // نافذة إنشاء طلب
  Widget _buildOrderSheet(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('طلب جديد - ${service.title}', style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xl),
          const TextField(
            decoration: InputDecoration(
              labelText: 'وصف الطلب',
              hintText: 'اكتب تفاصيل طلبك هنا...',
              prefixIcon: Icon(LucideIcons.pencil),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: AppSpacing.lg),
          const TextField(
            decoration: InputDecoration(
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
                SnackBar(content: const Text('تم إرسال طلبك بنجاح ✅'), backgroundColor: AppColors.success),
              );
            },
          ),
        ],
      ),
    );
  }
}
