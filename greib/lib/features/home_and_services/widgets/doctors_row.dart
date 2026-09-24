import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/mock_data/mock_data.dart';
import '../../../../core/models/doctor_model.dart';
import '../../../../core/theme/design_tokens.dart';

class DoctorsRow extends StatelessWidget {
  final bool isDark;

  const DoctorsRow({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final doctors = MockData.mockDoctors;
    return SizedBox(
      height: 120,
      child: ListView.separated(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        itemCount: doctors.length,
        separatorBuilder: (_, _) => const SizedBox(width: 20),
        itemBuilder: (context, i) => _doctorCircleItem(context, doctors[i]),
      ),
    );
  }

  Widget _doctorCircleItem(BuildContext context, DoctorProfile doctor) {
    final specialtyColor = MockData.getSpecialtyColor(doctor.specialty);
    final shortName = doctor.name.replaceFirst('د. ', '');
    // Randomly assign online status for demo
    final isOnline = doctor.name.length % 2 == 0;

    return GestureDetector(
      onTap: () => context.push('/doctors'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      specialtyColor.withValues(alpha: 0.8),
                      specialtyColor.withValues(alpha: 0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: specialtyColor.withValues(alpha: 0.3),
                      blurRadius: 15,
                      spreadRadius: -2,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.5),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: ClipOval(
                        child: Image.network(
                          doctor.avatar,
                          fit: BoxFit.cover,
                          // لا نترك الصورة فارغة عند فشل الشبكة: أيقونة بديلة.
                          errorBuilder: (_, _, _) => Container(
                            color: AppColors.accentPrimary.withValues(
                              alpha: 0.15,
                            ),
                            child: const Icon(
                              LucideIcons.user,
                              size: 22,
                              color: AppColors.accentPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (isOnline)
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent[400],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? const Color(0xFF121212) : Colors.white,
                        width: 2.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 76,
            child: Text(
              shortName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            width: 76,
            child: Text(
              doctor.specialty,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: specialtyColor,
                fontWeight: FontWeight.w600,
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
