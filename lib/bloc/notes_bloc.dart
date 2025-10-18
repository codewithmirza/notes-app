import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/note.dart';
import '../services/database_service.dart';
import 'notes_event.dart';
import 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final DatabaseService _databaseService = DatabaseService();

  NotesBloc() : super(const NotesInitial()) {
    on<NotesInitialized>(_onNotesInitialized);
    on<NotesLoaded>(_onNotesLoaded);
    on<NoteAdded>(_onNoteAdded);
    on<NoteUpdated>(_onNoteUpdated);
    on<NoteDeleted>(_onNoteDeleted);
    on<NotesSearched>(_onNotesSearched);
    on<NotesFilteredByTag>(_onNotesFilteredByTag);
    on<NotesFilteredByParent>(_onNotesFilteredByParent);
    on<PinnedFilterToggled>(_onPinnedFilterToggled);
    on<FiltersCleared>(_onFiltersCleared);
    on<NotePinnedToggled>(_onNotePinnedToggled);
    on<NoteMoved>(_onNoteMoved);
    on<NoteOrderUpdated>(_onNoteOrderUpdated);
    on<NotesErrorOccurred>(_onNotesErrorOccurred);
    on<NotesErrorCleared>(_onNotesErrorCleared);
  }

  Future<void> _onNotesInitialized(
    NotesInitialized event,
    Emitter<NotesState> emit,
  ) async {
    emit(const NotesLoading());
    try {
      final notes = await _databaseService.getAllNotes();
      final tags = await _databaseService.getAllTags();
      emit(NotesLoadedSuccess(
        notes: notes,
        filteredNotes: notes,
        availableTags: tags,
      ));
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> _onNotesLoaded(
    NotesLoaded event,
    Emitter<NotesState> emit,
  ) async {
    if (state is! NotesLoadedSuccess) return;
    
    final currentState = state as NotesLoadedSuccess;
    emit(NotesLoading());
    
    try {
      final notes = await _databaseService.getAllNotes();
      final tags = await _databaseService.getAllTags();
      
      // Apply current filters
      final filteredNotes = _applyFilters(
        notes,
        currentState.searchQuery,
        currentState.selectedTag,
        currentState.selectedParentId,
        currentState.showPinnedOnly,
      );
      
      emit(NotesLoadedSuccess(
        notes: notes,
        filteredNotes: filteredNotes,
        searchQuery: currentState.searchQuery,
        selectedTag: currentState.selectedTag,
        selectedParentId: currentState.selectedParentId,
        showPinnedOnly: currentState.showPinnedOnly,
        availableTags: tags,
      ));
    } catch (e) {
      emit(NotesError(e.toString(), previousNotes: currentState.notes));
    }
  }

  Future<void> _onNoteAdded(
    NoteAdded event,
    Emitter<NotesState> emit,
  ) async {
    if (state is! NotesLoadedSuccess) return;
    
    final currentState = state as NotesLoadedSuccess;
    emit(NoteOperationInProgress('Adding note', currentState.notes));
    
    try {
      await _databaseService.insertNote(event.note);
      final updatedNotes = await _databaseService.getAllNotes();
      final tags = await _databaseService.getAllTags();
      
      final filteredNotes = _applyFilters(
        updatedNotes,
        currentState.searchQuery,
        currentState.selectedTag,
        currentState.selectedParentId,
        currentState.showPinnedOnly,
      );
      
      emit(NotesLoadedSuccess(
        notes: updatedNotes,
        filteredNotes: filteredNotes,
        searchQuery: currentState.searchQuery,
        selectedTag: currentState.selectedTag,
        selectedParentId: currentState.selectedParentId,
        showPinnedOnly: currentState.showPinnedOnly,
        availableTags: tags,
      ));
    } catch (e) {
      emit(NotesError(e.toString(), previousNotes: currentState.notes));
    }
  }

  Future<void> _onNoteUpdated(
    NoteUpdated event,
    Emitter<NotesState> emit,
  ) async {
    if (state is! NotesLoadedSuccess) return;
    
    final currentState = state as NotesLoadedSuccess;
    emit(NoteOperationInProgress('Updating note', currentState.notes));
    
    try {
      await _databaseService.updateNote(event.note);
      final updatedNotes = await _databaseService.getAllNotes();
      final tags = await _databaseService.getAllTags();
      
      final filteredNotes = _applyFilters(
        updatedNotes,
        currentState.searchQuery,
        currentState.selectedTag,
        currentState.selectedParentId,
        currentState.showPinnedOnly,
      );
      
      emit(NotesLoadedSuccess(
        notes: updatedNotes,
        filteredNotes: filteredNotes,
        searchQuery: currentState.searchQuery,
        selectedTag: currentState.selectedTag,
        selectedParentId: currentState.selectedParentId,
        showPinnedOnly: currentState.showPinnedOnly,
        availableTags: tags,
      ));
    } catch (e) {
      emit(NotesError(e.toString(), previousNotes: currentState.notes));
    }
  }

  Future<void> _onNoteDeleted(
    NoteDeleted event,
    Emitter<NotesState> emit,
  ) async {
    if (state is! NotesLoadedSuccess) return;
    
    final currentState = state as NotesLoadedSuccess;
    emit(NoteOperationInProgress('Deleting note', currentState.notes));
    
    try {
      await _databaseService.deleteNote(event.noteId);
      final updatedNotes = await _databaseService.getAllNotes();
      final tags = await _databaseService.getAllTags();
      
      final filteredNotes = _applyFilters(
        updatedNotes,
        currentState.searchQuery,
        currentState.selectedTag,
        currentState.selectedParentId,
        currentState.showPinnedOnly,
      );
      
      emit(NotesLoadedSuccess(
        notes: updatedNotes,
        filteredNotes: filteredNotes,
        searchQuery: currentState.searchQuery,
        selectedTag: currentState.selectedTag,
        selectedParentId: currentState.selectedParentId,
        showPinnedOnly: currentState.showPinnedOnly,
        availableTags: tags,
      ));
    } catch (e) {
      emit(NotesError(e.toString(), previousNotes: currentState.notes));
    }
  }

  Future<void> _onNotesSearched(
    NotesSearched event,
    Emitter<NotesState> emit,
  ) async {
    if (state is! NotesLoadedSuccess) return;
    
    final currentState = state as NotesLoadedSuccess;
    
    if (event.query.isEmpty) {
      // If search query is empty, show all notes with current filters
      final filteredNotes = _applyFilters(
        currentState.notes,
        '',
        currentState.selectedTag,
        currentState.selectedParentId,
        currentState.showPinnedOnly,
      );
      
      emit(currentState.copyWith(
        searchQuery: '',
        filteredNotes: filteredNotes,
      ));
    } else {
      // Perform search
      try {
        final searchResults = await _databaseService.searchNotes(event.query);
        final filteredNotes = _applyFilters(
          searchResults,
          event.query,
          currentState.selectedTag,
          currentState.selectedParentId,
          currentState.showPinnedOnly,
        );
        
        emit(currentState.copyWith(
          searchQuery: event.query,
          filteredNotes: filteredNotes,
        ));
      } catch (e) {
        emit(NotesError(e.toString(), previousNotes: currentState.notes));
      }
    }
  }

  Future<void> _onNotesFilteredByTag(
    NotesFilteredByTag event,
    Emitter<NotesState> emit,
  ) async {
    if (state is! NotesLoadedSuccess) return;
    
    final currentState = state as NotesLoadedSuccess;
    
    if (event.tag == null) {
      // Clear tag filter
      final filteredNotes = _applyFilters(
        currentState.notes,
        currentState.searchQuery,
        null,
        currentState.selectedParentId,
        currentState.showPinnedOnly,
      );
      
      emit(currentState.copyWith(
        selectedTag: null,
        filteredNotes: filteredNotes,
      ));
    } else {
      // Apply tag filter
      try {
        final tagResults = await _databaseService.getNotesByTag(event.tag!);
        final filteredNotes = _applyFilters(
          tagResults,
          currentState.searchQuery,
          event.tag,
          currentState.selectedParentId,
          currentState.showPinnedOnly,
        );
        
        emit(currentState.copyWith(
          selectedTag: event.tag,
          filteredNotes: filteredNotes,
        ));
      } catch (e) {
        emit(NotesError(e.toString(), previousNotes: currentState.notes));
      }
    }
  }

  Future<void> _onNotesFilteredByParent(
    NotesFilteredByParent event,
    Emitter<NotesState> emit,
  ) async {
    if (state is! NotesLoadedSuccess) return;
    
    final currentState = state as NotesLoadedSuccess;
    
    if (event.parentId == null) {
      // Clear parent filter
      final filteredNotes = _applyFilters(
        currentState.notes,
        currentState.searchQuery,
        currentState.selectedTag,
        null,
        currentState.showPinnedOnly,
      );
      
      emit(currentState.copyWith(
        selectedParentId: null,
        filteredNotes: filteredNotes,
      ));
    } else {
      // Apply parent filter
      try {
        final parentResults = await _databaseService.getNotesByParent(event.parentId!);
        final filteredNotes = _applyFilters(
          parentResults,
          currentState.searchQuery,
          currentState.selectedTag,
          event.parentId,
          currentState.showPinnedOnly,
        );
        
        emit(currentState.copyWith(
          selectedParentId: event.parentId,
          filteredNotes: filteredNotes,
        ));
      } catch (e) {
        emit(NotesError(e.toString(), previousNotes: currentState.notes));
      }
    }
  }

  Future<void> _onPinnedFilterToggled(
    PinnedFilterToggled event,
    Emitter<NotesState> emit,
  ) async {
    if (state is! NotesLoadedSuccess) return;
    
    final currentState = state as NotesLoadedSuccess;
    final newShowPinnedOnly = !currentState.showPinnedOnly;
    
    final filteredNotes = _applyFilters(
      currentState.notes,
      currentState.searchQuery,
      currentState.selectedTag,
      currentState.selectedParentId,
      newShowPinnedOnly,
    );
    
    emit(currentState.copyWith(
      showPinnedOnly: newShowPinnedOnly,
      filteredNotes: filteredNotes,
    ));
  }

  Future<void> _onFiltersCleared(
    FiltersCleared event,
    Emitter<NotesState> emit,
  ) async {
    if (state is! NotesLoadedSuccess) return;
    
    final currentState = state as NotesLoadedSuccess;
    
    final filteredNotes = _applyFilters(
      currentState.notes,
      '',
      null,
      null,
      false,
    );
    
    emit(currentState.copyWith(
      searchQuery: '',
      selectedTag: null,
      selectedParentId: null,
      showPinnedOnly: false,
      filteredNotes: filteredNotes,
    ));
  }

  Future<void> _onNotePinnedToggled(
    NotePinnedToggled event,
    Emitter<NotesState> emit,
  ) async {
    if (state is! NotesLoadedSuccess) return;
    
    final currentState = state as NotesLoadedSuccess;
    
    try {
      final note = await _databaseService.getNoteById(event.noteId);
      if (note != null) {
        final updatedNote = note.copyWith(isPinned: !note.isPinned);
        await _databaseService.updateNote(updatedNote);
        
        // Reload notes to get updated data
        add(const NotesLoaded());
      }
    } catch (e) {
      emit(NotesError(e.toString(), previousNotes: currentState.notes));
    }
  }

  Future<void> _onNoteMoved(
    NoteMoved event,
    Emitter<NotesState> emit,
  ) async {
    if (state is! NotesLoadedSuccess) return;
    
    final currentState = state as NotesLoadedSuccess;
    
    try {
      final note = await _databaseService.getNoteById(event.noteId);
      if (note != null) {
        final updatedNote = note.copyWith(parentId: event.newParentId);
        await _databaseService.updateNote(updatedNote);
        
        // Reload notes to get updated data
        add(const NotesLoaded());
      }
    } catch (e) {
      emit(NotesError(e.toString(), previousNotes: currentState.notes));
    }
  }

  Future<void> _onNoteOrderUpdated(
    NoteOrderUpdated event,
    Emitter<NotesState> emit,
  ) async {
    if (state is! NotesLoadedSuccess) return;
    
    final currentState = state as NotesLoadedSuccess;
    
    try {
      final note = await _databaseService.getNoteById(event.noteId);
      if (note != null) {
        final updatedNote = note.copyWith(order: event.newOrder);
        await _databaseService.updateNote(updatedNote);
        
        // Reload notes to get updated data
        add(const NotesLoaded());
      }
    } catch (e) {
      emit(NotesError(e.toString(), previousNotes: currentState.notes));
    }
  }

  void _onNotesErrorOccurred(
    NotesErrorOccurred event,
    Emitter<NotesState> emit,
  ) {
    emit(NotesError(event.error));
  }

  void _onNotesErrorCleared(
    NotesErrorCleared event,
    Emitter<NotesState> emit,
  ) {
    if (state is NotesError) {
      final errorState = state as NotesError;
      if (errorState.previousNotes != null) {
        emit(NotesLoadedSuccess(
          notes: errorState.previousNotes!,
          filteredNotes: errorState.previousNotes!,
        ));
      } else {
        emit(const NotesInitial());
      }
    }
  }

  List<Note> _applyFilters(
    List<Note> notes,
    String searchQuery,
    String? selectedTag,
    String? selectedParentId,
    bool showPinnedOnly,
  ) {
    List<Note> filteredNotes = List.from(notes);

    // Filter by parent
    if (selectedParentId != null) {
      filteredNotes = filteredNotes.where((note) => note.parentId == selectedParentId).toList();
    }

    // Filter by pinned status
    if (showPinnedOnly) {
      filteredNotes = filteredNotes.where((note) => note.isPinned).toList();
    }

    // Filter by tag
    if (selectedTag != null) {
      filteredNotes = filteredNotes.where((note) => note.tags.contains(selectedTag)).toList();
    }

    // Apply search query
    if (searchQuery.isNotEmpty) {
      filteredNotes = filteredNotes.where((note) =>
          note.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          note.content.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }

    return filteredNotes;
  }
}
