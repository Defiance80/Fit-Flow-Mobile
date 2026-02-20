import 'package:elms/common/models/blueprints.dart';
import 'package:elms/features/help_support/models/discussion_topic.dart';

class DiscussionListArguments extends RouteArguments {
  final int groupId;
  final GroupPrivacy privacy;
  final String? groupName;

  const DiscussionListArguments({
    required this.groupId,
    required this.privacy,
    this.groupName,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'privacy': privacy == GroupPrivacy.private ? 'private' : 'public',
      'groupName': groupName,
    };
  }
}
