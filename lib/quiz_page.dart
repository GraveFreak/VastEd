import 'package:flutter/material.dart';

class QuizPage extends StatefulWidget {
  final List<Map<String, dynamic>> questions;

  const QuizPage({super.key, required this.questions});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  bool isAnswered = false;
  String? selectedAnswer;

  void _checkAnswer(String answer) {
    if (isAnswered) return;
    setState(() {
      selectedAnswer = answer;
      isAnswered = true;
      if (answer == widget.questions[currentQuestionIndex]['answer']) {
        correctAnswers++;
      }
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (currentQuestionIndex + 1 < widget.questions.length) {
        setState(() {
          currentQuestionIndex++;
          isAnswered = false;
          selectedAnswer = null;
        });
      } else {
        _showResults();
      }
    });
  }

  void _showResults() {
    bool passed = correctAnswers > (widget.questions.length / 2);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(passed ? "Quiz Passed!" : "Quiz Failed"),
          content: Text("You got $correctAnswers/${widget.questions.length} correct."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, passed);
              },
              child: const Text("OK"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[currentQuestionIndex];
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(title: const Text("Quiz"), automaticallyImplyLeading: false),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(question['question'], style: const TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 20),
              ...question['options'].map<Widget>((option) {
                bool isCorrect = option == question['answer'];
                return GestureDetector(
                  onTap: () => _checkAnswer(option),
                  child: Card(
                    color: selectedAnswer == null
                        ? Colors.white
                        : selectedAnswer == option
                        ? isCorrect
                        ? Colors.green
                        : Colors.red
                        : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(option, style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
