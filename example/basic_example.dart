import 'package:flexi_sqlite/flexi_sqlite.dart';

/// Basic example demonstrating simple CRUD operations
Future<void> basicExample() async {
  // Step 1: Define database schema
  final dbHelper = DatabaseHelper(
    dbName: 'simple_app.db',
    tables: [
      TableDefinition(
        name: 'users',
        columns: const [
          ColumnDefinition(
            name: 'id',
            type: SQType.integer,
            isPrimaryKey: true,
          ),
          ColumnDefinition(
            name: 'username',
            type: SQType.text,
            isNotNull: true,
            isUnique: true,
          ),
          ColumnDefinition(
            name: 'email',
            type: SQType.text,
            isNotNull: true,
          ),
        ],
      ),
    ],
  );

  // Step 2: Insert data
  await dbHelper.insert('users', {
    'username': 'john_doe',
    'email': 'john@example.com',
  });

  // Step 3: Query all records
  final users = await dbHelper.queryAll('users');
  print('All users: $users');

  // Step 4: Update a record
  await dbHelper.update(
    'users',
    {'email': 'john.new@example.com'},
    where: 'id = ?',
    whereArgs: [1],
  );

  // Step 5: Delete a record
  await dbHelper.delete('users', where: 'id = ?', whereArgs: [1]);

  // Step 6: Close database when done
  await dbHelper.closeDatabase();
}
