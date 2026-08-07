# گريب منك (Grab Menak) — دليل التشغيل

تطبيق إماراتي متكامل يدمج 6 خدمات في تطبيق واحد (توصيل طعام، صيدلية، نقل طرود، مواصلات، تسوق، سياحة وفعاليات) بهوية بصرية إماراتية عصرية.

---

## 1) المتطلبات

| الأداة | الإصدار المطلوب |
|---|---|
| Flutter SDK | ^3.12.2 أو أحدث |
| Node.js | ^18 أو أحدث |
| حساب Firebase | تجريبي (اختياري لهذه المرحلة) |
| حساب Vercel | تجريبي (اختياري لهذه المرحلة) |

---

## 2) خطوات التشغيل

### أ) تشغيل تطبيق Flutter

```bash
# 1. فك ضغط الملف
unzip grab-menak-prototype-v2.zip
cd grab-menak-prototype-v2/greib

# 2. تثبيت الاعتماديات
flutter pub get

# 3. تشغيل التطبيق
flutter run
```

### ب) تشغيل خادم الإشعارات (Next.js)

```bash
cd grab-menak-prototype-v2/notification-server

# تثبيت الاعتماديات
npm install

# تشغيل الخادم محلياً
npm start
```

---

## 3) بيانات الدخول التجريبية

| الدور | البريد الإلكتروني | كلمة المرور |
|---|---|---|
| **مستخدم** | `user@greib.com` | `123456` |
| **وكيل** | `agent@greib.com` | `123456` |
| **مشرف** | `admin@greib.com` | `123456` |

> يمكن أيضاً استخدام أزرار "دخول سريع" في شاشة تسجيل الدخول.

---

## 4) الميزات الجديدة في هذه النسخة (v2)

| الميزة | الوصف | مكان الشاشة في الكود |
|---|---|---|
| **تتبع حي على خريطة (Mock)** | خريطة وهمية متحركة مع مسار بين نقطتين | `lib/features/tracking/tracking_screen.dart` |
| **محفظة ونقاط ولاء** | رصيد وهمي + نقاط + استبدال مكافآت | `lib/features/wallet/wallet_screen.dart` |
| **أكواد خصم** | إدخال كود يفعّل خصم وهمي | `lib/features/promo/promo_codes_screen.dart` |
| **التقييمات والمراجعات** | تقييم نجوم + تعليق بعد الطلب | `lib/features/reviews/reviews_screen.dart` |
| **المفضلة وسجل الطلبات** | شاشتا مفضلة وطلبات سابقة | `lib/features/favorites/favorites_screen.dart` |
| **العضويات (Membership)** | مستوى عادي/ذهبي مع شارة بصرية | `lib/features/membership/membership_screen.dart` |
| **مركز الدعم (Support)** | تذاكر دعم مفتوحة/مغلقة | `lib/features/support/support_tickets_screen.dart` |
| **دعم اللغتين** | عربي/إنجليزي مع RTL/LTR تلقائي | `lib/core/localization/app_localizations.dart` |

---

## 5) نظام التصميم

- **الخط:** Cairo (عبر google_fonts)
- **الألوان:** أخضر عميق (`#0F5132`) + ذهبي (`#D4A853`) — هوية إماراتية
- **الوضع الليلي:** مدعوم بالكامل على 100% من الشاشات
- **التصميم:** Material 3 مع Design Tokens موحدة في `lib/core/theme/design_tokens.dart`

---

## 6) هيكل المشروع

```
greib/
├── lib/
│   ├── core/
│   │   ├── theme/          # نظام التصميم (ألوان، خطوط، ظلال)
│   │   ├── mock_data/      # بيانات وهمية
│   │   ├── permissions/    # نظام الصلاحيات
│   │   ├── notifications/  # إدارة الإشعارات
│   │   └── localization/   # دعم اللغتين
│   ├── shared_widgets/     # مكونات مشتركة (أزرار، بطاقات، هيدر)
│   └── features/           # كل خدمة بمجلد مستقل
│       ├── home/           # الشاشة الرئيسية
│       ├── food_delivery/  # توصيل طعام
│       ├── pharmacy/       # الصيدلية
│       ├── courier/        # نقل طرود
│       ├── ride/           # المواصلات
│       ├── shopping/       # تسوق ومقاضي
│       ├── tourism_events/ # سياحة وفعاليات
│       ├── chat/           # المحادثات
│       ├── wallet/         # المحفظة
│       ├── tracking/       # التتبع
│       ├── favorites/      # المفضلة
│       ├── promo/          # أكواد الخصم
│       ├── reviews/        # التقييمات
│       ├── membership/     # العضويات
│       ├── support/        # تذاكر الدعم
│       ├── splash/         # شاشة البداية
│       ├── auth/           # المصادقة
│       ├── admin_dashboard/ # لوحة المشرف
│       └── agent_dashboard/ # لوحة الوكيل
└── notification-server/    # خادم الإشعارات (Next.js)
```

---

## 7) Cloudflare (للمرحلة القادمة)

ملف `cloudflare.config.example` يوضح كيفية ربط R2 (تخزين الصور) و CDN لاحقاً. لا يتطلب أي مفاتيح إنتاج في هذه المرحلة.

---

## 8) ملاحظات

- جميع البيانات Mock بالكامل — لا اتصال حقيقي بأي خدمة خارجية
- لا بوابات دفع حقيقية — واجهة دفع وهمية فقط
- لا مصادقة حقيقية — Mock Auth بحسابات تجريبية ثابتة