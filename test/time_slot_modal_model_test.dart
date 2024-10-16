// test/time_slot_modal_model_test.dart

// Import Firebase Auth with an alias to avoid conflicts
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

    test('Model is correctly initialized', () async {
      // Wait for any asynchronous initialization to complete
      await Future.delayed(Duration.zero);

      // Verify that getTeachersByIds was called with the correct teacher IDs
      verify(mockDataProvider.getTeachersByIds(timeSlot.teachersIds)).called(1);

      // Check the state of the model
      expect(model.state[TimeSlotModalStateKeys.loading.name], false);
      expect(model.state[TimeSlotModalStateKeys.teachers.name], teachers);
      expect(model.state[TimeSlotModalStateKeys.selectedTeacher.name], teachers.first);
      expect(model.state[TimeSlotModalStateKeys.bookButtonDisabled.name], false);
      expect(model.state[TimeSlotModalStateKeys.booked.name], timeSlot.booked);
      expect(model.state[TimeSlotModalStateKeys.duration.name], timeSlot.duration);
    });
  });
}
