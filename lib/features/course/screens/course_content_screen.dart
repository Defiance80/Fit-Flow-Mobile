import 'package:fitflow/common/enums.dart';
import 'package:fitflow/common/models/chapter_model.dart';
import 'package:fitflow/common/models/course_model.dart';
import 'package:fitflow/common/widgets/custom_text.dart';
import 'package:fitflow/core/constants/app_labels.dart';
import 'package:fitflow/core/routes/route_params.dart';
import 'package:fitflow/core/routes/routes.dart';
import 'package:fitflow/core/services/refresh_notifier.dart';
import 'package:fitflow/features/course/cubit/course_chapters_cubit.dart';
import 'package:fitflow/features/course/cubit/course_details_cubit.dart';
import 'package:fitflow/features/course/cubits/fetch_discussion_cubit.dart';
import 'package:fitflow/features/course/repository/course_repository.dart';
import 'package:fitflow/features/course/repositories/discussion_repository.dart';
import 'package:fitflow/features/course/services/course_content_notifier.dart';
import 'package:fitflow/features/course/features/discussion/widgets/message_bottombar.dart';
import 'package:fitflow/features/course/features/quiz/widgets/start_quiz_card.dart';
import 'package:fitflow/features/course/widgets/assignment_preview_widget.dart';
import 'package:fitflow/features/course/widgets/chapters_list_section.dart';
import 'package:fitflow/features/course/widgets/course_details_appbar.dart';
import 'package:fitflow/features/course/widgets/document_preview_widget.dart';
import 'package:fitflow/features/course/features/discussion/widgets/discussion_section.dart';
import 'package:fitflow/features/course/widgets/mini_screen.dart';
import 'package:fitflow/features/course/widgets/more_content_section.dart';
import 'package:fitflow/features/video_player/bloc/video_player_bloc.dart';
import 'package:fitflow/features/video_player/video_player.dart';
import 'package:fitflow/utils/extensions/context_extension.dart';
import 'package:fitflow/utils/file_download_helper.dart';
import 'package:flutter/material.dart';
import 'package:fitflow/common/widgets/custom_tab_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class CourseContentBaseWidget extends StatefulWidget {
  const CourseContentBaseWidget({super.key});

  @override
  State<CourseContentBaseWidget> createState() =>
      _CourseContentBaseWidgetState();
}

