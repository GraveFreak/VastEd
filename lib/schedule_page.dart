import 'package:flutter/material.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.event),
            title: Text('Meeting with Team'),
            subtitle: Text('March 25, 2025 - 10:00 AM'),
          ),
          ListTile(
            leading: Icon(Icons.event),
            title: Text('Project Deadline'),
            subtitle: Text('April 5, 2025 - 5:00 PM'),
          ),
          ListTile(
            leading: Icon(Icons.event),
            title: Text('Evaluation Review'),
            subtitle: Text('April 10, 2025 - 2:00 PM'),
          ),
        ],
      ),
    );
  }
}
