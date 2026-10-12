// Central Content Localization — التبويبات والبيانات الديناميكية.
// مهيأ للربط المستقبلي مع API دون تغيير بنية الكود.
class ContentKeys {
  static const String all = 'all';
  static const String electronics = 'electronics';
  static const String food = 'food';
  static const String pharmacy = 'pharmacy';
  static const String fashion = 'fashion';
  static const String services = 'services';
  static const String stores = 'stores';
  static const String travel = 'travel';
  static const String hotels = 'hotels';
  static const String doctors = 'doctors';
}

class LocalizedItem {
  final String id;
  final String titleAr;
  final String titleEn;
  const LocalizedItem({required this.id, required this.titleAr, required this.titleEn});
  String titleFor(String locale) => locale == 'en' ? titleEn : titleAr;
}

class AppContentLocalization {
  static const List<LocalizedItem> tabs = [
    LocalizedItem(id: ContentKeys.all, titleAr: 'الكل', titleEn: 'All'),
    LocalizedItem(id: ContentKeys.electronics, titleAr: 'إلكترونيات', titleEn: 'Electronics'),
    LocalizedItem(id: ContentKeys.food, titleAr: 'طعام', titleEn: 'Food'),
    LocalizedItem(id: ContentKeys.pharmacy, titleAr: 'صيدلية', titleEn: 'Pharmacy'),
    LocalizedItem(id: ContentKeys.fashion, titleAr: 'أزياء', titleEn: 'Fashion'),
    LocalizedItem(id: ContentKeys.services, titleAr: 'خدمات', titleEn: 'Services'),
    LocalizedItem(id: ContentKeys.stores, titleAr: 'متاجر', titleEn: 'Stores'),
    LocalizedItem(id: ContentKeys.travel, titleAr: 'سفر', titleEn: 'Travel'),
    LocalizedItem(id: ContentKeys.hotels, titleAr: 'فنادق', titleEn: 'Hotels'),
    LocalizedItem(id: ContentKeys.doctors, titleAr: 'أطباء', titleEn: 'Doctors'),
  ];

  static const List<LocalizedItem> categories = tabs;

  static String tabTitle(String id, [String locale = 'ar']) {
    for (final t in tabs) {
      if (t.id == id) return t.titleFor(locale);
    }
    return id;
  }

  static List<String> tabTitles([String locale = 'ar']) {
    return [for (final t in tabs) t.titleFor(locale)];
  }
}
