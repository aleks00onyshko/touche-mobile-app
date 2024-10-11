import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:touche_app/models/entities/location.dart';
import 'package:touche_app/models/entities/teacher.dart';
import 'package:touche_app/models/entities/time-slot.dart';

class TimeSlotModalDataProvider {
  final FirebaseFirestore firebaseApp;

  TimeSlotModalDataProvider({required this.firebaseApp});
  // TODO: think about error handling
  Stream<TimeSlot> getTimeSlotDocumentStream$(String timeSlotId, String dateId, String locationId) {
    final DocumentReference<TimeSlot> timeSlotRef = firebaseApp
        .collection('dateIds/$dateId/$locationId-slots')
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

  Future<void> setTimeSlotBookedState(
      {required bool booked,
      required String attendeeId,
      required String timeSlotId,
      required String dateId,
      required String locationId}) async {
    return firebaseApp.doc('dateIds/$dateId/$locationId-slots/$timeSlotId').update({'booked': booked, 'attendeeId': attendeeId});
  }
}
