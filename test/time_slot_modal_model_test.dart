// test/time_slot_modal_model_test.dart

// Import Firebase Auth with an alias to avoid conflicts
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
// Import your model and dependencies
import 'package:touche_app/models/entities/teacher.dart';
import 'package:touche_app/models/entities/time-slot.dart';
import 'package:touche_app/widgets/authentication/widgets/state/authentication.model.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots/widgets/time-slot-modal/state/state.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots/widgets/time-slot-modal/state/time-slot-modal.model.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots/widgets/time-slot-modal/state/time_slot_modal_data_provider.dart';
import 'package:tuple/tuple.dart';

// Import the generated mocks
import 'time_slot_modal_model_test.mocks.dart';

// Generate mocks for the classes and Firebase User
@GenerateMocks([
  TimeSlotModalDataProvider,
  AuthenticationModel,
  firebase_auth.User,
])
void main() {
  group('TimeSlotModalModel Initialization Test', () {
    late MockTimeSlotModalDataProvider mockDataProvider;
    late MockAuthenticationModel mockAuthModel;
    late TimeSlotModalModel model;
    late TimeSlot timeSlot;
    late firebase_auth.User mockFirebaseUser;
    late List<Teacher> teachers;

    setUp(() {
      // Initialize mocks
      mockDataProvider = MockTimeSlotModalDataProvider();
      mockAuthModel = MockAuthenticationModel();
      mockFirebaseUser = MockUser(); // Mocked Firebase User

      // Set up a mock current user
      when(mockFirebaseUser.uid).thenReturn('user123');
      when(mockFirebaseUser.displayName).thenReturn('Test User');
      when(mockFirebaseUser.email).thenReturn('testuser@mail.com');

      // Mock the authentication model to return the current user
      when(mockAuthModel.getCurrentLoggedInUser()).thenReturn(mockFirebaseUser);

      // Set up a TimeSlot object
      timeSlot = TimeSlot(
        id: 'timeslot1',
        dateId: 'date1',
        locationId: 'location1',
        teachersIds: ['teacher1', 'teacher2'],
        selectedTeacherId: 'teacher1',
        attendeeId: null,
        booked: false,
        duration: 60,
        startTime: const Tuple2<int, int>(1, 2),
      );

      // Set up mock teachers
      teachers = [
        Teacher(
          id: 'teacher1',
          displayName: 'Teacher One',
          backgroundImageUrl: '',
          email: 'teacher1@mail.com',
          uid: 'teacher1',
          number: '',
          description: '',
        ),
        Teacher(
          id: 'teacher2',
          displayName: 'Teacher Two',
          backgroundImageUrl: '',
          email: 'teacher2@mail.com',
          uid: 'teacher2',
          number: '',
          description: '',
        ),
      ];

      // Mock the dataProvider methods
      when(mockDataProvider.getTeachersByIds(any)).thenAnswer((_) async => teachers);
      when(mockDataProvider.getTimeSlotDocumentStream$(any, any, any)).thenAnswer((_) => Stream<TimeSlot>.value(timeSlot));

      // Initial state
      TimeSlotModalState initialState = TimeSlotModalState();

      // Initialize the model
      model = TimeSlotModalModel(
        initialState,
        dataProvider: mockDataProvider,
        timeSlot: timeSlot,
        authenticationModel: mockAuthModel,
      );
    });

    group('Initialization', () {
      test('State is patched correctly if the initial slot is booked', () async {
        timeSlot = TimeSlot(
          id: 'timeslot1',
          dateId: 'date1',
          locationId: 'location1',
          teachersIds: ['teacher1', 'teacher2'],
          selectedTeacherId: 'teacher1',
          attendeeId: 'user123',
          booked: true,
          duration: 60,
          startTime: const Tuple2<int, int>(1, 2),
        );

        model = TimeSlotModalModel(
          TimeSlotModalState(),
          dataProvider: mockDataProvider,
          timeSlot: timeSlot,
          authenticationModel: mockAuthModel,
        );

        await Future.delayed(Duration.zero);

        expect(model.state[TimeSlotModalStateKeys.booked.name], true);
        expect(model.state[TimeSlotModalStateKeys.attendeeId.name], 'user123');
      });

      test('State is patched correctly if the initial slot is unbooked', () async {
        timeSlot = TimeSlot(
          id: 'timeslot1',
          dateId: 'date1',
          locationId: 'location1',
          teachersIds: ['teacher1', 'teacher2'],
          selectedTeacherId: 'teacher1',
          attendeeId: '',
          booked: false,
          duration: 60,
          startTime: const Tuple2<int, int>(1, 2),
        );

        model = TimeSlotModalModel(
          TimeSlotModalState(),
          dataProvider: mockDataProvider,
          timeSlot: timeSlot,
          authenticationModel: mockAuthModel,
        );

        await Future.delayed(Duration.zero);

        expect(model.state[TimeSlotModalStateKeys.booked.name], false);
        expect(model.state[TimeSlotModalStateKeys.attendeeId.name], '');
      });

      test('Snackbar is shown on initialization error', () async {
        when(mockDataProvider.getTeachersByIds(any)).thenThrow(Exception('Error fetching teachers'));

        timeSlot = TimeSlot(
          id: 'timeslot1',
          dateId: 'date1',
          locationId: 'location1',
          teachersIds: ['teacher1', 'teacher2'],
          selectedTeacherId: 'teacher1',
          attendeeId: 'user123', // Mark as booked
          booked: true,
          duration: 60,
          startTime: const Tuple2<int, int>(1, 2),
        );

        model = TimeSlotModalModel(
          TimeSlotModalState(),
          dataProvider: mockDataProvider,
          timeSlot: timeSlot,
          authenticationModel: mockAuthModel,
        );

        await Future.delayed(Duration.zero);

        expect(model.state[TimeSlotModalStateKeys.snackbarText.name], 'Error during initialization, try later please!');
      });
    });

    group('Booking flow', () {
      test('Slot is booked successfully', () async {
        when(mockDataProvider.bookTimeSlot(any, any, any)).thenAnswer((_) async => Future.value());

        await model.bookTimeSlot();

        expect(model.state[TimeSlotModalStateKeys.booked.name], true);
        expect(model.state[TimeSlotModalStateKeys.attendeeId.name], mockFirebaseUser.uid);

        verify(mockDataProvider.bookTimeSlot(any, any, any)).called(1); // works fine
      });

      test('Error during booking triggers snackbar', () async {
        when(mockDataProvider.bookTimeSlot(any, any, any)).thenThrow(Exception('Booking error'));

        await model.bookTimeSlot();

        expect(model.state[TimeSlotModalStateKeys.booked.name], false);
        expect(model.state[TimeSlotModalStateKeys.snackbarText.name], 'Error booking the time slot. Please try again.');
      });
    });

    group('Unbooking flow', () {
      test('Slot is unbooked successfully', () async {
        when(mockDataProvider.bookTimeSlot(any, any, any)).thenAnswer((_) async => Future.value());

        await model.unBookTimeSlot();

        expect(model.state[TimeSlotModalStateKeys.booked.name], false);
        expect(model.state[TimeSlotModalStateKeys.attendeeId.name], '');

        verify(mockDataProvider.unBookTimeSlot(timeSlot)).called(1);
      });

      test('Error during unbooking triggers snackbar', () async {
        when(mockDataProvider.unBookTimeSlot(any)).thenThrow(Exception('Unbooking error'));

        await model.unBookTimeSlot();

        expect(model.state[TimeSlotModalStateKeys.booked.name], true);
        expect(model.state[TimeSlotModalStateKeys.snackbarText.name], 'Error unbooking the time slot. Please try again.');
      });
    });
  });
}
