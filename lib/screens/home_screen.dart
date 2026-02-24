import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import '../models/task.dart';
import 'post_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> tasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFromLocal();   // Load cached data first
    fetchTasks();      // Then try fetching from API
  }

  // ---------------- FETCH FROM API ----------------

  Future<void> fetchTasks() async {
  final box = Hive.box('tasksBox');

  try {
    final response = await http.get(
  Uri.parse('https://jsonplaceholder.typicode.com/todos'),
  headers: {
    "Accept": "application/json",
  },
    );

    print("STATUS: ${response.statusCode}");

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);

      List<Task> fetchedTasks = data
          .take(20)
          .map((json) => Task.fromJson(json))
          .toList();

      print("Fetched: ${fetchedTasks.length}");

      await box.put(
        'tasks',
        fetchedTasks.map((task) => task.toJson()).toList(),
      );

      setState(() {
        tasks = fetchedTasks;
      });
    }
  } catch (e) {
    print("ERROR: $e");
  }

  // ALWAYS load from local if tasks empty
  if (tasks.isEmpty) {
    final cachedData = box.get('tasks');

    if (cachedData != null) {
      tasks = (cachedData as List)
          .map((json) => Task.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      print("Loaded from cache: ${tasks.length}");
    } else {
      print("No cache found");
    }
  }

  setState(() {
    isLoading = false;
  });
}

  // ---------------- LOAD FROM LOCAL ----------------

  void loadFromLocal() {
    final box = Hive.box('tasksBox');
    List? savedTasks = box.get('tasks');

    if (savedTasks != null) {
      tasks = savedTasks
          .map((json) =>
              Task.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    }
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Field Service Reporter"),
        actions: [
          IconButton(
            icon: const Icon(Icons.note_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PostScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
              ? const Center(child: Text("No tasks available"))
              : ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];

                    return ListTile(
                      title: Text(task.title),
                      trailing: Icon(
                        task.completed
                            ? Icons.check_circle
                            : Icons.access_time,
                        color: task.completed
                            ? Colors.green
                            : Colors.red,
                      ),
                    );
                  },
                ),
    );
  }
}