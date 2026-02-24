import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final TextEditingController controller = TextEditingController();
  bool isSending = false;

  Future<void> sendNote() async {
    setState(() {
      isSending = true;
    });

    final response = await http.post(
      Uri.parse('https://jsonplaceholder.typicode.com/posts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'note': controller.text,
      }),
    );

    if (!mounted) return;

    setState(() {
      isSending = false;
    });

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Job Completed Successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to send data")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complete Job")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration:
                  const InputDecoration(labelText: "Technician Note"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isSending ? null : sendNote,
              child: isSending
                  ? const CircularProgressIndicator()
                  : const Text("Complete Job"),
            ),
          ],
        ),
      ),
    );
  }
}