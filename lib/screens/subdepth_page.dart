import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hive/hive.dart';
import '/ai_services.dart';
import 'locker_screen.dart';


class SubDepthPage extends StatefulWidget {
  final String title;
  final AIService aiService;

  const SubDepthPage({super.key, required this.title, required this.aiService});

  @override
  _SubDepthPageState createState() => _SubDepthPageState();
}

class _SubDepthPageState extends State<SubDepthPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlutterTts _flutterTts = FlutterTts();
  List<Map<String, String>> chatHistory = [];
  bool _isSpeaking = false;
  late Box sessionBox;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  // ✅ Open Hive Box
  Future<void> _openBox() async {
    sessionBox = await Hive.openBox('chat_sessions');
    _loadLastSession();
  }

  // ✅ Load last saved session
  void _loadLastSession() {
    final savedChats = sessionBox.get(widget.title);
    if (savedChats != null) {
      setState(() {
        chatHistory = List<Map<String, String>>.from(savedChats);
      });
    }
  }

  // ✅ Save current session
  void _saveSession() async {
    await sessionBox.put(widget.title, chatHistory);

    // Save to global session list
    List<Map<String, dynamic>> sessions =
        sessionBox.get("SubDepth", defaultValue: [])?.cast<Map<String, dynamic>>() ?? [];

    bool sessionExists = sessions.any((session) => session['title'] == widget.title);
    if (!sessionExists) {
      sessions.add({"title": widget.title, "messages": chatHistory.map((msg) => msg["content"]!).toList()});
      await sessionBox.put("SubDepth", sessions);
    }
  }

  // ✅ Show history pop-up
  Future<void> _showHistoryDialog(BuildContext context) async {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.topCenter,
          child: Material(
            color: Colors.transparent,
            child: FractionallySizedBox(
              heightFactor: 0.3, // 30% of the screen
              widthFactor: 1.0,
              child: LockerScreen(title: "Chat History"),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1), // Start from top
            end: Offset.zero,
          ).animate(anim1),
          child: child,
        );
      },
    );
  }




  // ✅ Load a selected session
  void _loadSession(List<dynamic> messages) {
    setState(() {
      chatHistory = messages.map((msg) => {"role": "ai", "content": msg.toString()}).toList();
    });
  }

  // ✅ Speak AI Response
  Future<void> _speak(String text) async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      setState(() => _isSpeaking = false);
    } else {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.3);
      await _flutterTts.speak(text);
      setState(() => _isSpeaking = true);
      _flutterTts.setCompletionHandler(() => setState(() => _isSpeaking = false));
    }
  }

  // ✅ Send prompt to AI
  void _sendPrompt() async {
    if (_controller.text.trim().isEmpty) return;

    String userPrompt = _controller.text.trim();
    _controller.clear();

    setState(() {
      chatHistory.add({"role": "user", "content": userPrompt});
    });

    List<Map<String, String>> recentMessages = chatHistory.length > 5
        ? chatHistory.sublist(chatHistory.length - 5)
        : List.from(chatHistory);

    String formattedChat = recentMessages
        .map((msg) => "${msg['role']}: ${msg['content']}")
        .join("\n");

    try {
      String response = await widget.aiService.sendMessage(formattedChat);

      setState(() {
        chatHistory.add({"role": "ai", "content": response});
      });

      _saveSession();
    } catch (e) {
      setState(() {
        chatHistory.add({"role": "ai", "content": "❌ Error: Unable to generate response"});
      });
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), actions: [
        IconButton(
          icon: const Icon(Icons.history, color: Colors.white),
          onPressed: () => _showHistoryDialog(context),
        ),
      ]),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: chatHistory.length,
              itemBuilder: (context, index) {
                final message = chatHistory[index];
                bool isUser = message["role"] == "user";

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.blue[200] : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(message["content"]!),
                      ),
                      if (!isUser)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(Icons.volume_up, color: Colors.blue),
                            onPressed: () => _speak(message["content"]!),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          // ✅ Input Box
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type your message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendPrompt,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
