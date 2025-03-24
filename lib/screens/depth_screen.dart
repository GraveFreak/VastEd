import 'package:flutter/material.dart';
import 'subdepth_page.dart'; // Import the new page
import '/ai_services.dart'; // Import AI service classes

class DepthScreen extends StatelessWidget {
  const DepthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> subDepthItems = [
      {"title": "MathsGrave", "info": "Trigonometry & Calculus", "service": MathsGraveAI()},
      {"title": "HistoryGrave", "info": "History & Historians", "service": HistoryGraveAI()},
      {"title": "GeographyGrave", "info": "Plains & Mountains", "service": GeographyGraveAI()},
      {"title": "EconomicGrave", "info": "Cash & Card", "service": EconomicGraveAI()},
      {"title": "PoliticalGrave", "info": "Democracy & Constitution", "service": PoliticalGraveAI()},
      {"title": "PhysicsGrave", "info": "Rocket & Science", "service": PhysicsGraveAI()},
      {"title": "ChemistryGrave", "info": "Red+Blue=Pink", "service": ChemistryGraveAI()},
      {"title": "BiologyGrave", "info": "Organs & Blood", "service": BiologyGraveAI()},
      {"title": "AIGrave", "info": "Neurons & Networks", "service": AIGraveAI()},
      {"title": "MLGrave", "info": "Models & Predictions", "service": MLGraveAI()},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Depth'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 30),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔥 Search Bar
              Container(
                height: 40,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: "Search...",
                    border: InputBorder.none,
                    icon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 🔥 Recently Used Section
              const Text(
                "Recently Used",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: SizedBox(
                  height: 150,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    itemBuilder: (context, index) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(140, 140),
                        ),
                        onPressed: () {},
                        child: Text("Item ${index + 1}"),
                      );
                    },
                    separatorBuilder: (context, index) => const SizedBox(width: 15),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 🔥 SubDepth Section
              const Text(
                "SubDepth",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemCount: subDepthItems.length,
                itemBuilder: (context, index) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(10),
                    ),
                    onPressed: () {
                      // Navigate to SubDepthPage with the selected AIService
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubDepthPage(
                            title: subDepthItems[index]["title"]!,
                            aiService: subDepthItems[index]["service"],
                          ),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          subDepthItems[index]["title"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          subDepthItems[index]["info"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
