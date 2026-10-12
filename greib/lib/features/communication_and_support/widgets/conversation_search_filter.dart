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
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: chat.inputHint),
        prefixIcon: Icon(
          LucideIcons.search,
          size: 20,
          color: chat.composerIcon,
        ),
        suffixIcon: query.isEmpty
            ? null
            : IconButton(
                icon: Icon(LucideIcons.x, size: 18, color: chat.composerIcon),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                tooltip: 'مسح البحث',
              ),
        filled: true,
        fillColor: chat.inputField,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.full),
          borderSide: BorderSide.none,
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
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: labels.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
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
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              color: selected ? chat.sendIcon : chat.inputText,
            ),
            selectedColor: chat.sendButton,
            backgroundColor: chat.inputField,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.full),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
          );
        },
      ),
    );
  }
}
