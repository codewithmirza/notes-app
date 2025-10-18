import '../models/note.dart';
import 'database_service.dart';

class SampleDataService {
  static final DatabaseService _databaseService = DatabaseService();

  static Future<void> addSampleData() async {
    // Check if sample data already exists
    final existingNotes = await _databaseService.getAllNotes();
    if (existingNotes.isNotEmpty) return;

    // Create sample notes
    final sampleNotes = [
      Note(
        title: 'Welcome to Notes App',
        content: 'Welcome to your new notes app! This is a powerful note-taking application inspired by Notion.\n\nYou can:\n- Create rich text notes\n- Organize with tags and colors\n- Search through your notes\n- Pin important notes\n- Create different types of content',
        color: '#DBEAFE',
        tags: ['welcome', 'getting-started'],
        isPinned: true,
        type: NoteType.page,
      ),
      Note(
        title: 'Project Ideas',
        content: 'Here are some project ideas to work on:\n\n1. **Mobile App Development**\n   - Flutter app for task management\n   - React Native e-commerce app\n\n2. **Web Development**\n   - Portfolio website\n   - Blog with CMS\n\n3. **Data Science**\n   - Machine learning model for predictions\n   - Data visualization dashboard',
        color: '#D1FAE5',
        tags: ['projects', 'ideas', 'development'],
        type: NoteType.page,
      ),
      Note(
        title: 'Meeting Notes - Q1 Planning',
        content: '## Q1 Planning Meeting\n\n**Date:** January 15, 2024\n**Attendees:** Team leads, Product managers\n\n### Key Points:\n- Review Q4 performance\n- Set Q1 objectives\n- Resource allocation\n- Timeline planning\n\n### Action Items:\n- [ ] Prepare Q4 report\n- [ ] Define Q1 KPIs\n- [ ] Schedule follow-up meetings',
        color: '#FEF3C7',
        tags: ['meeting', 'planning', 'work'],
        type: NoteType.template,
      ),
      Note(
        title: 'Book Recommendations',
        content: 'Books I want to read this year:\n\n### Technical Books\n- Clean Code by Robert Martin\n- Design Patterns by Gang of Four\n- System Design Interview by Alex Xu\n\n### Fiction\n- The Seven Husbands of Evelyn Hugo\n- Project Hail Mary\n- The Midnight Library\n\n### Business\n- Atomic Habits by James Clear\n- The Lean Startup by Eric Ries',
        color: '#F3E8FF',
        tags: ['books', 'reading', 'recommendations'],
        type: NoteType.page,
      ),
      Note(
        title: 'Recipe Collection',
        content: '## My Favorite Recipes\n\n### Breakfast\n- **Pancakes**\n  - 2 cups flour\n  - 2 eggs\n  - 1 cup milk\n  - 2 tbsp sugar\n\n- **Omelette**\n  - 3 eggs\n  - Cheese\n  - Vegetables\n\n### Dinner\n- **Pasta Carbonara**\n  - Spaghetti\n  - Eggs\n  - Bacon\n  - Parmesan cheese',
        color: '#FCE7F3',
        tags: ['recipes', 'cooking', 'food'],
        type: NoteType.page,
      ),
      Note(
        title: 'Learning Resources',
        content: '## Online Learning Resources\n\n### Programming\n- **Flutter:**\n  - Flutter.dev official docs\n  - Flutter YouTube channel\n  - Dart language tour\n\n- **Web Development:**\n  - MDN Web Docs\n  - freeCodeCamp\n  - Codecademy\n\n### Design\n- Figma tutorials\n- Adobe Creative Suite\n- Design principles\n\n### General\n- Coursera courses\n- Udemy classes\n- YouTube tutorials',
        color: '#E0E7FF',
        tags: ['learning', 'resources', 'education'],
        type: NoteType.page,
      ),
    ];

    // Add sample notes to database
    for (final note in sampleNotes) {
      await _databaseService.insertNote(note);
    }
  }

  static Future<void> clearAllData() async {
    final db = await _databaseService.database;
    await db.delete('notes');
    await db.delete('note_blocks');
    await db.delete('database_columns');
    await db.delete('database_rows');
  }
}
