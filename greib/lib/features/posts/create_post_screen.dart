import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/extensions/context_extensions.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/super_header.dart';
import '../../core/widgets/user_avatar.dart';
import '../../shared_widgets/app_button.dart';
import '../auth/auth_service.dart';

/// ============================================================================
///  CreatePostScreen — صفحة «إنشاء منشور».
///
///  تُفتح من أيقونة «إنشاء منشور» داخل تبويب الملف الشخصي (/profile).
///  المرحلة الحالية: كتابة نص + رفع صورة + رفع فيديو (اختيار محلي).
///  ★ للتطوير لاحقاً: الجمهور، الوسوم، الموقع، ثم النشر على الخادم.
/// ============================================================================
class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

/// وسيط مرفوع واحد (صورة أو فيديو): مسار محلي + نوعه.
class _MediaItem {
  final String path;
  final bool isVideo;

  const _MediaItem({required this.path, required this.isVideo});
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<_MediaItem> _media = [];

  bool get _canPublish =>
      _textController.text.trim().isNotEmpty || _media.isNotEmpty;

  @override
  void initState() {
    super.initState();
    // تفعيل/تعطيل زر «نشر» حسب وجود نص أو وسائط.
    _textController.addListener(_onTextChanged);
  }

  void _onTextChanged() => setState(() {});

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------------------
  //  رفع الوسائط: صلاحيات ثم اختيار من المعرض.
  // --------------------------------------------------------------------------
  Future<bool> _ensurePermission(Permission permission, String denied) async {
    final status = await permission.status;
    if (status.isGranted) return true;
    final result = await permission.request();
    if (result.isGranted) return true;
    if (mounted) context.showSnackBar(denied, isError: true);
    return false;
  }

  Future<void> _pickImage() async {
    final ok = await _ensurePermission(
      Permission.photos,
      'يجب السماح بالوصول إلى الصور لاختيار صورة',
    );
    if (!ok) return;
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (picked == null) return;
      setState(() => _media.add(_MediaItem(path: picked.path, isVideo: false)));
    } catch (_) {
      if (mounted) context.showSnackBar('تعذر اختيار الصورة', isError: true);
    }
  }

  Future<void> _pickVideo() async {
    final ok = await _ensurePermission(
      Permission.photos,
      'يجب السماح بالوصول إلى الملفات لاختيار فيديو',
    );
    if (!ok) return;
    try {
      final XFile? picked = await _picker.pickVideo(source: ImageSource.gallery);
      if (picked == null) return;
      setState(() => _media.add(_MediaItem(path: picked.path, isVideo: true)));
    } catch (_) {
      if (mounted) context.showSnackBar('تعذر اختيار الفيديو', isError: true);
    }
  }

  void _removeMedia(int index) => setState(() => _media.removeAt(index));

  void _publish() {
    if (!_canPublish) return;
    context.showSnackBar('تم نشر المنشور');
    if (context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final name = AuthService.instance.currentUser?.name ?? 'مستخدم گريب منك';

    return Scaffold(
      backgroundColor: context.backgroundColors.primary,
      appBar: const SuperHeader(showBackButton: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        children: [
          // ---- بطاقة الكتابة: الأفاتار + الاسم + حقل النص ----
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: context.backgroundColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.xl),
              border: Border.all(color: context.backgroundColors.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const UserAvatar(size: 44, iconSize: 20),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: AppTypography.titleMedium.copyWith(
                              color: context.textColors.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'منشور عام',
                            style: AppTypography.bodySmall.copyWith(
                              color: context.textColors.tertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _textController,
                  minLines: 5,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: AppTypography.bodyLarge.copyWith(
                    color: context.textColors.primary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'اكتب نص المنشور…',
                    hintStyle: AppTypography.bodyLarge.copyWith(
                      color: context.textColors.tertiary,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ---- أزرار الإضافة: صورة / فيديو ----
          Row(
            children: [
              Expanded(
                child: _MediaActionTile(
                  icon: LucideIcons.imagePlus,
                  label: 'صورة',
                  onTap: _pickImage,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _MediaActionTile(
                  icon: LucideIcons.video,
                  label: 'فيديو',
                  onTap: _pickVideo,
                ),
              ),
            ],
          ),

          // ---- معاينة الوسائط المرفوعة ----
          if (_media.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                for (int i = 0; i < _media.length; i++)
                  _MediaThumb(
                    item: _media[i],
                    onRemove: () => _removeMedia(i),
                  ),
              ],
            ),
          ],

          const SizedBox(height: AppSpacing.xl),

          // ---- زر النشر (Pill) ----
          AppButton(
            label: 'نشر',
            icon: LucideIcons.send,
            onPressed: _canPublish ? _publish : null,
          ),
        ],
      ),
    );
  }
}

/// زر رفع وسائط (صورة/فيديو) بنمط Pill — حبة بلون accent خفيف.
class _MediaActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MediaActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = context.accentColor;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.full),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadii.full),
            border: Border.all(color: accent.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: accent),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: AppTypography.labelLarge.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// معاينة وسيط مرفوع (صورة حقيقية / فيديو بأيقونة تشغيل) + زر إزالة.
class _MediaThumb extends StatelessWidget {
  final _MediaItem item;
  final VoidCallback onRemove;

  const _MediaThumb({required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    const double size = 96;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.lg),
              child: item.isVideo
                  ? Container(
                      color: onSurface.withValues(alpha: 0.08),
                      alignment: Alignment.center,
                      child: Icon(
                        LucideIcons.circlePlay,
                        size: 30,
                        color: onSurface.withValues(alpha: 0.75),
                      ),
                    )
                  : Image.file(
                      File(item.path),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: onSurface.withValues(alpha: 0.08),
                        alignment: Alignment.center,
                        child: Icon(
                          LucideIcons.image,
                          size: 26,
                          color: onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
            ),
          ),
          Positioned(
            top: -6,
            right: -6,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.backgroundColors.surface,
                  border: Border.all(color: onSurface.withValues(alpha: 0.15)),
                ),
                child: Icon(LucideIcons.x, size: 14, color: onSurface),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
