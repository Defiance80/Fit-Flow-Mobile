class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String message;
  final String notificationType;
  final int typeId;
  final String? typeLink;
  final String? slug;
  final String? image;
  final DateTime dateSent;
  final String dateSentFormatted;
  final String timeAgo;
  final bool isRead;
  final String? readAt;
  final InstructorDetailsModel? instructorDetails;
  final TeamMemberModel? teamMembers;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.notificationType,
    required this.typeId,
    this.typeLink,
    this.slug,
    this.image,
    required this.dateSent,
    required this.dateSentFormatted,
    required this.timeAgo,
    required this.isRead,
    this.readAt,
    this.instructorDetails,
    this.teamMembers,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'].toString(),
      type: json['type'],
      title: json['title'],
      message: json['message'],
      notificationType: json['notification_type'],
      typeId: json['type_id'] ?? 0,
      typeLink: json['type_link'],
      slug: json['slug'],
      image: json['image'],
      dateSent: DateTime.parse(json['date_sent']),
      dateSentFormatted: json['date_sent_formatted'],
      timeAgo: json['time_ago'],
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'],
      instructorDetails: json['instructor_details'] != null
          ? InstructorDetailsModel.fromJson(json['instructor_details'])
          : null,
      teamMembers: json['team_members'] != null && json['team_members'] is! List
          ? TeamMemberModel.fromJson(json['team_members'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'notification_type': notificationType,
      'type_id': typeId,
      'type_link': typeLink,
      'slug': slug,
      'image': image,
      'date_sent': dateSent.toIso8601String(),
      'date_sent_formatted': dateSentFormatted,
      'time_ago': timeAgo,
      'is_read': isRead,
      'read_at': readAt,
      'instructor_details': instructorDetails?.toJson(),
      'team_members': teamMembers?.toJson(),
    };
  }
}

class InstructorDetailsModel {
  final int id;
  final int userId;
  final String name;
  final String slug;
  final String profile;

  InstructorDetailsModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.slug,
    required this.profile,
  });

  factory InstructorDetailsModel.fromJson(Map<String, dynamic> json) {
    return InstructorDetailsModel(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      slug: json['slug'],
      profile: json['profile'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'slug': slug,
      'profile': profile,
    };
  }
}

class TeamMemberModel {
  final int id;
  final int instructorId;
  final int userId;
  final String status;
  final String? invitationToken;
  final String createdAt;
  final String updatedAt;

  TeamMemberModel({
    required this.id,
    required this.instructorId,
    required this.userId,
    required this.status,
    required this.invitationToken,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) {
    return TeamMemberModel(
      id: json['id'],
      instructorId: json['instructor_id'],
      userId: json['user_id'],
      status: json['status'],
      invitationToken: json['invitation_token'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'instructor_id': instructorId,
      'user_id': userId,
      'status': status,
      'invitation_token': invitationToken,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
