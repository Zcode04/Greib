import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/extensions/context_extensions.dart';
import 'user_request_sheet.dart';

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
  static const double _imageHeight = 170;

  @override
  Widget build(BuildContext context) {
    final bottomColor = context.backgroundColors.surface;

    return GestureDetector(
      // ★ الضغط على البطاقة يفتح شيت الخدمات
      onTap: onTap ?? () => showUserRequestSheet(context),
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
                    // ── الشريط السفلي: الرائج + اطلب الآن ──
                    // الزر الدائري متقاطع في المنتصف على الخط الفاصل (مثل فيسبوك)
                    Expanded(
                      child: Container(
                        width: _cardWidth,
                        decoration: BoxDecoration(
                          color: bottomColor,
                          border: Border(
                            top: BorderSide(
                              color: context.accentColor,
                              width: 2.5,
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.only(top: 22, bottom: 6),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'الرائج',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: context.textColors.secondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'اطلب الآن',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: context.textColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // ── الزر الدائري 🔥 في المنتصف على الخط الفاصل ──
                // ★ نفس موضع زر (+) فيسبوك: متقاطع بين الصورة والشريط
                Positioned(
                  top: _imageHeight - 18,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.accentColor,
                        // ★ نفس ستايل زر (+) فيسبوك: حد بلون الشريط + ظل بارز
                        border: Border.all(
                          color: bottomColor,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        LucideIcons.flame,
                        color: Colors.white,
                        size: 18,
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
