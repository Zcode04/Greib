import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';
import '../../shared_widgets/app_button.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  int _selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();

  final List<Map<String, dynamic>> _reviews = [
    {
      'user': 'أحمد محمد',
      'rating': 5,
      'comment': 'خدمة ممتازة وسريعة جداً!',
      'time': 'منذ يومين',
      'order': 'طلب برياني',
    },
    {
      'user': 'سارة علي',
      'rating': 4,
      'comment': 'جيدة جداً ولكن التأخير بسيط',
      'time': 'منذ أسبوع',
      'order': 'توصيل أدوية',
    },
    {
      'user': 'محمد خالد',
      'rating': 5,
      'comment': 'أفضل تطبيق خدمات في الإمارات',
      'time': 'منذ أسبوعين',
      'order': 'توصيل طرود',
    },
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('التقييمات والمراجعات'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // إضافة تقييم جديد
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أضف تقييمك',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedRating = index + 1);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: AppSpacing.xs),
                            child: Icon(
                              index < _selectedRating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: AppColors.warning,
                              size: 32,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _commentController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'اكتب تعليقك هنا...',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      label: 'إرسال التقييم',
                      icon: Icons.send,
                      onPressed: _submitReview,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            Text(
              'آخر التقييمات',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.md),

            ..._reviews.map((review) {
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
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppRadii.full),
                            ),
                            child: Icon(
                              Icons.person,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  review['user'] as String,
                                  style: theme.textTheme.titleMedium,
                                ),
                                Row(
                                  children: [
                                    ...List.generate(5, (index) {
                                      return Icon(
                                        index < (review['rating'] as int)
                                            ? Icons.star
                                            : Icons.star_border,
                                        size: 14,
                                        color: AppColors.warning,
                                      );
                                    }),
                                    const SizedBox(width: AppSpacing.sm),
                                    Text(
                                      review['time'] as String,
                                      style: theme.textTheme.bodySmall,
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
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'طلب: ${review['order']}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _submitReview() {
    if (_selectedRating == 0 || _commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تحديد التقييم وكتابة تعليق'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _reviews.insert(0, {
        'user': 'أنت',
        'rating': _selectedRating,
        'comment': _commentController.text.trim(),
        'time': 'الآن',
        'order': 'طلب حديث',
      });
      _selectedRating = 0;
      _commentController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إرسال تقييمك بنجاح ✅'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
