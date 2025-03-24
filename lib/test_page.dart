import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'quiz_page.dart';

class TestPage extends StatefulWidget {
  final String topic;
  final int testCount;

  const TestPage({super.key, required this.topic, required this.testCount});

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  List<Map<String, dynamic>> tests = [];
  bool isLoading = true;
  final String hfToken = dotenv.env['HF_API_TOKEN'] ?? ""; // ✅ HF API Token from .env
  final String hfApiUrl = dotenv.env['HF_API_URL'] ?? ""; // ✅ HF Space API URL from .env

  @override
  void initState() {
    super.initState();
    _loadTestsFromJson();
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/${widget.topic}_tests.json');
  }

  Future<void> _loadTestsFromJson() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        String contents = await file.readAsString();
        List<dynamic> jsonData = json.decode(contents);
        setState(() {
          tests = List<Map<String, dynamic>>.from(jsonData);
          isLoading = false;
        });
        return;
      }
    } catch (e) {
      print("❌ Error loading tests: $e");
    }
    _generateTests();
  }

  Future<void> _saveTestsToJson() async {
    final file = await _localFile;
    await file.writeAsString(json.encode(tests));
  }

  Future<void> _generateTests() async {
    for (int i = 0; i < widget.testCount; i++) {
      String prompt = i == 0
          ? "Build an easiest level of quiz about ${widget.topic} containing 10 questions along with answers."
          : "Build a bit harder than this";

      Map<String, dynamic> test = await _fetchTestFromAI(prompt);
      if (test.isNotEmpty) {
        test['unlocked'] = i == 0; // ✅ First test is unlocked, others are locked
        tests.add(test);
        await _saveTestsToJson();
        setState(() {});
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<Map<String, dynamic>> _fetchTestFromAI(String prompt) async {
    try {
      final Uri requestUri = Uri.parse(hfApiUrl);

      final Map<String, dynamic> requestBody = {
        "data": [
          prompt,
          "Generate multiple-choice questions (MCQs) with four answer options from the given text. Indicate the correct answer.",
          512,
          0.7,
          0.95
        ]
      };

      final response = await http.post(
        requestUri,
        headers: {
          "Authorization": "Bearer $hfToken",
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        String eventId = jsonResponse["event_id"];

        await Future.delayed(const Duration(seconds: 2));

        return await _fetchResult(eventId);
      } else {
        print("❌ Error: ${response.statusCode} - ${response.body}");
        return {};
      }
    } catch (e) {
      print("🚨 API Request Failed: $e");
      return {};
    }
  }

  Future<Map<String, dynamic>> _fetchResult(String eventId) async {
    final Uri resultUri = Uri.parse("$hfApiUrl/result/$eventId");

    for (int attempt = 0; attempt < 10; attempt++) {
      try {
        final response = await http.get(resultUri, headers: {
          "Authorization": "Bearer $hfToken",
        });

        if (response.statusCode == 200 && response.body.contains("data:")) {
          String jsonString = response.body.split("data:")[1].trim();
          return jsonDecode(jsonString);
        }
      } catch (e) {
        print("🚨 Result Fetch Failed: $e");
      }

      await Future.delayed(const Duration(seconds: 2));
    }

    print("❌ Fetching result failed after multiple attempts.");
    return {};
  }

  void _onTestTap(int index) {
    if (!tests[index]['unlocked']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Complete Previous Tests First")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizPage(questions: tests[index]['questions']),
      ),
    ).then((passed) async {
      if (passed == true && index + 1 < tests.length) {
        setState(() {
          tests[index + 1]['unlocked'] = true;
        });
        await _saveTestsToJson();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test Series: ${widget.topic}')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: tests.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(tests[index]['title']),
              trailing: tests[index]['unlocked']
                  ? const Icon(Icons.play_arrow, color: Colors.green)
                  : const Icon(Icons.lock, color: Colors.grey),
              onTap: () => _onTestTap(index),
            ),
          );
        },
      ),
    );
  }
}