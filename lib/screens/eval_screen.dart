import 'package:flutter/material.dart';
import '/progress_page.dart';
import '/schedule_page.dart';
import '/updates_page.dart';
import '/build_test.dart'; // Import BuildTestPage

class EvalScreen extends StatefulWidget {
  const EvalScreen({super.key});

  @override
  _EvalScreenState createState() => _EvalScreenState();
}

class _EvalScreenState extends State<EvalScreen> {
  bool _isMenuOpen = false;

  void _navigateToPage(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  // Show Bottom Sheet
  void _showBuildTestBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows it to take half screen
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const BuildTestBottomSheet(), // Bottom Sheet Content
    );
  }

  @override
  Widget build(BuildContext context) {
    double menuHeight = MediaQuery.of(context).size.height * 0.3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eval', style: TextStyle(fontSize: 24)),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              setState(() {
                _isMenuOpen = !_isMenuOpen;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Test Series',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),

              // Horizontal Scrollable Grid
              SizedBox(
                height: 150,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _newTestSeriesCard(), // Open Bottom Sheet on Tap
                  ],
                ),
              ),
            ],
          ),

          // Slide-down menu
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: _isMenuOpen ? 0 : -menuHeight,
            left: 0,
            right: 0,
            height: menuHeight,
            child: Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _menuItem(Icons.bar_chart, "Progress", () => _navigateToPage(const ProgressPage())),
                    _menuItem(Icons.schedule, "Schedule", () => _navigateToPage(const SchedulePage())),
                    _menuItem(Icons.update, "Updates", () => _navigateToPage(const UpdatesPage())),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: Colors.blue),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _newTestSeriesCard() {
    return GestureDetector(
      onTap: _showBuildTestBottomSheet, // Open Bottom Sheet on Tap
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(left: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.lightBlue[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'Join A New Test Series',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
