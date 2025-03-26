import 'package:flutter/material.dart';
import 'quiz_page.dart'; // ✅ Import QuizPage
import 'quiz_service.dart'; // ✅ Import QuizService

class TestPage extends StatefulWidget {
  final String topic;
  final int testCount;

  const TestPage({super.key, required this.topic, required this.testCount});

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final QuizService _quizService = QuizService();
  bool _isLoading = false;

  // ✅ Function to fetch quiz and navigate to QuizPage
  void _startTest(int testNumber) async {
    setState(() => _isLoading = true);

    try {
      final quizData = await _quizService.fetchQuiz(widget.topic);

      if (!mounted) return; // Avoid state updates if widget is disposed

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizPage(topic: widget.topic),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load quiz: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Series'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Topic: ${widget.topic}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Number of Tests: ${widget.testCount}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: widget.testCount,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text('Test ${index + 1}'),
                      subtitle: Text('Test based on "${widget.topic}"'),
                      trailing: const Icon(Icons.play_arrow),
                      onTap: () => _startTest(index + 1), // ✅ Fetch quiz and navigate
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
