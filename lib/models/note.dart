import 'package:uuid/uuid.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? color;
  final List<String> tags;
  final bool isPinned;
  final String? parentId; // For hierarchical organization like Notion
  final int order; // For ordering notes
  final NoteType type;

  Note({
    String? id,
    required this.title,
    required this.content,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.color,
    this.tags = const [],
    this.isPinned = false,
    this.parentId,
    this.order = 0,
    this.type = NoteType.page,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Note copyWith({
    String? title,
    String? content,
    DateTime? updatedAt,
    String? color,
    List<String>? tags,
    bool? isPinned,
    String? parentId,
    int? order,
    NoteType? type,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      color: color ?? this.color,
      tags: tags ?? this.tags,
      isPinned: isPinned ?? this.isPinned,
      parentId: parentId ?? this.parentId,
      order: order ?? this.order,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'color': color,
      'tags': tags.join(','), // Convert List<String> to comma-separated string
      'isPinned': isPinned ? 1 : 0, // Convert bool to int
      'parentId': parentId,
      'order': order,
      'type': type.toString(),
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      color: json['color'],
      tags: (json['tags'] as String?)?.split(',') ?? [], // Convert comma-separated string back to List<String>
      isPinned: (json['isPinned'] as int?) == 1, // Convert int back to bool
      parentId: json['parentId'],
      order: json['order'] ?? 0,
      type: NoteType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => NoteType.page,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Note && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum NoteType {
  page,
  database,
  template,
  folder,
}

class NoteBlock {
  final String id;
  final String type;
  final Map<String, dynamic> data;
  final int order;
  final String? parentId;

  NoteBlock({
    String? id,
    required this.type,
    required this.data,
    this.order = 0,
    this.parentId,
  }) : id = id ?? const Uuid().v4();

  NoteBlock copyWith({
    String? type,
    Map<String, dynamic>? data,
    int? order,
    String? parentId,
  }) {
    return NoteBlock(
      id: id,
      type: type ?? this.type,
      data: data ?? this.data,
      order: order ?? this.order,
      parentId: parentId ?? this.parentId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'data': data,
      'order': order,
      'parentId': parentId,
    };
  }

  factory NoteBlock.fromJson(Map<String, dynamic> json) {
    return NoteBlock(
      id: json['id'],
      type: json['type'],
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      order: json['order'] ?? 0,
      parentId: json['parentId'],
    );
  }
}

class DatabaseColumn {
  final String id;
  final String name;
  final String type;
  final Map<String, dynamic> properties;
  final int order;

  DatabaseColumn({
    String? id,
    required this.name,
    required this.type,
    this.properties = const {},
    this.order = 0,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'properties': properties,
      'order': order,
    };
  }

  factory DatabaseColumn.fromJson(Map<String, dynamic> json) {
    return DatabaseColumn(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      properties: Map<String, dynamic>.from(json['properties'] ?? {}),
      order: json['order'] ?? 0,
    );
  }
}

class DatabaseRow {
  final String id;
  final Map<String, dynamic> cells;
  final DateTime createdAt;
  final DateTime updatedAt;

  DatabaseRow({
    String? id,
    required this.cells,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cells': cells,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory DatabaseRow.fromJson(Map<String, dynamic> json) {
    return DatabaseRow(
      id: json['id'],
      cells: Map<String, dynamic>.from(json['cells'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
