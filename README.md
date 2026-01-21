# flexi_sqlite

🗄️ **Flexible SQLite helper for Flutter with schema-based multi-table support**

A simple yet powerful package for managing SQLite databases in Flutter applications. Define your database schema declaratively and get automatic table creation with an intuitive API for all common operations.

## ✨ Features

- **📋 Schema-based database design** - Define tables and columns declaratively
- **🔄 Automatic table creation** - Tables are created automatically on app startup
- **⚡ Simple CRUD operations** - `insert()`, `update()`, `delete()`, `queryAll()`
- **🔍 Raw SQL support** - Execute complex queries with `rawQuery()`
- **🔐 Column constraints** - PRIMARY KEY, NOT NULL, UNIQUE, DEFAULT values
- **📊 Multiple data types** - Support for TEXT, INTEGER, REAL, and BLOB
- **🛡️ Type-safe** - Strongly typed column definitions
- **💾 Database management** - Easy close and reset operations
- **🚀 Zero configuration** - Works out of the box with sensible defaults

## 📦 Installation

Add to your app's `pubspec.yaml`:

```yaml
dependencies:
  flexi_sqlite:
    path: packages/flexi_sqlite
```

Then run:

```sh
flutter pub get
```

## 🚀 Quick Start

Here's the simplest way to get started:

```dart
import 'package:flexi_sqlite/flexi_sqlite.dart';

// Step 1: Define your database schema
final dbHelper = DatabaseHelper(
  dbName: 'app.db',
  tables: [
    TableDefinition(
      name: 'users',
      columns: const [
        ColumnDefinition(name: 'id', type: SQType.integer, isPrimaryKey: true),
        ColumnDefinition(name: 'username', type: SQType.text, isNotNull: true),
        ColumnDefinition(name: 'email', type: SQType.text, isNotNull: true),
      ],
    ),
  ],
);

// Step 2: Insert data
await dbHelper.insert('users', {
  'username': 'john_doe',
  'email': 'john@example.com',
});

// Step 3: Query data
final users = await dbHelper.queryAll('users');
print(users);

// Step 4: Update data
await dbHelper.update('users', {'email': 'john.new@example.com'}, 
  where: 'id = ?', whereArgs: [1]);

// Step 5: Delete data
await dbHelper.delete('users', where: 'id = ?', whereArgs: [1]);

// Step 6: Close the database
await dbHelper.closeDatabase();
```

## 📚 Detailed Usage

### 1. Define Your Schema

Define tables with columns and their properties:

```dart
final dbHelper = DatabaseHelper(
  dbName: 'myapp.db',
  tables: [
    TableDefinition(
      name: 'users',
      columns: const [
        ColumnDefinition(
          name: 'id',
          type: SQType.integer,
          isPrimaryKey: true, // Auto-incremented primary key
        ),
        ColumnDefinition(
          name: 'username',
          type: SQType.text,
          isNotNull: true,
          isUnique: true, // Enforce unique usernames
        ),
        ColumnDefinition(
          name: 'email',
          type: SQType.text,
          isNotNull: true,
        ),
        ColumnDefinition(
          name: 'created_at',
          type: SQType.text,
          defaultValue: "'2024-01-01'", // Set default value
        ),
      ],
    ),
  ],
);
```

### 2. Supported Data Types

Use the `SQType` enum to define column types:

```dart
SQType.text       // TEXT - For strings
SQType.integer    // INTEGER - For whole numbers
SQType.real       // REAL - For decimal numbers
SQType.blob       // BLOB - For binary data
```

### 3. Column Constraints

- **`isPrimaryKey`** - Makes column a primary key with auto-increment
- **`isNotNull`** - Column cannot be NULL
- **`isUnique`** - Column values must be unique
- **`defaultValue`** - Set a default value (pass as string, e.g., `"'default_value'"`)

### 4. CRUD Operations

**Insert:**
```dart
await dbHelper.insert('users', {
  'username': 'alice',
  'email': 'alice@example.com',
});
```

**Query All:**
```dart
final users = await dbHelper.queryAll('users');
```

