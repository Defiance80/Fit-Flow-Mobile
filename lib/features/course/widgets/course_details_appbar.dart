import 'package:fitflow/common/models/course_model.dart';
import 'package:fitflow/common/widgets/custom_icon_button.dart';
import 'package:fitflow/common/widgets/custom_image.dart';
import 'package:fitflow/common/widgets/wishlist_button.dart';
import 'package:fitflow/core/constants/app_icons.dart';
import 'package:fitflow/core/deep_linking/deep_link_manager.dart';
import 'package:fitflow/core/services/refresh_notifier.dart';
import 'package:fitflow/features/course/services/course_content_notifier.dart';
import 'package:fitflow/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class CourseDetailsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final CourseModel course;
  const CourseDetailsAppBar({super.key, required this.course});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);

  void _onBackPressed() {
    // Hide the course content screen
    CourseContentNotifier.instance.hide();
    // Mark My Learning screen for refresh
    RefreshNotifier.instance.markMyLearningForRefresh();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: _onBackPressed,
        icon: CustomImage(
          AppIcons.arrowLeft,
          height: 24,
          width: 24,
          color: context.color.onSurface,
        ),
      ),
      actions: [
        CustomIconButton(
          image: AppIcons.share,
          onTap: () async {
            await Share.shareUri(
              Uri.parse(
                DeepLinkManager.instance.createDeepLink(slug: course.slug!),
              ),
            );
          },
          size: const Size.square(38),
          padding: const .all(8),
          color: context.color.onSurface,
        ),
        const SizedBox(width: 16),
        WishlistButton(
          courseId: course.id,
          isWishlisted: course.isWishlisted,
          size: 40,
          isCircular: false,
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}
