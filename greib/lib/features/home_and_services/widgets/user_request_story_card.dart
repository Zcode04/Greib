import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/extensions/context_extensions.dart';

// ─────────────────────────────────────────────
//  بطاقة المستخدم — ستايل قصص فيسبوك (FB Create Story)
//  صورة فوق + زر دائري متقاطع في النص + نص تحت
//  الفرق عن فيسبوك:
//   - فيسبوك: زر (+) أزرق + نص (إنشاء قصة)
//   - نحن: زر (🔥 الرائج) + نص (اطلب الآن)
// ─────────────────────────────────────────────
class UserRequestStoryCard extends StatelessWidget {
  final VoidCallback? onTap;

  /// صورة القسم العلوي (نفس فكرة صورة المستخدم في كرت فيسبوك)
  final String imageUrl;

  const UserRequestStoryCard({
    super.key,
    this.onTap,
    this.imageUrl =
        'https://images.unsplash.com/photo-1600880292203-757bb62b4baf?w=400&q=80',
  });

  static const double _cardWidth = 130;
  static const double _cardHeight = 240;
  static const double _imageHeight = 175;
  static const double _buttonSize = 44;

  @override
  Widget build(BuildContext context) {
    final bottomColor = context.backgroundColors.surface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _cardWidth,
        height: _cardHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          // ★ إطار خارجي حول البطاقة — نفس لون إطارات بطاقات الرائج
          border: Border.all(
            color: context.backgroundColors.outline,
            width: 1.2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: SizedBox(
            width: _cardWidth,
            height: _cardHeight,
            child: Stack(
              children: [
                // ── العمود الأساسي: صورة فوق + شريط نص تحت ──
                Column(
                  children: [
                    // الصورة العلوية (مثل صورة المستخدم في كرت فيسبوك)
                    SizedBox(
                      width: _cardWidth,
                      height: _imageHeight,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: Colors.grey.shade800,
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.white54,
                            size: 40,
                          ),
                        ),
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: Colors.grey.shade900,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white54,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // الشريط السفلي (مثل الشريط الأبيض في كرت فيسبوك)
                    Expanded(
                      child: Container(
                        width: _cardWidth,
                        color: bottomColor,
                        padding: const EdgeInsets.only(top: 24, bottom: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'اطلب الآن',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.textColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'خدمة شخصية',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.textColors.secondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // ── الزر الدائري المتقاطع في النص (مكان زر + في فيسبوك) ──
                // فيسبوك: دائرة زرقاء بأيقونة (+) بيضاء
                // نحن: دائرة بلون البراند بأيقونة الرائج (🔥 flame) بيضاء
                Positioned(
                  top: _imageHeight - (_buttonSize / 2),
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: _buttonSize,
                      height: _buttonSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.accentColor,
                        border: Border.all(
                          color: bottomColor,
                          width: 3.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        LucideIcons.flame,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
