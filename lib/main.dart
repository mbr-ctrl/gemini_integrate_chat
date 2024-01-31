import 'package:flutter/material.dart';
import 'package:gemini_integrate_chat/pages/gemini_chat_page.dart';

import 'models/chat.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Integrate Gemini AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Intégration de Gemini AI'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<ChatModel> chatList = []; // Your list of ChatModel objects
  String apiKey = 'YOURAPIKEY';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(widget.title),
      ),
      body: FlutterGeminiChat(
        chatContext: 'Tu es un développeur front-end',
        chatList: chatList,
        apiKey: apiKey,
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
