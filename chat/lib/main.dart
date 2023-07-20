import 'package:chat/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'screens/login_page.dart';
import 'screens/set_user_name_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      initialRoute: '/root',
      routes: {
        '/root': (context) => const Root(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class Root extends StatefulWidget {
  const Root({Key? key}) : super(key: key);

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  late Future<String?> usernameFuture;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      Navigator.popUntil(context, ModalRoute.withName('/root'));
      if (user != null) usernameFuture = fetchUsername();
    });
  }

  Future<String?> fetchUsername() async {
    DocumentSnapshot<Map<String, dynamic>> user = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    if (user.exists) {
      return user.data()!['username'];
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Material(
            child: FutureBuilder(
              future: usernameFuture,
              builder: (context, AsyncSnapshot<String?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Text('Something went wrong.');
                }
                if (snapshot.data != null) {
                  // return HomePage(snapshot.data!);
                  return Container();
                } else {
                  return SetUsernamePage(() {
                    setState(() {
                      usernameFuture = fetchUsername();
                    });
                  });
                }
              },
            ),
          );
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
