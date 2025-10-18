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

    // Simple tests that don't require database initialization
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
