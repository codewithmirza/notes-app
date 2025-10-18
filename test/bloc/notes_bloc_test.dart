import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:notes_app/bloc/notes_bloc.dart';
import 'package:notes_app/bloc/notes_event.dart';
import 'package:notes_app/bloc/notes_state.dart';
import 'package:notes_app/models/note.dart';

void main() {
  group('NotesBloc', () {
    late NotesBloc notesBloc;

    setUp(() {
      notesBloc = NotesBloc();
    });

    tearDown(() {
      notesBloc.close();
    });

    test('initial state is NotesInitial', () {
      expect(notesBloc.state, equals(const NotesInitial()));
    });

    blocTest<NotesBloc, NotesState>(
      'emits [NotesLoading, NotesLoadedSuccess] when NotesInitialized is added',
      build: () => notesBloc,
      act: (bloc) => bloc.add(const NotesInitialized()),
      expect: () => [
        isA<NotesLoading>(),
        isA<NotesLoadedSuccess>(),
      ],
    );

    blocTest<NotesBloc, NotesState>(
      'emits [NotesLoading, NotesLoadedSuccess] when NotesLoaded is added',
      build: () => notesBloc,
      seed: () => const NotesLoadedSuccess(
        notes: [],
        filteredNotes: [],
      ),
      act: (bloc) => bloc.add(const NotesLoaded()),
      expect: () => [
        isA<NotesLoading>(),
        isA<NotesLoadedSuccess>(),
      ],
    );

    blocTest<NotesBloc, NotesState>(
      'emits [NoteOperationInProgress, NotesLoadedSuccess] when NoteAdded is added',
      build: () => notesBloc,
      seed: () => const NotesLoadedSuccess(
        notes: [],
        filteredNotes: [],
      ),
      act: (bloc) => bloc.add(NoteAdded(Note(
        title: 'Test Note',
        content: 'Test Content',
      ))),
      expect: () => [
        isA<NoteOperationInProgress>(),
        isA<NotesLoadedSuccess>(),
      ],
    );

    blocTest<NotesBloc, NotesState>(
      'emits [NoteOperationInProgress, NotesLoadedSuccess] when NoteUpdated is added',
      build: () => notesBloc,
      seed: () => const NotesLoadedSuccess(
        notes: [],
        filteredNotes: [],
      ),
      act: (bloc) => bloc.add(NoteUpdated(Note(
        id: 'test-id',
        title: 'Updated Note',
        content: 'Updated Content',
      ))),
      expect: () => [
        isA<NoteOperationInProgress>(),
        isA<NotesLoadedSuccess>(),
      ],
    );

    blocTest<NotesBloc, NotesState>(
      'emits [NoteOperationInProgress, NotesLoadedSuccess] when NoteDeleted is added',
      build: () => notesBloc,
      seed: () => const NotesLoadedSuccess(
        notes: [],
        filteredNotes: [],
      ),
      act: (bloc) => bloc.add(const NoteDeleted('test-id')),
      expect: () => [
        isA<NoteOperationInProgress>(),
        isA<NotesLoadedSuccess>(),
      ],
    );

    blocTest<NotesBloc, NotesState>(
      'emits updated state when NotesSearched is added',
      build: () => notesBloc,
      seed: () => const NotesLoadedSuccess(
        notes: [],
        filteredNotes: [],
        searchQuery: '',
      ),
      act: (bloc) => bloc.add(const NotesSearched('test query')),
      expect: () => [
        isA<NotesLoadedSuccess>(),
      ],
    );

    blocTest<NotesBloc, NotesState>(
      'emits updated state when PinnedFilterToggled is added',
      build: () => notesBloc,
      seed: () => const NotesLoadedSuccess(
        notes: [],
        filteredNotes: [],
        showPinnedOnly: false,
      ),
      act: (bloc) => bloc.add(const PinnedFilterToggled()),
      expect: () => [
        isA<NotesLoadedSuccess>(),
      ],
    );

    blocTest<NotesBloc, NotesState>(
      'emits updated state when FiltersCleared is added',
      build: () => notesBloc,
      seed: () => const NotesLoadedSuccess(
        notes: [],
        filteredNotes: [],
        searchQuery: 'test',
        selectedTag: 'test-tag',
        showPinnedOnly: true,
      ),
      act: (bloc) => bloc.add(const FiltersCleared()),
      expect: () => [
        isA<NotesLoadedSuccess>(),
      ],
    );
  });
}
