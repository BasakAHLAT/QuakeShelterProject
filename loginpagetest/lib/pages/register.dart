import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loginpagetest/pages/loginpage.dart';
import 'dart:math';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

String generateRandomId() {
  const chars = "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  final random = Random.secure();
  String userID = String.fromCharCodes(Iterable.generate(15, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  return userID;
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController1 = TextEditingController();
  final TextEditingController _passwordController2 = TextEditingController();
  final TextEditingController _numberOfPeopleController = TextEditingController();
  //final TextEditingController _countryController = TextEditingController();
  //final TextEditingController _provinceController = TextEditingController();
  //final TextEditingController _typeController = TextEditingController();

  //String? _country = 'Türkiye';
  String? _type;
  List<String> _types = [
    'Evimi ücretsiz kiraya vermek istiyorum',
    'Ücretsiz ev kiralamak istiyorum'
  ];
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
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Color.fromARGB(213, 86, 80, 80), //sayfa arkaplanı
      appBar: AppBar(
        /*title: Text('Login',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontSize: 20,
            )),*/
        backgroundColor: Color.fromARGB(255, 255, 72, 0), 
        toolbarHeight: 40,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image:  AssetImage('lib/pages/registerbackground3.png'),
            fit: BoxFit.fill,
          ),
        ),
        padding: EdgeInsets.all(20.0),
        child: Center(
          //color: Color.fromARGB(255, 255, 0, 0),
          child: Container(
            height: 672,
            width: 335,
            alignment: Alignment.center,
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 5.0,
                  offset: Offset(0, 2)
                )
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Type'),
                      value: _type,
                      items: [
                        for (var type in _types)
                          DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          )
                      ],
                      onChanged: (value) {
                        setState(() {
                          _type = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Type gerekli';
                        }
                        return null;
                      },
                      onSaved: (value) => _type = value,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Ad',
                      ),
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen adınızı girin';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Soyad',
                      ),
                      controller: _surnameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen soyadınızı girin';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'E-posta',
                      ),
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen bir e-posta girin';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Telefon Numarası',
                        hintText: 'XXXXXXXXXX',
                        prefixText: '+90 ',
                      ),
                      controller: _phoneController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Contact gerekli';
                        } else if (value.length != 13) {
                          return 'Geçersiz telefon numarası';
                        } else if (!value.startsWith('+90')) {
                          return 'Telefon numarası +90 ile başlamalıdır';
                        }
                        return null;
                      },
                      onSaved: (value) => _phoneController.text = value ?? '',
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Şifre',
                      ),
                      obscureText: true,
                      controller: _passwordController1,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen bir şifre girin';
                        }
                        if (value.length < 6) {
                          return 'Şifre en az 6 karakter olmalıdır';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Şifre Tekrar',
                      ),
                      obscureText: true,
                      controller: _passwordController2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen bir şifre girin';
                        }
                        if (value.length < 6) {
                          return 'Şifre en az 6 karakter olmalıdır';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Kişi Sayısı',
                      ),
                      controller: _numberOfPeopleController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen kişi sayısını girin';
                        }
                        return null;
                      },
                    ),

                    //Bu kısım default kalsın
                    /*TextFormField(
                      decoration: InputDecoration(labelText: 'Country'),
                      initialValue: 'Türkiye',
                      enabled: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Country gerekli';
                        }
                        return null;
                      },
                      //onSaved: (value) => _country = value,
                    ),*/

                   DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Province'),
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
                    
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _registerUser();
                        }
                      },
                      child: Text('Kayıt Ol'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 255, 72, 0),)
                    ),
                    ],
                    ),
                    ),
                    ),
                    ),
                    ),
                    );
                    }

  void _registerUser() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
           email: _emailController.text, password: _passwordController1.text);
      User? user = userCredential.user;
      String pass1 = _passwordController1.text;
      String pass2 = _passwordController2.text;

      if(pass1 == pass2)
      {
        if (user != null) {
        // Kullanıcıyı veritabanına kaydet
        String userid = generateRandomId();
        FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .set({
        'id': userid,
        'name': _nameController.text,
        'surname': _surnameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'password': _passwordController1.text,
        'numberofpeople': int.parse(_numberOfPeopleController.text),
        'country':'Türkiye',
        'province': _province,
        'type': _type,
      });
      showSuccessSnackBar('Kayıt işlemleri başarılı!');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
        } 
      } else if (pass1 != pass2){
        showErrorSnackBar('Şifrelerin aynı olduğundan emin olun.');
      }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          print('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
           print('The account already exists for that email.');
        }
      } catch (e) {
        print(e);
        }
      }

  void showSuccessSnackBar(String message) {
  final snackBar = SnackBar(
    content: Text(message),
    backgroundColor: Colors.green,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);

  //5 sn bekle
  Future.delayed(Duration(seconds: 5), () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  });
}

  void showErrorSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


}