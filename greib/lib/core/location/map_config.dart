/// ============================================================================
///  MapConfig — إعدادات مزوّد الخرائط + مفتاح التبديل الاحترافي.
///
///  • providerFor(isDark)  → يختار OSM أو CartoDB Dark تبعاً للوضع الليلي.
///  • providerFromIndex(i) → يعيد النمط المحفوظ من المستخدم (0,1,2).
///  • التبديل مستقبلاً لـ Google Maps بإضافة MapProviderKind.google فقط —
///    كل الشاشات تستخدم RealMapView ولا تتأثر.
/// ============================================================================
enum MapProviderKind {
  /// OpenStreetMap مجاني — الافتراضي (بلا مفتاح).
  osm,

  /// CartoDB داكن — يطابق الوضع الليلي للتطبيق.
  osmDark,

  /// صور أقمار Esri — مجانية للاستخدام الخفيف.
  satellite,
}

class MapConfig {
  MapConfig._();

  /// ★ المفتاح الرئيسي: هل نعرض خرائط OSM الحقيقية أم الكرة القديمة؟
  static bool kUseRealMaps = true;

  // ── مُعرّفات الأنماط الثلاثة (مطابقة لـ MapProviderKind.index) ──────────
  static const int styleOsm       = 0; // عادي (فاتح)
  static const int styleOsmDark   = 1; // داكن
  static const int styleSatellite = 2; // أقمار صناعية

  /// يختار النمط تلقائياً بناءً على وضع النظام الداكن/الفاتح.
  static MapProviderKind providerFor(bool isDark) =>
      isDark ? MapProviderKind.osmDark : MapProviderKind.osm;

  /// يعيد النمط المحفوظ من اختيار المستخدم (من AppPrefs.mapStyleIndex).
  static MapProviderKind providerFromIndex(int index) {
    switch (index) {
      case styleSatellite: return MapProviderKind.satellite;
      case styleOsmDark:   return MapProviderKind.osmDark;
      default:             return MapProviderKind.osm;
    }
  }

  static String tileUrl(MapProviderKind kind) {
    switch (kind) {
      case MapProviderKind.osmDark:
        return 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png';
      case MapProviderKind.satellite:
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
      case MapProviderKind.osm:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }

  static List<String> subdomains(MapProviderKind kind) {
    switch (kind) {
      case MapProviderKind.satellite:
        return const [];
      case MapProviderKind.osm:
        return const ['a', 'b', 'c'];
      case MapProviderKind.osmDark:
        return const ['a', 'b', 'c', 'd'];
    }
  }

  static String attribution(MapProviderKind kind) {
    switch (kind) {
      case MapProviderKind.satellite:
        return 'Esri World Imagery';
      case MapProviderKind.osmDark:
        return '© OpenStreetMap © CARTO';
      case MapProviderKind.osm:
        return '© OpenStreetMap contributors';
    }
  }

  static double defaultZoom = 14.0;
}
