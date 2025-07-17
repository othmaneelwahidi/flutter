import 'package:flutter/material.dart';

import 'deep.page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Welcome to the LLM ChatBot App",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigation vers la page DeepSeek
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DeepSeekPage()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal, // Couleur d'arrière-plan
            foregroundColor: Colors.white, // Couleur du texte
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          child: const Text(
            "Talk to AI",
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
