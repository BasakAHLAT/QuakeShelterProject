import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'forgotpassword.dart';
import 'register.dart';
import 'profile.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password= '';

  void showErrorSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _signInWithEmailAndPassword() async {
  final formState = _formKey.currentState;
  if (formState!.validate()) {
    formState.save();
    try {
      //Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _email, password: _password);

      //e-posta ve şifre eşleşmesini
      if (userCredential.user != null) {
        final User? user = userCredential.user;
        if (user != null) {
          final DocumentSnapshot<Map<String, dynamic>> userSnapshot =
              await FirebaseFirestore.instance
                  .collection("Users")
                  .doc(user.uid)
                  .get();
          if (userSnapshot.exists) {
            final userData = userSnapshot.data()!;
            if (userData['email'] == _email && userData['password'] == _password) {
              // E-posta ve şifre eşleşiyor, profil sayfasına git
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            } else {
              showErrorSnackBar('Geçersiz e-posta veya şifre');
            }
          } else {
            print("Kullanıcı verisi bulunamadı");
          }
        } else {
          print("Oturum açan kullanıcı bulunamadı");
        }
      } else {
        showErrorSnackBar('Geçersiz e-posta veya şifre');
      }
    } on FirebaseAuthException catch (e) {
      print("Giriş başarısız: $e");
    }
  }
}


@override
Widget build(BuildContext context) {
  return Scaffold(
    //backgroundColor: Color.fromARGB(255, 250, 0, 0), //sayfa arkaplanı
    body: SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image:  AssetImage('lib/pages/loginbackground.png'),
            fit: BoxFit.cover,
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.3,
          vertical: MediaQuery.of(context).size.height * 0.2,
        ),
        child: Center(
        child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Shelter App",
              style: TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255), //Sayfa Başlığı
                  fontSize: 50.0,
                  fontWeight: FontWeight.bold),
            ),
        
            //e-posta şifre alımı yapılan kare
            SizedBox(height: 70.0),
            Container(
              height: 340,
              width: 300,
              alignment: Alignment.center,
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black,
                        blurRadius: 5.0,
                        offset: Offset(0, 2))
                  ]),

              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 20.0),
                    TextFormField(
                      validator: (input) {
                        if (input == null || input.isEmpty) {
                          return 'E-posta giriniz';
                        }
                        return null; // Boş değil
                      },
                      decoration: InputDecoration(
                        hintText: "E-posta",
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (input) => _email = input!,
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      validator: (input) {
                        if (input == null || input.isEmpty) {
                          return 'Şifre giriniz';
                        }
                        return null; // Boş değil
                      },
                      decoration: InputDecoration(
                        hintText: "Şifre",
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      onSaved: (input) => _password = input!,
                    ),

                    SizedBox(height: 30.0),
                    ElevatedButton(
                      onPressed: _signInWithEmailAndPassword,
                      child: Text("Giriş"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 255, 0, 0),)
                    ),
                    
                    //Register sayfasına gitme butonu
                    SizedBox(height: 20.0),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterPage()),
                        );
                      },
                      child: Text(
                        "Hesabınız yok mu? Kayıt Olun",
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 0, 0),
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline, // altı çizili olarak ayarla
                        ),
                      ),
                    ),

                    //Reset Password sayfasına gitme butonu
                    SizedBox(height: 20.0),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                        );
                      },
                      child: Text(
                        "Şifremi Unuttum",
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 0, 0),
                          fontWeight: FontWeight.bold,
                          //decoration: TextDecoration.underline, // altı çizili olarak ayarla
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    ),
  );
}
}