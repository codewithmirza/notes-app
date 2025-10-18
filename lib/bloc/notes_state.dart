import 'package:equatable/equatable.dart';
import '../models/note.dart';

abstract class NotesState extends Equatable {
  const NotesState();

  @override
  List<Object?> get props => [];
}

// Initial state
class NotesInitial extends NotesState {
  const NotesInitial();
}

// Loading state
class NotesLoading extends NotesState {
  const NotesLoading();
}

// Loaded states
class NotesLoadedSuccess extends NotesState {
  final List<Note> notes;
  final List<Note> filteredNotes;
  final String searchQuery;
  final String? selectedTag;
  final String? selectedParentId;
  final bool showPinnedOnly;
  final List<String> availableTags;
  
  const NotesLoadedSuccess({
    required this.notes,
    required this.filteredNotes,
    this.searchQuery = '',
    this.selectedTag,
    this.selectedParentId,
    this.showPinnedOnly = false,
    this.availableTags = const [],
  });
  
  @override
  List<Object?> get props => [
    notes,
    filteredNotes,
    searchQuery,
    selectedTag,
    selectedParentId,
    showPinnedOnly,
    availableTags,
  ];
  
  NotesLoadedSuccess copyWith({
    List<Note>? notes,
    List<Note>? filteredNotes,
    String? searchQuery,
    String? selectedTag,
    String? selectedParentId,
    bool? showPinnedOnly,
    List<String>? availableTags,
  }) {
    return NotesLoadedSuccess(
      notes: notes ?? this.notes,
      filteredNotes: filteredNotes ?? this.filteredNotes,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTag: selectedTag ?? this.selectedTag,
      selectedParentId: selectedParentId ?? this.selectedParentId,
      showPinnedOnly: showPinnedOnly ?? this.showPinnedOnly,
      availableTags: availableTags ?? this.availableTags,
    );
  }
}

// Error state
class NotesError extends NotesState {
  final String error;
  final List<Note>? previousNotes;
  
  const NotesError(this.error, {this.previousNotes});
  
  @override
  List<Object?> get props => [error, previousNotes];
}

// Operation states
class NoteOperationInProgress extends NotesState {
  final String operation;
  final List<Note> notes;
  
  const NoteOperationInProgress(this.operation, this.notes);
  
  @override
  List<Object?> get props => [operation, notes];
}

class NoteOperationSuccess extends NotesState {
  final String operation;
  final List<Note> notes;
  final String? message;
  
  const NoteOperationSuccess(this.operation, this.notes, {this.message});
  
  @override
  List<Object?> get props => [operation, notes, message];
}
