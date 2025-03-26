import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';  // Import dotenv

class QuizService {
  final String apiUrl = dotenv.env['HF_API_URL'] ?? "";  // Fetch API URL from .env
  final String hfToken = dotenv.env['HF_API_TOKEN'] ?? "";  // Fetch API token from .env

  /// ✅ Fetches quiz from Hugging Face API
  Future<List<Map<String, dynamic>>> fetchQuiz(String topic) async {
    try {
      debugPrint("🔹 Sending API request to: $apiUrl");
      debugPrint("📢 Quiz Topic: $topic");

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $hfToken",
        },
        body: jsonEncode({
          "data": [
            topic,
            "You are a friendly chatbot that generates quizzes.",
            2048,
            0.7,
            0.95
          ]
        }),
      );

      debugPrint("🟢 API Response Status: ${response.statusCode}");
      debugPrint("📩 API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        if (decodedResponse.containsKey("event_id")) {
          String eventId = decodedResponse["event_id"];
          debugPrint("⏳ Waiting for quiz results... Event ID: $eventId");
          return await _fetchResult(eventId);
        } else {
          throw Exception("Unexpected API response format.");
        }
      } else {
        debugPrint("❌ API Error: ${response.body}");
        throw Exception("Failed to fetch quiz. Status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("⚠️ Exception: $e");
      throw Exception("Error fetching quiz: $e");
    }
  }

  /// ✅ Fetches the result after processing completes
  Future<List<Map<String, dynamic>>> _fetchResult(String eventId) async {
    final resultUrl = "https://dgsr2809-quiz.hf.space/gradio_api/call/predict/$eventId";

    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        await Future.delayed(Duration(seconds: 15));
        debugPrint("🔄 Fetching results from: $resultUrl");

        final response = await http.get(
          Uri.parse(resultUrl),
          headers: {
            "Authorization": "Bearer $hfToken"
          },
        );

        debugPrint("🟢 Result Response Status: ${response.statusCode}");
        debugPrint("📩 Result Response Body: ${response.body}");

        if (response.statusCode == 200) {
          String responseBody = response.body;

          // ✅ Extract actual quiz data (removes 'event: complete' & 'data:')
          RegExp dataRegex = RegExp(r'data:\s*(\[".*"\])', dotAll: true);
          Match? match = dataRegex.firstMatch(responseBody);

          if (match != null) {
            String extractedData = match.group(1)!;
            List<dynamic> parsedList = jsonDecode(extractedData);
            String quizText = parsedList[0];

            debugPrint("✅ Extracted Quiz Data: $quizText");
            return parseQuizData(quizText);
          } else {
            debugPrint("⚠️ Still processing... Retrying in 5s");
          }
        }
      } catch (e) {
        debugPrint("⚠️ Exception while fetching result: $e");
      }
    }
    throw Exception("Quiz generation timed out.");
  }

  /// ✅ Parses the string response into structured List<Map<String, dynamic>>
  List<Map<String, dynamic>> parseQuizData(String responseText) {
    List<Map<String, dynamic>> quizList = [];
    List<String> lines = responseText.split("\n");

    Map<String, dynamic>? currentQuestion;

    for (var line in lines) {
      line = line.trim();

      if (RegExp(r'^\d+\.\s').hasMatch(line)) {
        currentQuestion = {
          "question": line.replaceAll(RegExp(r'^\d+\.\s'), ''),
          "options": [],
          "correctAnswer": "",
        };
        quizList.add(currentQuestion);
      } else if (RegExp(r'^[A-D]\)').hasMatch(line) && currentQuestion != null) {
        currentQuestion["options"].add(line);

        if (line.contains("✅ Correct Answer: [")) {
          RegExp correctAnswerRegex = RegExp(r"✅ Correct Answer: \[([A-D])\]");
          Match? match = correctAnswerRegex.firstMatch(line);
          if (match != null) {
            String correctLetter = match.group(1)!;
            for (var option in currentQuestion["options"]) {
              if (option.startsWith(correctLetter)) {
                currentQuestion["correctAnswer"] = option;
                break;
              }
            }
          }
        }
      }
    }
    debugPrint("🎯 Final Parsed Quiz Data: $quizList");
    return quizList;
  }
}
