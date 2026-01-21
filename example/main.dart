import 'package:flutter/material.dart';
import 'package:flexi_sqlite/flexi_sqlite.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flexi SQLite Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DatabaseExampleScreen(),
    );
  }
}

class DatabaseExampleScreen extends StatefulWidget {
  const DatabaseExampleScreen({Key? key}) : super(key: key);

  @override
  State<DatabaseExampleScreen> createState() => _DatabaseExampleScreenState();
}

class _DatabaseExampleScreenState extends State<DatabaseExampleScreen> {
  late DatabaseHelper dbHelper;
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> tasks = [];

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final taskTitleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  void _initializeDatabase() async {
    // Define database schema
    dbHelper = DatabaseHelper(
      dbName: 'app_database.db',
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
            ),
            ColumnDefinition(
              name: 'created_at',
              type: SQType.text,
              defaultValue: "'2024-01-01'",
            ),
          ],
        ),
        // Tasks table
        TableDefinition(
          name: 'tasks',
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
              name: 'description',
              type: SQType.text,
            ),
            ColumnDefinition(
              name: 'is_completed',
              type: SQType.integer,
              defaultValue: "0",
            ),
          ],
        ),
      ],
    );

    // Load initial data
    await _loadUsers();
    await _loadTasks();
  }

  Future<void> _loadUsers() async {
    final result = await dbHelper.queryAll('users');
    setState(() {
      users = result;
    });
  }

  Future<void> _loadTasks() async {
    final result = await dbHelper.queryAll('tasks');
    setState(() {
      tasks = result;
    });
  }

  Future<void> _addUser() async {
    if (usernameController.text.isEmpty || emailController.text.isEmpty) {
      _showSnackbar('Please fill all fields');
      return;
    }

    try {
      await dbHelper.insert('users', {
        'username': usernameController.text,
        'email': emailController.text,
      });

      usernameController.clear();
      emailController.clear();
      await _loadUsers();
      _showSnackbar('User added successfully');
    } catch (e) {
      _showSnackbar('Error: $e');
    }
  }

  Future<void> _addTask(int userId) async {
    if (taskTitleController.text.isEmpty) {
      _showSnackbar('Please enter task title');
      return;
    }

    try {
      await dbHelper.insert('tasks', {
        'user_id': userId,
        'title': taskTitleController.text,
        'description': 'Sample task description',
        'is_completed': 0,
      });

      taskTitleController.clear();
      await _loadTasks();
      _showSnackbar('Task added successfully');
    } catch (e) {
      _showSnackbar('Error: $e');
    }
  }

  Future<void> _deleteUser(int id) async {
    try {
      await dbHelper.delete('users', where: 'id = ?', whereArgs: [id]);
      await _loadUsers();
      _showSnackbar('User deleted');
    } catch (e) {
      _showSnackbar('Error: $e');
    }
  }

  Future<void> _updateTask(int id, int isCompleted) async {
    try {
      await dbHelper.update(
        'tasks',
        {'is_completed': isCompleted == 0 ? 1 : 0},
        where: 'id = ?',
        whereArgs: [id],
      );
      await _loadTasks();
      _showSnackbar('Task updated');
    } catch (e) {
      _showSnackbar('Error: $e');
    }
  }

  Future<void> _resetDatabase() async {
    try {
      await dbHelper.resetDatabase();
      _initializeDatabase();
      _showSnackbar('Database reset successfully');
    } catch (e) {
      _showSnackbar('Error: $e');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Flexi SQLite Example'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Users'),
              Tab(text: 'Tasks'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                await _loadUsers();
                await _loadTasks();
                _showSnackbar('Data refreshed');
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _resetDatabase,
            ),
          ],
        ),
        body: TabBarView(
          children: [
            // Users Tab
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          hintText: 'Enter username',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          hintText: 'Enter email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _addUser,
                        child: const Text('Add User'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: users.isEmpty
                      ? const Center(child: Text('No users yet'))
                      : ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return ListTile(
                              title: Text(user['username']),
                              subtitle: Text(user['email']),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteUser(user['id']),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
            // Tasks Tab
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: taskTitleController,
                        decoration: const InputDecoration(
                          hintText: 'Enter task title',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: users.isEmpty
                            ? null
                            : () => _addTask(users[0]['id']),
                        child: const Text('Add Task'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: tasks.isEmpty
                      ? const Center(child: Text('No tasks yet'))
                      : ListView.builder(
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return CheckboxListTile(
                              title: Text(task['title']),
                              subtitle: Text(task['description'] ?? ''),
                              value: task['is_completed'] == 1,
                              onChanged: (_) =>
                                  _updateTask(task['id'], task['is_completed']),
                            );
                          },
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    taskTitleController.dispose();
    dbHelper.closeDatabase();
    super.dispose();
  }
}
