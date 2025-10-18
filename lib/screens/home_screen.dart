import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../bloc/notes_bloc.dart';
import '../models/note.dart';
import '../widgets/note_card.dart';
import '../widgets/search_bar.dart';
import '../widgets/filter_chips.dart';
import 'note_editor_screen.dart';
import 'note_detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedView = 'grid'; // 'grid' or 'list'

  @override
  void initState() {
    super.initState();
    // BLoC is initialized in main.dart, no need for manual initialization
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Notes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(_selectedView == 'grid' ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _selectedView = _selectedView == 'grid' ? 'list' : 'grid';
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'new_page':
                  _createNewNote(NoteType.page);
                  break;
                case 'new_database':
                  _createNewNote(NoteType.database);
                  break;
                case 'new_template':
                  _createNewNote(NoteType.template);
                  break;
                case 'new_folder':
                  _createNewNote(NoteType.folder);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'new_page',
                child: Row(
                  children: [
                    Icon(Icons.note_add),
                    SizedBox(width: 8),
                    Text('New Page'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'new_database',
                child: Row(
                  children: [
                    Icon(Icons.table_chart),
                    SizedBox(width: 8),
                    Text('New Database'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'new_template',
                child: Row(
                  children: [
                    Icon(Icons.description),
                    SizedBox(width: 8),
                    Text('New Template'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'new_folder',
                child: Row(
                  children: [
                    Icon(Icons.folder),
                    SizedBox(width: 8),
                    Text('New Folder'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<NotesBloc, NotesState>(
        builder: (context, state) {
          if (state is NotesLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is NotesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.error}',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<NotesBloc>().add(const NotesInitialized()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is NotesLoadedSuccess) {
            return Column(
              children: [
                // Search and Filter Section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CustomSearchBar(
                        controller: _searchController,
                        onChanged: (value) => context.read<NotesBloc>().add(NotesSearched(value)),
                      ),
                      const SizedBox(height: 12),
                      FilterChips(
                        onTagSelected: (tag) => context.read<NotesBloc>().add(NotesFilteredByTag(tag)),
                        onPinnedToggle: () => context.read<NotesBloc>().add(const PinnedFilterToggled()),
                        onClearFilters: () {
                          context.read<NotesBloc>().add(const FiltersCleared());
                          _searchController.clear();
                        },
                      ),
                    ],
                  ),
                ),

                // Notes List
                Expanded(
                  child: state.filteredNotes.isEmpty
                      ? _buildEmptyState()
                      : _buildNotesList(state.filteredNotes),
                ),
              ],
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewNote(NoteType.page),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_add,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No notes yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first note to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _createNewNote(NoteType.page),
            icon: const Icon(Icons.add),
            label: const Text('Create Note'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList(List<Note> notes) {
    if (_selectedView == 'grid') {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return NoteCard(
            note: note,
            onTap: () => _openNote(note),
            onEdit: () => _editNote(note),
            onDelete: () => _deleteNote(note),
            onPin: () => _togglePin(note),
          );
        },
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: NoteCard(
              note: note,
              onTap: () => _openNote(note),
              onEdit: () => _editNote(note),
              onDelete: () => _deleteNote(note),
              onPin: () => _togglePin(note),
              isListView: true,
            ),
          );
        },
      );
    }
  }

  void _createNewNote(NoteType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(
          noteType: type,
        ),
      ),
    );
  }

  void _openNote(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteDetailScreen(note: note),
      ),
    );
  }

  void _editNote(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(
          note: note,
        ),
      ),
    );
  }

  void _deleteNote(Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<NotesBloc>().add(NoteDeleted(note.id));
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _togglePin(Note note) {
    context.read<NotesBloc>().add(NotePinnedToggled(note.id));
  }
}
