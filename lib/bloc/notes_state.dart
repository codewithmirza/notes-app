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

// Loaded state
class NotesLoadedSuccess extends NotesState {
  final List<Note> notes;
  final String searchQuery;
  final String? selectedTag;
  final bool showPinnedOnly;
  final List<String> availableTags;
  
  const NotesLoadedSuccess({
    required this.notes,
    this.searchQuery = '',
    this.selectedTag,
    this.showPinnedOnly = false,
    this.availableTags = const [],
  });
  
  @override
  List<Object?> get props => [
    notes,
    searchQuery,
    selectedTag,
    showPinnedOnly,
    availableTags,
  ];
  
  NotesLoadedSuccess copyWith({
    List<Note>? notes,
    String? searchQuery,
    String? selectedTag,
    bool? showPinnedOnly,
    List<String>? availableTags,
  }) {
    return NotesLoadedSuccess(
      notes: notes ?? this.notes,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTag: selectedTag ?? this.selectedTag,
      showPinnedOnly: showPinnedOnly ?? this.showPinnedOnly,
      availableTags: availableTags ?? this.availableTags,
    );
  }
}

// Error state
class NotesError extends NotesState {
  final String error;
  
  const NotesError(this.error);
  
  @override
  List<Object?> get props => [error];
}

// Operation in progress state
class NoteOperationInProgress extends NotesState {
  const NoteOperationInProgress();
}