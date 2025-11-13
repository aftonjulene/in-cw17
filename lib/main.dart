import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

Future<void> _backgroundHandler(RemoteMessage message) async {
  print("Background message: ${message.data}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
  runApp(const MessagingApp());
}

class MessagingApp extends StatelessWidget {
  const MessagingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "FCM Demo",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? token = "";
  String lastMessage = "No messages yet";

  @override
  void initState() {
    super.initState();
    final messaging = FirebaseMessaging.instance;

    messaging.getToken().then((value) {
      print("FCM TOKEN: $value");
      setState(() => token = value);
    });

    FirebaseMessaging.onMessage.listen((message) {
      _handleNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNotification(message);
    });
  }

  void _handleNotification(RemoteMessage message) {
    final type = message.data["type"] ?? "regular";
    final body = message.notification?.body ?? "No body";

    setState(() => lastMessage = "$type → $body");

    if (type == "important") {
      _showImportantDialog(body);
    } else {
      _showRegularDialog(body);
    }
  }

  void _showRegularDialog(String body) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Regular Notification"),
        content: Text(body),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showImportantDialog(String body) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.red.shade100,
        title: const Text(
          "🔥 IMPORTANT ALERT",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: Text(body, style: const TextStyle(fontSize: 18)),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Firebase Notifications")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your FCM Token:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SelectableText(token ?? ""),
            const SizedBox(height: 30),
            const Text(
              "Last message received:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(lastMessage, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
