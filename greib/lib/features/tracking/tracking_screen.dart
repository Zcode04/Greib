import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';
import '../../shared_widgets/app_button.dart';

class TrackingScreen extends StatefulWidget {
  final String orderId;

  const TrackingScreen({
    super.key,
    this.orderId = 'ord1',
  });

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  final int _currentStep = 2;

  final List<Map<String, dynamic>> _steps = [
    {'title': 'تم تأكيد الطلب', 'time': '10:30 ص', 'done': true},
    {'title': 'جاري التحضير', 'time': '10:35 ص', 'done': true},
    {'title': 'في الطريق إليك', 'time': '10:45 ص', 'done': true},
    {'title': 'تم التسليم', 'time': 'متوقع 11:15 ص', 'done': false},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تتبع الطلب'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // خريطة وهمية
            Container(
              height: 220,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.05),
                    AppColors.primaryLight.withValues(alpha: 0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppRadii.lg),
                border: Border.all(color: AppColors.lightOutline),
              ),
              child: Stack(
                children: [
                  Center(
                    child: CustomPaint(
                      size: const Size(300, 180),
                      painter: RoutePainter(progress: _animation.value),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      final x = 60.0 + _animation.value * 180.0;
                      final y = 90.0 + 30.0 * (_animation.value > 0.5 ? 1 : -1);
                      return Positioned(
                        left: x,
                        top: y,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(AppRadii.full),
                            boxShadow: AppShadows.md,
                          ),
                          child: const Icon(
                            Icons.delivery_dining,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      );
                    },
                  ),
                  // نقطة الانطلاق
                  const Positioned(
                    left: 40,
                    top: 70,
                    child: _MapMarker(isOrigin: true),
                  ),
                  // نقطة الوصول
                  const Positioned(
                    right: 40,
                    bottom: 60,
                    child: _MapMarker(isOrigin: false),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // معلومات الطلب
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadii.sm),
                          ),
                          child: Icon(
                            Icons.receipt_long,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'طلب برياني دجاج',
                                style: theme.textTheme.titleMedium,
                              ),
                              Text(
                                'من مطعم المندي الملكي',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'AED 45.00',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // خطوات التتبع
            ...List.generate(_steps.length, (index) {
              final step = _steps[index];
              final isActive = index <= _currentStep;
              final isLast = index == _steps.length - 1;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.neutral200,
                          borderRadius: BorderRadius.circular(AppRadii.full),
                          border: Border.all(
                            color: isActive
                                ? AppColors.primary
                                : AppColors.neutral300,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          isActive ? Icons.check : Icons.circle,
                          size: 16,
                          color: isActive ? Colors.white : AppColors.neutral400,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 40,
                          color: isActive
                              ? AppColors.primary
                              : AppColors.neutral200,
                        ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: isLast ? 4 : 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step['title'] as String,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: isActive
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onSurfaceVariant,
                              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                          Text(
                            step['time'] as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),

            const SizedBox(height: AppSpacing.xl),

            AppButton(
              label: 'تواصل مع السائق',
              icon: Icons.phone,
              color: AppColors.primary,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('جارٍ الاتصال بالسائق... 📞'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MapMarker extends StatelessWidget {
  final bool isOrigin;

  const _MapMarker({required this.isOrigin});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isOrigin ? AppColors.success : AppColors.error,
        borderRadius: BorderRadius.circular(AppRadii.full),
        boxShadow: AppShadows.sm,
      ),
      child: Icon(
        isOrigin ? Icons.location_on : Icons.flag,
        color: Colors.white,
        size: 14,
      ),
    );
  }
}

class RoutePainter extends CustomPainter {
  final double progress;

  RoutePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(40, size.height - 40)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.2,
        size.width * 0.6,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.8,
        size.height * 0.7,
        size.width - 40,
        40,
      );

    canvas.drawPath(path, paint);

    final dashPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final metrics = path.computeMetrics().first;
    final drawLength = metrics.length * progress;
    final dashPath = metrics.extractPath(0, drawLength);
    canvas.drawPath(dashPath, dashPaint);
  }

  @override
  bool shouldRepaint(covariant RoutePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
