import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'loginpage.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  Future<void> resetPassword(BuildContext context) async {
    String email = emailController.text.trim();
    String newPassword = newPasswordController.text;
    String confirmPassword = confirmPasswordController.text;

    if (newPassword != confirmPassword) {
      // İki şifre eşleşmiyorsa hata mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Şifreler eşleşmiyor')),
      );
      return;
    }

    try {
      //Şifre sıfırlama isteğinin gösterilmesi
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    
      //Şifre sıfırlama e-postası gönderildi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Şifre sıfırlama e-postası gönderildi')),
      );

    final firestore = FirebaseFirestore.instance;
    final collectionRef = firestore.collection('Users');
    final querySnapshot = await collectionRef.where('email', isEqualTo: email).get();

    if (querySnapshot.docs.isNotEmpty) { //bilgiler varsa
      final docRef = querySnapshot.docs.first.reference;
      
      await docRef.update({'password': newPassword});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Şifre güncellendi.')),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } 

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Color.fromARGB(255, 250, 0, 0), //sayfa arkaplanı
      appBar: AppBar(
        /*title: Text('Login',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontSize: 20,
            )),*/
        backgroundColor: Color.fromARGB(255, 255, 0, 0), 
        toolbarHeight: 40,
      ),
       
      body: Container (
        decoration: BoxDecoration(
          image: DecorationImage(
            image:  AssetImage('lib/pages/forgotpasswordbackground3.jpg'),
            fit: BoxFit.fill,
          ),
        ),
      child: Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.4,
          vertical: MediaQuery.of(context).size.height * 0.15,
        ),
        child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Shelter App",
              style: TextStyle(
                  color: Color.fromARGB(255, 255, 0, 0),  //Sayfa Başlığı
                  fontSize: 50.0,
                  fontWeight: FontWeight.bold),
            ),
            //e-posta şifre alımı yapılan ortadaki karenin bilgileri
            SizedBox(height: 70.0),
            Container(
              height: 300,
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

          child: Column(
            children: [
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'E-posta',
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Lütfen e-posta adresinizi girin.';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Yeni Şifre',
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Lütfen yeni şifrenizi girin.';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Yeni Şifreyi Onayla',
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Lütfen yeni şifrenizi tekrar girin.';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => resetPassword(context),
              child: Text('Şifremi Sıfırla'),
              style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 255, 0, 0)
            ),
          )
          ],
        ),
            )
          ]
          ),
    )
    )
    )
    )
    );
    
  }
}
