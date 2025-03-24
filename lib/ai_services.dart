import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

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

// 🔥 Different AI Models for Each Subject

class MathsGraveAI extends AIService {
  MathsGraveAI() : super("https://mathsgrave.hf.space", "hf_MATHS_TOKEN_HERE");
}

class HistoryGraveAI extends AIService {
  HistoryGraveAI() : super("https://historygrave.hf.space", "hf_HISTORY_TOKEN_HERE");
}

class GeographyGraveAI extends AIService {
  GeographyGraveAI() : super("https://geographygrave.hf.space", "hf_GEOGRAPHY_TOKEN_HERE");
}

class EconomicGraveAI extends AIService {
  EconomicGraveAI() : super("https://economicgrave.hf.space", "hf_ECONOMIC_TOKEN_HERE");
}

class PoliticalGraveAI extends AIService {
  PoliticalGraveAI() : super("https://politicalgrave.hf.space", "hf_POLITICAL_TOKEN_HERE");
}

class PhysicsGraveAI extends AIService {
  PhysicsGraveAI() : super("https://waynebruce2110-gravescienceai.hf.space", "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");
}

class ChemistryGraveAI extends AIService {
  ChemistryGraveAI() : super("https://waynebruce2110-gravescienceai.hf.space", "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");
}

class BiologyGraveAI extends AIService {
  BiologyGraveAI() : super("https://waynebruce2110-gravescienceai.hf.space", "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");
}

class AIGraveAI extends AIService {
  AIGraveAI() : super("https://aigrave.hf.space", "hf_AI_TOKEN_HERE");
}

class MLGraveAI extends AIService {
  MLGraveAI() : super("https://machinelearninggrave.hf.space", "hf_ML_TOKEN_HERE");
}
