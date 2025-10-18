import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../services/database_service.dart';

class NotesProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  String _searchQuery = '';
  String? _selectedTag;
  String? _selectedParentId;
  bool _showPinnedOnly = false;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Note> get notes => _filteredNotes;
  List<Note> get allNotes => _notes;
  String get searchQuery => _searchQuery;
  String? get selectedTag => _selectedTag;
  String? get selectedParentId => _selectedParentId;
  bool get showPinnedOnly => _showPinnedOnly;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize the provider
  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await loadNotes();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load all notes from database
  Future<void> loadNotes() async {
    try {
      _notes = await _databaseService.getAllNotes();
      _applyFilters();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  // Add a new note
  Future<String> addNote(Note note) async {
    try {
      final id = await _databaseService.insertNote(note);
      await loadNotes();
      return id;
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  // Update an existing note
  Future<void> updateNote(Note note) async {
    try {
      await _databaseService.updateNote(note);
      await loadNotes();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  // Delete a note
  Future<void> deleteNote(String id) async {
    try {
      await _databaseService.deleteNote(id);
      await loadNotes();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  // Get note by ID
  Future<Note?> getNoteById(String id) async {
    try {
      return await _databaseService.getNoteById(id);
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }

  // Search notes
  Future<void> searchNotes(String query) async {
    _searchQuery = query;
    if (query.isEmpty) {
      _applyFilters();
    } else {
      try {
        _filteredNotes = await _databaseService.searchNotes(query);
        notifyListeners();
      } catch (e) {
        _error = e.toString();
        notifyListeners();
      }
    }
  }

  // Filter by tag
  Future<void> filterByTag(String? tag) async {
    _selectedTag = tag;
    if (tag == null) {
      _applyFilters();
    } else {
      try {
        _filteredNotes = await _databaseService.getNotesByTag(tag);
        notifyListeners();
      } catch (e) {
        _error = e.toString();
        notifyListeners();
      }
    }
  }

  // Filter by parent (for hierarchical view)
  Future<void> filterByParent(String? parentId) async {
    _selectedParentId = parentId;
    if (parentId == null) {
      _applyFilters();
    } else {
      try {
        _filteredNotes = await _databaseService.getNotesByParent(parentId);
        notifyListeners();
      } catch (e) {
        _error = e.toString();
        notifyListeners();
      }
    }
  }

  // Toggle pinned filter
  void togglePinnedFilter() {
    _showPinnedOnly = !_showPinnedOnly;
    _applyFilters();
  }

  // Apply all active filters
  void _applyFilters() {
    _filteredNotes = List.from(_notes);

    // Filter by parent
    if (_selectedParentId != null) {
      _filteredNotes = _filteredNotes.where((note) => note.parentId == _selectedParentId).toList();
    }

    // Filter by pinned status
    if (_showPinnedOnly) {
      _filteredNotes = _filteredNotes.where((note) => note.isPinned).toList();
    }

    // Filter by tag
    if (_selectedTag != null) {
      _filteredNotes = _filteredNotes.where((note) => note.tags.contains(_selectedTag)).toList();
    }

    // Apply search query
    if (_searchQuery.isNotEmpty) {
      _filteredNotes = _filteredNotes.where((note) =>
          note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.content.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    notifyListeners();
  }

  // Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedTag = null;
    _selectedParentId = null;
    _showPinnedOnly = false;
    _applyFilters();
  }

  // Get all available tags
  Future<List<String>> getAllTags() async {
    try {
      return await _databaseService.getAllTags();
    } catch (e) {
      _error = e.toString();
      return [];
    }
  }

  // Pin/unpin a note
  Future<void> togglePinNote(String id) async {
    try {
      final note = await _databaseService.getNoteById(id);
      if (note != null) {
        final updatedNote = note.copyWith(isPinned: !note.isPinned);
        await _databaseService.updateNote(updatedNote);
        await loadNotes();
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  // Move note to different parent
  Future<void> moveNote(String id, String? newParentId) async {
    try {
      final note = await _databaseService.getNoteById(id);
      if (note != null) {
        final updatedNote = note.copyWith(parentId: newParentId);
        await _databaseService.updateNote(updatedNote);
        await loadNotes();
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  // Update note order
  Future<void> updateNoteOrder(String id, int newOrder) async {
    try {
      final note = await _databaseService.getNoteById(id);
      if (note != null) {
        final updatedNote = note.copyWith(order: newOrder);
        await _databaseService.updateNote(updatedNote);
        await loadNotes();
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
