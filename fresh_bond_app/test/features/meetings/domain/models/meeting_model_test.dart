import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_bond_app/features/meetings/domain/models/meeting_model.dart';

void main() {
  final now = DateTime.now();
  
  final testMeeting = MeetingModel(
    id: 'meeting123',
    title: 'Coffee Chat',
    description: 'Networking over coffee',
    location: 'Downtown Cafe',
    scheduledTime: now.add(const Duration(days: 3)),
    durationMinutes: 60,
    creatorId: 'user1',
    inviteeId: 'user2',
    status: MeetingStatus.pending,
    createdAt: now.subtract(const Duration(days: 1)),
    updatedAt: now.subtract(const Duration(days: 1)),
    notes: 'Bring resume',
    topics: ['Career', 'Networking'],
  );

  group('MeetingModel', () {
    test('copyWith creates a new instance with updated values', () {
      final updatedTime = now.add(const Duration(days: 5));
      final updatedMeeting = testMeeting.copyWith(
        title: 'Updated Title',
        description: 'Updated Description',
        scheduledTime: updatedTime,
        durationMinutes: 90,
        status: MeetingStatus.confirmed,
        notes: 'Updated notes',
      );
      
      // Verify updated fields
      expect(updatedMeeting.title, equals('Updated Title'));
      expect(updatedMeeting.description, equals('Updated Description'));
      expect(updatedMeeting.scheduledTime, equals(updatedTime));
      expect(updatedMeeting.durationMinutes, equals(90));
      expect(updatedMeeting.status, equals(MeetingStatus.confirmed));
      expect(updatedMeeting.notes, equals('Updated notes'));
      
      // Verify unchanged fields
      expect(updatedMeeting.id, equals(testMeeting.id));
      expect(updatedMeeting.location, equals(testMeeting.location));
      expect(updatedMeeting.creatorId, equals(testMeeting.creatorId));
      expect(updatedMeeting.inviteeId, equals(testMeeting.inviteeId));
      expect(updatedMeeting.createdAt, equals(testMeeting.createdAt));
      expect(updatedMeeting.updatedAt, equals(testMeeting.updatedAt));
      expect(updatedMeeting.topics, equals(testMeeting.topics));
    });

    test('toJson converts model to JSON correctly', () {
      final json = testMeeting.toJson();
      
      expect(json['id'], equals('meeting123'));
      expect(json['title'], equals('Coffee Chat'));
      expect(json['description'], equals('Networking over coffee'));
      expect(json['location'], equals('Downtown Cafe'));
      expect(json['scheduledTime'], equals(testMeeting.scheduledTime.toIso8601String()));
      expect(json['durationMinutes'], equals(60));
      expect(json['creatorId'], equals('user1'));
      expect(json['inviteeId'], equals('user2'));
      expect(json['status'], equals('pending'));
      expect(json['createdAt'], equals(testMeeting.createdAt.toIso8601String()));
      expect(json['updatedAt'], equals(testMeeting.updatedAt.toIso8601String()));
      expect(json['notes'], equals('Bring resume'));
      expect(json['topics'], equals(['Career', 'Networking']));
    });

    test('fromJson converts JSON to model correctly', () {
      final json = {
        'id': 'meeting123',
        'title': 'Coffee Chat',
        'description': 'Networking over coffee',
        'location': 'Downtown Cafe',
        'scheduledTime': testMeeting.scheduledTime.toIso8601String(),
        'durationMinutes': 60,
        'creatorId': 'user1',
        'inviteeId': 'user2',
        'status': 'pending',
        'createdAt': testMeeting.createdAt.toIso8601String(),
        'updatedAt': testMeeting.updatedAt.toIso8601String(),
        'notes': 'Bring resume',
        'topics': ['Career', 'Networking'],
      };
      
      final meeting = MeetingModel.fromJson(json);
      
      expect(meeting.id, equals('meeting123'));
      expect(meeting.title, equals('Coffee Chat'));
      expect(meeting.description, equals('Networking over coffee'));
      expect(meeting.location, equals('Downtown Cafe'));
      expect(meeting.scheduledTime.toIso8601String(), equals(testMeeting.scheduledTime.toIso8601String()));
      expect(meeting.durationMinutes, equals(60));
      expect(meeting.creatorId, equals('user1'));
      expect(meeting.inviteeId, equals('user2'));
      expect(meeting.status, equals(MeetingStatus.pending));
      expect(meeting.createdAt.toIso8601String(), equals(testMeeting.createdAt.toIso8601String()));
      expect(meeting.updatedAt.toIso8601String(), equals(testMeeting.updatedAt.toIso8601String()));
      expect(meeting.notes, equals('Bring resume'));
      expect(meeting.topics, equals(['Career', 'Networking']));
    });
    
    test('fromJson handles null or missing optional fields', () {
      final json = {
        'id': 'meeting123',
        'title': 'Coffee Chat',
        'description': 'Networking over coffee',
        'location': 'Downtown Cafe',
        'scheduledTime': testMeeting.scheduledTime.toIso8601String(),
        'durationMinutes': 60,
        'creatorId': 'user1',
        'inviteeId': 'user2',
        'status': 'pending',
        'createdAt': testMeeting.createdAt.toIso8601String(),
        'updatedAt': testMeeting.updatedAt.toIso8601String(),
        // No notes or topics
      };
      
      final meeting = MeetingModel.fromJson(json);
      
      expect(meeting.notes, isNull);
      expect(meeting.topics, isEmpty);
    });
    
    test('fromJson handles different status values correctly', () {
      for (final status in MeetingStatus.values) {
        final json = {
          'id': 'meeting123',
          'title': 'Coffee Chat',
          'description': 'Networking over coffee',
          'location': 'Downtown Cafe',
          'scheduledTime': testMeeting.scheduledTime.toIso8601String(),
          'durationMinutes': 60,
          'creatorId': 'user1',
          'inviteeId': 'user2',
          'status': status.name,
          'createdAt': testMeeting.createdAt.toIso8601String(),
          'updatedAt': testMeeting.updatedAt.toIso8601String(),
        };
        
        final meeting = MeetingModel.fromJson(json);
        expect(meeting.status, equals(status));
      }
    });
    
    test('fromJson defaults to pending status for invalid status values', () {
      final json = {
        'id': 'meeting123',
        'title': 'Coffee Chat',
        'description': 'Networking over coffee',
        'location': 'Downtown Cafe',
        'scheduledTime': testMeeting.scheduledTime.toIso8601String(),
        'durationMinutes': 60,
        'creatorId': 'user1',
        'inviteeId': 'user2',
        'status': 'invalid_status',
        'createdAt': testMeeting.createdAt.toIso8601String(),
        'updatedAt': testMeeting.updatedAt.toIso8601String(),
      };
      
      final meeting = MeetingModel.fromJson(json);
      expect(meeting.status, equals(MeetingStatus.pending));
    });
    
    test('props returns correct list of properties for equality check', () {
      final props = testMeeting.props;
      
      expect(props.length, equals(13));
      expect(props, contains(testMeeting.id));
      expect(props, contains(testMeeting.title));
      expect(props, contains(testMeeting.description));
      expect(props, contains(testMeeting.location));
      expect(props, contains(testMeeting.scheduledTime));
      expect(props, contains(testMeeting.durationMinutes));
      expect(props, contains(testMeeting.creatorId));
      expect(props, contains(testMeeting.inviteeId));
      expect(props, contains(testMeeting.status));
      expect(props, contains(testMeeting.createdAt));
      expect(props, contains(testMeeting.updatedAt));
      expect(props, contains(testMeeting.notes));
      expect(props, contains(testMeeting.topics));
    });
    
    test('equality works correctly', () {
      final sameMeeting = MeetingModel(
        id: 'meeting123',
        title: 'Coffee Chat',
        description: 'Networking over coffee',
        location: 'Downtown Cafe',
        scheduledTime: testMeeting.scheduledTime,
        durationMinutes: 60,
        creatorId: 'user1',
        inviteeId: 'user2',
        status: MeetingStatus.pending,
        createdAt: testMeeting.createdAt,
        updatedAt: testMeeting.updatedAt,
        notes: 'Bring resume',
        topics: ['Career', 'Networking'],
      );
      
      expect(testMeeting, equals(sameMeeting));
      
      final differentMeeting = testMeeting.copyWith(id: 'different123');
      expect(testMeeting, isNot(equals(differentMeeting)));
    });
  });
}