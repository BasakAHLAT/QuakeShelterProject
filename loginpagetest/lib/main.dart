import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:loginpagetest/pages/loginpage.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: firebaseConfig['apiKey'],
      authDomain: firebaseConfig['authDomain'],
      projectId: firebaseConfig['projectId'],
      storageBucket: firebaseConfig['storageBucket'],
      messagingSenderId: firebaseConfig['messagingSenderId'],
      appId: firebaseConfig['appId'],
      measurementId: firebaseConfig['measurementId'],
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Bir şeyler yanlış gitti!'),
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            title: 'Flutter Firebase Login',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: LoginPage(),
            //home: ForgotPasswordPage(),
          );
        }

        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}





