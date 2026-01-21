import 'package:flexi_sqlite/flexi_sqlite.dart';

/// Advanced example with multiple tables and relationships
Future<void> advancedExample() async {
  // Define a more complex database schema
  final dbHelper = DatabaseHelper(
    dbName: 'advanced_app.db',
    tables: [
      // Users table
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
            isUnique: true,
          ),
          ColumnDefinition(
            name: 'age',
            type: SQType.integer,
          ),
          ColumnDefinition(
            name: 'created_at',
            type: SQType.text,
            defaultValue: "'2024-01-01'",
          ),
        ],
      ),
      // Posts table
      TableDefinition(
        name: 'posts',
        columns: const [
          ColumnDefinition(
            name: 'id',
            type: SQType.integer,
            isPrimaryKey: true,
          ),
          ColumnDefinition(
            name: 'user_id',
            type: SQType.integer,
            isNotNull: true,
          ),
          ColumnDefinition(
            name: 'title',
            type: SQType.text,
            isNotNull: true,
          ),
          ColumnDefinition(
            name: 'content',
            type: SQType.text,
          ),
          ColumnDefinition(
            name: 'likes',
            type: SQType.integer,
            defaultValue: '0',
          ),
        ],
      ),
      // Comments table
      TableDefinition(
        name: 'comments',
        columns: const [
          ColumnDefinition(
            name: 'id',
            type: SQType.integer,
            isPrimaryKey: true,
          ),
          ColumnDefinition(
            name: 'post_id',
            type: SQType.integer,
            isNotNull: true,
          ),
          ColumnDefinition(
            name: 'user_id',
            type: SQType.integer,
            isNotNull: true,
          ),
          ColumnDefinition(
            name: 'text',
            type: SQType.text,
            isNotNull: true,
          ),
        ],
      ),
    ],
  );

  // Insert multiple users
  await dbHelper.insert('users', {
    'username': 'alice',
    'email': 'alice@example.com',
    'age': 25,
  });

  await dbHelper.insert('users', {
    'username': 'bob',
    'email': 'bob@example.com',
    'age': 30,
  });

  // Insert posts for users
  await dbHelper.insert('posts', {
    'user_id': 1,
    'title': 'My First Post',
    'content': 'This is my first post on this platform!',
    'likes': 5,
  });

  await dbHelper.insert('posts', {
    'user_id': 2,
    'title': 'Hello World',
    'content': 'Welcome to my blog',
    'likes': 10,
  });

  // Add comments
  await dbHelper.insert('comments', {
    'post_id': 1,
    'user_id': 2,
    'text': 'Great post!',
  });

  // Query all posts
  final posts = await dbHelper.queryAll('posts');
  print('All posts: $posts');

  // Query all comments
  final comments = await dbHelper.queryAll('comments');
  print('All comments: $comments');

  // Update post likes
  await dbHelper.update(
    'posts',
    {'likes': 15},
    where: 'id = ?',
    whereArgs: [1],
  );

  // Use raw SQL for more complex queries
  final userPostCount = await dbHelper.rawQuery(
    'SELECT users.username, COUNT(posts.id) as post_count FROM users LEFT JOIN posts ON users.id = posts.user_id GROUP BY users.id',
  );
  print('User post count: $userPostCount');

  // Delete old comments
  await dbHelper.delete(
    'comments',
    where: 'post_id = ?',
    whereArgs: [1],
  );

  // Close database
  await dbHelper.closeDatabase();
}
