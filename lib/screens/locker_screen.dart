import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class LockerScreen extends StatefulWidget {
  final String title;

  const LockerScreen({Key? key, required this.title}) : super(key: key);

  @override
  State<LockerScreen> createState() => _LockerScreenState();
}

class _LockerScreenState extends State<LockerScreen> {
  late Box sessionBox;

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    sessionBox = await Hive.openBox('sessionBox');
    setState(() {}); // Refresh UI after box is initialized
  }

  @override
  Widget build(BuildContext context) {
    if (!Hive.isBoxOpen('sessionBox')) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            widget.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: sessionBox.length,
              itemBuilder: (context, index) {
                final session = sessionBox.getAt(index);
                return ListTile(
                  title: Text(session.toString()),
                  onTap: () {
                    Navigator.pop(context, session);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
