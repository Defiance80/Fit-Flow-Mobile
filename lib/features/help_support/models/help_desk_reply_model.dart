import 'package:elms/common/models/blueprints.dart';

class ReplyAuthor {
  final int id;
  final String name;
  final String? avatar;

  ReplyAuthor({required this.id, required this.name, this.avatar});

  factory ReplyAuthor.fromJson(Map<String, dynamic> json) {
    return ReplyAuthor(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'avatar': avatar};
  }
}

class HelpDeskReplyModel extends Model {
  final int id;
  final String reply;
  final DateTime createdAt;
  final String timeAgo;
  final ReplyAuthor author;
  final List<HelpDeskReplyModel> children;

  HelpDeskReplyModel({
    required this.id,
    required this.reply,
    required this.createdAt,
    required this.timeAgo,
    required this.author,
    this.children = const [],
  });

  factory HelpDeskReplyModel.fromJson(Map<String, dynamic> json) {
    return HelpDeskReplyModel(
      id: json['id'] ?? 0,
      reply: json['reply'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      timeAgo: json['time_ago'] ?? '',
      author: ReplyAuthor.fromJson(json['author'] ?? {}),
      children: (json['children'] as List<dynamic>?)
              ?.map((child) =>
                  HelpDeskReplyModel.fromJson(child as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reply': reply,
      'created_at': createdAt.toIso8601String(),
      'time_ago': timeAgo,
      'author': author.toJson(),
      'children': children.map((child) => child.toJson()).toList(),
    };
  }
}
