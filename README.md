# Notes App - Notion-like Flutter Application

A modern Flutter application that combines the simplicity of a notes app with the powerful features of Notion. Built with Flutter and SQLite for local storage.

## Features

### Core Notes Functionality
- ✅ Create, read, update, and delete notes
- ✅ Rich text editing with Quill editor
- ✅ Note categorization with tags
- ✅ Color coding for notes
- ✅ Pin/unpin important notes
- ✅ Search functionality
- ✅ Filter by tags and pinned status

### Notion-like Features
- ✅ Rich text editor with formatting options
- ✅ Multiple note types (Page, Database, Template, Folder)
- ✅ Hierarchical organization
- ✅ Block-based content structure
- ✅ Database functionality for structured data
- ✅ Modern, clean UI design

### Additional Features
- ✅ Dark/Light theme support
- ✅ Grid and List view modes
- ✅ Responsive design
- ✅ Local SQLite database
- ✅ State management with Provider
- ✅ Material Design 3

## Screenshots

The app includes:
- Home screen with notes grid/list view
- Rich text editor for creating and editing notes
- Note detail view with read-only and edit modes
- Search and filtering capabilities
- Color picker for note customization
- Tag management system

## Getting Started

### Prerequisites
- Flutter SDK (3.6.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Android device or emulator / iOS simulator

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd notes_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run
```

## Project Structure

```
lib/
├── models/           # Data models (Note, NoteBlock, etc.)
├── providers/        # State management (NotesProvider)
├── screens/          # UI screens (Home, Editor, Detail)
├── widgets/          # Reusable UI components
├── services/         # Database and business logic
├── utils/            # Utilities and themes
└── main.dart         # App entry point
```

## Dependencies

- **flutter_quill**: Rich text editor
- **provider**: State management
- **sqflite**: Local database
- **font_awesome_flutter**: Icons
- **flutter_colorpicker**: Color selection
- **uuid**: Unique ID generation

## Database Schema

The app uses SQLite with the following tables:
- `notes`: Main notes table
- `note_blocks`: Block-based content
- `database_columns`: Database column definitions
- `database_rows`: Database row data

## Features in Detail

### Rich Text Editor
- Bold, italic, underline formatting
- Headers and text styles
- Lists (bulleted and numbered)
- Code blocks and quotes
- Links and alignment options

### Note Organization
- Hierarchical structure with parent-child relationships
- Tag-based categorization
- Color coding system
- Pin important notes
- Search across title and content

### Database Functionality
- Create structured databases
- Define custom columns
- Add and manage rows
- Sort and filter data

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Future Enhancements

- [ ] Cloud synchronization
- [ ] Collaboration features
- [ ] Advanced database views
- [ ] Export/Import functionality
- [ ] Templates system
- [ ] Advanced search with filters
- [ ] File attachments
- [ ] Voice notes
- [ ] Offline support improvements

## Support

For support, please open an issue on GitHub or contact the development team.

---

Built with ❤️ using Flutter