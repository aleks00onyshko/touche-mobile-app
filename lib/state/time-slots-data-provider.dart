import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:touche_app/models/entities/location.dart';
import 'package:touche_app/models/entities/teacher.dart';
import 'package:touche_app/models/entities/time-slot.dart';

class TimeSlotDataProvider {
  final FirebaseFirestore firebaseApp;

  TimeSlotDataProvider({required this.firebaseApp});

  Stream<List<TimeSlot>> getTimeSlotsCollectionStream$(String selectedDateId, Location selectedLocation) {
    final CollectionReference<TimeSlot> timeSlotsRef = FirebaseFirestore.instance
        .collection('dateIds/$selectedDateId/${selectedLocation.id}-slots')
        .withConverter<TimeSlot>(
            fromFirestore: (snapshot, _) => TimeSlot.fromJson(snapshot.data()!), toFirestore: (timeSlot, _) => timeSlot.toJson());

    return timeSlotsRef.snapshots().map((snapshot) => snapshot.docs.map((docSnapshot) => docSnapshot.data()).toList());
  }

  Future<List<Location>> getLocations() async {
    final CollectionReference<Location> locationsRef = FirebaseFirestore.instance.collection('locations').withConverter<Location>(
        fromFirestore: (snapshot, _) => Location.fromJson(snapshot.data()!), toFirestore: (location, _) => location.toJson());
    final QuerySnapshot<Location> querySnapshot = await locationsRef.get();

    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Teacher>> getTeachers() async {
    final CollectionReference<Teacher> teachersRef = FirebaseFirestore.instance.collection('teachers').withConverter<Teacher>(
        fromFirestore: (snapshot, _) => Teacher.fromJson(snapshot.data()!), toFirestore: (teacher, _) => teacher.toJson());
    final QuerySnapshot<Teacher> querySnapshot = await teachersRef.get();

    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }
}
