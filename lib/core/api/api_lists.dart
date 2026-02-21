import 'package:fitflow/core/configs/app_settings.dart';

class Apis {
  Apis._();

  // Base URL
  static String baseUrl = AppSettings.baseUrl;

  // Auth endpoints
  static final String userExists = api('user-exists');
  static final String login = api('user-login');
  static final String userSignup = api('user-signup');
  static final String getUserDetails = api('get-user-details');
  static final String mobileLogin = api('mobile-login');
  static final String mobileRegister = api('mobile-registration');
  static final String resetPassword = api('mobile-reset-password');
  static final String appSettings = api('app-settings');

  ///Course related apis
  static final String getCourses = api('get-courses');
  static final String getCourse = api('get-course');
  static final String getCourseChapters = api('get-course-chapters');

  ///Category related APIs
  static final String categories = api('categories');
  static final String getInstructors = api('get-instructors');
  static final String getInstructorDetails = api('get-instructor-details');
  static final String slider = api('get-sliders');
  static final String getFeatureSections = api('get-feature-sections');
  static final String getWishlist = api('wishlist');
  static final String wishlist = api('wishlist/add-update-wishlist');
  static final String couponsForCourse = api('promo-code/for-course');
  static final String getSearchSuggestions = api('get-search-suggestions');
  static final String markCurriculumComplete = api('curriculum/mark-completed');

  ///Cart related APIs
  static final String getCart = api('cart');
  static final String clearCart = api('cart/clear');
  static final String addToCart = api('cart/add');
  static final String removeFromCart = api('cart/remove');
  static final String placeOrder = api('place_order');
  static final String orders = api('orders');

  ///My Learning related APIs
  static final String myLearning = api('my-learning');

  ///Assignment related APIs
  static final String getAssignments = api('get-assignments');
  static final String submitAssignment = api('assignments/submit');
  static final String updateAssignmentSubmission = api(
    'assignments/submission',
  );
  static final String getCourseReviews = api('get-course-reviews');
  static final String getResources = api('get-resources');

  ///Review related APIs
  static final String addReview = api('rating/add');
  static final String deleteReview = api('rating/delete');
  static final String notifications = api('notifications');
  static final String updateProfile = api('update-profile');
  static final String changePassword = api('change-password');

  ///Discussion related APIs
  static final String courseDiscussion = api('discussion/course');
  static final String getValidCoupons = api('promo-code/get-valid-list');
  static final String applyCouponCart = api('cart/apply-promo');
  static final String removeCouponCart = api('cart/remove-promo');
  static final String applyCoupon = api('promo-code/apply-promo-code');

  ///help desk
  static final String discussionGroups = api('helpdesk/groups');
  static final String discussionQuestions = api('helpdesk/questions');
  static final String requestPrivateGroup = api('helpdesk/groups/request');
  static final String helpDeskQuestion = api('helpdesk/question');
  static final String helpDeskQuestionReply = api('helpdesk/question/reply');
  static final String askQuestion = api('helpdesk/question');
  static final String getCourseLanguages = api('get-course-languages');

  ///Quiz related APIs
  static final String getQuizDetails = api('quiz/details');
  static final String quizStart = api('quiz/start');
  static final String quizAnswer = api('quiz/answer');
  static final String quizFinish = api('quiz/finish');

  static final String quizSummary = api('quiz/summary');

  static final String invoiceDownload = api('download-invoice');
  static final String faqs = api('faqs');
  static final String courseCompletion = api('curriculum/course-completion');
  static final String applyPromoCode = api('promo-code/apply-promo-code');
  static final String downloadCertificate = api('certificate/course/download');
  static final String purchaseCertificate = api('purchase-certificate');
  static final String deleteAccount = api('delete-account');
  static final String pages = api('pages');
  static final String contactUs = api('contact-us');

  static final String systemLanguages = api('system-languages');

  ///Team invitation related APIs
  static final String teamInvitationAction = api('accept-team-invitation');

  ///Refund related APIs
  static final String refundRequest = api('refund/request');
  static final String myRefunds = api('refund/my-refunds');

  ///Wallet related APIs
  static final String walletHistory = api('wallet/history');
  static final String withdrawalRequest = api('wallet/withdrawal-request');

  static String api(String url) {
    // ignore: no_leading_underscores_for_local_identifiers
    String _baseUrl = baseUrl;

    if (_baseUrl.endsWith('/')) {
      _baseUrl = _baseUrl.substring(0, _baseUrl.length - 1);
    } else {
      _baseUrl = baseUrl;
    }

    return '$_baseUrl/api/$url';
  }
}
