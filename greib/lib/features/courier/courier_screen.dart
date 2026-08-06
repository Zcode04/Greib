import 'package:flutter/material.dart';
import '../../shared_widgets/app_button.dart';

// صفحة نقل الطرود (Courier)
class CourierScreen extends StatelessWidget {
  const CourierScreen({super.key});

  static const List<Map<String, String>> courierOptions = [
    {
      'name': 'توصيل سريع',
      'desc': 'توصيل خلال ساعة واحدة',
      'price': '25 درهم',
      'time': '60 دقيقة',
      'weight': 'حتى 5 كجم',
      'icon': '⚡',
    },
    {
      'name': 'توصيل قياسي',
      'desc': 'توصيل خلال 4 ساعات',
      'price': '15 درهم',
      'time': '240 دقيقة',
      'weight': 'حتى 5 كجم',
      'icon': '🚚',
    },
    {
      'name': 'طرود كبيرة',
      'desc': 'أثاث ومعدات كبيرة',
      'price': 'يُحدد لاحقاً',
      'time': '24 ساعة',
      'weight': 'أكثر من 20 كجم',
      'icon': '📦',
    },
    {
      'name': 'مستندات رسمية',
      'desc': 'توصيل آمن للمستندات',
      'price': '20 درهم',
      'time': '30 دقيقة',
      'weight': 'خفيف',
      'icon': '📄',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('نقل الطرود'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقة ترحيبية
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Text('📦', style: TextStyle(fontSize: 40)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'نوصل أي شيء لأي مكان',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'من المستندات للأثاث الكبير',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // إنشاء طلب شحن جديد
            AppButton(
              label: 'إنشاء طلب شحن جديد',
              icon: Icons.add_box,
              color: const Color(0xFF2196F3),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => _buildNewShipmentSheet(context, theme),
                );
              },
            ),
            const SizedBox(height: 24),

            // خيارات التوصيل
            Text(
              'خيارات التوصيل',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),

            // قائمة الخيارات
            ...courierOptions.map((option) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        option['icon']!,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  title: Text(
                    option['name']!,
                    style: theme.textTheme.titleMedium,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(option['desc']!),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 14),
                          const SizedBox(width: 4),
                          Text(option['time']!),
                          const SizedBox(width: 12),
                          const Icon(Icons.fitness_center, size: 14),
                          const SizedBox(width: 4),
                          Text(option['weight']!),
                        ],
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        option['price']!,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: const Color(0xFF2196F3),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'اختر',
                        style: TextStyle(
                          color: Color(0xFF2196F3),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 24),

            // تتبع الطرد
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تتبع طردك',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'رقم التتبع',
                        hintText: 'أدخل رقم التتبع...',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      label: 'تتبع الآن',
                      icon: Icons.location_searching,
                      color: const Color(0xFF2196F3),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('جارٍ البحث عن طردك... 🔍'),
                            backgroundColor: Colors.blue,
                          ),
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
    );
  }

  // نافذة إنشاء طلب شحن
  Widget _buildNewShipmentSheet(BuildContext context, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'طلب شحن جديد',
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextField(
            decoration: const InputDecoration(
              labelText: 'وصف الطرد',
              hintText: 'مثال: صندوق ملابس',
              prefixIcon: Icon(Icons.inventory_2),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              labelText: 'موقع الاستلام',
              prefixIcon: Icon(Icons.location_on),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              labelText: 'موقع التوصيل',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'إرسال الطلب',
            icon: Icons.send,
            color: const Color(0xFF2196F3),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إرسال طلب الشحن بنجاح ✅'),
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