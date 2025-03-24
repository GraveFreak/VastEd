import 'package:flutter/material.dart';

class UpdatesPage extends StatelessWidget {
  const UpdatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Updates')),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.update),
            title: Text('New Feature Released'),
            subtitle: Text('Dark mode is now available!'),
          ),
          ListTile(
            leading: Icon(Icons.update),
            title: Text('Bug Fixes'),
            subtitle: Text('Fixed login issues and improved performance.'),
          ),
          ListTile(
            leading: Icon(Icons.update),
            title: Text('Upcoming Maintenance'),
            subtitle: Text('Scheduled maintenance on March 30, 2025.'),
          ),
        ],
      ),
    );
  }
}
