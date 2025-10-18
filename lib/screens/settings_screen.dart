import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';
import '../bloc/notes_state.dart';
import '../services/notes_cache_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // App Info Section
          _buildSection(
            context,
            'App Information',
            [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Version'),
                subtitle: const Text('1.0.0'),
                trailing: const Icon(Icons.chevron_right),
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('About'),
                subtitle: const Text('Notes App - Notion-like Flutter Application'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showAboutDialog(context),
              ),
            ],
          ),
          
          // Data Management Section
          _buildSection(
            context,
            'Data Management',
            [
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Add Sample Data'),
                subtitle: const Text('Add sample notes to get started'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _addSampleData(context),
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('Clear All Data'),
                subtitle: const Text('Delete all notes and data'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _clearAllData(context),
              ),
            ],
          ),
          
          // Theme Section
          _buildSection(
            context,
            'Appearance',
            [
              ListTile(
                leading: const Icon(Icons.palette),
                title: const Text('Theme'),
                subtitle: const Text('System default'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showThemeDialog(context),
              ),
            ],
          ),
          
          // Statistics Section
          _buildSection(
            context,
            'Statistics',
            [
              BlocBuilder<NotesBloc, NotesState>(
                builder: (context, state) {
                  if (state is NotesLoadedSuccess) {
                    return ListTile(
                      leading: const Icon(Icons.note),
                      title: const Text('Total Notes'),
                      subtitle: Text('${state.notes.length} notes'),
                    );
                  }
                  return const ListTile(
                    leading: Icon(Icons.note),
                    title: Text('Total Notes'),
                    subtitle: Text('0 notes'),
                  );
                },
              ),
              BlocBuilder<NotesBloc, NotesState>(
                builder: (context, state) {
                  if (state is NotesLoadedSuccess) {
                    final pinnedNotes = state.notes.where((note) => note.isPinned).length;
                    return ListTile(
                      leading: const Icon(Icons.push_pin),
                      title: const Text('Pinned Notes'),
                      subtitle: Text('$pinnedNotes pinned'),
                    );
                  }
                  return const ListTile(
                    leading: Icon(Icons.push_pin),
                    title: Text('Pinned Notes'),
                    subtitle: Text('0 pinned'),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Notes App',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.note, size: 48),
      children: [
        const Text(
          'A modern Flutter application that combines the simplicity of a notes app with the powerful features of Notion.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Features:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Text('• Rich text editing'),
        const Text('• Note organization with tags'),
        const Text('• Color coding system'),
        const Text('• Search and filtering'),
        const Text('• Multiple note types'),
        const Text('• Dark/Light theme support'),
      ],
    );
  }

  void _addSampleData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Sample Data'),
        content: const Text('This will add sample notes to help you get started. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
                try {
                  await NotesCacheService().initialize();
                  if (context.mounted) {
                    context.read<NotesBloc>().add(const NotesLoaded());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sample data added successfully')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _clearAllData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your notes and data. This action cannot be undone. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await NotesCacheService().clearAllData();
                if (context.mounted) {
                  context.read<NotesBloc>().add(const NotesLoaded());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All data cleared successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Theme'),
        content: const Text('Theme selection will be available in a future update. Currently using system default.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
