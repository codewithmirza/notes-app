import 'package:equatable/equatable.dart';
import '../models/note.dart';

abstract class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object?> get props => [];
}

// Initialization events
class NotesInitialized extends NotesEvent {
  const NotesInitialized();
}

class NotesLoaded extends NotesEvent {
  const NotesLoaded();
}

// CRUD events
class NoteAdded extends NotesEvent {
  final Note note;
  
  const NoteAdded(this.note);
  
  @override
  List<Object?> get props => [note];
}

class NoteUpdated extends NotesEvent {
  final Note note;
  
  const NoteUpdated(this.note);
  
  @override
  List<Object?> get props => [note];
}

class NoteDeleted extends NotesEvent {
  final String noteId;
  
  const NoteDeleted(this.noteId);
  
  @override
  List<Object?> get props => [noteId];
}

// Search and filter events
class NotesSearched extends NotesEvent {
  final String query;
  
  const NotesSearched(this.query);
  
  @override
  List<Object?> get props => [query];
}

class NotesFilteredByTag extends NotesEvent {
  final String? tag;
  
  const NotesFilteredByTag(this.tag);
  
  @override
  List<Object?> get props => [tag];
}

class NotesFilteredByParent extends NotesEvent {
  final String? parentId;
  
  const NotesFilteredByParent(this.parentId);
  
  @override
  List<Object?> get props => [parentId];
}

class PinnedFilterToggled extends NotesEvent {
  const PinnedFilterToggled();
}

class FiltersCleared extends NotesEvent {
  const FiltersCleared();
}

// Note management events
class NotePinnedToggled extends NotesEvent {
  final String noteId;
  
  const NotePinnedToggled(this.noteId);
  
  @override
  List<Object?> get props => [noteId];
}

class NoteMoved extends NotesEvent {
  final String noteId;
  final String? newParentId;
  
  const NoteMoved(this.noteId, this.newParentId);
  
  @override
  List<Object?> get props => [noteId, newParentId];
}

class NoteOrderUpdated extends NotesEvent {
  final String noteId;
  final int newOrder;
  
  const NoteOrderUpdated(this.noteId, this.newOrder);
  
  @override
  List<Object?> get props => [noteId, newOrder];
}

// Error handling
class NotesErrorOccurred extends NotesEvent {
  final String error;
  
  const NotesErrorOccurred(this.error);
  
  @override
  List<Object?> get props => [error];
}

class NotesErrorCleared extends NotesEvent {
  const NotesErrorCleared();
}
