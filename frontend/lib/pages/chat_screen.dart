import "package:flutter/material.dart";
import "package:web_socket_channel/web_socket_channel.dart";
import "package:web_socket_channel/status.dart" as status;
import "dart:convert";
import "package:http/http.dart" as http;

class ChatScreen extends StatefulWidget {
  final String me;
  final String username;
  final String name;
  final String token;

  const ChatScreen({
    super.key,
    required this.me,
    required this.username,
    required this.name,
    required this.token,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController(); // Add this
  late WebSocketChannel _channel;

  @override
  void initState() {
    super.initState();
    _fetchOldMessages();
    _connectWebSocket();
  }

  Future<void> _fetchOldMessages() async {
    final url = Uri.parse(
      "http://127.0.0.1:8000/messages/${widget.me}/${widget.username}",
    );
    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer ${widget.token}"},
    );

    if (response.statusCode == 200) {
      final List<dynamic> messages = jsonDecode(response.body);
      setState(() {
        _messages.addAll(
          messages.map(
            (msg) => {
              "text": msg["message"] ?? msg["response"],
              "isMe": msg.containsKey("message"),
            },
          ),
        );
      });
      _scrollToBottom(); // Scroll after fetching messages
    }
  }

  void _connectWebSocket() {
    _channel = WebSocketChannel.connect(
      Uri.parse("ws://127.0.0.1:8000/ws/${widget.token}"),
    );

    _channel.stream.listen((message) {
      final decodedMessage = jsonDecode(message);
      setState(() {
        _messages.add({
          "text": decodedMessage["message"] ?? decodedMessage["response"],
          "isMe": decodedMessage.containsKey("message"),
        });
      });
      _scrollToBottom(); // Scroll when a new message arrives
    });
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final messageData = jsonEncode({
      "sender": widget.me,
      "receiver": widget.username,
      "message": _controller.text,
    });

    _channel.sink.add(messageData);
    setState(() {
      _messages.add({"text": _controller.text, "isMe": true});
    });
    _controller.clear();
    _scrollToBottom(); // Scroll after sending message
  }

  @override
  void dispose() {
    _channel.sink.close(status.goingAway);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // Attach controller
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message["isMe"];

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: 0.75,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.green[300] : Colors.blue[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        message["text"],
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.green),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