**Update:**
```dart
await dbHelper.update(
  'users',
  {'email': 'alice.new@example.com'},
  where: 'id = ?',
  whereArgs: [1],
);
```

**Delete:**
```dart
await dbHelper.delete(
  'users',
  where: 'id = ?',
  whereArgs: [1],
);
```

### 5. Advanced Queries

Use raw SQL for complex queries:

```dart
// Join tables
final result = await dbHelper.rawQuery('''
  SELECT users.username, COUNT(posts.id) as post_count
  FROM users
  LEFT JOIN posts ON users.id = posts.user_id
  GROUP BY users.id
''');

// Conditional queries with aggregation
final result = await dbHelper.rawQuery(
  'SELECT * FROM products WHERE price < ? ORDER BY price DESC',
);
```

### 6. Database Management

**Close database:**
```dart
await dbHelper.closeDatabase();
```

**Reset database (delete all tables and data):**
```dart
await dbHelper.resetDatabase();
```

## 📖 Complete Examples

### Example 1: Simple Todo App

```dart
final dbHelper = DatabaseHelper(
  dbName: 'todo_app.db',
  tables: [
    TableDefinition(
      name: 'todos',
      columns: const [
        ColumnDefinition(name: 'id', type: SQType.integer, isPrimaryKey: true),
        ColumnDefinition(name: 'title', type: SQType.text, isNotNull: true),
        ColumnDefinition(name: 'description', type: SQType.text),
        ColumnDefinition(name: 'is_completed', type: SQType.integer, defaultValue: '0'),
      ],
    ),
  ],
);

// Add a todo
await dbHelper.insert('todos', {
  'title': 'Buy groceries',
  'description': 'Milk, bread, eggs',
  'is_completed': 0,
});

// Mark as completed
await dbHelper.update('todos', {'is_completed': 1}, where: 'id = ?', whereArgs: [1]);

// Get incomplete todos
final incompleteTodos = await dbHelper.rawQuery(
  'SELECT * FROM todos WHERE is_completed = 0',
);
```

### Example 2: Multi-Table Database

```dart
final dbHelper = DatabaseHelper(
  dbName: 'social_app.db',
  tables: [
    // Users table
    TableDefinition(
      name: 'users',
      columns: const [
        ColumnDefinition(name: 'id', type: SQType.integer, isPrimaryKey: true),
        ColumnDefinition(name: 'username', type: SQType.text, isNotNull: true, isUnique: true),
        ColumnDefinition(name: 'email', type: SQType.text, isNotNull: true),
      ],
    ),
    // Posts table
    TableDefinition(
      name: 'posts',
      columns: const [
        ColumnDefinition(name: 'id', type: SQType.integer, isPrimaryKey: true),
        ColumnDefinition(name: 'user_id', type: SQType.integer, isNotNull: true),
        ColumnDefinition(name: 'title', type: SQType.text, isNotNull: true),
        ColumnDefinition(name: 'content', type: SQType.text),
        ColumnDefinition(name: 'likes', type: SQType.integer, defaultValue: '0'),
      ],
    ),
  ],
);

// Insert user
await dbHelper.insert('users', {'username': 'alice', 'email': 'alice@example.com'});

// Insert post
await dbHelper.insert('posts', {'user_id': 1, 'title': 'Hello!', 'content': 'My first post'});

// Get all posts with usernames (raw query)
final postsWithUsers = await dbHelper.rawQuery('''
  SELECT posts.*, users.username FROM posts
  JOIN users ON posts.user_id = users.id
''');
```

### Example 3: E-commerce Product Database

