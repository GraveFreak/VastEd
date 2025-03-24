import 'package:flutter/material.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text('Your Progress Stats', style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
