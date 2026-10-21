import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/chat_colors.dart';
import '../../../core/theme/design_tokens.dart';

/// شريط بحث ثابت (Persistent Search Bar) مثل واتساب.
class ConversationSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final String hintText;

  const ConversationSearchBar({
    super.key,
    required this.controller,
    required this.query,
    required this.onChanged,
    this.hintText = 'ابحث في المحادثات...',
  });

  /// ★ حواف الحقل دائرية بالكامل (99) — تُعرَّف صراحةً لكل الحالات،
  /// لأن ثيم التطبيق يفرض enabledBorder بزوايا 16 ويتجاهل `border`.
  static const OutlineInputBorder _pillBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(99)),
    borderSide: BorderSide.none,
  );

  @override
  Widget build(BuildContext context) {
    final chat = context.chatColors;
    return SizedBox(
      // ★ 48 ارتفاع واتساب للبحث (مريح قليلاً) — يتوازن مع شبكة 8px.
      height: 48,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: chat.inputHint, fontSize: 14),
          prefixIcon: Icon(
            LucideIcons.search,
            size: 18,
            color: chat.composerIcon,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
          suffixIcon: query.isEmpty
              ? null
              : IconButton(
                  icon: Icon(LucideIcons.x, size: 16, color: chat.composerIcon),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                  tooltip: 'مسح البحث',
                ),
          filled: true,
          fillColor: chat.inputField,
          // ★ حشوة داخلية مضغوطة: واتساب البحث نحيف.
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          border: _pillBorder,
          enabledBorder: _pillBorder,
          focusedBorder: _pillBorder,
        ),
      ),
    );
  }
}

/// فلاتر أفقية مبسطة: 3 فقط بدون (مفضلة/مقفلة/مؤرشفة/Meta AI).
class ConversationFilterChips extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final int unreadCount;

  const ConversationFilterChips({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    this.unreadCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final chat = context.chatColors;
    return SizedBox(
      // ★ 36 ارتفاع واتساب للشيبس — إيقاع 8/4 متناسق مع البحث 48.
      height: 36,
      child: Padding(
        // ★ 12 أفقي مثل البحث — محاذاة عمودية واحدة.
        padding: const EdgeInsets.symmetric(horizontal: 12),
        // ★ التبويبات موزّعة على كامل العرض المتاح: المسافات بينها تتوسّع
        //   أفقياً لتملأ المساحة (بدل التمرير الأفقي) — مظهر أكثر احترافية.
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (int i = 0; i < labels.length; i++)
              // ★ Flexible بمرونة (loose): يمنع أي تجاوز على الشاشات الضيقة
              //   مع الحفاظ على عرض الشيبس الطبيعي.
              Flexible(child: _chip(context, chat, i)),
          ],
        ),
      ),
    );
  }

  /// شيبس فلتر واحد — المختار يتلوّن باللون الرسمي.
  Widget _chip(BuildContext context, AppChatColors chat, int i) {
    final selected = selectedIndex == i;
    final isUnreadChip = labels[i].contains('غير مقروء');
    final label = isUnreadChip && unreadCount > 0
        ? '${labels[i]} $unreadCount'
        : labels[i];
    return ChoiceChip(
      label: Text(
        label,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
      ),
      selected: selected,
      onSelected: (_) => onSelected(i),
      showCheckmark: false,
      // ★ خط 12 مضغوط مثل واتساب بدل 13.
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
        color: selected ? chat.sendIcon : chat.inputText,
      ),
      selectedColor: chat.sendButton,
      backgroundColor: chat.inputField,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.full),
      ),
      // ★ حشوة الشيبس مضغوطة: واتساب الشيبس صغيرة ومتلاصقة.
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
