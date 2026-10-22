// features/liveserver/live_merchants_screen.dart
//
// صفحة «التجار في البث الآن» (المسار /live-merchants).
// ★ تُفتح من «الاتصال المباشر بالتاجر» في صفحة اختيار وضع البث.
// ★ تعرض قائمة بالمتاجر التي تبثّ الآن (من متاجر التطبيق الحقيقية)،
//   ويمكن للمستخدم الاتصال بأحدهم ⇒ شاشة الاتصال (/liveserver).
// ★ محاكاة واجهة (UI Mock) — ستُطوَّر لاحقاً بربط بث حقيقي.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/extensions/context_extensions.dart';
import '../../core/models/account_model.dart';
import '../services/data/account_repository.dart';

/// LiveMerchantsScreen — قائمة التجار الذين يبثّون الآن (المسار /live-merchants).
class LiveMerchantsScreen extends StatelessWidget {
  const LiveMerchantsScreen({super.key});

  /// ★ عدد المتاجر التي نعتبرها «تبثّ الآن» (محاكاة ثابتة في كل مرة).
  static const int _liveCount = 8;

  List<AccountProfile> get _liveStores => AccountRepository.instance.all
      .take(_liveCount)
      .toList(growable: false);

  @override
  Widget build(BuildContext context) {
    final stores = _liveStores;
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F17),
      body: SafeArea(
        child: Column(
          children: [
            const _MerchantsTopBar(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                physics: const BouncingScrollPhysics(),
                itemCount: stores.length + 1,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  if (i == 0) return const _MerchantsHeader();
                  final store = stores[i - 1];
                  return _LiveStoreTile(
                    store: store,
                    viewers: 120 + (i - 1) * 37,
                    onConnect: () => _connect(context, store),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ★ الاتصال بالتاجر: فتح شاشة الاتصال بنفس مكوّن البث الحالي.
  void _connect(BuildContext context, AccountProfile store) {
    HapticFeedback.mediumImpact();
    context.push('/liveserver?store=${store.id}');
  }
}

/// الشريط العلوي: رجوع + عنوان + شارة «مباشر».
class _MerchantsTopBar extends StatelessWidget {
  const _MerchantsTopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 14, 4),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.pop(),
              customBorder: const CircleBorder(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.chevronRight,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'التجار في البث الآن',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: context.iconColors.error,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.radio, size: 14, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  'مباشر',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ترويسة القائمة: عنوان + وصف إرشادي.
class _MerchantsHeader extends StatelessWidget {
  const _MerchantsHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'التجار الذين يبثّون الآن',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'اختر تاجراً للاتصال به مباشرة.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// صف تاجر واحد يبثّ الآن: أفاتار بإطار مباشر + الاسم + المشاهدون + زر اتصال.
class _LiveStoreTile extends StatelessWidget {
  const _LiveStoreTile({
    required this.store,
    required this.viewers,
    required this.onConnect,
  });

  final AccountProfile store;
  final int viewers;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = store.avatarUrl;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onConnect,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              // ★ الأفاتار بإطار «مباشر».
              Container(
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.iconColors.error,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white24,
                  backgroundImage: avatarUrl == null
                      ? null
                      : NetworkImage(avatarUrl),
                  child: avatarUrl == null
                      ? const Icon(
                          LucideIcons.store,
                          size: 22,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            store.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (store.isVerified) ...[
                          const SizedBox(width: 4),
                          Icon(
                            LucideIcons.badgeCheck,
                            size: 14,
                            color: context.iconColors.info,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: context.iconColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'يبثّ الآن',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          LucideIcons.eye,
                          size: 13,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$viewers',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // ★ زر الاتصال (هاتف).
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1E3A8A), Color(0xFF0EA5E9)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.phoneCall,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
