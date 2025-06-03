//import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'loginpage.dart';

class ChangeUserInfoPage extends StatefulWidget {
  @override
  _ChangeUserInfoPageState createState() => _ChangeUserInfoPageState();
}

class _ChangeUserInfoPageState extends State<ChangeUserInfoPage> {
  User? user = FirebaseAuth.instance.currentUser;
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  RegExp phoneRegExp = RegExp(r'^\+90\d{10}$'); // +90 ile başlayan 13 haneli telefon numarası kontrolü
  final passwordController = TextEditingController();
  final countryController = TextEditingController();
  final provinceController = TextEditingController();
  final numberOfPeopleController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  //String? _country = 'Türkiye';
  String? _province;
  List<String> _provinces = [
    'Adana',
    'Adıyaman',
    'Afyonkarahisar',
    'Ağrı',
    'Amasya',
    'Ankara',
    'Antalya',
    'Artvin',
    'Aydın',
    'Balıkesir',
    'Bilecik',
    'Bingöl',
    'Bitlis',
    'Bolu',
    'Burdur',
    'Bursa',
    'Çanakkale',
    'Çankırı',
    'Çorum',
    'Denizli',
    'Diyarbakır',
    'Edirne',
    'Elazığ',
    'Erzincan',
    'Erzurum',
    'Eskişehir',
    'Gaziantep',
    'Giresun',
    'Gümüşhane',
    'Hakkari',
    'Hatay',
    'Isparta',
    'Mersin',
    'İstanbul',
    'İzmir',
    'Kars',
    'Kastamonu',
    'Kayseri',
    'Kırklareli',
    'Kırşehir',
    'Kocaeli',
    'Konya',
    'Kütahya',
    'Malatya',
    'Manisa',
    'Kahramanmaraş',
    'Mardin',
    'Muğla',
    'Muş',
    'Nevşehir',
    'Niğde',
    'Ordu',
    'Rize',
    'Sakarya',
    'Samsun',
    'Siirt',
    'Sinop',
    'Sivas',
    'Tekirdağ',
    'Tokat',
    'Trabzon',
    'Tunceli',
    'Şanlıurfa',
    'Uşak',
    'Van',
    'Yozgat',
    'Zonguldak',
    'Aksaray',
    'Bayburt',
    'Karaman',
    'Kırıkkale',
    'Batman',
    'Şırnak',
    'Bartın',
    'Ardahan',
    'Iğdır',
    'Yalova',
    'Karabük',
    'Kilis',
    'Osmaniye',
    'Düzce'
  ];

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().then((value) {
      getUserData(); // Güncel kullanıcı verilerini almak için getUserData metodu çağrılır
    });

    _province = provinceController.text; // _province değeri başlangıçta atansın
  }

  Future<void> getUserData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .get();

    if (snapshot.exists) {
      var data = snapshot.data() as Map<String, dynamic>;

      setState(() {
        nameController.text = data['name'] ?? '';
        surnameController.text = data['surname'] ?? '';
        countryController.text = data['country'] ?? '';
        provinceController.text = data['province'] ?? '';
        phoneController.text = data['phone'] ?? '';
        numberOfPeopleController.text = data['numberofpeople']?.toString() ?? '';
        passwordController.text = data['password'] ?? '';
        _province = provinceController.text; //güncel değere atama
      });
    }
  }

  Future<void> updateUserData() async {
  try {
    if (phoneController.text.isEmpty || !phoneRegExp.hasMatch(phoneController.text)) {
      showErrorSnackBar('Lütfen geçerli bir telefon numarası girin.');
      return;
    }

    //Profil bilgilerininin güncellenmesi
    await FirebaseFirestore.instance.collection('Users').doc(user!.uid).update({
      'name': nameController.text,
      'surname': surnameController.text,
      'country': countryController.text,
      'province': provinceController.text,
      'phone': phoneController.text,
      'numberofpeople': numberOfPeopleController.text.toString(),
      'email': emailController.text,
      'password': passwordController.text, 
    });

    //E-posta doğrulama maili gönderme işlemi
    await user!.updateEmail(emailController.text);
    await user!.sendEmailVerification();

    //Şifreyi güncelle
    if (passwordController.text.isNotEmpty) {
      await user!.updatePassword(passwordController.text);
      showSuccessSnackBar('Değişiklikleriniz başarıyla kaydedildi. E-posta doğrulama e-postası gönderildi.');

      await FirebaseAuth.instance.signOut(); // Oturumu kapat

      //Login sayfasına git
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } else {
      showSuccessSnackBar('Değişiklikleriniz başarıyla kaydedildi. E-posta doğrulama e-postası gönderildi.');
    }

    //Geri dönüldüğünde profil bilgilerini güncelle
    getUserData();
  } catch (error) {
    showErrorSnackBar('Bir hata oluştu. ${error.toString()}');
  }
}

void showSuccessSnackBar(String message) {
  final snackBar = SnackBar(
    content: Text(message),
    backgroundColor: Colors.green,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void showErrorSnackBar(String message) {
  final snackBar = SnackBar(
    content: Text(message),
    backgroundColor: Colors.red,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void showInfoSnackBar(String message) {
  final snackBar = SnackBar(
    content: Text(message),
    backgroundColor: Colors.blue,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

//Şifre değiştir
Future<void> changePassword() async {
  try {
    // Şifre değiştirme işlemi
    await user!.updatePassword(passwordController.text);
    showSuccessSnackBar('Şifreniz başarıyla değiştirildi.');
    passwordController.text = '';
  } catch (error) {
    showErrorSnackBar('Bir hata oluştu. ${error.toString()}');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
      leading: IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
    //title: Text('Profilim'),
    backgroundColor: Color.fromARGB(255, 255, 0, 0), 
    toolbarHeight: 40,
    // diğer AppBar özellikleri
  ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(user!.uid)
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Bir hata oluştu: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;

          nameController.text = data['name'] ?? '';
          surnameController.text = data['surname'] ?? '';
          countryController.text = data['country'] ?? '';
          provinceController.text = data['province'] ?? '';
          phoneController.text = data['phone'] ?? '';
          emailController.text = data['email'] ?? '';
          passwordController.text = data['password'] ?? '';
          numberOfPeopleController.text = data['numberofpeople']?.toString() ?? '';

          return Container(
            color: Color.fromARGB(255, 255, 255, 255),
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kullanıcı Bilgileri',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Ad',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: surnameController,
                  decoration: InputDecoration(
                    labelText: 'Soyad',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Ülke',
                    border: OutlineInputBorder(),
                    ),
                  initialValue: 'Türkiye',
                  enabled: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Country gerekli';
                    }
                    return null;
                  },
                  //onSaved: (value) => _country = value,
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Şehir',
                    border: OutlineInputBorder(),
                    ),
                  value: _province,
                  items: [
                    for (var province in _provinces)
                      DropdownMenuItem(
                        value: province,
                        child: Text(province),
                        )
                        ],
                        onChanged: (value) {
                          setState(() {
                            _province = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Province gerekli';
                          }
                          return null;
                        },
                        onSaved: (value) => _province = value,
                      ),
                SizedBox(height: 10),
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Telefon Numarası',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: numberOfPeopleController,
                  decoration: InputDecoration
            (
                labelText: 'Kişi Sayısı',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateUserData,
              child: Text('Kaydet'),
              style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 255, 0, 0),)
            ),
          ],
        ),
      );
    },
  ),
);
  }
  }