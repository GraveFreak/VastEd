import 'package:flutter/material.dart';
import 'test_page.dart'; // Import TestPage

class BuildTestBottomSheet extends StatefulWidget {
  const BuildTestBottomSheet({super.key});

  @override
  _BuildTestBottomSheetState createState() => _BuildTestBottomSheetState();
}

class _BuildTestBottomSheetState extends State<BuildTestBottomSheet> {
  final TextEditingController _topicController = TextEditingController();
  int? _selectedTestCount; // Stores selected test count
  String? _errorMessage;

  // Validate input and navigate to TestPage
  void _makeTestSeries() {
    String topic = _topicController.text.trim();

    if (topic.isEmpty) {
      setState(() {
        _errorMessage = "Please enter a test topic.";
      });
      return;
    }

    // Limit to 10 words
    List<String> words = topic.split(" ");
    if (words.length > 10) {
      setState(() {
        _errorMessage = "Topic cannot exceed 10 words.";
      });
      return;
    }

    if (_selectedTestCount == null) {
      setState(() {
        _errorMessage = "Please select the number of tests.";
      });
      return;
    }

    // Navigate to TestPage with the selected values
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestPage(topic: topic, testCount: _selectedTestCount!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Indicator
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Text Field for Topic Input
          TextField(
            controller: _topicController,
            decoration: InputDecoration(
              labelText: 'Enter test topic (max 10 words)',
              border: OutlineInputBorder(),
              errorText: _errorMessage,
            ),
          ),
          const SizedBox(height: 20),

          // Select Number of Tests
          const Text(
            'Select number of tests:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [1, 2, 3].map((count) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTestCount = count;
                    _errorMessage = null; // Clear error when selecting
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    color: _selectedTestCount == count ? Colors.blue : Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "$count Tests",
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedTestCount == count ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Button to Create Test Series
          ElevatedButton(
            onPressed: _makeTestSeries,
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            child: const Text('Make My Test Series'),
          ),
        ],
      ),
    );
  }
}
