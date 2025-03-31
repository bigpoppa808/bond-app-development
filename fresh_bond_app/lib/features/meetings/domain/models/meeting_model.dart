import 'package:equatable/equatable.dart';
import 'package:fresh_bond_app/features/auth/domain/models/user_model.dart';

/// Status of a meeting
enum MeetingStatus {
  /// Meeting is scheduled but not yet confirmed by all parties
  pending,
  
  /// Meeting is confirmed by all parties
  confirmed,
  
  /// Meeting is completed
  completed,
  
  /// Meeting was canceled
  canceled,
  
  /// Meeting was rescheduled
  rescheduled,
}

/// A model representing a meeting between two users
class MeetingModel extends Equatable {
  /// Unique identifier for the meeting
  final String id;
  
  /// Title of the meeting
  final String title;
  
  /// Description of the meeting
  final String description;
  
  /// Location of the meeting
  final String location;
  
  /// Scheduled date and time for the meeting
  final DateTime scheduledTime;
  
  /// Duration of the meeting in minutes
  final int durationMinutes;
  
  /// User who created the meeting
  final String creatorId;
  
  /// User invited to the meeting
  final String inviteeId;
  
  /// Status of the meeting
  final MeetingStatus status;
  
  /// When the meeting was created
  final DateTime createdAt;
  
  /// When the meeting was last updated
  final DateTime updatedAt;
  
  /// Additional notes for the meeting
  final String? notes;
  
  /// Any interests or topics associated with this meeting
  final List<String> topics;
  
  /// Constructor
  const MeetingModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.scheduledTime,
    required this.durationMinutes,
    required this.creatorId,
    required this.inviteeId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.topics = const [],
  });
  
  /// Create a copy of this meeting with specified attributes changed
  MeetingModel copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    DateTime? scheduledTime,
    int? durationMinutes,
    String? creatorId,
    String? inviteeId,
    MeetingStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    List<String>? topics,
  }) {
    return MeetingModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      creatorId: creatorId ?? this.creatorId,
      inviteeId: inviteeId ?? this.inviteeId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      topics: topics ?? this.topics,
    );
  }
  
  /// Create a meeting object from a JSON map
  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    return MeetingModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      durationMinutes: json['durationMinutes'] as int,
      creatorId: json['creatorId'] as String,
      inviteeId: json['inviteeId'] as String,
      status: MeetingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MeetingStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      notes: json['notes'] as String?,
      topics: (json['topics'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
  
  /// Convert this meeting object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'scheduledTime': scheduledTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'creatorId': creatorId,
      'inviteeId': inviteeId,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (notes != null) 'notes': notes,
      'topics': topics,
    };
  }
  
  @override
  List<Object?> get props => [
        id,
        title,
        description,
        location,
        scheduledTime,
        durationMinutes,
        creatorId,
        inviteeId,
        status,
        createdAt,
        updatedAt,
        notes,
        topics,
      ];
}