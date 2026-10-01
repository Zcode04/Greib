import '../../../core/models/service_model.dart';
import 'services_repository.dart';

/// ============================================================================
///  ServiceProvider — مقدم خدمة (Entity).
///
///  بيانات وهمية (Mock) مولّدة حتمياً (Deterministic) من معرّف الخدمة
///  ⇒ نفس العرض في كل مرة، وبدون أي ملف JSON جديد.
/// ============================================================================
class ServiceProvider {
  final String id;
  final String name;
  final String bio;
  final double rating;

  const ServiceProvider({
    required this.id,
    required this.name,
    required this.bio,
    required this.rating,
  });
}

/// ============================================================================
///  ProviderRepository — طبقة البيانات لمقدمي الخدمة.
///
///  نفس نمط ServicesRepository: مصدر واحد للحقيقة، والواجهة لا تعرف من أين
///  تأتي البيانات (يمكن استبداله لاحقاً بطبقة API دون تغيير الواجهة).
/// ============================================================================
class ProviderRepository {
  ProviderRepository._();

  static final ProviderRepository instance = ProviderRepository._();

  static const List<String> _names = [
    'أحمد محمد',
    'سارة علي',
    'محمود حسن',
    'ليلى يوسف',
    'خالد عمر',
  ];

  static const List<String> _bios = [
    'أكثر من 8 سنوات خبرة في تقديم الخدمة لعميل Greib.',
    'أقدّم خدمة سريعة مع متابعة ما بعد الطلب.',
    'خدماتي مميزة بالأسعار المناسبة والجودة العالية.',
    'متاحة يومياً للرد على استفساراتك في أي وقت.',
    'خبرة طويلة في السوق ورضا كامل عن الخدمة.',
  ];

  /// مقدمو خدمة معيّنة (خمسة دائماً) — مرتّبين ثابتاً.
  List<ServiceProvider> forService(String serviceId) => List.generate(
    _names.length,
    (i) => ServiceProvider(
      id: '${serviceId}_p$i',
      name: _names[i],
      bio: _bios[i],
      rating: 4.4 + (i % 3) * 0.2,
    ),
  );

  /// مقدم واحد بمعرّفه (المعرّف = معرّف الخدمة + _p + الفهرس).
  ServiceProvider? byId(String providerId) {
    final parts = providerId.split('_p');
    if (parts.length != 2) return null;
    final all = forService(parts.first);
    final index = int.tryParse(parts.last);
    if (index == null || index < 0 || index >= all.length) return null;
    return all[index];
  }

  /// منشورات مقدم الخدمة: مصدرها منشورات الخدمة نفسها (مصدر واحد للحقيقة)،
  /// مرتّبة بترتيب ثابت مشتق من اسمه ⇒ نفس العرض في كل فتح.
  List<ServicePost> postsFor(String providerId) {
    final provider = byId(providerId);
    if (provider == null) return const [];
    final source = ServicesRepository.instance.postsFor(
      providerId.split('_p').first,
    );
    return List<ServicePost>.of(source)
      ..sort((a, b) => a.text.hashCode.compareTo(b.text.hashCode));
  }
}
