import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/note.dart';
import '../utils/app_theme.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onPin;
  final bool isListView;

  const NoteCard({
    super.key,
    required this.note,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onPin,
    this.isListView = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = note.color != null 
        ? Color(int.parse(note.color!.replaceFirst('#', '0xFF')))
        : AppTheme.noteColors[0];

    return Card(
      elevation: note.isPinned ? 4 : 1,
      color: color,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with pin and actions
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getTextColor(color),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (note.isPinned)
                    Icon(
                      Icons.push_pin,
                      size: 16,
                      color: _getTextColor(color).withOpacity(0.7),
                    ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit?.call();
                          break;
                        case 'pin':
                          onPin?.call();
                          break;
                        case 'delete':
                          onDelete?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'pin',
                        child: Row(
                          children: [
                            Icon(
                              note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text(note.isPinned ? 'Unpin' : 'Pin'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    child: Icon(
                      Icons.more_vert,
                      size: 20,
                      color: _getTextColor(color).withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Content preview
              Flexible(
                child: Text(
                  note.content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _getTextColor(color).withOpacity(0.8),
                  ),
                  maxLines: isListView ? 3 : 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Footer with tags and date
              Row(
                children: [
                  // Tags
                  if (note.tags.isNotEmpty)
                    Flexible(
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: note.tags.take(2).map((tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getTextColor(color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tag,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _getTextColor(color).withOpacity(0.8),
                              fontSize: 10,
                            ),
                          ),
                        )).toList(),
                      ),
                    ),
                  
                  // Date
                  Text(
                    _formatDate(note.updatedAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getTextColor(color).withOpacity(0.6),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              
              // Type indicator
              if (note.type != NoteType.page)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTextColor(color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getTypeIcon(note.type),
                        size: 12,
                        color: _getTextColor(color).withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getTypeName(note.type),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getTextColor(color).withOpacity(0.7),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTextColor(Color backgroundColor) {
    // Calculate luminance to determine if we need light or dark text
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  IconData _getTypeIcon(NoteType type) {
    switch (type) {
      case NoteType.page:
        return Icons.note;
      case NoteType.database:
        return Icons.table_chart;
      case NoteType.template:
        return Icons.description;
      case NoteType.folder:
        return Icons.folder;
    }
  }

  String _getTypeName(NoteType type) {
    switch (type) {
      case NoteType.page:
        return 'Page';
      case NoteType.database:
        return 'Database';
      case NoteType.template:
        return 'Template';
      case NoteType.folder:
        return 'Folder';
    }
  }
}
