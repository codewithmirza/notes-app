import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';
import '../bloc/notes_state.dart';

class FilterChips extends StatefulWidget {
  final ValueChanged<String?>? onTagSelected;
  final VoidCallback? onPinnedToggle;
  final VoidCallback? onClearFilters;

  const FilterChips({
    super.key,
    this.onTagSelected,
    this.onPinnedToggle,
    this.onClearFilters,
  });

  @override
  State<FilterChips> createState() => _FilterChipsState();
}

class _FilterChipsState extends State<FilterChips> {
  List<String> _availableTags = [];
  bool _isLoadingTags = false;

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    setState(() {
      _isLoadingTags = true;
    });

    try {
      // Tags are loaded with the notes, so we can get them from the current state
      final state = context.read<NotesBloc>().state;
      if (state is NotesLoadedSuccess) {
        setState(() {
          _availableTags = state.availableTags;
        });
      }
    } catch (e) {
      // Handle error silently
    } finally {
      setState(() {
        _isLoadingTags = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotesBloc, NotesState>(
      builder: (context, state) {
        if (state is! NotesLoadedSuccess) {
          return const SizedBox.shrink();
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Pinned filter
              FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      state.showPinnedOnly ? Icons.push_pin : Icons.push_pin_outlined,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(state.showPinnedOnly ? 'Pinned' : 'All'),
                  ],
                ),
                selected: state.showPinnedOnly,
                onSelected: (selected) {
                  widget.onPinnedToggle?.call();
                },
              ),
              
              const SizedBox(width: 8),
              
              // Tag filters
              if (_isLoadingTags)
                const Chip(
                  label: Text('Loading tags...'),
                  avatar: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                ...state.availableTags.take(5).map((tag) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(tag),
                    selected: state.selectedTag == tag,
                    onSelected: (selected) {
                      widget.onTagSelected?.call(selected ? tag : null);
                    },
                  ),
                )),
              
              // Clear filters button
              if (state.selectedTag != null || 
                  state.showPinnedOnly ||
                  state.searchQuery.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ActionChip(
                    label: const Text('Clear'),
                    onPressed: () {
                      widget.onClearFilters?.call();
                    },
                    avatar: const Icon(Icons.clear, size: 16),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
