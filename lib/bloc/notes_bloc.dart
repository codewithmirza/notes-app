import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/note.dart';
import '../services/notes_cache_service.dart';
import 'notes_event.dart';
import 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final NotesCacheService _cacheService = NotesCacheService();

  NotesBloc() : super(const NotesInitial()) {
    on<NotesInitialized>(_onNotesInitialized);
    on<NotesLoaded>(_onNotesLoaded);
    on<NoteAdded>(_onNoteAdded);
    on<NoteUpdated>(_onNoteUpdated);
    on<NoteDeleted>(_onNoteDeleted);
    on<NotesSearched>(_onNotesSearched);
    on<PinnedFilterToggled>(_onPinnedFilterToggled);
    on<TagFilterSelected>(_onTagFilterSelected);
    on<FiltersCleared>(_onFiltersCleared);
    on<NotePinnedToggled>(_onNotePinnedToggled);
  }

  Future<void> _onNotesInitialized(
    NotesInitialized event,
    Emitter<NotesState> emit,
  ) async {
    try {
      emit(const NotesLoading());
      await _cacheService.initialize();
      final notes = _cacheService.getNotes();
      final tags = _cacheService.getAvailableTags();
      emit(NotesLoadedSuccess(
        notes: notes,
        availableTags: tags,
        searchQuery: '',
        selectedTag: null,
        showPinnedOnly: false,
      ));
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> _onNotesLoaded(
    NotesLoaded event,
    Emitter<NotesState> emit,
  ) async {
    try {
      emit(const NotesLoading());
      final notes = _cacheService.getNotes();
      final tags = _cacheService.getAvailableTags();
      emit(NotesLoadedSuccess(
        notes: notes,
        availableTags: tags,
        searchQuery: '',
        selectedTag: null,
        showPinnedOnly: false,
      ));
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> _onNoteAdded(
    NoteAdded event,
    Emitter<NotesState> emit,
  ) async {
    try {
      emit(const NoteOperationInProgress());
      await _cacheService.addNote(event.note);
      final notes = _cacheService.getNotes();
      final tags = _cacheService.getAvailableTags();
      emit(NotesLoadedSuccess(
        notes: notes,
        availableTags: tags,
        searchQuery: '',
        selectedTag: null,
        showPinnedOnly: false,
      ));
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> _onNoteUpdated(
    NoteUpdated event,
    Emitter<NotesState> emit,
  ) async {
    try {
      emit(const NoteOperationInProgress());
      await _cacheService.updateNote(event.note);
      final notes = _cacheService.getNotes();
      final tags = _cacheService.getAvailableTags();
      emit(NotesLoadedSuccess(
        notes: notes,
        availableTags: tags,
        searchQuery: '',
        selectedTag: null,
        showPinnedOnly: false,
      ));
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> _onNoteDeleted(
    NoteDeleted event,
    Emitter<NotesState> emit,
  ) async {
    try {
      emit(const NoteOperationInProgress());
      await _cacheService.deleteNote(event.noteId);
      final notes = _cacheService.getNotes();
      final tags = _cacheService.getAvailableTags();
      emit(NotesLoadedSuccess(
        notes: notes,
        availableTags: tags,
        searchQuery: '',
        selectedTag: null,
        showPinnedOnly: false,
      ));
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> _onNotesSearched(
    NotesSearched event,
    Emitter<NotesState> emit,
  ) async {
    try {
      final notes = _cacheService.getFilteredNotes(
        searchQuery: event.query,
        selectedTag: event.selectedTag,
        showPinnedOnly: event.showPinnedOnly,
      );
      final tags = _cacheService.getAvailableTags();
      emit(NotesLoadedSuccess(
        notes: notes,
        availableTags: tags,
        searchQuery: event.query,
        selectedTag: event.selectedTag,
        showPinnedOnly: event.showPinnedOnly,
      ));
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> _onPinnedFilterToggled(
    PinnedFilterToggled event,
    Emitter<NotesState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is NotesLoadedSuccess) {
        final notes = _cacheService.getFilteredNotes(
          searchQuery: currentState.searchQuery,
          selectedTag: currentState.selectedTag,
          showPinnedOnly: !currentState.showPinnedOnly,
        );
        emit(NotesLoadedSuccess(
          notes: notes,
          availableTags: currentState.availableTags,
          searchQuery: currentState.searchQuery,
          selectedTag: currentState.selectedTag,
          showPinnedOnly: !currentState.showPinnedOnly,
        ));
      }
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> _onTagFilterSelected(
    TagFilterSelected event,
    Emitter<NotesState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is NotesLoadedSuccess) {
        final notes = _cacheService.getFilteredNotes(
          searchQuery: currentState.searchQuery,
          selectedTag: event.tag,
          showPinnedOnly: currentState.showPinnedOnly,
        );
        emit(NotesLoadedSuccess(
          notes: notes,
          availableTags: currentState.availableTags,
          searchQuery: currentState.searchQuery,
          selectedTag: event.tag,
          showPinnedOnly: currentState.showPinnedOnly,
        ));
      }
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> _onFiltersCleared(
    FiltersCleared event,
    Emitter<NotesState> emit,
  ) async {
    try {
      final notes = _cacheService.getNotes();
      final tags = _cacheService.getAvailableTags();
      emit(NotesLoadedSuccess(
        notes: notes,
        availableTags: tags,
        searchQuery: '',
        selectedTag: null,
        showPinnedOnly: false,
      ));
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> _onNotePinnedToggled(
    NotePinnedToggled event,
    Emitter<NotesState> emit,
  ) async {
    try {
      emit(const NoteOperationInProgress());
      await _cacheService.togglePin(event.noteId);
      final notes = _cacheService.getNotes();
      final tags = _cacheService.getAvailableTags();
      emit(NotesLoadedSuccess(
        notes: notes,
        availableTags: tags,
        searchQuery: '',
        selectedTag: null,
        showPinnedOnly: false,
      ));
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }
}