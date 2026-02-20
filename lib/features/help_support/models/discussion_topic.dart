import 'package:elms/features/help_support/models/discussion_message.dart';

enum GroupPrivacy { public, private }

class DiscussionTopic {
  final String id;
  final String title;
  final String description;
  final String? iconUrl;
  final String groupId;
  final GroupPrivacy privacy;
  final DateTime createdAt;
  final int messageCount;
  final List<DiscussionMessage>? messages;
  final bool isPinned;
  final int viewCount;

  DiscussionTopic({
    required this.id,
    required this.title,
    required this.description,
    this.iconUrl,
    required this.groupId,
    this.privacy = GroupPrivacy.public,
    required this.createdAt,
    this.messageCount = 0,
    this.messages,
    this.isPinned = false,
    this.viewCount = 0,
  });

  factory DiscussionTopic.fromJson(Map<String, dynamic> json) {
    return DiscussionTopic(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      iconUrl: json['iconUrl'],
      groupId: json['groupId'],
      privacy: json['privacy'] == 'private'
          ? GroupPrivacy.private
          : GroupPrivacy.public,
      createdAt: DateTime.parse(json['createdAt']),
      messageCount: json['messageCount'] ?? 0,
      messages: json['messages'] != null
          ? (json['messages'] as List)
                .map((e) => DiscussionMessage.fromJson(e))
                .toList()
          : null,
      isPinned: json['isPinned'] ?? false,
      viewCount: json['viewCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconUrl': iconUrl,
      'groupId': groupId,
      'privacy': privacy == GroupPrivacy.private ? 'private' : 'public',
      'createdAt': createdAt.toIso8601String(),
      'messageCount': messageCount,
      'messages': messages?.map((e) => e.toJson()).toList(),
      'isPinned': isPinned,
      'viewCount': viewCount,
    };
  }
}
