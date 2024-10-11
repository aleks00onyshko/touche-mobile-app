import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:touche_app/models/entities/location.dart';
import 'package:touche_app/models/entities/teacher.dart';
import 'package:touche_app/models/entities/time-slot.dart';

class TimeSlotsDataProvider {
  final FirebaseFirestore firebaseApp;

  TimeSlotsDataProvider({required this.firebaseApp});

  Stream<List<TimeSlot>> getTimeSlotsCollectionStream$(String selectedDateId, Location selectedLocation, String loggedInUserID) {
    final CollectionReference<TimeSlot> timeSlotsRef = firebaseApp
        .collection('dateIds/$selectedDateId/${selectedLocation.id}-slots')
        .withConverter<TimeSlot>(
            fromFirestore: (snapshot, _) => TimeSlot.fromJson(snapshot.data()!), toFirestore: (timeSlot, _) => timeSlot.toJson());

    final Query<TimeSlot> query = timeSlotsRef.where(
      'attendeeId',
      whereIn: ['', loggedInUserID],
    );

    return query.snapshots().map((snapshot) => snapshot.docs.map((docSnapshot) => docSnapshot.data()).toList());
  }

  Future<List<Location>> getLocations() async {
    final CollectionReference<Location> locationsRef = firebaseApp.collection('locations').withConverter<Location>(
        fromFirestore: (snapshot, _) => Location.fromJson(snapshot.data()!), toFirestore: (location, _) => location.toJson());
    final QuerySnapshot<Location> querySnapshot = await locationsRef.get();

    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Teacher>> getTeachers() async {
    final CollectionReference<Teacher> teachersRef = firebaseApp.collection('teachers').withConverter<Teacher>(
        fromFirestore: (snapshot, _) => Teacher.fromJson(snapshot.data()!), toFirestore: (teacher, _) => teacher.toJson());
    final QuerySnapshot<Teacher> querySnapshot = await teachersRef.get();

    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }
}
