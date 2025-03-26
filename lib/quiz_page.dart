import 'package:flutter/material.dart';
import 'quiz_service.dart';

class QuizPage extends StatefulWidget {
  final String topic;

  const QuizPage({super.key, required this.topic});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late Future<List<Map<String, dynamic>>> _quizFuture;
  List<Map<String, dynamic>> _quizData = [];
  int _currentQuestionIndex = 0;
  String? _selectedAnswer;
  bool _isLoading = true;
  bool _showResult = false;
  int _score = 0;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _fetchQuiz();
  }

  void _fetchQuiz() {
    setState(() {
      _quizFuture = QuizService().fetchQuiz(widget.topic);
    });

    _quizFuture.then((quiz) {
      if (quiz.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No quiz available for this topic.")),
        );
      }
      setState(() {
        _quizData = quiz;
        _isLoading = false;
      });
    }).catchError((error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load quiz. Please try again.")),
      );
    });
  }

  void _nextQuestion() {
    if (_answered) {
      if (_currentQuestionIndex < _quizData.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _selectedAnswer = null;
          _answered = false;
        });
      } else {
        setState(() {
          _showResult = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Quiz on ${widget.topic}")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _showResult
          ? _buildResultView()
          : _quizData.isEmpty
          ? const Center(child: Text("No quiz available."))
          : _buildQuizView(),
    );
  }

  Widget _buildQuizView() {
    var questionData = _quizData[_currentQuestionIndex];
    List<String> rawOptions = List<String>.from(questionData["options"]);
    List<String> options = rawOptions.map((e) => e.replaceAll(RegExp(r"✅ Correct Answer: \[.*?\]"), "").trim()).toList();

    String correctAnswer = questionData["correctAnswer"];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Question ${_currentQuestionIndex + 1}/${_quizData.length}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(questionData["question"], style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 20),
          Column(
            children: options.map((option) {
              bool isSelected = _selectedAnswer == option;
              bool isCorrect = option == correctAnswer;

              Color cardColor = Colors.white;
              if (_answered) {
                if (isSelected && isCorrect) {
                  cardColor = Colors.green;
                } else if (isSelected && !isCorrect) {
                  cardColor = Colors.red;
                } else if (isCorrect) {
                  cardColor = Colors.green;
                }
              }

              return GestureDetector(
                onTap: _answered
                    ? null
                    : () {
                  setState(() {
                    _selectedAnswer = option;
                    _answered = true;
                    if (isCorrect) {
                      _score++;
                    }
                  });
                },
                child: Card(
                  color: cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Colors.black, width: 1),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Center(
                      child: Text(
                        option,
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          if (_answered)
            Text(
              "Correct Answer: $correctAnswer",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
            ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _answered ? _nextQuestion : null,
            child: Text(_currentQuestionIndex < _quizData.length - 1 ? "Next" : "Finish"),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Quiz Completed!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text("Your Score: $_score / ${_quizData.length}",
                style: const TextStyle(fontSize: 18, color: Colors.blue)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showResult = false;
                  _currentQuestionIndex = 0;
                  _score = 0;
                  _selectedAnswer = null;
                  _answered = false;
                });
              },
              child: const Text("Restart Quiz"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Back to Home"),
            ),
          ],
        ),
      ),
    );
  }
}
