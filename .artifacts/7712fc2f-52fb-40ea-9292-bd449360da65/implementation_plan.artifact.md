# إغناء واجهة تطبيق Greib Menk (Glassi & Animations)

يهدف هذا المشروع إلى تحويل واجهة التطبيق إلى تجربة بصرية غنية وتفاعلية باستخدام تقنيات Glassmorphism والأنيميشن، مع إضافة أقسام جديدة للسفر والفنادق.

## User Review Required

> [!IMPORTANT]
> جميع التعديلات ستكون محلية (Local Mock) ولن تؤثر على أي أكواد في الخادم (Server). سنقوم باستخدام `BackdropFilter` لتحقيق تأثير الزجاج، وهو ما يتطلب أداءً جيداً من الجهاز.

## Proposed Changes

### [Component] Shared Widgets
إضافة مكونات قابلة لإعادة الاستخدام تدعم التصميم الجديد.

#### [NEW] [glass_container.dart](file:///Users/zeinmohamed/Greib-menk/greib/lib/shared_widgets/glass_container.dart)
إنشاء ويدجت `GlassContainer` لتطبيق تأثير الزجاج الضبابي في أي مكان في التطبيق.

### [Component] Home Feature
تحديث الصفحة الرئيسية لتكون أكثر ديناميكية.

#### [MODIFY] [home_screen.dart](file:///Users/zeinmohamed/Greib-menk/greib/lib/features/home/home_screen.dart)
*   إضافة خلفية متحركة (Animated Mesh Gradients) باستخدام `CustomPainter` أو `AnimatedPositioned` مع فقاعات ملونة.
*   تحويل البطاقات الحالية لاستخدام `GlassContainer`.
*   إضافة قسم "السفر والفنادق" (Travel & Hotels) بتصميم جذاب.
*   إضافة تأثيرات حركية عند التمرير (Parallax items).

### [Component] Core Data
تحديث البيانات الوهمية لدعم الميزات الجديدة.

#### [MODIFY] [mock_data.dart](file:///Users/zeinmohamed/Greib-menk/greib/lib/core/mock_data/mock_data.dart)
*   إضافة نماذج `Hotel` و `TravelDestination`.
*   إضافة بيانات وهمية للفنادق والرحلات السياحية.

## Verification Plan

### Automated Tests
*   تشغيل التطبيق والتأكد من عدم وجود أخطاء في الـ Layout بعد إضافة الـ `BackdropFilter`.
*   التأكد من سلاسة الأنيميشن (Frame Rate).

### Manual Verification
*   معاينة الواجهة في الوضعين الليلي والنهاري للتأكد من وضوح تأثير الزجاج.
*   اختبار التمرير والتأكد من تفاعل العناصر بشكل صحيح.
