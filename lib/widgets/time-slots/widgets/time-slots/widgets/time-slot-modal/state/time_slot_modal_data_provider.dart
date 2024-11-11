import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:touche_app/models/entities/location.dart';
import 'package:touche_app/models/entities/teacher.dart';
import 'package:touche_app/models/entities/time-slot.dart';

class TimeSlotModalDataProvider {
  final FirebaseFirestore firebaseApp;

  TimeSlotModalDataProvider({required this.firebaseApp});

  Stream<TimeSlot> getTimeSlotDocumentStream$(String timeSlotId, String dateId, String locationId) {
    final DocumentReference<TimeSlot> timeSlotRef = firebaseApp
        .collection('dateIds/$dateId/timeSlots')
        .doc(timeSlotId)
        .withConverter<TimeSlot>(
            fromFirestore: (snapshot, _) => TimeSlot.fromJson(snapshot.data()!), toFirestore: (timeSlot, _) => timeSlot.toJson());

    return timeSlotRef.snapshots().map((snapshot) => snapshot.data()!);
  }

  Future<List<Location>> getLocations() async {
    final CollectionReference<Location> locationsRef = firebaseApp.collection('locations').withConverter<Location>(
        fromFirestore: (snapshot, _) => Location.fromJson(snapshot.data()!), toFirestore: (location, _) => location.toJson());
    final QuerySnapshot<Location> querySnapshot = await locationsRef.get();

    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Teacher>> getTeachersByIds(List<String> teacherIds) async {
    final Query<Teacher> teachersQuery = firebaseApp
        .collection('teachers')
        .where('id', whereIn: teacherIds)
        .withConverter<Teacher>(
            fromFirestore: (snapshot, _) => Teacher.fromJson(snapshot.data()!), toFirestore: (teacher, _) => teacher.toJson());
    final QuerySnapshot<Teacher> querySnapshot = await teachersQuery.get();

    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> bookTimeSlot(TimeSlot timeSlot, String attendeeId, String selectedTeacherId) async {
    try {
      await firebaseApp
          .doc('dateIds/${timeSlot.dateId}/timeSlots/${timeSlot.id}')
          .update({'booked': true, 'attendeeId': attendeeId, 'selectedTeacherId': selectedTeacherId});
    } catch (e) {
      throw Exception('Failed to book time slot');
    }
  }

  Future<void> unBookTimeSlot(TimeSlot timeSlot) async {
    try {
      await firebaseApp
          .doc('dateIds/${timeSlot.dateId}/timeSlots/${timeSlot.id}')
          .update({'booked': false, 'attendeeId': '', 'selectedTeacherId': ''});
    } catch (e) {
      throw Exception('Failed to unbook time slot');
    }
  }
}
