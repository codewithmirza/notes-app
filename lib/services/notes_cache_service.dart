import 'package:notes_app/models/note.dart';

class NotesCacheService {
  static final NotesCacheService _instance = NotesCacheService._internal();
  factory NotesCacheService() => _instance;
  NotesCacheService._internal();

  final List<Note> _notes = [];
  final List<String> _availableTags = [];

  // Initialize with sample data
  Future<void> initialize() async {
    if (_notes.isEmpty) {
      await _addSampleData();
    }
  }

  // Get all notes
  List<Note> getNotes() {
    return List.from(_notes);
  }

  // Get filtered notes
  List<Note> getFilteredNotes({
    String searchQuery = '',
    String? selectedTag,
    bool showPinnedOnly = false,
  }) {
    return _notes.where((note) {
      final matchesSearch = searchQuery.isEmpty ||
          note.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          note.content.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesTag = selectedTag == null || note.tags.contains(selectedTag);
      final matchesPinned = !showPinnedOnly || note.isPinned;
      return matchesSearch && matchesTag && matchesPinned;
    }).toList();
  }

  // Get available tags
  List<String> getAvailableTags() {
    return List.from(_availableTags);
  }

  // Add note
  Future<String> addNote(Note note) async {
    _notes.add(note);
    _updateTags();
    return note.id;
  }

  // Update note
  Future<void> updateNote(Note note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
      _updateTags();
    }
  }

  // Delete note
  Future<void> deleteNote(String id) async {
    _notes.removeWhere((note) => note.id == id);
    _updateTags();
  }

  // Toggle pin status
  Future<void> togglePin(String id) async {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(isPinned: !_notes[index].isPinned);
    }
  }

  // Update tags list
  void _updateTags() {
    final Set<String> tags = {};
    for (final note in _notes) {
      tags.addAll(note.tags);
    }
    _availableTags.clear();
    _availableTags.addAll(tags.toList()..sort());
  }

  // Add sample data
  Future<void> _addSampleData() async {
    final sampleNotes = [
      Note(
        title: 'Welcome to Notes App',
        content: '{"ops":[{"insert":"Welcome to your new notes app! This is a powerful note-taking application with Notion-like features.\\n"}]}',
        color: '#DBEAFE',
        tags: ['welcome', 'getting-started'],
        type: NoteType.page,
      ),
      Note(
        title: 'Project Ideas',
        content: '{"ops":[{"insert":"My Project Ideas\\n\\nWeb Development\\n- Personal portfolio website\\n- E-commerce platform\\n- Blog with CMS\\n\\nMobile Apps\\n- Fitness tracking app\\n- Recipe manager\\n- Expense tracker\\n\\nAI/ML Projects\\n- Chatbot for customer service\\n- Image recognition system\\n- Recommendation engine\\n"}]}',
        color: '#F3E8FF',
        tags: ['projects', 'ideas', 'development'],
        type: NoteType.page,
      ),
      Note(
        title: 'Learning Resources',
        content: '{"ops":[{"insert":"Online Learning Resources\\n\\nProgramming\\n- Flutter:\\n  - Flutter.dev official docs\\n  - Flutter YouTube channel\\n  - Dart language tour\\n\\n- Web Development:\\n  - MDN Web Docs\\n  - freeCodeCamp\\n  - Codecademy\\n\\nDesign\\n- Figma tutorials\\n- Adobe Creative Suite\\n- Design principles\\n\\nGeneral\\n- Coursera courses\\n- Udemy classes\\n- YouTube tutorials\\n"}]}',
        color: '#E0E7FF',
        tags: ['learning', 'resources', 'education'],
        type: NoteType.page,
      ),
    ];

    for (final note in sampleNotes) {
      _notes.add(note);
    }
    _updateTags();
  }

  // Clear all data
  Future<void> clearAllData() async {
    _notes.clear();
    _availableTags.clear();
  }

  // Get statistics
  Map<String, int> getStatistics() {
    return {
      'totalNotes': _notes.length,
      'pinnedNotes': _notes.where((note) => note.isPinned).length,
      'totalTags': _availableTags.length,
    };
  }
}
