import 'package:deepseek_chatbot_app/pages/dashboard.page.dart';
import 'package:deepseek_chatbot_app/pages/deep.page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        "/deepbot": (context) => DeepSeekPage(),
        "/dashboard": (context) => DashboardPage()
      },
      title: 'Flutter Demo',
      theme: ThemeData(primaryColor: Colors.teal),
      home: DashboardPage(),
    );
  }
}