class _CourseContentBaseWidgetState extends State<CourseContentBaseWidget>
    with MiniScreenMixin {
  static const double _videoHeight = 220.0;
  double _getVideoHeight(BuildContext context) {
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    if (isLandscape) {
      return MediaQuery.of(context).size.height * 0.4;
    }
    return _videoHeight;
  }

  bool _hideLayout = false;

  @override
  Widget build(BuildContext context) {
    final double videoHeight = _getVideoHeight(context);
    return Scaffold(
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;

          final navigator = Get.nestedKey(1)?.currentState;
          if (navigator != null && navigator.canPop()) {
            navigator.pop();
          } else {
            // Let the outer PopScope handle closing the overlay
            CourseContentNotifier.instance.hide();
          }
        },
        child: Stack(
          children: [
            Screen(
              settings: Settings(
                opacityWeight: 10,
                playerSize: Size(context.screenWidth, videoHeight),
                miniPlayerSize: Size(context.screenWidth * 0.6, 150),
              ),
              builder: (context, value) {
                _hideLayout = value > 0.2;

                return Scaffold(
                  resizeToAvoidBottomInset: true,
                  backgroundColor: Color.lerp(
                    Theme.of(context).scaffoldBackgroundColor,
                    Colors.transparent,
                    1 - weightedOpacity,
                  ),
                  body: _MiniPlayerData(
                    hideLayout: _hideLayout,
                    weightedOpacity: weightedOpacity,
                    miniScreenState: this,
                    child: Material(
                      color: Colors.transparent,
                      child: HeroControllerScope(
                        controller: MaterialApp.createMaterialHeroController(),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height,
                          child: Navigator(
                            key: Get.nestedKey(1),
                            initialRoute: '/',
                            onGenerateRoute: CourseContentRoute.onGenerateRoute,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// InheritedWidget to pass mini player state through the Navigator
class _MiniPlayerData extends InheritedWidget {
  final bool hideLayout;
  final double weightedOpacity;
  final _CourseContentBaseWidgetState miniScreenState;

  const _MiniPlayerData({
    required this.hideLayout,
    required this.weightedOpacity,
    required this.miniScreenState,
    required super.child,
  });

  static _MiniPlayerData? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_MiniPlayerData>();
  }

  @override
  bool updateShouldNotify(_MiniPlayerData oldWidget) {
    return hideLayout != oldWidget.hideLayout ||
        weightedOpacity != oldWidget.weightedOpacity;
  }
}

class CourseContentScreen extends StatefulWidget {
  final int courseId;
  const CourseContentScreen({super.key, required this.courseId});

  static Widget route() {
    // Check if arguments are of the correct type before casting
    final CourseContentScreenArguments? arguments =
        Get.arguments is CourseContentScreenArguments
        ? Get.arguments as CourseContentScreenArguments
        : null;

    // Get course from notifier first, fallback to arguments for route-based navigation
    final int courseId =
        CourseContentNotifier.instance.currentCourse?.id ??
        arguments?.course.id ??
        (throw Exception('CourseContentScreen requires course data'));

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CourseChaptersCubit(CourseRepository()),
        ),
        BlocProvider(
          create: (context) => CourseDetailsCubit(CourseRepository()),
        ),
        BlocProvider(
          create: (context) =>
              FetchDiscussionCubit(DiscussionRepository(), courseId: courseId),
        ),
      ],
      child: CourseContentScreen(courseId: courseId),
    );
  }

  @override
  State<CourseContentScreen> createState() => _CourseContentScreenState();
}

class _CourseContentScreenState extends State<CourseContentScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ValueNotifier<bool> _showMessageBottomBar = ValueNotifier(false);
  final ValueNotifier<CurriculumModel?> _currentCurriculum = ValueNotifier(
    null,
  );
  final ValueNotifier<int?> _currentChapterId = ValueNotifier(null);
  late CourseModel _course;

  // Video player constants
  static const double _videoHeight = 211.0;
  static const double _contentPadding = 16.0;

  @override
  void initState() {
    super.initState();

    // Check if arguments are of the correct type before casting
    final CourseContentScreenArguments? arguments =
        Get.arguments is CourseContentScreenArguments
        ? Get.arguments as CourseContentScreenArguments
        : null;

    // Get course from notifier first, fallback to arguments for route-based navigation
    _course =
        CourseContentNotifier.instance.currentCourse ??
        arguments?.course ??
        (throw Exception(
          'CourseContentScreen requires course data via arguments or notifier',
        ));

    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(_handleTabChange);

    // Fetch chapters for this course
    context.read<CourseChaptersCubit>().fetchChapters(_course.id);

    // Fetch course details
    context.read<CourseDetailsCubit>().fetchCourseDetails(_course);
  }

  void _handleTabChange() {
    _showMessageBottomBar.value = _tabController.index == 1;
  }

  void _onCurriculumTap(
    int chapterId,
    CurriculumModel curriculum,
    bool sequentialAccess,
  ) {
    // Update the displayed curriculum and chapter ID
    setState(() {
      _currentCurriculum.value = curriculum;
      _currentChapterId.value = chapterId;
    });
  }

  void _onVideoCompletion() async {
    final curriculum = _currentCurriculum.value;
    if (curriculum == null) return;

    // Find the chapter ID for the current curriculum
    final chaptersState = context.read<CourseChaptersCubit>().state;
    if (chaptersState is! CourseChaptersSuccess) return;

    int? chapterId;
    for (final chapter in chaptersState.data) {
      if (chapter.curriculum.any((c) => c.id == curriculum.id)) {
        chapterId = chapter.id;
        break;
      }
    }

    if (chapterId == null) return;

    final sequentialAccess =
        context.read<CourseDetailsCubit>().courseDetails?.sequentialAccess ??
        false;

    // Mark curriculum as completed
    await context.read<CourseChaptersCubit>().markCurriculumCompleted(
      chapterId: chapterId,
      courseId: widget.courseId,
      curriculum: curriculum,
      sequentialAccess: sequentialAccess,
    );

    // Mark My Learning screen for refresh
    RefreshNotifier.instance.markMyLearningForRefresh();
  }

  Future<void> _onDocumentOpen() async {
    final curriculum = _currentCurriculum.value;
    if (curriculum == null) return;

    // Get the document URL (prefer file over url)
    final String? documentUrl = curriculum.file ?? curriculum.url;
    if (documentUrl == null || documentUrl.isEmpty) return;

    // Find the chapter ID for the current curriculum
    final chaptersState = context.read<CourseChaptersCubit>().state;
    if (chaptersState is! CourseChaptersSuccess) return;

    int? chapterId;
    for (final ChapterModel chapter in chaptersState.data) {
      if (chapter.curriculum.any((c) => c.id == curriculum.id)) {
        chapterId = chapter.id;
        break;
      }
    }

    if (chapterId == null) return;

    final bool sequentialAccess =
        context.read<CourseDetailsCubit>().courseDetails?.sequentialAccess ??
        false;

    // Mark curriculum as completed and wait for state update
    await context.read<CourseChaptersCubit>().markCurriculumCompleted(
      chapterId: chapterId,
      curriculum: curriculum,
      sequentialAccess: sequentialAccess,
      courseId: widget.courseId,
    );

    // Open the document after marking as complete
    await FileDownloadHelper.downloadOrOpenFile(
      documentUrl,
      fileName: curriculum.title,
    );

    // Mark My Learning screen for refresh
    RefreshNotifier.instance.markMyLearningForRefresh();
  }

  Future<void> _onSkipToNextLecture(CurriculumModel curriculum) async {
    // Find the chapter ID for the current curriculum
    final chaptersState = context.read<CourseChaptersCubit>().state;
    if (chaptersState is! CourseChaptersSuccess) return;

    int? chapterId;
    for (final ChapterModel chapter in chaptersState.data) {
      if (chapter.curriculum.any((c) => c.id == curriculum.id)) {
        chapterId = chapter.id;
        break;
      }
    }

    if (chapterId == null) return;

    final bool sequentialAccess =
        context.read<CourseDetailsCubit>().courseDetails?.sequentialAccess ??
        false;

    // Mark assignment curriculum as completed
    await context.read<CourseChaptersCubit>().markCurriculumCompleted(
      chapterId: chapterId,
      curriculum: curriculum,
      sequentialAccess: sequentialAccess,
      courseId: widget.courseId,
    );

    // Check if widget is still mounted before using context
    if (!mounted) return;

    // Find and navigate to the next curriculum
    final updatedState = context.read<CourseChaptersCubit>().state;
    if (updatedState is! CourseChaptersSuccess) return;

    CurriculumModel? nextCurriculum;
    int? nextChapterId;

    // Find the current curriculum's position
    bool foundCurrent = false;
    for (final chapter in updatedState.data) {
      for (final curr in chapter.curriculum) {
        if (foundCurrent) {
          nextCurriculum = curr;
          nextChapterId = chapter.id;
          break;
        }
        if (curr.id == curriculum.id) {
          foundCurrent = true;
        }
      }
      if (nextCurriculum != null) break;
    }

    // Update to next curriculum if found
    if (nextCurriculum != null && nextChapterId != null) {
      _onCurriculumTap(nextChapterId, nextCurriculum, sequentialAccess);
    }

    // Mark My Learning screen for refresh
    RefreshNotifier.instance.markMyLearningForRefresh();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _showMessageBottomBar.dispose();
    _currentCurriculum.dispose();
    super.dispose();
  }

  void _initializeCurrentCurriculum(List<ChapterModel> chapters) {
    if (_currentCurriculum.value != null) return; // Already initialized

    final courseDetails = context.read<CourseDetailsCubit>().courseDetails;
    final currentCurriculumData = courseDetails?.currentCurriculum;

    // Find curriculum by model_id from current_curriculum if provided
    if (currentCurriculumData != null) {
      for (final chapter in chapters) {
        final curriculum = chapter.curriculum.firstWhereOrNull(
          (c) => c.id == currentCurriculumData.modelId,
        );
        if (curriculum != null) {
          _currentCurriculum.value = curriculum;
          _currentChapterId.value = chapter.id;
          return;
        }
      }
    }

    // Fallback to first curriculum if available
    if (chapters.isNotEmpty && chapters.first.curriculum.isNotEmpty) {
      _currentCurriculum.value = chapters.first.curriculum.first;
      _currentChapterId.value = chapters.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final miniPlayerData = _MiniPlayerData.of(context);
    final hideLayout = miniPlayerData?.hideLayout ?? false;
    final weightedOpacity = miniPlayerData?.weightedOpacity ?? 1.0;

    return Material(
      color: Color.lerp(
        Theme.of(context).scaffoldBackgroundColor,
        Colors.transparent,
        1 - weightedOpacity,
      ),
      child: Stack(
        children: [
          _buildMainContent(hideLayout, weightedOpacity),
          _buildMessageBar(widget.courseId),
        ],
      ),
    );
  }

  Widget _buildMainContent(bool hideLayout, double weightedOpacity) {
    return DefaultTabController(
      length: 3,
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) =>
            [
              if (!hideLayout) _buildAppBar(weightedOpacity),
              _buildHeaderSection(),
              _buildTabBar(weightedOpacity),
            ],
        body: AnimatedOpacity(
          opacity: weightedOpacity,
          duration: const Duration(milliseconds: 200),
          child: _buildTabContent(),
        ),
      ),
    );
  }

  Widget _buildAppBar(double weightedOpacity) {
    return SliverAnimatedOpacity(
      opacity: weightedOpacity,
      duration: const Duration(milliseconds: 200),
      sliver: SliverAppBar(
        expandedHeight: 0,
        toolbarHeight: kToolbarHeight + 10,
        pinned: true,
        automaticallyImplyLeading: false,
        flexibleSpace: CourseDetailsAppBar(course: _course),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const .symmetric(horizontal: _contentPadding, vertical: 16),
        child: MultiBlocListener(
          listeners: [
            BlocListener<CourseDetailsCubit, CourseDetailsState>(
              listener: (context, courseDetailsState) {
                // Initialize when course details are loaded (if chapters are ready)
                final chaptersState = context.read<CourseChaptersCubit>().state;
                if (courseDetailsState is CourseDetailsSuccess &&
                    chaptersState is CourseChaptersSuccess &&
                    chaptersState.data.isNotEmpty) {
                  _initializeCurrentCurriculum(chaptersState.data);
                  setState(() {});
                }
              },
            ),
            BlocListener<CourseChaptersCubit, CourseChaptersState>(
              listener: (context, chaptersState) {
                // Initialize when chapters are loaded (if course details are ready)
                final courseDetailsState = context
                    .read<CourseDetailsCubit>()
                    .state;
                if (courseDetailsState is CourseDetailsSuccess &&
                    chaptersState is CourseChaptersSuccess &&
                    chaptersState.data.isNotEmpty) {
                  _initializeCurrentCurriculum(chaptersState.data);
                  setState(() {});
                }
              },
            ),
          ],
          child: ValueListenableBuilder<CurriculumModel?>(
            valueListenable: _currentCurriculum,
            builder: (context, curriculum, child) {
              if (curriculum == null) {
                return _buildLoadingPlaceholder();
              }

              // Show UI based on curriculum type
              final String? type = curriculum.type?.toLowerCase();
              if (type == 'quiz') {
                return StartQuizCard(
                  curriculum: curriculum,
                  courseChapterQuizId: curriculum.id.toString(),
                  courseId: _course.id,
                  chapterId: _currentChapterId.value ?? 0,
                );
              } else if (type == 'document') {
                return _buildDocumentPreview(curriculum);
              } else if (type == 'assignment') {
                return _buildAssignmentPreview(curriculum);
              } else {
                return _buildVideoPlayer(curriculum);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(double weightedOpacity) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverTabBarDelegate(
        Material(
          color: Colors.transparent,
          child: Opacity(
            opacity: weightedOpacity,
            child: CustomTabBar(
              controller: _tabController,
              tabs: [
                AppLabels.chapter.tr,
                AppLabels.discussion.tr,
                AppLabels.more.tr,
              ],
              margin: const .symmetric(horizontal: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        BlocBuilder<CourseChaptersCubit, CourseChaptersState>(
          builder: (context, state) {
            if (state is CourseChaptersSuccess) {
              final bool sequentialAccess =
                  context
                      .read<CourseDetailsCubit>()
                      .courseDetails
                      ?.sequentialAccess ??
                  false;

              return ValueListenableBuilder<CurriculumModel?>(
                valueListenable: _currentCurriculum,
                builder: (context, currentCurriculum, child) {
                  return ChaptersListSection(
                    chapters: state.data,
                    sequentialAccess: sequentialAccess,
                    isEnrolled: _course.isEnrolled,
                    currentCurriculumId: currentCurriculum?.id,
                    padding: const .symmetric(horizontal: 16),
                    onCurriculumTap: (chapterId, curriculum) {
                      _onCurriculumTap(chapterId, curriculum, sequentialAccess);
                    },
                  );
                },
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
        const DiscussionSection(),
        MoreContentSection(course: _course),
      ],
    );
  }

  Widget _buildMessageBar(int courseId) {
    return ValueListenableBuilder(
      valueListenable: _showMessageBottomBar,
      builder: (context, value, child) {
        if (value) {
          return Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MessageBottomBar(
              id: courseId,
              destination: DiscussionDestination.course,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoadingPlaceholder() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: _videoHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.color.surfaceContainerHighest,
          border: Border.all(color: context.color.outline),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: .center,
            spacing: 12,
            children: [
              CustomText(
                AppLabels.loading.tr,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge!.copyWith(color: context.color.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(CurriculumModel curriculum) {
    final baseWidgetState = context
        .findAncestorStateOfType<_CourseContentBaseWidgetState>();

    if (baseWidgetState == null) {
      // Fallback if base widget state is not available
      return ClipRRect(
        key: ValueKey(curriculum.id.toString()),
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: _videoHeight,
          child: BlocProvider(
            create: (context) => VideoPlayerBloc(),
            child: CustomVideoPlayer(
              url: curriculum.file ?? curriculum.youtubeUrl ?? '-',
              onVideoCompletion: _onVideoCompletion,
            ),
          ),
        ),
      );
    }

    return baseWidgetState.MiniPlayer(
      builder: (BuildContext context, bool isMiniPlayer) {
        return ClipRRect(
          key: ValueKey(curriculum.id.toString()),
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            child: BlocProvider(
              create: (context) => VideoPlayerBloc(),
              child: CustomVideoPlayer(
                hideLayout: isMiniPlayer,
                url: curriculum.file ?? curriculum.youtubeUrl ?? '-',
                onVideoCompletion: _onVideoCompletion,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDocumentPreview(CurriculumModel curriculum) {
    return DocumentPreviewWidget(
      curriculum: curriculum,
      courseImage: _course.image,
      height: _videoHeight,
      onDocumentOpen: _onDocumentOpen,
    );
  }

  Widget _buildAssignmentPreview(CurriculumModel curriculum) {
    return AssignmentPreviewWidget(
      curriculum: curriculum,
      courseImage: _course.image,
      courseId: widget.courseId,
      height: _videoHeight,
      onSkipToNext: () => _onSkipToNextLecture(curriculum),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: overlapsContent ? context.color.surface : null,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => 56.0;

  @override
  double get minExtent => 56.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
