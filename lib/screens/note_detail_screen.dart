import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/note.dart';
import '../bloc/notes_bloc.dart';
import 'note_editor_screen.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note note;

  const NoteDetailScreen({
    super.key,
    required this.note,
  });

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late QuillController _quillController;
  bool _isReadOnly = true;

  @override
  void initState() {
    super.initState();
    _quillController = QuillController(
      document: Document.fromJson(_parseContent(widget.note.content)),
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  @override
  void dispose() {
    _quillController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _parseContent(String content) {
    try {
      // Simple parsing - in a real app, you'd want more robust parsing
      return [
        {
          "insert": content,
        }
      ];
    } catch (e) {
      return [
        {
          "insert": content,
        }
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.note.color != null 
        ? Color(int.parse(widget.note.color!.replaceFirst('#', '0xFF')))
        : null;

    return Scaffold(
      backgroundColor: color,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isReadOnly ? Icons.edit : Icons.visibility),
            onPressed: () {
              if (_isReadOnly) {
                _editNote();
              } else {
                setState(() {
                  _isReadOnly = true;
                });
              }
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _editNote();
                  break;
                case 'pin':
                  _togglePin();
                  break;
                case 'duplicate':
                  _duplicateNote();
                  break;
                case 'delete':
                  _deleteNote();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'pin',
                child: Row(
                  children: [
                    Icon(widget.note.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
                    const SizedBox(width: 8),
                    Text(widget.note.isPinned ? 'Unpin' : 'Pin'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.copy),
                    SizedBox(width: 8),
                    Text('Duplicate'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Title and metadata
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.note.title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getTextColor(color),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: _getTextColor(color).withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Created ${_formatDate(widget.note.createdAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getTextColor(color).withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.update,
                      size: 16,
                      color: _getTextColor(color).withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Updated ${_formatDate(widget.note.updatedAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getTextColor(color).withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                
                // Tags
                if (widget.note.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: widget.note.tags.map((tag) => Chip(
                      label: Text(tag),
                      backgroundColor: _getTextColor(color).withOpacity(0.1),
                      labelStyle: TextStyle(
                        color: _getTextColor(color).withOpacity(0.8),
                      ),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
          
          const Divider(),
          
          // Content
          Expanded(
            child: _isReadOnly
                ? SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: QuillEditor.basic(
                      controller: _quillController,
                    ),
                  )
                : QuillEditor.basic(
                    controller: _quillController,
                  ),
          ),
          
          // Toolbar (only in edit mode)
          if (!_isReadOnly)
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
              child: QuillToolbar.simple(
                configurations: QuillSimpleToolbarConfigurations(
                  controller: _quillController,
                  sharedConfigurations: const QuillSharedConfigurations(
                    locale: Locale('en'),
                  ),
                  showBoldButton: true,
                  showItalicButton: true,
                  showUnderLineButton: true,
                  showStrikeThrough: true,
                  showCodeBlock: true,
                  showQuote: true,
                  showListNumbers: true,
                  showListBullets: true,
                  showIndent: true,
                  showLink: true,
                  showSearchButton: false,
                  showUndo: true,
                  showRedo: true,
                  showClearFormat: true,
                  showAlignmentButtons: true,
                  showHeaderStyle: true,
                  showListCheck: true,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getTextColor(Color? backgroundColor) {
    if (backgroundColor == null) return Colors.black87;
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _editNote() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(note: widget.note),
      ),
    ).then((_) {
      // Refresh the note data when returning from editor
      context.read<NotesBloc>().add(const NotesLoaded());
    });
  }

  void _togglePin() {
    context.read<NotesBloc>().add(NotePinnedToggled(widget.note.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.note.isPinned ? 'Note unpinned' : 'Note pinned'),
      ),
    );
  }

  void _duplicateNote() {
    final duplicatedNote = widget.note.copyWith(
      title: '${widget.note.title} (Copy)',
    );
    context.read<NotesBloc>().add(NoteAdded(duplicatedNote));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note duplicated')),
    );
  }

  void _deleteNote() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete "${widget.note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<NotesBloc>().add(NoteDeleted(widget.note.id));
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to home
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
