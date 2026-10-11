import 'dart:async';
import '../../../core/models/product_model.dart';
import '../../../core/models/hotel_model.dart';

/// أنماط مصادر البيانات لدعم الانتقال السلس من المحلي إلى خادم API
enum CommerceDataSourceMode {
  /// جلب محلي ممركز (المرحلة الحالية)
  localAggregator,

  /// خادم خلفي خاص (المرحلة المستقبلية للـ Backend API)
  remoteBackendApi,
}

/// نموذج المنتج المجمّع من المتاجر مع بيانات المصدر وهامش السعر
class AggregatedProduct {
  final String id;
  final String name;
  final String category;
  final String sourceStore; // متجر نون (الإمارات / السعودية)، أمازون الخليج، إكسترا، إلخ
  final String sourceCountry; // SA, AE
  final double originalPrice; // السعر الأصلي في المتجر المصدر
  double customPrice; // سعرنا المخصص بعد تطبيق سياسة التسعير
  final double? oldPrice;
  final String currency; // ر.س أو د.إ
  final String imageUrl;
  final double rating;
  final int reviewsCount;
  final bool inStock;
  final bool isHalalCertified;
  final List<String> tags;
  final String description;
  final Map<String, String> specifications;

  AggregatedProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.sourceStore,
    required this.sourceCountry,
    required this.originalPrice,
    required this.customPrice,
    this.oldPrice,
    this.currency = 'ر.س',
    required this.imageUrl,
    required this.rating,
    this.reviewsCount = 0,
    this.inStock = true,
    this.isHalalCertified = true,
    this.tags = const [],
    this.description = '',
    this.specifications = const {},
  });

  /// تحويل لنموذج Product القياسي للتطبيق
  Product toProduct() {
    return Product(
      id: id,
      name: name,
      category: category,
      price: customPrice,
      oldPrice: oldPrice,
      imageUrl: imageUrl,
      rating: rating,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'source_store': sourceStore,
        'source_country': sourceCountry,
        'original_price': originalPrice,
        'custom_price': customPrice,
        'old_price': oldPrice,
        'currency': currency,
        'image_url': imageUrl,
        'rating': rating,
        'reviews_count': reviewsCount,
        'in_stock': inStock,
        'is_halal_certified': isHalalCertified,
        'tags': tags,
        'description': description,
        'specifications': specifications,
      };

  factory AggregatedProduct.fromJson(Map<String, dynamic> json) {
    return AggregatedProduct(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      sourceStore: json['source_store'] as String? ?? 'نون',
      sourceCountry: json['source_country'] as String? ?? 'SA',
      originalPrice: (json['original_price'] as num).toDouble(),
      customPrice: (json['custom_price'] as num?)?.toDouble() ??
          (json['original_price'] as num).toDouble(),
      oldPrice: (json['old_price'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'ر.س',
      imageUrl: json['image_url'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      reviewsCount: json['reviews_count'] as int? ?? 0,
      inStock: json['in_stock'] as bool? ?? true,
      isHalalCertified: json['is_halal_certified'] as bool? ?? true,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const [],
      description: json['description'] as String? ?? '',
      specifications: (json['specifications'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v.toString()),
          ) ??
          const {},
    );
  }
}

/// نموذج الفنادق وعروض الإقامة المجمعة من المنصات الخليجية
class AggregatedHotel {
  final String id;
  final String name;
  final String city;
  final String country;
  final String sourcePlatform; // المسافر، فلاي دبي، بوكينج الخليج
  final int stars;
  final double originalPricePerNight;
  double customPricePerNight;
  final double rating;
  final String imageUrl;
  final List<String> gallery;
  final List<String> amenities;
  final String subscriptionType; // حجز فوري، اشتراك موسمي، باقة عائلية
  final bool isFamilyOnly; // بيئة عائلية محافظة وخالية من الممنوعات
  final String description;

  AggregatedHotel({
    required this.id,
    required this.name,
    required this.city,
    required this.country,
    required this.sourcePlatform,
    required this.stars,
    required this.originalPricePerNight,
    required this.customPricePerNight,
    required this.rating,
    required this.imageUrl,
    this.gallery = const [],
    this.amenities = const [],
    this.subscriptionType = 'حجز فوري',
    this.isFamilyOnly = true,
    this.description = '',
  });

  Hotel toHotel() {
    return Hotel(
      id: id,
      name: name,
      location: '$city، $country',
      imageUrl: imageUrl,
      gallery: gallery,
      description: description,
      rating: rating,
      pricePerNight: customPricePerNight,
      amenities: amenities,
    );
  }
}

/// ============================================================================
///  CommerceAggregatorService — خدمة جلب وإدارة التجارة المجمعة
///
///  المسؤوليات:
///  1. جلب المنتجات والعروض من المتاجر العربية الكبرى (نون السعودية/الإمارات، أمازون الخليج، إكسترا).
///  2. تطبيق الضوابط الشرعية والأخلاقية (فلترة المحظورات: لا لحم خنزير، لا كحول،
///     لا ملابس غير محتشمة، حصر الملابس في الرجالية والأولاد، منتجات تجميل محترمة).
///  3. التحكم الديناميكي في الأسعار (هامش ربح، تخفيضات، أو أسعار مخصصة).
///  4. دعم عروض الفنادق واشتراكات الإقامة العائلية المحافظة.
///  5. معمارية مزدوجة جاهزة للربط مع السيرفر والـ Backend API فور توفره.
/// ============================================================================
class CommerceAggregatorService {
  CommerceAggregatorService._();
  static final CommerceAggregatorService instance = CommerceAggregatorService._();

  CommerceDataSourceMode mode = CommerceDataSourceMode.localAggregator;
  String? backendApiBaseUrl;

  /// نسبة هامش الربح الافتراضية (مثلاً 1.05 = زيادة 5% على سعر المصدر للتسويق)
  double globalMarkupRatio = 1.0;

  // ==================== الضوابط الشرعية والأخلاقية ====================
  static const List<String> _forbiddenKeywords = [
    'خنزير',
    'pork',
    'bacon',
    'خمر',
    'خمور',
    'نبيذ',
    'كحول',
    'alcohol',
    'beer',
    'wine',
    'فستان عاري',
    'بيكيني',
    'bikini',
    'ملابس داخلية نسائية',
    'قمار',
    'يانصيب',
  ];

  /// فحص الامتثال الشرعي لأي منتج قبل اعتماده في التطبيق
  bool isContentCompliant({
    required String title,
    String? category,
    String? description,
    List<String>? tags,
  }) {
    final fullText = '${title.toLowerCase()} ${(category ?? '').toLowerCase()} ${(description ?? '').toLowerCase()} ${(tags?.join(' ') ?? '').toLowerCase()}';
    for (final badWord in _forbiddenKeywords) {
      if (fullText.contains(badWord)) {
        return false;
      }
    }
    // الملابس محصورة في الرجال والأولاد فقط
    if (category == 'women_fashion') {
      return false;
    }
    return true;
  }

  // ==================== تبويبات المتجر الرسمية المنقحة ====================
  static const List<Map<String, String>> categories = [
    {'id': 'all', 'label': 'الكل', 'icon': 'sparkles'},
    {'id': 'men_fashion', 'label': 'أزياء الرجال', 'icon': 'shirt'},
    {'id': 'boys_fashion', 'label': 'أزياء الأولاد', 'icon': 'smile'},
    {'id': 'electronics', 'label': 'الإلكترونيات والسماعات', 'icon': 'headphones'},
    {'id': 'watches', 'label': 'الساعات والإكسسوارات', 'icon': 'watch'},
    {'id': 'health_nutrition', 'label': 'الصحة والتغذية الحلال', 'icon': 'apple'},
    {'id': 'sports', 'label': 'الرياضة واللياقة', 'icon': 'trophy'},
    {'id': 'cars', 'label': 'عناية ومستلزمات السيارات', 'icon': 'car'},
    {'id': 'toys', 'label': 'الألعاب وتنمية المهارات', 'icon': 'gamepad-2'},
    {'id': 'perfumes_care', 'label': 'العطور والعناية الشخصية', 'icon': 'sparkle'},
    {'id': 'hotels', 'label': 'فنادق وإقامات عائلية', 'icon': 'hotel'},
    {'id': 'best', 'label': 'أحسن المنتجات والعروض', 'icon': 'flame'},
  ];

  // ==================== كتالوج المنتجات المجمعة الموثقة ====================
  final List<AggregatedProduct> _cachedProducts = [
    // 1. أزياء الرجال (أقمصة وثياب راقية ومريحة)
    AggregatedProduct(
      id: 'agg_m1',
      name: 'ثوب رجالي كلاسيكي مطرز فاخر',
      category: 'men_fashion',
      sourceStore: 'نون السعودية',
      sourceCountry: 'SA',
      originalPrice: 160.0,
      customPrice: 175.0,
      oldPrice: 220.0,
      currency: 'ر.س',
      imageUrl: 'https://images.unsplash.com/photo-1598033129183-c4f50c736f10?w=600&q=80',
      rating: 4.8,
      reviewsCount: 340,
      tags: ['ثياب', 'أزياء رجال', 'ملابس رسمية'],
      description: 'ثوب رجالي سعودي بقماش مريح مضاد للتجعد بتطريز أنيق على الياقة والأكمام.',
    ),
    AggregatedProduct(
      id: 'agg_m2',
      name: 'قميص كتان كاجوال بأزرار أمامية',
      category: 'men_fashion',
      sourceStore: 'نون الإمارات',
      sourceCountry: 'AE',
      originalPrice: 110.0,
      customPrice: 125.0,
      oldPrice: 155.0,
      currency: 'ر.س',
      imageUrl: 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600&q=80',
      rating: 4.6,
      reviewsCount: 215,
      tags: ['قميص', 'كتان', 'أزياء رجال'],
      description: 'قميص صيفي مريح من الكتان الطبيعي الفاخر بتصميم عصري ملائم للاستخدام اليومي.',
    ),
    AggregatedProduct(
      id: 'agg_m3',
      name: 'حذاء كلاسيكي جلدي طبيعي للرجال',
      category: 'men_fashion',
      sourceStore: 'أمازون الخليج',
      sourceCountry: 'SA',
      originalPrice: 240.0,
      customPrice: 260.0,
      oldPrice: 320.0,
      currency: 'ر.س',
      imageUrl: 'https://images.unsplash.com/photo-1614252369475-531eba835eb1?w=600&q=80',
      rating: 4.9,
      reviewsCount: 410,
      tags: ['حذاء', 'جلد طبيعي', 'رجال'],
      description: 'حذاء رسمي فاخر مصنوع من الجلد الطبيعي المريح لراحة تدوم طوال اليوم.',
    ),

    // 2. أزياء الأولاد
    AggregatedProduct(
      id: 'agg_b1',
      name: 'طقم ولادي قطني مريح (قميص وشورت)',
      category: 'boys_fashion',
      sourceStore: 'نون السعودية',
      sourceCountry: 'SA',
      originalPrice: 75.0,
      customPrice: 85.0,
      oldPrice: 110.0,
      currency: 'ر.س',
      imageUrl: 'https://images.unsplash.com/photo-1519238263530-99bdd11df2ea?w=600&q=80',
      rating: 4.7,
      reviewsCount: 180,
      tags: ['أولاد', 'أطقم قطن', 'ملابس أطفال'],
      description: 'طقم قطن 100% عالي الجودة ناعم على بشرة الأطفال ومثالي للأنشطة واللعب.',
    ),
    AggregatedProduct(
      id: 'agg_b2',
      name: 'حذاء رياضي للأولاد سريع الارتداء',
      category: 'boys_fashion',
      sourceStore: 'نون الإمارات',
      sourceCountry: 'AE',
      originalPrice: 90.0,
      customPrice: 99.0,
      oldPrice: 135.0,
      currency: 'ر.س',
      imageUrl: 'https://images.unsplash.com/photo-1514989940723-e8e51635b782?w=600&q=80',
      rating: 4.5,
      reviewsCount: 128,
      tags: ['أحذية أولاد', 'رياضي'],
      description: 'حذاء رياضي خفيف ومبطن بنعل مانع للانزلاق لدعم حركة الطفل.',
    ),

    // 3. الإلكترونيات والسماعات
    AggregatedProduct(
      id: 'agg_e1',
      name: 'سماعات لاسلكية عازلة للضوضاء Pro',
      category: 'electronics',
      sourceStore: 'نون الإمارات',
      sourceCountry: 'AE',
      originalPrice: 320.0,
      customPrice: 349.0,
      oldPrice: 450.0,
      currency: 'ر.س',
      imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600&q=80',
      rating: 4.8,
      reviewsCount: 890,
      tags: ['سماعات', 'إلكترونيات', 'بلوتوث'],
      description: 'سماعات رأس صوت نقي وصوت محيطي مع خاصية العزل النشط للضوضاء وبطارية تدوم 40 ساعة.',
    ),
    AggregatedProduct(
      id: 'agg_e2',
      name: 'مكبر صوت بلوتوث محمول مقاوم للماء',
      category: 'electronics',
      sourceStore: 'شرف دي جي',
      sourceCountry: 'AE',
      originalPrice: 150.0,
      customPrice: 169.0,
      oldPrice: 210.0,
      currency: 'ر.س',
      imageUrl: 'https://images.unsplash.com/photo-1545454675-3531b543be5d?w=600&q=80',
      rating: 4.7,
      reviewsCount: 430,
      tags: ['صوتيات', 'مكبر صوت', 'إلكترونيات'],
      description: 'مكبر صوت محمول بقوة صوت جهير ومقاومة للماء بتصنيف IPX7 للتنقل والرحلات.',
    ),

    // 4. الساعات والإكسسوارات
    AggregatedProduct(
      id: 'agg_w1',
      name: 'ساعة ذكية رياضية بشاشة AMOLED',
      category: 'watches',
      sourceStore: 'أمازون الخليج',
      sourceCountry: 'SA',
      originalPrice: 280.0,
      customPrice: 299.0,
      oldPrice: 380.0,
      currency: 'ر.س',
      imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600&q=80',
      rating: 4.9,
      reviewsCount: 650,
      tags: ['ساعات', 'ساعة ذكية', 'رياضة'],
      description: 'تتبع نبضات القلب والنشاط الرياضي، قياس الأكسجين، ودعم المكالمات عبر البلوتوث.',
    ),
    AggregatedProduct(
      id: 'agg_w2',
      name: 'ساعة يد كلاسيكية ستانلس ستيل للرجال',
      category: 'watches',
      sourceStore: 'نون السعودية',
      sourceCountry: 'SA',
      originalPrice: 190.0,
      customPrice: 210.0,
      oldPrice: 280.0,
      currency: 'ر.س',
      imageUrl: 'https://images.unsplash.com/photo-1524805444758-089113d48a6d?w=600&q=80',
      rating: 4.6,
      reviewsCount: 310,
      tags: ['ساعات', 'رجالي', 'كلاسيك'],
      description: 'تصميم معدني أنيق ومقاوم للماء مع ميناء فاخر يعكس الفخامة والأناقة.',
    ),

    // 5. الصحة والتغذية الحلال
    AggregatedProduct(
      id: 'agg_h1',
      name: 'عسل سدر جبلي بلدي طبيعي 100%',
      category: 'health_nutrition',
      sourceStore: 'نون السعودية',
      sourceCountry: 'SA',
      originalPrice: 180.0,
      customPrice: 195.0,
      oldPrice: 250.0,
      currency: 'ر.س',
      imageUrl: 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=600&q=80',
      rating: 5.0,
      reviewsCount: 780,
      tags: ['عسل طبيعي', 'غذاء صحي', 'حلال'],
      description: 'عسل سدر طبيعي خام نقي ومفحوص مخبرياً لدعم المناعة والصحة العامة.',
    ),
    AggregatedProduct(
      id: 'agg_h2',
      name: 'مجموعة مكسرات وفواكه مجففة فاخرة',
      category: 'health_nutrition',
      sourceStore: 'نون الإمارات',
      sourceCountry: 'AE',
      originalPrice: 65.0,
      customPrice: 75.0,
      oldPrice: 95.0,
      currency: 'ر.س',
      imageUrl: 'https://images.unsplash.com/photo-1509937528035-ad76254b0356?w=600&q=80',
      rating: 4.8,
      reviewsCount: 220,
      tags: ['مكسرات', 'طاقة', 'صحي'],
      description: 'تشكيلة ممتازة من اللوز والجوز والكاجو غير المملح والمحمص بعناية.',
    ),

    // 6. الرياضة واللياقة
    AggregatedProduct(
      id: 'agg_s1',
      name: 'حذاء جري خفيف بتقنية التوسيد المريح',
      category: 'sports',
      sourceStore: 'أمازون الخليج',
      sourceCountry: 'SA',
      originalPrice: 199.0,
      customPrice: 219.0,
      oldPrice: 279.0,
      currency: 'ر.س',
      imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600&q=80',
      rating: 4.8,
      reviewsCount: 520,
      tags: ['حذاء رياضي', 'جري', 'لياقة'],
      description: 'نعل مطاطي مرن يمتص الصدمات مع نسيج شبكي يسمح بتهوية القدم أثناء التمرين.',
    ),
    AggregatedProduct(
      id: 'agg_s2',
      name: 'حقيبة ظهر رياضية مضادة للماء متعددة الجيوب',
      category: 'sports',
      sourceStore: 'نون السعودية',
      sourceCountry: 'SA',
      originalPrice: 85.0,
      customPrice: 95.0,
      oldPrice: 130.0,
      currency: 'ر.س',
      imageUrl: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=600&q=80',
      rating: 4.7,
      reviewsCount: 190,
      tags: ['حقائب', 'رياضة', 'نادي'],
      description: 'حقيبة واسعة بجيوب منفصلة للأحذية والملابس وخامة مقاومة للتمزق والماء.',
    ),

    // 7. مستلزمات وعناية السيارات
    AggregatedProduct(
      id: 'agg_c1',
      name: 'مجموعة عناية وغسيل السيارات بالنانو سيراميك',
      category: 'cars',
      sourceStore: 'نون السعودية',
      sourceCountry: 'SA',
      originalPrice: 120.0,
      customPrice: 139.0,
      oldPrice: 180.0,
      currency: 'ر.س',
      imageUrl: 'https://images.unsplash.com/photo-1520340356584-f9917d1eea6f?w=600&q=80',
      rating: 4.8,
      reviewsCount: 310,
      tags: ['سيارات', 'نانو سيراميك', 'عناية'],
      description: 'تلميع وحماية طلاء السيارة مع شامبو رغوي وألياف ميكروفايبر فائقة النعومة.',
    ),
    AggregatedProduct(
      id: 'agg_c2',
      name: 'شاحن سيارة سريع بقوة 65 واط بمنفذين Type-C',
      category: 'cars',
      sourceStore: 'نون الإمارات',
      sourceCountry: 'AE',
      originalPrice: 55.0,
      customPrice: 65.0,
      oldPrice: 89.0,
      currency: 'ر.س',
      imageUrl: 'https://images.unsplash.com/photo-1583863788434-e58a36330cf0?w=600&q=80',
      rating: 4.9,
      reviewsCount: 440,
      tags: ['سيارات', 'شواحن', 'إلكترونيات'],
      description: 'شحن فائق السرعة يدعم الهواتف والأجهزة اللوحية مع حماية ضد الحمل الزائد.',
    ),

    // 8. الألعاب وتنمية المهارات
    AggregatedProduct(
      id: 'agg_t1',
      name: 'مجموعة البناء الهندسية الذكية للأطفال',
      category: 'toys',
      sourceStore: 'أمازون الخليج',
      sourceCountry: 'SA',
      originalPrice: 115.0,
      customPrice: 129.0,
      oldPrice: 165.0,
      currency: 'ر.س',
      imageUrl: 'https://images.unsplash.com/photo-1587654780291-39c9404d746b?w=600&q=80',
      rating: 4.9,
      reviewsCount: 390,
      tags: ['ألعاب أطفال', 'تنمية مهارات', 'ذكاء'],
      description: 'لعبة تركيب تفاعلية آمنة لتنمية التفكير الإبداعي والقدرات الهندسية للصغار.',
    ),

    // 9. العطور والعناية الشخصية الراقية المحترمة
    AggregatedProduct(
      id: 'agg_p1',
      name: 'عطر دهن العود الكمبودي الملكي المعتّق',
      category: 'perfumes_care',
      sourceStore: 'نون السعودية',
      sourceCountry: 'SA',
      originalPrice: 290.0,
      customPrice: 310.0,
      oldPrice: 420.0,
      currency: 'ر.س',
      imageUrl: 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=600&q=80',
      rating: 5.0,
      reviewsCount: 620,
      tags: ['عطور', 'عود', 'عناية فاخرة'],
      description: 'رائحة أصيلة فواحة وثبات يدوم لأيام مستخلص من أجود خشب العود الطبيعي.',
    ),
    AggregatedProduct(
      id: 'agg_p2',
      name: 'زيت اللحية والشعر الطبيعي العضوي للرجال',
      category: 'perfumes_care',
      sourceStore: 'أمازون الخليج',
      sourceCountry: 'AE',
      originalPrice: 70.0,
      customPrice: 79.0,
      oldPrice: 105.0,
      currency: 'ر.س',
      imageUrl: 'https://images.unsplash.com/photo-1608248597359-29112467d1d2?w=600&q=80',
      rating: 4.7,
      reviewsCount: 230,
      tags: ['عناية شخصية', 'زيوت طبيعية', 'رجال'],
      description: 'تركيبة غنية بزيت الأرغان والجوجوبا لتغذية الشعر وترطيبه بعمق دون لزوجة.',
    ),
  ];

  // ==================== فنادق وإقامات عائلية محافظة ====================
  final List<AggregatedHotel> _cachedHotels = [
    AggregatedHotel(
      id: 'agg_ht1',
      name: 'فندق وأبراج مكة الفاخرة',
      city: 'مكة المكرمة',
      country: 'المملكة العربية السعودية',
      sourcePlatform: 'المسافر',
      stars: 5,
      originalPricePerNight: 650.0,
      customPricePerNight: 620.0,
      rating: 4.9,
      imageUrl: 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=700&q=80',
      gallery: [
        'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=700&q=80',
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=700&q=80',
      ],
      amenities: ['إطلالة مباشرة على الحرم', 'خدمة نقل مريحة', 'مطعم حلال فاخر', 'واي فاي مجاني'],
      subscriptionType: 'باقة العمرة العائلية',
      isFamilyOnly: true,
      description: 'إقامة روحانية متميزة على بُعد خطوات من الحرم المكي مع أرقى وسائل الراحة للعائلات.',
    ),
    AggregatedHotel(
      id: 'agg_ht2',
      name: 'منتجع نسمة الرياض العائلي',
      city: 'الرياض',
      country: 'المملكة العربية السعودية',
      sourcePlatform: 'فلاي دبي / المسافر',
      stars: 5,
      originalPricePerNight: 520.0,
      customPricePerNight: 490.0,
      rating: 4.8,
      imageUrl: 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=700&q=80',
      gallery: [
        'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=700&q=80',
        'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=700&q=80',
      ],
      amenities: ['شاليهات بمسابح خاصة مغلقة', 'ألعاب أطفال', 'حدائق عائلية', 'مواقف خاصة'],
      subscriptionType: 'اشتراك عطلات نهاية الأسبوع',
      isFamilyOnly: true,
      description: 'خصوصية كاملة للعائلات المحافظة مع مساحات خضراء ومرافق ترفيهية للأطفال.',
    ),
    AggregatedHotel(
      id: 'agg_ht3',
      name: 'أجنحة دبي مارينا العائلية الراقية',
      city: 'دبي',
      country: 'الإمارات العربية المتحدة',
      sourcePlatform: 'المسافر',
      stars: 5,
      originalPricePerNight: 580.0,
      customPricePerNight: 550.0,
      rating: 4.7,
      imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=700&q=80',
      gallery: [
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=700&q=80',
      ],
      amenities: ['أجنحة فندقية مفروشة بالكامل', 'إطلالة بحرية', 'نادي صحي منفصل', 'بيئة أسرية'],
      subscriptionType: 'باقة الإقامة الشهرية والموسمية',
      isFamilyOnly: true,
      description: 'أجنحة فسيحة تلبي احتياجات العائلة في قلب مارينا مع أعلى معايير الضيافة العربية.',
    ),
  ];

  // ==================== واجهات الاستعلام والفلترة ====================

  /// جلب المنتجات المجمعة حسب الفئة مع الفلترة الشرعية وضبط الأسعار
  Future<List<AggregatedProduct>> fetchProducts({
    String? categoryId,
    String? query,
    int page = 1,
    int limit = 20,
  }) async {
    // محاكاة تأخير شبكة طفيف
    await Future.delayed(const Duration(milliseconds: 60));

    var list = _cachedProducts.where((p) {
      if (!isContentCompliant(
        title: p.name,
        category: p.category,
        description: p.description,
        tags: p.tags,
      )) {
        return false;
      }

      if (categoryId != null && categoryId != 'all' && categoryId != 'best') {
        if (p.category != categoryId) return false;
      }

      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        final match = p.name.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q) ||
            p.tags.any((t) => t.toLowerCase().contains(q));
        if (!match) return false;
      }

      return true;
    }).toList();

    // تطبيق سياسة التسعير إذا تغير الهامش
    if (globalMarkupRatio != 1.0) {
      for (final p in list) {
        p.customPrice = (p.originalPrice * globalMarkupRatio).roundToDouble();
      }
    }

    return list;
  }

  /// جلب الفنادق والإقامات العائلية
  Future<List<AggregatedHotel>> fetchHotels({String? city}) async {
    await Future.delayed(const Duration(milliseconds: 60));
    if (city == null || city.isEmpty) {
      return _cachedHotels;
    }
    return _cachedHotels
        .where((h) => h.city.contains(city) || h.country.contains(city))
        .toList();
  }

  /// جلب أحدث المنتجات كـ Product models جاهزة للاستخدام في الكاروسيل
  List<Product> getLatestProducts({int count = 6}) {
    final list = _cachedProducts.where((p) => isContentCompliant(
          title: p.name,
          category: p.category,
          description: p.description,
          tags: p.tags,
        )).toList();

    return list.take(count).map((p) => p.toProduct()).toList();
  }

  /// تحكم يدوي في سعر منتج معين
  void setCustomProductPrice(String productId, double newPrice) {
    final index = _cachedProducts.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _cachedProducts[index].customPrice = newPrice;
    }
  }

  /// تغيير هامش الربح العام (لتعديل أسعار كل المنتجات دفعة واحدة)
  void setGlobalMarkup(double ratio) {
    globalMarkupRatio = ratio;
  }
}
