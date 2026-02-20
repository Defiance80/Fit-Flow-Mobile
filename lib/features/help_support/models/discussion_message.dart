class DiscussionMessage {
  final String id;
  final String topicId;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final String content;
  final DateTime createdAt;
  final List<DiscussionMessage>? replies;
  final int likeCount;
  final bool isLiked;

  DiscussionMessage({
    required this.id,
    required this.topicId,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.content,
    required this.createdAt,
    this.replies,
    this.likeCount = 0,
    this.isLiked = false,
  });

  factory DiscussionMessage.fromJson(Map<String, dynamic> json) {
    return DiscussionMessage(
      id: json['id'],
      topicId: json['topicId'],
      userId: json['userId'],
      userName: json['userName'],
      userAvatarUrl: json['userAvatarUrl'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      replies: json['replies'] != null
          ? (json['replies'] as List)
              .map((e) => DiscussionMessage.fromJson(e))
              .toList()
          : null,
      likeCount: json['likeCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topicId': topicId,
      'userId': userId,
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'replies': replies?.map((e) => e.toJson()).toList(),
      'likeCount': likeCount,
      'isLiked': isLiked,
    };
  }
}
