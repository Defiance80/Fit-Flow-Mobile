import 'package:fitflow/core/constants/app_labels.dart';
import 'package:fitflow/core/login/guest_checker.dart';
import 'package:fitflow/utils/extensions/context_extension.dart';
import 'package:fitflow/common/widgets/custom_image.dart';
import 'package:fitflow/core/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:fitflow/common/widgets/custom_text.dart';
import 'package:get/get.dart';

class CustomBottomNavBar extends StatelessWidget {
  final Function(int index) onTabSelected;
  final int selectedTabIndex;
  CustomBottomNavBar({
    super.key,
    required this.onTabSelected,
    required this.selectedTabIndex,
  });

  final List<({String svgPath, String labelKey, bool loginRequired})> _tabs = [
    (svgPath: AppIcons.home, labelKey: AppLabels.home.tr, loginRequired: false),
    (
      svgPath: AppIcons.myLearning,
      labelKey: AppLabels.myLearning.tr,
      loginRequired: true,
    ),
    (svgPath: AppIcons.cart, labelKey: AppLabels.cart.tr, loginRequired: true),
    (
      svgPath: AppIcons.profile,
      labelKey: AppLabels.profile.tr,
      loginRequired: false,
    ),
  ];

  final _tabItemAnimationDuration = const Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    final deviceBottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      height:
          kBottomNavigationBarHeight +
          (deviceBottomPadding < 28 ? 18 : (deviceBottomPadding - 12)),
      padding: .zero,
      margin: .zero,
      color: context.color.surface,
      child: Row(
        crossAxisAlignment: .stretch,
        children: List.generate(
          _tabs.length,
          (index) => _buildTabItem(
            context,
            index: index,
            svgPath: _tabs[index].svgPath,
            labelKey: _tabs[index].labelKey,
            loginRequired: _tabs[index].loginRequired,
          ),
        ),
      ),
    );
  }

  ///to be used in [Row] or [Column] as it includes [Expanded] widget
  Widget _buildTabItem(
    BuildContext context, {
    required int index,
    required String svgPath,
    required String labelKey,
    required bool loginRequired,
  }) {
    final isSelected = index == selectedTabIndex;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (loginRequired) {
              GuestChecker.check(
                onNotGuest: () {
                  onTabSelected(index);
                },
              );
            } else {
              onTabSelected(index);
            }
          },
          child: AnimatedContainer(
            duration: _tabItemAnimationDuration,
            padding: const .all(12),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withAlpha(20),
                        Theme.of(context).colorScheme.surface.withAlpha(0),
                      ],
                      stops: const [0.4, 1],
                      begin: .topCenter,
                      end: .bottomCenter,
                    )
                  : null,
              border: Border(
                top: isSelected
                    ? BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      )
                    : BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(50),
                        width: 0.5,
                      ),
              ),
            ),
            child: Column(
              crossAxisAlignment: .stretch,
              mainAxisSize: .min,
              children: [
                CustomImage(
                  svgPath,
                  color: isSelected
                      ? context.color.primary
                      : context.color.onSurface.withValues(alpha: 0.6),
                  width: 24,
                  height: 24,
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: .scaleDown,
                  child: CustomText(
                    labelKey.tr,
                    textAlign: .center,
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      fontWeight: isSelected
                          ? .w600
                          : .w400,
                      color: isSelected
                          ? context.color.primary
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
