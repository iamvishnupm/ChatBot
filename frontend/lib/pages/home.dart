import "dart:convert";
import "package:flutter/material.dart";
import "package:frontend/pages/chat_screen.dart";
import "package:http/http.dart" as http;
import "package:shared_preferences/shared_preferences.dart";
import "package:frontend/config.dart";
import "package:frontend/components/theme_button.dart";

class ChatAppHome extends StatefulWidget {
  const ChatAppHome({super.key});

  @override
  State<ChatAppHome> createState() => _ChatAppHomeState();
}

class _ChatAppHomeState extends State<ChatAppHome> {
  Map<String, String> contactsMap = {};
  String? token;
  String? me;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString("token");
      me = prefs.getString("user");
    });
    fetchContacts();
  }

  Future<void> fetchContacts() async {
    if (token == null) return;
    final response = await http.get(
      Uri.parse("$baseURL/contacts/"),
      headers: {'Authorization': "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        contactsMap = Map<String, String>.from(data["contacts"]);
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Contacts Fetch Failed !! ")));
    }
  }

  Future<void> addContact(String username, String name) async {
    if (token == null) return;
    final response = await http.post(
      Uri.parse("$baseURL/contacts/add"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"username": username, "name": name}),
    );

    if (response.statusCode == 200) {
      setState(() {
        contactsMap[username] = name;
      });
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to add contact!")));
    }
  }

  void showAddContactModal() {
    String username = "";
    String name = "";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Contact"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: "Username"),
                onChanged: (value) => username = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: "Name"),
                onChanged: (value) => name = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => addContact(username, name),
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ChatApp"),
        toolbarHeight: 70,
        actions: [
          IconButton(icon: Icon(Icons.add), onPressed: showAddContactModal),
          ThemeButton(),
          SizedBox(width: 7),
          CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: ListView.builder(
        itemCount: contactsMap.length,
        itemBuilder: (context, index) {
          String username = contactsMap.keys.elementAt(index);
          String name = contactsMap[username]!;
          return ListTile(
            leading: CircleAvatar(child: Text(name[0])),
            title: Text(name),
            subtitle: Text("@$username"),
            onTap: () {
              if (token != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ChatScreen(
                          me: me!,
                          username: username,
                          name: name,
                          token: token!,
                        ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
