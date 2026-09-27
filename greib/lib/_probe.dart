import 'package:flutter/material.dart';
class Probe { String f() { return                                       Row(
                                        children: [
                                          // grouped ⇒ Expanded داخلي.
                                          _fbActionButton(
                                            grouped: true,
                                            icon: LucideIcons.thumbsUp,
                                            label: 'إعجاب',
                                            color: current == 1
                                                ? AppColors.info
                                                : idle,
                                            onTap: () => setSheetState(() {
                                              _reactions[service.id] = 1;
                                              setState(() {});
                                            }),
                                          ),
                                          const SizedBox(width: 10),
                                          _fbActionButton(
                                            grouped: true,
                                            icon: LucideIcons.thumbsDown,
                                            label: 'عدم إعجاب',
                                            color: current == -1
                                                ? AppColors.error
                                                : idle,
                                            onTap: () => setSheetState(() {
                                              _reactions[service.id] = -1;
                                              setState(() {});
                                            }),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      // ★ تبويب يحمل الأعداد.
                                      SizedBox(
                                        height: 240,
                                        child: DefaultTabController(
                                          length: 2,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              TabBar(
                                                labelColor: AppColors.info,
                                                unselectedLabelColor: idle,
                                                indicatorColor: AppColors.info,
                                                indicatorSize:
                                                    TabBarIndicatorSize.tab,
                                                dividerColor: widget.isDark
                                                    ? AppColors.outline
                                                    : AppColors.lightOutline,
                                                labelStyle: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                tabs: [
                                                  Tab(text: 'إعجاب ($likeCount)'),
                                                  Tab(
                                                    text:
                                                        'عدم إعجاب ($dislikeCount)',
                                                  ),
                                                ],
                                              ),
                                              Expanded(
                                                child: TabBarView(
                                                  children: [
                                                    _reactionUsersList(
                                                      _kMockLikedUsers,
                                                      LucideIcons.thumbsUp,
                                                      AppColors.info,
                                                    ),
                                                    _reactionUsersList(
                                                      _kMockDislikedUsers,
                                                      LucideIcons.thumbsDown,
                                                      AppColors.error,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],; } }
