import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// ★ أيقونة «إعادة النشر» (سهم المشاركة المنحني) — نسخة SVG مطابقة للتصميم.
class ShareArrowIcon extends StatelessWidget {
  const ShareArrowIcon({
    super.key,
    this.size = 20,
    this.color,
  });

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/share_arrow.svg',
      width: size,
      height: size,
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color!, BlendMode.srcIn),
    );
  }
}