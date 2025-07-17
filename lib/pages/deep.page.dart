import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DeepSeekPage extends StatefulWidget {
  DeepSeekPage({super.key});

  @override
  State<DeepSeekPage> createState() => _DeepSeekPageState();
}

class _DeepSeekPageState extends State<DeepSeekPage> {
  TextEditingController userController = TextEditingController();
  TextEditingController apiUriController =
      TextEditingController(text: "https://api.deepseek.com");
  TextEditingController apiKeyController = TextEditingController();

  ScrollController scrollController = ScrollController();
  var messages = [
    {"role": "user", "content": "Bonjour"},
    {"role": "assistant", "content": "Bienvenue que puis-je faire pour vous"},
  ];

  bool _showApiFields = false;
  bool _isLoading = false;

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (userController.text.isEmpty) return;

    final question = userController.text;

    setState(() {
      _isLoading = true;
      messages.add({"role": "user", "content": question});
    });

    _scrollToBottom();

    try {
      final uri = Uri.parse(apiUriController.text);
      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${apiKeyController.text}"
      };

      final body = {"model": "deepseek-chat", "messages": messages};

      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final aiResponse = json.decode(response.body);
        final answer = aiResponse['choices'][0]['message']['content'];

        setState(() {
          messages.add({"role": "assistant", "content": answer});
        });
      } else {
        setState(() {
          messages.add({
            "role": "assistant",
            "content":
                "Erreur: ${response.statusCode} - ${response.reasonPhrase}"
          });
        });
      }
    } catch (e) {
      setState(() {
        messages
            .add({"role": "assistant", "content": "Erreur de connexion: $e"});
      });
    } finally {
      setState(() {
        _isLoading = false;
        userController.clear();
        _scrollToBottom();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "LLM Chatbot",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _showApiFields = !_showApiFields;
              });
            },
            icon: Icon(
              Icons.settings,
              color: Colors.white,
            ),
            tooltip: 'Configurer l\'API',
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, "/dashboard");
            },
            icon: Icon(
              Icons.logout,
              color: Colors.white,
            ),
            tooltip: 'Retour au dashboard',
          )
        ],
      ),
      body: Column(
        children: [
          // Section de configuration API (visible seulement quand activée)
          if (_showApiFields) ...[
            Container(
              padding: EdgeInsets.all(12),
              color: Colors.teal.shade50,
              child: Column(
                children: [
                  Text(
                    "Configuration API",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.teal,
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: apiUriController,
                    decoration: InputDecoration(
                      labelText: "URI de l'API",
                      hintText: "https://api.example.com/endpoint",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.link),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: apiKeyController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Clé API",
                      hintText: "Entrez votre clé secrète",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.key),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showApiFields = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                    child: Text("Enregistrer et masquer"),
                  ),
                ],
              ),
            ),
            Divider(height: 1),
          ],

          // Historique de chat
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final isUser = messages[index]['role'] == 'user';

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUser
                            ? Colors.teal.shade100
                            : Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        messages[index]['content']!,
                        style: TextStyle(
                          color: isUser
                              ? Colors.teal.shade900
                              : Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Indicateur de chargement
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: CircularProgressIndicator(color: Colors.teal),
            ),

          // Zone de saisie
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: userController,
                    decoration: InputDecoration(
                      hintText: "Tapez votre message ici...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      filled: true,
                      fillColor: Colors.teal.shade50,
                    ),
                    onFieldSubmitted: (_) => _sendMessage(),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
