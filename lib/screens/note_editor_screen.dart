import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/note.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';
import '../bloc/notes_state.dart';
import '../utils/app_theme.dart';
import '../widgets/color_picker_dialog.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;
  final NoteType? noteType;

  const NoteEditorScreen({
    super.key,
    this.note,
    this.noteType,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late QuillController _quillController;
  late TextEditingController _titleController;
  String? _selectedColor;
  List<String> _tags = [];
  bool _isPinned = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _selectedColor = widget.note?.color;
    _tags = List.from(widget.note?.tags ?? []);
    _isPinned = widget.note?.isPinned ?? false;

    // Initialize Quill controller
    if (widget.note != null) {
      _quillController = QuillController(
        document: Document.fromJson(widget.note!.content.isNotEmpty 
            ? _parseContent(widget.note!.content) 
            : []),
        selection: const TextSelection.collapsed(offset: 0),
      );
    } else {
      _quillController = QuillController.basic();
    }
  }

  @override
  void dispose() {
    _quillController.dispose();
    _titleController.dispose();
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: Icon(_isPinned ? Icons.push_pin : Icons.push_pin_outlined),
            onPressed: () {
              setState(() {
                _isPinned = !_isPinned;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: _showColorPicker,
          ),
          IconButton(
            icon: const Icon(Icons.label),
            onPressed: _showTagDialog,
          ),
          IconButton(
            icon: _isSaving ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ) : const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveNote,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 
                      MediaQuery.of(context).padding.top - 
                      kToolbarHeight - 
                      kBottomNavigationBarHeight,
          ),
          child: IntrinsicHeight(
            child: Column(
              children: [
                // Title input
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Untitled',
                      border: InputBorder.none,
                    ),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                // Tags display
                if (_tags.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 8,
                      children: _tags.map((tag) => Chip(
                        label: Text(tag),
                        onDeleted: () {
                          setState(() {
                            _tags.remove(tag);
                          });
                        },
                      )).toList(),
                    ),
                  ),
                
                const Divider(),
                
                // Rich text editor
                Flexible(
                  child: Container(
                    color: _selectedColor != null 
                        ? Color(int.parse(_selectedColor!.replaceFirst('#', '0xFF')))
                        : null,
                    child: QuillEditor.basic(
                      configurations: QuillEditorConfigurations(
                        controller: _quillController,
                        placeholder: 'Start writing...',
                        autoFocus: false,
                        expands: true,
                        padding: const EdgeInsets.all(16),
                        scrollable: true,
                        showCursor: true,
                        enableInteractiveSelection: true,
                      ),
                    ),
                  ),
                ),
                
                // Toolbar
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
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
          ),
        ),
      ),
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => ColorPickerDialog(
        selectedColor: _selectedColor,
        onColorSelected: (color) {
          setState(() {
            _selectedColor = color;
          });
        },
      ),
    );
  }

  void _showTagDialog() {
    final TextEditingController tagController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Tag'),
        content: TextField(
          controller: tagController,
          decoration: const InputDecoration(
            hintText: 'Enter tag name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final tag = tagController.text.trim();
              if (tag.isNotEmpty && !_tags.contains(tag)) {
                setState(() {
                  _tags.add(tag);
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveNote() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final content = _quillController.document.toDelta().toJson();
      final note = Note(
        id: widget.note?.id,
        title: _titleController.text.trim(),
        content: content.toString(),
        color: _selectedColor,
        tags: _tags,
        isPinned: _isPinned,
        type: widget.noteType ?? widget.note?.type ?? NoteType.page,
      );

      if (widget.note == null) {
        context.read<NotesBloc>().add(NoteAdded(note));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note created successfully')),
        );
      } else {
        context.read<NotesBloc>().add(NoteUpdated(note));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note updated successfully')),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }
}
