import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/extensions/context_extensions.dart';
import '../../core/mock_data/mock_data.dart';
import '../../core/theme/chat_colors.dart';
import '../../core/theme/design_tokens.dart';
import '../../shared_widgets/loading_states.dart';
import 'chat_screen.dart' show ChatDetailScreen;
import 'contacts_chat_store.dart';

/// ============================================================================
///  صفحة «جهات الاتصال» — تُفتح من أيقونة القلم أسفل قائمة الدردشة.
///
///  ★ التبويبان (بنمط underline مثل صفحة الحساب /profile):
///    1) «جهات اتصال گريب منك»: الحسابات الرسمية + حسابات خدمات
///       مُرتّبة حسب تصنيفات الرئيسية (شيبس قابلة للتمرير).
///    2) «جهات اتصلي»: المحادثات القائمة للمستخدم (+ أي محادثة جديدة
///       بدأها من هنا) — بأسلوب جهات اتصال واتساب.
///
///  ★ الضغط على أي حساب: يفتح `ChatDetailScreen` بنفس الطريقة الحالية،
///    وحسابات الخدمات تُحفظ في `ContactsChatStore` ⇒ تظهر فوراً في
///    قائمة الدردشة الرئيسية.
/// ============================================================================
class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key, required this.existingConversations});

  /// محادثات المستخدم الحالية (تُعرض في تبويب «جهات اتصلي» وتُدمج معها
  /// المحادثات الجديدة المحفوظة في المخزن).
  final List<Map<String, dynamic>> existingConversations;

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  /// التصنيف المختار لشيبس الخدمات (null = الكل).
  String? _selectedCategory;

  /// «جهات اتصلي»: المحادثات الحالية + المحادثات الجديدة من المخزن
  /// (بدون تكرار بنفس المعرّف).
  List<Map<String, dynamic>> get _myContacts {
    final started = ContactsChatStore.instance.contactConversations();
    return [
      ...widget.existingConversations,
      ...started.where(
        (s) => !widget.existingConversations.any((e) => e['id'] == s['id']),
      ),
    ];
  }

  /// حسابات الخدمات بعد فلترة التصنيف المختار.
  List<ServiceContact> get _visibleServiceAccounts {
    final all = ContactsChatStore.serviceAccounts;
    if (_selectedCategory == null) return all;
    return all.where((a) => a.category == _selectedCategory).toList();
  }

  /// فتح دردشة حساب — بنفس آلية قائمة الدردشة (push لـ ChatDetailScreen).
  /// حسابات الخدمات تُحفظ أولاً في المخزن لتظهر في القائمة والتبويب الثاني.
  void _openAccountChat(ServiceContact contact) {
    ContactsChatStore.instance.startChat(contact);
    _pushChat(
      title: contact.name,
      conversationId: contact.id,
      avatar: contact.avatar,
      phone: contact.phone,
      online: contact.online,
      activity: contact.activity,
      // الرسمية تفتح محادثتها القائمة — والخدمات الجديدة تفتح محادثة
      // فارغة تماماً مثل واتساب.
      startEmpty:
          !ContactsChatStore.officialAccounts.any((a) => a.id == contact.id),
    );
  }

  /// فتح محادثة قائمة من تبويب «جهات اتصلي».
  void _openExistingChat(Map<String, dynamic> conv) {
    _pushChat(
      title: conv['name'] as String,
      conversationId: conv['id'] as String,
      avatar: conv['avatar'] as String,
      phone: (conv['phone'] as String?) ?? '',
      online: (conv['online'] as bool?) ?? false,
      activity: (conv['activity'] as String?) ?? '',
      startEmpty: (conv['isEmpty'] as bool?) ?? false,
    );
  }

  void _pushChat({
    required String title,
    required String conversationId,
    required String avatar,
    required String phone,
    required bool online,
    required String activity,
    required bool startEmpty,
  }) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => ChatDetailScreen(
          conversationTitle: title,
          conversationId: conversationId,
          avatar: avatar,
          phone: phone,
          online: online,
          activity: activity,
          isGroup: false,
          startEmpty: startEmpty,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chat = context.chatColors;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        title: Text(
          'جهات الاتصال',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      // ★ RTL ثابت (مثل باقي صفحات الدردشة).
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              // ★ شريط تبويب underline ملاصق للأعلى (نفس ستايل /profile).
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.10),
                    ),
                  ),
                ),
                child: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(
                      color: context.accentColor,
                      width: 2.5,
                    ),
                    insets:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  ),
                  labelPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  labelColor: context.accentColor,
                  unselectedLabelColor:
                      theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  labelStyle: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: const [
                    Tab(text: 'جهات اتصال گريب منك'),
                    Tab(text: 'جهات اتصلي'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildDirectoryTab(context, chat),
                    _buildMyContactsTab(context, chat),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────── التبويب ١: جهات اتصال گريب منك ─────────────────
  Widget _buildDirectoryTab(BuildContext context, AppChatColors chat) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.only(bottom: 110),
      children: [
        // ── قسم الحسابات الرسمية ──
        _SectionHeader(title: 'حسابات گريب منك'),
        ...ContactsChatStore.officialAccounts.expand(
          (a) => [
            _ContactTile(
              name: a.name,
              subtitle: a.activity,
              avatar: a.avatar,
              online: a.online,
              onTap: () => _openAccountChat(a),
            ),
            _tileDivider(chat),
          ],
        ),
        // ── قسم الخدمات حسب التصنيف ──
        _SectionHeader(title: 'الخدمات حسب التصنيف'),
        // ★ شيبس تصنيفات — نفس تبويبات الرئيسية (الكل + كل التصنيفات).
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            itemCount: MockData.productCategories.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, i) {
              final cat = MockData.productCategories[i];
              final id = cat['id'];
              final label = cat['label'] ?? '';
              final selected = id == 'all'
                  ? _selectedCategory == null
                  : _selectedCategory == id;
              return InkWell(
                borderRadius: BorderRadius.circular(AppRadii.full),
                onTap: () => setState(() {
                  _selectedCategory = (id == 'all' || selected) ? null : id;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? context.accentColor.withValues(alpha: 0.12)
                        : chat.sendButton.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(AppRadii.full),
                    border: Border.all(
                      color: selected
                          ? context.accentColor
                          : chat.composerBorder,
                    ),
                  ),
                  child: Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: selected
                          ? context.accentColor
                          : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        // ★ حسابات التصنيف المختار (أو الكل).
        if (_visibleServiceAccounts.isEmpty)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: EmptyState(
              icon: LucideIcons.users,
              title: 'لا توجد حسابات في هذا التصنيف',
              description: 'جرّب تصنيفاً آخر من الشيبس بالأعلى',
            ),
          )
        else
          ..._visibleServiceAccounts.expand(
            (a) => [
              _ContactTile(
                name: a.name,
                subtitle: a.phone,
                avatar: a.avatar,
                online: a.online,
                onTap: () => _openAccountChat(a),
              ),
              _tileDivider(chat),
            ],
          ),
      ],
    );
  }

  // ───────────────────────── التبويب ٢: جهات اتصلي ──────────────────────────
  Widget _buildMyContactsTab(BuildContext context, AppChatColors chat) {
    final contacts = _myContacts;
    if (contacts.isEmpty) {
      return const EmptyState(
        icon: LucideIcons.users,
        title: 'لا توجد جهات اتصال بعد',
        description: 'ابدأ محادثة من تبويب «جهات اتصال گريب منك»',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 110),
      itemCount: contacts.length,
      itemBuilder: (context, i) {
        final conv = contacts[i];
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ContactTile(
              name: conv['name'] as String,
              subtitle: (conv['activity'] as String?) ??
                  (conv['phone'] as String?) ??
                  '',
              avatar: conv['avatar'] as String,
              online: (conv['online'] as bool?) ?? false,
              onTap: () => _openExistingChat(conv),
            ),
            _tileDivider(chat),
          ],
        );
      },
    );
  }

  /// فاصل واتساب: رفيع + يبدأ بعد الأفاتار (12+52+12=76).
  Widget _tileDivider(AppChatColors chat) => Divider(
        height: 1,
        thickness: 0.5,
        indent: 76,
        endIndent: 12,
        color: chat.composerBorder,
      );
}


/// عنوان قسم صغير بلون الـ accent (مثل واتساب: «الأكثر تواصلاً»).
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: context.accentColor,
        ),
      ),
    );
  }
}

/// صف جهة اتصال: أفاتار دائري (إيموجي) + اسم + حالة + نقطة اتصال.
class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.name,
    required this.subtitle,
    required this.avatar,
    required this.onTap,
    this.online = false,
  });

  final String name;
  final String subtitle;
  final String avatar;
  final bool online;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chat = context.chatColors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: chat.sendButton.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(avatar, style: const TextStyle(fontSize: 22)),
                  ),
                ),
                if (online)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: chat.onlineDot,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.scaffoldBackgroundColor,
                          width: 2.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                      color: chat.recordingWaveUnplayed,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronLeft,
              size: 18,
              color: chat.recordingWaveUnplayed,
            ),
          ],
        ),
      ),
    );
  }
}

