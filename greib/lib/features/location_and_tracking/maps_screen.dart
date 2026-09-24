import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../shared_widgets/glass_container.dart';

class MapsScreen extends StatelessWidget {
  const MapsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Stack(
        children: [
          // Placeholder for Google Maps
          Container(
            color: isDark ? const Color(0xFF242f3e) : const Color(0xFFe5e3df),
            child: Center(
              child: Image.network(
                isDark 
                  ? 'https://upload.wikimedia.org/wikipedia/commons/b/b0/Google_Maps_Dark_Mode_Logo.png' // Example dark map pattern 
                  : 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a9/Google_Maps_icon.svg/1024px-Google_Maps_icon.svg.png', // Example light map pattern
                opacity: const AlwaysStoppedAnimation(0.2),
                width: 150,
              ),
            ),
          ),
          
          // Custom Top App Bar overlay
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              borderRadius: BorderRadius.circular(24),
              opacity: isDark ? 0.8 : 0.9,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.arrowRight),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'أين تريد الذهاب؟',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Icon(LucideIcons.search, color: isDark ? AppColors.accentPrimary : AppColors.accentPrimaryDark),
                ],
              ),
            ),
          ),
          
          // Bottom Sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.background : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('الأماكن المحفوظة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: (isDark ? AppColors.accentPrimary : AppColors.accentPrimaryDark).withValues(alpha: 0.2),
                      child: Icon(LucideIcons.home, color: isDark ? AppColors.accentPrimary : AppColors.accentPrimaryDark),
                    ),
                    title: const Text('المنزل', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('دبي مارينا, برج الأميرة'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppColors.info.withValues(alpha: 0.2),
                      child: const Icon(LucideIcons.briefcase, color: AppColors.info),
                    ),
                    title: const Text('العمل', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('مركز دبي المالي العالمي'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentPrimary,
                      foregroundColor: AppColors.onAccentPrimary,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('تأكيد الموقع', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
