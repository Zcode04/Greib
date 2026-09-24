import 'package:flutter/material.dart';

/// ============================================================================
///  LocationController — متحكم المدينة المختارة (Geolocation تجريبية UI)
///  لتجربة Super-App: اختيار الموقع من الـ Header و انعكاسه مباشرة
///  على كل شاشات التطبيق عبر Provider.
/// ============================================================================

/// مدينة ضمن التطبيق (بيانات تجريبية بلا خرائط حقيقية).
class AppCity {
  final String name;
  final List<String> areas;

  const AppCity({required this.name, this.areas = const []});
}

class LocationController extends ChangeNotifier {
  /// المدن المدعومة تجريبياً في هذه المرحلة.
  static const List<AppCity> cities = [
    AppCity(name: 'دبي', areas: ['الممزر', 'ديرة', 'الكرامة', 'القصيص', 'البرشاء']),
    AppCity(name: 'أبوظبي', areas: ['مدينة خليفة', 'السعديات', 'الروضة', 'التل']),
    AppCity(name: 'الشارقة', areas: ['المجاز', 'النوف', 'الحيرة']),
    AppCity(name: 'العين', areas: ['وسط المدينة', 'الفلاح']),
    AppCity(name: 'عجمان', areas: ['البستان', 'الراشدية']),
    AppCity(name: 'رأس الخيمة', areas: ['المعيريض', 'الظيت']),
  ];

  AppCity _city = cities.first;
  AppCity get city => _city;
  String get cityName => _city.name;

  void setCity(AppCity city) {
    if (city.name == _city.name) return;
    _city = city;
    notifyListeners();
  }
}