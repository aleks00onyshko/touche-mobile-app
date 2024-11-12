import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:touche_app/models/entities/teacher.dart';
import 'package:touche_app/models/entities/time-slot.dart';
import 'package:touche_app/widgets/authentication/widgets/state/authentication.model.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots/widgets/time-slot-modal/state/state.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots/widgets/time-slot-modal/state/time-slot-modal.model.dart';
import 'package:touche_app/widgets/time-slots/widgets/time-slots/widgets/time-slot-modal/state/time_slot_modal_data_provider.dart';
import 'package:tuple/tuple.dart';

import 'time_slot_modal_model_test.mocks.dart';

@GenerateMocks([
  TimeSlotModalDataProvider,
  AuthenticationModel,
  firebase_auth.User,
])
void main() {
  group('TimeSlotModalModel Tests', () {
    late MockTimeSlotModalDataProvider mockDataProvider;
    late MockAuthenticationModel mockAuthModel;
    late TimeSlotModalModel model;
    late StreamController<TimeSlot> timeSlotController;
    late TimeSlot timeSlot;
    late firebase_auth.User mockFirebaseUser;
    late List<Teacher> teachers;

    setUp(() {
      // Initialize mocks
      mockDataProvider = MockTimeSlotModalDataProvider();
      mockAuthModel = MockAuthenticationModel();
      mockFirebaseUser = MockUser();
      timeSlotController = StreamController<TimeSlot>();

      // Set up mock user
      when(mockFirebaseUser.uid).thenReturn('user123');
      when(mockFirebaseUser.displayName).thenReturn('Test User');
      when(mockFirebaseUser.email).thenReturn('testuser@mail.com');
      when(mockAuthModel.getCurrentLoggedInUser()).thenReturn(mockFirebaseUser);

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

      // Set up initial TimeSlot
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

      // Set up mocked responses
      when(mockDataProvider.getTeachersByIds(any)).thenAnswer((_) async => teachers);
      when(mockDataProvider.getTimeSlotDocumentStream$(any, any, any)).thenAnswer((_) => timeSlotController.stream);
    });

    tearDown(() {
      timeSlotController.close();
    });

    group('Initialization', () {
      test('State is patched correctly if the initial slot is booked', () async {
        final bookedTimeSlot = TimeSlot(
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
          timeSlot: bookedTimeSlot,
          authenticationModel: mockAuthModel,
        );

        // Just wait for initial data loading
        await Future.delayed(Duration.zero);

        expect(model.state[TimeSlotModalStateKeys.booked.name], true);
        expect(model.state[TimeSlotModalStateKeys.attendeeId.name], 'user123');
      });

      test('State is patched correctly if the initial slot is unbooked', () async {
        final unbookedTimeSlot = TimeSlot(
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
          timeSlot: unbookedTimeSlot,
          authenticationModel: mockAuthModel,
        );

        await Future.delayed(Duration.zero);

        expect(model.state[TimeSlotModalStateKeys.booked.name], false);
        expect(model.state[TimeSlotModalStateKeys.attendeeId.name], '');
        expect(model.state[TimeSlotModalStateKeys.bookButtonDisabled.name], false);
      });

      test('State handles initialization error correctly', () async {
        when(mockDataProvider.getTeachersByIds(any)).thenThrow(Exception('Error fetching teachers'));

        model = TimeSlotModalModel(
          TimeSlotModalState(),
          dataProvider: mockDataProvider,
          timeSlot: timeSlot,
          authenticationModel: mockAuthModel,
        );

        await Future.delayed(Duration.zero);

        expect(model.state[TimeSlotModalStateKeys.snackbarText.name], 'Error during initialization, try later please!');
      });

      test('Teachers are loaded and selected teacher is set correctly', () async {
        model = TimeSlotModalModel(
          TimeSlotModalState(),
          dataProvider: mockDataProvider,
          timeSlot: timeSlot,
          authenticationModel: mockAuthModel,
        );

        await Future.delayed(Duration.zero);

        expect(model.state[TimeSlotModalStateKeys.teachers.name], teachers);
        expect((model.state[TimeSlotModalStateKeys.selectedTeacher.name] as Teacher).id, 'teacher1');
        verify(mockDataProvider.getTeachersByIds(['teacher1', 'teacher2'])).called(1);
      });
    });

    group('Reactivity', () {
      group('Teachers Signal Effect', () {
        test('updates teachers when ids change', () async {
          model = TimeSlotModalModel(
            TimeSlotModalState(),
            dataProvider: mockDataProvider,
            timeSlot: timeSlot,
            authenticationModel: mockAuthModel,
          );

          // First verify initialization call
          verify(mockDataProvider.getTeachersByIds(['teacher1', 'teacher2'])).called(1);
          clearInteractions(mockDataProvider);

          // Set up new teachers
          final newTeachers = [
            Teacher(
              id: 'teacher3',
              displayName: 'Teacher Three',
              backgroundImageUrl: '',
              email: 'teacher3@mail.com',
              uid: 'teacher3',
              number: '',
              description: '',
            ),
            Teacher(
              id: 'teacher4',
              displayName: 'Teacher Four',
              backgroundImageUrl: '',
              email: 'teacher4@mail.com',
              uid: 'teacher4',
              number: '',
              description: '',
            ),
          ];

          when(mockDataProvider.getTeachersByIds(['teacher3', 'teacher4'])).thenAnswer((_) async => newTeachers);

          final updatedTimeSlot = TimeSlot(
            id: 'timeslot1',
            dateId: 'date1',
            locationId: 'location1',
            teachersIds: ['teacher3', 'teacher4'],
            selectedTeacherId: 'teacher3',
            attendeeId: null,
            booked: false,
            duration: 60,
            startTime: const Tuple2<int, int>(1, 2),
          );

          timeSlotController.add(timeSlot);
          await Future.delayed(Duration.zero);
          timeSlotController.add(updatedTimeSlot);
          await Future.delayed(Duration.zero);

          final stateTeachers = model.state[TimeSlotModalStateKeys.teachers.name] as List<Teacher>;
          expect(stateTeachers[0].id, 'teacher3');
          expect(stateTeachers[1].id, 'teacher4');

          // Verify only one new call with new teacher ids
          verify(mockDataProvider.getTeachersByIds(['teacher3', 'teacher4'])).called(1);
        });
      });

      group('Attendee Signal Effect', () {
        test('updates booking state when slot is booked by another user', () async {
          model = TimeSlotModalModel(
            TimeSlotModalState(),
            dataProvider: mockDataProvider,
            timeSlot: timeSlot,
            authenticationModel: mockAuthModel,
          );
          await Future.delayed(Duration.zero);

          final bookedTimeSlot = TimeSlot(
            id: 'timeslot1',
            dateId: 'date1',
            locationId: 'location1',
            teachersIds: ['teacher1', 'teacher2'],
            selectedTeacherId: 'teacher1',
            attendeeId: 'other_user', // Different user
            booked: true,
            duration: 60,
            startTime: const Tuple2<int, int>(1, 2),
          );

          // Skip first emission
          timeSlotController.add(timeSlot);
          await Future.delayed(Duration.zero);

          // Emit booked state
          timeSlotController.add(bookedTimeSlot);
          await Future.delayed(Duration.zero);

          expect(model.state[TimeSlotModalStateKeys.booked.name], true);
          expect(model.state[TimeSlotModalStateKeys.attendeeId.name], 'other_user');
          expect(model.state[TimeSlotModalStateKeys.bookButtonDisabled.name], true);
        });

        test('updates booking state when slot is booked by current user', () async {
          model = TimeSlotModalModel(
            TimeSlotModalState(),
            dataProvider: mockDataProvider,
            timeSlot: timeSlot,
            authenticationModel: mockAuthModel,
          );
          await Future.delayed(Duration.zero);

          final bookedTimeSlot = TimeSlot(
            id: 'timeslot1',
            dateId: 'date1',
            locationId: 'location1',
            teachersIds: ['teacher1', 'teacher2'],
            selectedTeacherId: 'teacher1',
            attendeeId: 'user123', // Current user
            booked: true,
            duration: 60,
            startTime: const Tuple2<int, int>(1, 2),
          );

          // Skip first emission
          timeSlotController.add(timeSlot);
          await Future.delayed(Duration.zero);

          // Emit booked state
          timeSlotController.add(bookedTimeSlot);
          await Future.delayed(Duration.zero);

          expect(model.state[TimeSlotModalStateKeys.booked.name], true);
          expect(model.state[TimeSlotModalStateKeys.attendeeId.name], 'user123');
          expect(model.state[TimeSlotModalStateKeys.bookButtonDisabled.name], false);
        });
      });
    });

    group('Booking/Unbooking Flow', () {
      test('successfully books a time slot', () async {
        model = TimeSlotModalModel(
          TimeSlotModalState(),
          dataProvider: mockDataProvider,
          timeSlot: timeSlot,
          authenticationModel: mockAuthModel,
        );
        await Future.delayed(Duration.zero); // Wait for initialization

        // Mock successful booking
        when(mockDataProvider.bookTimeSlot(any, any, any)).thenAnswer((_) async => Future<void>.value());

        await model.bookTimeSlot();

        // Verify state changes
        expect(model.state[TimeSlotModalStateKeys.booked.name], true);
        expect(model.state[TimeSlotModalStateKeys.attendeeId.name], 'user123');

        // Verify the correct booking call was made
        verify(mockDataProvider.bookTimeSlot(
          timeSlot,
          'user123',
          (model.state[TimeSlotModalStateKeys.selectedTeacher.name] as Teacher).id,
        )).called(1);
      });

      test('handles booking error correctly', () async {
        model = TimeSlotModalModel(
          TimeSlotModalState(),
          dataProvider: mockDataProvider,
          timeSlot: timeSlot,
          authenticationModel: mockAuthModel,
        );
        await Future.delayed(Duration.zero);

        // Mock booking failure
        when(mockDataProvider.bookTimeSlot(any, any, any)).thenThrow(Exception('Booking failed'));

        await model.bookTimeSlot();

        // Verify error state
        expect(model.state[TimeSlotModalStateKeys.booked.name], false);
        expect(
          model.state[TimeSlotModalStateKeys.snackbarText.name],
          'Error booking the time slot. Please try again.',
        );
      });

      test('successfully unbooks a time slot', () async {
        // Start with a booked time slot
        final bookedTimeSlot = TimeSlot(
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
          timeSlot: bookedTimeSlot,
          authenticationModel: mockAuthModel,
        );
        await Future.delayed(Duration.zero);

        // Mock successful unbooking
        when(mockDataProvider.unBookTimeSlot(any)).thenAnswer((_) async => Future<void>.value());

        await model.unBookTimeSlot();

        // Verify state changes
        expect(model.state[TimeSlotModalStateKeys.booked.name], false);
        expect(model.state[TimeSlotModalStateKeys.attendeeId.name], '');

        // Verify the correct unbooking call was made
        verify(mockDataProvider.unBookTimeSlot(bookedTimeSlot)).called(1);
      });

      test('handles unbooking error correctly', () async {
        // Start with a booked time slot
        final bookedTimeSlot = TimeSlot(
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
          timeSlot: bookedTimeSlot,
          authenticationModel: mockAuthModel,
        );
        await Future.delayed(Duration.zero);

        // Mock unbooking failure
        when(mockDataProvider.unBookTimeSlot(any)).thenThrow(Exception('Unbooking failed'));

        await model.unBookTimeSlot();

        // Verify error state
        expect(model.state[TimeSlotModalStateKeys.booked.name], true);
        expect(
          model.state[TimeSlotModalStateKeys.snackbarText.name],
          'Error unbooking the time slot. Please try again.',
        );
      });
    });

    group('Teacher Selection', () {
      test('successfully changes selected teacher', () async {
        model = TimeSlotModalModel(
          TimeSlotModalState(),
          dataProvider: mockDataProvider,
          timeSlot: timeSlot,
          authenticationModel: mockAuthModel,
        );
        await Future.delayed(Duration.zero); // Wait for initialization

        // Grab the second teacher to switch to
        final newSelectedTeacher = teachers[1]; // teacher2

        model.changeSelectedTeacher(newSelectedTeacher);

        // Verify selected teacher was updated
        final stateSelectedTeacher = model.state[TimeSlotModalStateKeys.selectedTeacher.name] as Teacher;
        expect(stateSelectedTeacher.id, newSelectedTeacher.id);
        expect(stateSelectedTeacher.displayName, newSelectedTeacher.displayName);
      });

      test('changing selected teacher maintains other state', () async {
        // Initialize with a booked time slot
        final bookedTimeSlot = TimeSlot(
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
          timeSlot: bookedTimeSlot,
          authenticationModel: mockAuthModel,
        );
        await Future.delayed(Duration.zero);

        // Store initial state values we want to verify don't change
        final initialBooked = model.state[TimeSlotModalStateKeys.booked.name];
        final initialAttendeeId = model.state[TimeSlotModalStateKeys.attendeeId.name];
        final initialDuration = model.state[TimeSlotModalStateKeys.duration.name];

        // Change selected teacher
        final newSelectedTeacher = teachers[1];
        model.changeSelectedTeacher(newSelectedTeacher);

        // Verify other state remained unchanged
        expect(model.state[TimeSlotModalStateKeys.booked.name], initialBooked);
        expect(model.state[TimeSlotModalStateKeys.attendeeId.name], initialAttendeeId);
        expect(model.state[TimeSlotModalStateKeys.duration.name], initialDuration);
      });
    });

    group('Snackbar Handling', () {
      test('closeSnackbar clears snackbar text', () async {
        model = TimeSlotModalModel(
          TimeSlotModalState(),
          dataProvider: mockDataProvider,
          timeSlot: timeSlot,
          authenticationModel: mockAuthModel,
        );
        await Future.delayed(Duration.zero);

        // First set some error to show snackbar
        when(mockDataProvider.bookTimeSlot(any, any, any)).thenThrow(Exception('Booking failed'));

        await model.bookTimeSlot();
        expect(model.state[TimeSlotModalStateKeys.snackbarText.name], 'Error booking the time slot. Please try again.');

        // Now clear the snackbar
        model.closeSnackbar();
        expect(model.state[TimeSlotModalStateKeys.snackbarText.name], '');
      });
    });

    group('Cleanup/Disposal', () {
      test('dispose cancels stream subscription and effects', () async {
        model = TimeSlotModalModel(
          TimeSlotModalState(),
          dataProvider: mockDataProvider,
          timeSlot: timeSlot,
          authenticationModel: mockAuthModel,
        );
        await Future.delayed(Duration.zero);

        // Store initial state
        final initialTeachers = model.state[TimeSlotModalStateKeys.teachers.name] as List<Teacher>;

        // Dispose the model
        model.dispose();

        // Try to emit new data after disposal
        final updatedTimeSlot = TimeSlot(
          id: 'timeslot1',
          dateId: 'date1',
          locationId: 'location1',
          teachersIds: ['teacher3'],
          selectedTeacherId: 'teacher3',
          attendeeId: null,
          booked: false,
          duration: 60,
          startTime: const Tuple2<int, int>(1, 2),
        );

        timeSlotController.add(updatedTimeSlot);
        await Future.delayed(Duration.zero);

        // Verify state hasn't changed after disposal
        expect(model.state[TimeSlotModalStateKeys.teachers.name], initialTeachers);
      });
    });

    group('Edge Cases', () {
      test('handles null attendeeId correctly', () async {
        final nullAttendeeSlot = TimeSlot(
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

        model = TimeSlotModalModel(
          TimeSlotModalState(),
          dataProvider: mockDataProvider,
          timeSlot: nullAttendeeSlot,
          authenticationModel: mockAuthModel,
        );
        await Future.delayed(Duration.zero);

        expect(model.state[TimeSlotModalStateKeys.attendeeId.name], '');
        expect(model.state[TimeSlotModalStateKeys.booked.name], false);
        expect(model.state[TimeSlotModalStateKeys.bookButtonDisabled.name], false);
      });

      test('handles empty teachers list', () async {
        final emptyTeachersSlot = TimeSlot(
          id: 'timeslot1',
          dateId: 'date1',
          locationId: 'location1',
          teachersIds: [], // Empty list
          selectedTeacherId: '',
          attendeeId: null,
          booked: false,
          duration: 60,
          startTime: const Tuple2<int, int>(1, 2),
        );

        when(mockDataProvider.getTeachersByIds([])).thenAnswer((_) async => []);

        model = TimeSlotModalModel(
          TimeSlotModalState(),
          dataProvider: mockDataProvider,
          timeSlot: emptyTeachersSlot,
          authenticationModel: mockAuthModel,
        );
        await Future.delayed(Duration.zero);

        expect(model.state[TimeSlotModalStateKeys.teachers.name], isEmpty);
      });

      test('falls back to first teacher when selected teacher is not in list', () async {
        final invalidSelectedTeacherSlot = TimeSlot(
          id: 'timeslot1',
          dateId: 'date1',
          locationId: 'location1',
          teachersIds: ['teacher1', 'teacher2'],
          selectedTeacherId: 'non_existent_teacher',
          attendeeId: null,
          booked: false,
          duration: 60,
          startTime: const Tuple2<int, int>(1, 2),
        );

        model = TimeSlotModalModel(
          TimeSlotModalState(),
          dataProvider: mockDataProvider,
          timeSlot: invalidSelectedTeacherSlot,
          authenticationModel: mockAuthModel,
        );
        await Future.delayed(Duration.zero);

        final selectedTeacher = model.state[TimeSlotModalStateKeys.selectedTeacher.name] as Teacher;
        expect(selectedTeacher.id, 'teacher1'); // Falls back to first teacher
      });
    });
  });
}
