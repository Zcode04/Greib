import 'package:flutter/material.dart';
import '../../core/mock_data/mock_data.dart';
import '../../shared_widgets/app_button.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(service.title),
        backgroundColor: service.color,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقة وصف الخدمة
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: service.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: service.color,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      MockData.getIconByName(service.iconName),
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.title,
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          service.subtitle,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // قائمة الخيارات
            Text(
              'الخيارات المتاحة',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),

            ...items.map((item) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: service.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      MockData.getIconByName(service.iconName),
                      color: service.color,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    item['name']!,
                    style: theme.textTheme.titleMedium,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(item['desc']!),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(item['rating']!),
                          const SizedBox(width: 12),
                          Icon(Icons.schedule, size: 14),
                          const SizedBox(width: 4),
                          Text(item['time']!),
                        ],
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        item['price']!,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('تمت إضافة ${item['name']} إلى سلتك 🛒'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'اطلب الآن',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 16),

            // زر إنشاء طلب جديد لهذه الخدمة
            AppButton(
              label: 'اطلب من ${service.title}',
              icon: Icons.add_shopping_cart,
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
    );
  }

  // نافذة إنشاء طلب
  Widget _buildCreateOrderSheet(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'طلب جديد - ${service.title}',
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextField(
            decoration: const InputDecoration(
              labelText: 'وصف الطلب',
              hintText: 'اكتب تفاصيل طلبك هنا...',
              prefixIcon: Icon(Icons.edit),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'موقع التوصيل',
              prefixIcon: Icon(Icons.location_on),
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'إرسال الطلب',
            icon: Icons.send,
            color: service.color,
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم إرسال طلبك بنجاح ✅'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}