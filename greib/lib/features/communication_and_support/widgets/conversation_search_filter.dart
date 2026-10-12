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

  @override
  Widget build(BuildContext context) {
    final chat = context.chatColors;
    return SizedBox(
      // ★ 44 ارتفاع واتساب الفعلي للبحث (مضغوط) بدل ~56 المريح.
      height: 44,
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.full),
            borderSide: BorderSide.none,
          ),
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
      // ★ 32 ارتفاع واتساب للشيبس (نحيفة) بدل 40.
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        // ★ 8 أفقي مثل البحث — ملتصقة بالحافة مثل واتساب.
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: labels.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final selected = selectedIndex == i;
          final isUnreadChip = labels[i].contains('غير مقروء');
          final label = isUnreadChip && unreadCount > 0
              ? '${labels[i]} $unreadCount'
              : labels[i];
          return ChoiceChip(
            label: Text(label),
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
          );
        },
      ),
    );
  }
}