```dart
final dbHelper = DatabaseHelper(
  dbName: 'shop.db',
  tables: [
    TableDefinition(
      name: 'products',
      columns: const [
        ColumnDefinition(name: 'id', type: SQType.integer, isPrimaryKey: true),
        ColumnDefinition(name: 'name', type: SQType.text, isNotNull: true),
        ColumnDefinition(name: 'price', type: SQType.real, isNotNull: true),
        ColumnDefinition(name: 'category', type: SQType.text),
        ColumnDefinition(name: 'stock', type: SQType.integer, defaultValue: '0'),
      ],
    ),
  ],
);

// Add products
await dbHelper.insert('products', {
  'name': 'Laptop',
  'price': 999.99,
  'category': 'Electronics',
  'stock': 10,
});

// Find products under $100 sorted by price
final affordableProducts = await dbHelper.rawQuery(
  'SELECT * FROM products WHERE price < 100 ORDER BY price DESC',
);

// Update stock
await dbHelper.update('products', {'stock': 20}, where: 'name = ?', whereArgs: ['Laptop']);

// Get stock summary by category
final stockByCategory = await dbHelper.rawQuery(
  'SELECT category, SUM(stock) as total FROM products GROUP BY category',
);
```

## 🏗️ Flutter App Integration

```dart
class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late DatabaseHelper dbHelper;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  void _initDatabase() {
    dbHelper = DatabaseHelper(
      dbName: 'app.db',
      tables: [...], // Your table definitions
    );
  }

  @override
  void dispose() {
    dbHelper.closeDatabase();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Your app code
  }
}
```

## 🔧 Advanced Tips

### Parameterized Queries (Prevent SQL Injection)

Always use `whereArgs` for dynamic values:

```dart
// ✅ Good - Safe from SQL injection
await dbHelper.update(
  'users',
  {'email': userInput},
  where: 'username = ?',
  whereArgs: [usernameInput],
);

// ❌ Bad - Vulnerable to SQL injection
await dbHelper.rawQuery(
  "SELECT * FROM users WHERE username = '$usernameInput'",
);
```

### Error Handling

```dart
try {
  await dbHelper.insert('users', {'username': 'alice', 'email': 'alice@example.com'});
} catch (e) {
  print('Error inserting user: $e');
}
```

### Batch Operations

```dart
final users = [
  {'username': 'alice', 'email': 'alice@example.com'},
  {'username': 'bob', 'email': 'bob@example.com'},
  {'username': 'charlie', 'email': 'charlie@example.com'},
];

for (var user in users) {
  await dbHelper.insert('users', user);
}
```

## 📋 API Reference

### DatabaseHelper

- **`DatabaseHelper(dbName, tables, version)`** - Initialize database
- **`Future<List<Map>> queryAll(tableName)`** - Get all records
- **`Future<int> insert(tableName, data)`** - Insert record
- **`Future<int> update(tableName, data, where, whereArgs)`** - Update records
- **`Future<int> delete(tableName, where, whereArgs)`** - Delete records
- **`Future<List<Map>> rawQuery(sql)`** - Execute raw SQL
- **`Future<void> closeDatabase()`** - Close database connection
- **`Future<void> resetDatabase()`** - Delete database file

### ColumnDefinition

- **`name`** - Column name (required)
- **`type`** - Data type: SQType.text, integer, real, blob (required)
- **`isPrimaryKey`** - Set as primary key with auto-increment
- **`isNotNull`** - Column cannot be NULL
- **`isUnique`** - Column values must be unique
- **`defaultValue`** - Default value for new records

### TableDefinition

- **`name`** - Table name (required)
- **`columns`** - List of ColumnDefinition objects (required)

## 🐛 Troubleshooting

**Q: Database file not being created?**
A: Make sure to call the database getter or any method that triggers `_initDB()`.

**Q: Getting "table already exists" error?**
A: The database is already initialized. Remove `publish_to: none` from pubspec.yaml if publishing.

**Q: How do I handle database migrations?**
A: Increment the `version` parameter in DatabaseHelper and handle migrations in `onCreate`.

## 📝 Publishing

To publish this package to pub.dev:

1. Remove `publish_to: none` in `pubspec.yaml`
2. Update version number following semantic versioning
3. Run `flutter pub publish --dry-run` to check for issues
4. Run `flutter pub publish` to publish

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

Contributions are welcome! Feel free to submit issues and pull requests.

## 👤 Author

Created by Nihal Mammad

---

Made with ❤️ for Flutter developers
# flexi_sqlite
