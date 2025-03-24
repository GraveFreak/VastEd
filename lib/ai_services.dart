import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// 🔥 Base AI Service Class
class AIService {
  final String apiUrl;
  final String hfToken;

  AIService(this.apiUrl, this.hfToken);

  Future<String> sendMessage(String message) async {
    final Uri uri = Uri.parse("$apiUrl/gradio_api/call/predict");

    final Map<String, dynamic> data = {
      "data": [message, "You are a friendly Chatbot.", 512, 0.7, 0.95]
    };

    final Map<String, String> headers = {
      "Authorization": "Bearer $hfToken",
      "Content-Type": "application/json"
    };

    print("📝 [REQUEST] Sending POST request to: $uri");

    try {
      final response = await http.post(uri, headers: headers, body: jsonEncode(data));

      print("🔹 [RESPONSE] Status Code: ${response.statusCode}");
      print("🔹 [RESPONSE] Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        String eventId = jsonResponse["event_id"];
        print("🚀 [EVENT ID] Received: $eventId");

        // Wait 1 second before fetching result
        await Future.delayed(Duration(seconds: 1));

        return await _fetchResult(eventId);
      } else {
        return "❌ Error ${response.statusCode}: ${response.body}";
      }
    } catch (e) {
      print("❌ [ERROR] Exception: $e");
      return "❌ Exception: $e";
    }
  }

  Future<String> _fetchResult(String eventId) async {
    final Uri resultUri = Uri.parse("$apiUrl/gradio_api/call/predict/$eventId");

    print("📝 [RESULT] Fetching result from: $resultUri");

    try {
      final response = await http.get(resultUri, headers: {
        "Authorization": "Bearer $hfToken"
      });

      print("🔹 [RESULT] Status Code: ${response.statusCode}");
      print("🔹 [RESULT] Body: ${response.body}");

      if (response.statusCode == 200) {
        final resultText = response.body;

        // ✅ Extract JSON part from response
        final jsonStartIndex = resultText.indexOf("data: ");
        if (jsonStartIndex == -1) {
          return "❌ Error: No 'data:' found in response";
        }

        final jsonPart = resultText.substring(jsonStartIndex + 5).trim();
        final jsonResponse = jsonDecode(jsonPart);
        return jsonResponse[0]; // ✅ Extract AI response
      } else {
        return "❌ Error fetching result: ${response.body}";
      }
    } catch (e) {
      print("❌ [ERROR] Exception: $e");
      return "❌ Exception: $e";
    }
  }
}

// 🔥 Different AI Models for Each Subject, Using .env Variables

class MathsGraveAI extends AIService {
  MathsGraveAI() : super(dotenv.env['MATHS_AI_URL'] ?? '', dotenv.env['MATHS_AI_TOKEN'] ?? '');
}

class HistoryGraveAI extends AIService {
  HistoryGraveAI() : super(dotenv.env['HISTORY_AI_URL'] ?? '', dotenv.env['HISTORY_AI_TOKEN'] ?? '');
}

class GeographyGraveAI extends AIService {
  GeographyGraveAI() : super(dotenv.env['GEOGRAPHY_AI_URL'] ?? '', dotenv.env['GEOGRAPHY_AI_TOKEN'] ?? '');
}

class EconomicGraveAI extends AIService {
  EconomicGraveAI() : super(dotenv.env['ECONOMIC_AI_URL'] ?? '', dotenv.env['ECONOMIC_AI_TOKEN'] ?? '');
}

class PoliticalGraveAI extends AIService {
  PoliticalGraveAI() : super(dotenv.env['POLITICAL_AI_URL'] ?? '', dotenv.env['POLITICAL_AI_TOKEN'] ?? '');
}

class PhysicsGraveAI extends AIService {
  PhysicsGraveAI() : super(dotenv.env['PHYSICS_AI_URL'] ?? '', dotenv.env['PHYSICS_AI_TOKEN'] ?? '');
}

class ChemistryGraveAI extends AIService {
  ChemistryGraveAI() : super(dotenv.env['CHEMISTRY_AI_URL'] ?? '', dotenv.env['CHEMISTRY_AI_TOKEN'] ?? '');
}

class BiologyGraveAI extends AIService {
  BiologyGraveAI() : super(dotenv.env['BIOLOGY_AI_URL'] ?? '', dotenv.env['BIOLOGY_AI_TOKEN'] ?? '');
}

class AIGraveAI extends AIService {
  AIGraveAI() : super(dotenv.env['AI_AI_URL'] ?? '', dotenv.env['AI_AI_TOKEN'] ?? '');
}

class MLGraveAI extends AIService {
  MLGraveAI() : super(dotenv.env['ML_AI_URL'] ?? '', dotenv.env['ML_AI_TOKEN'] ?? '');
}
