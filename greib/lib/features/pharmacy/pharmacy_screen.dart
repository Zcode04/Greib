import 'package:flutter/material.dart';
import '../../shared_widgets/app_button.dart';

// صفحة الصيدلية
class PharmacyScreen extends StatelessWidget {
  const PharmacyScreen({super.key});

  static const List<Map<String, String>> pharmacies = [
    {
      'name': 'صيدلية أستر',
      'desc': 'أدوية ومستلزمات طبية',
      'rating': '4.9',
      'time': '20 دقيقة',
      'image': '💊',
      'available': 'مفتوحة الآن',
    },
    {
      'name': 'صيدلية دبي',
      'desc': 'أدوية ووصفات طبية',
      'rating': '4.7',
      'time': '15 دقيقة',
      'image': '⚕️',
      'available': 'مفتوحة الآن',
    },
    {
      'name': 'صيدلية الحياة',
      'desc': 'فيتامينات ومكملات غذائية',
      'rating': '4.5',
      'time': '25 دقيقة',
      'image': '🌿',
      'available': 'مفتوحة 24/7',
    },
    {
      'name': 'صيدلية النور',
      'desc': 'مستحضرات تجميل طبية',
      'rating': '4.6',
      'time': '30 دقيقة',
      'image': '🧴',
      'available': 'مفتوحة الآن',
    },
    {
      'name': 'صيدلية المدينة',
      'desc': 'معدات طبية وقياس السكر',
      'rating': '4.3',
      'time': '25 دقيقة',
      'image': '🩺',
      'available': 'مفتوحة الآن',
    },
    {
      'name': 'صيدلية الشفاء',
      'desc': 'أدوية الأطفال والعناية',
      'rating': '4.8',
      'time': '18 دقيقة',
      'image': '👶',
      'available': 'مفتوحة 24/7',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الصيدلية'),
        backgroundColor: const Color(0xFF4CAF50),
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
                  colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Text('💊', style: TextStyle(fontSize: 40)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'صحتك أولوية',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'الصيدليات قريبة منك ونوصل للأدوية لحد باب البيت',
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

            // رفع وصفة طبية
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'عندك وصفة طبية؟',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      label: 'ارفع صورة الوصفة',
                      icon: Icons.upload_file,
                      color: const Color(0xFF4CAF50),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم استلام الوصفة، سنراجعها ونواصل معك قريباً ✅'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // قسم الصيدليات
            Text(
              'أقرب الصيدليات',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),

            // قائمة الصيدليات
            ...pharmacies.map((pharmacy) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        pharmacy['image']!,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  title: Text(
                    pharmacy['name']!,
                    style: theme.textTheme.titleMedium,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(pharmacy['desc']!),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(pharmacy['rating']!),
                          const SizedBox(width: 12),
                          const Icon(Icons.schedule, size: 14),
                          const SizedBox(width: 4),
                          Text(pharmacy['time']!),
                        ],
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          pharmacy['available']!,
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'اطلب الآن',
                        style: TextStyle(
                          color: Color(0xFF4CAF50),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}