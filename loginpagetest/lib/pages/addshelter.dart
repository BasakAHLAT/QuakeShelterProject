import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class AddShelterPage extends StatefulWidget {
  @override
  _AddShelterPageState createState() => _AddShelterPageState();
}

class _AddShelterPageState extends State<AddShelterPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  String? _zipCode;
  String? _country = 'Türkiye';
  String? _province;
  String? _status;
  int? _capacity;
  //String? _contact;
  String? _address;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  Map<String, dynamic>? _userData;
  String _userId = ''; //sheltes'a aktif kullanıcının userını kaydetmek için
  String _userPhone = ''; //sheltes'a aktif kullanıcının numarasını kaydetmek için

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  String generateRandomId() {
  const chars = "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  final random = Random.secure();
  String shelterID = String.fromCharCodes(Iterable.generate(15, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  return shelterID;
}

  Future<void> _getUserData() async { //Kullanıcı bilgilerinin Firebase'den alınması
    _user = _auth.currentUser;
    if (_user != null) {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await _firestore.collection('Users').doc(_user!.uid).get(); //Users koleksiyonundan verileri al
      setState(() {
        _userData = documentSnapshot.data();
        _userId = _userData?['id'];
        _userPhone = _userData?['phone'];
      });
    }
  }
  
  //Barınma alanının durumu
  List<String> _statusOptions = ['Açık', 'Kapalı'];
  //Barınma alanı şehir listesi
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
      appBar: AppBar(
      leading: IconButton(
      icon: Icon(Icons.arrow_back), //Önceki sayfaya dönme butonu
      onPressed: () {
        Navigator.pop(context);
      },
    ),
    //title: Text('Profilim'),
    backgroundColor: Color.fromARGB(255, 255, 0, 0), 
    toolbarHeight: 40,
  ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Posta Kodu'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Zip Code gerekli';
                    }
                    return null;
                  },
                  onSaved: (value) => _zipCode = value,
                ),

                //Türkiye kısıtlaması olmalı bu durum değişirse bu kısım açılmalı
                TextFormField(
                  decoration: InputDecoration(labelText: 'Ülke'),
                  initialValue: 'Türkiye',
                  enabled: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Country gerekli';
                    }
                    return null;
                  },
                  onSaved: (value) => _country = value,
                ),
                
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Şehir'),
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
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Durum'),
                  value: _status,
                  items: _statusOptions
                      .map((status) => DropdownMenuItem(
                            child: Text(status),
                            value: status,
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _status = value;
                    });
                  }),

                  //Telefon numarası varolan mı kalmalı? Yeni mi alınmalı??
                  /*TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Contact',
                      hintText: 'XXXXXXXXXX',
                      prefixText: '+90 ',
                    ),
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
                    onSaved: (value) => _contact = value,
                  ),*/

                TextFormField(
                  decoration: InputDecoration(labelText: 'Kapasite'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kapasite gerekli';
                    } else if (int.tryParse(value) == null) {
                      return 'Kapasite geçersiz';
                    }
                    return null;
                  },
                  onSaved: (value) => _capacity = int.parse(value!),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Adres'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Adres gerekli';
                    }
                    return null;
                  },
                  onSaved: (value) => _address = value,
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async { 
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      String shelterid = generateRandomId();
                      await firestore.collection('Shelters').add({
                        'zipCode': _zipCode,
                        'country': _country,
                        'province': _province,
                        'status': _status,
                        'capacity': _capacity,
                        'contact': _userPhone,
                        'address': _address,
                        'contactUser': _userId,
                        'id': shelterid,
                      });

                      ScaffoldMessenger.of(context).showSnackBar( //Bildirim mesajı
                        SnackBar(
                          backgroundColor: Colors.green,
                          content: Text('Barınak başarıyla eklendi.'),
                          duration: Duration(seconds: 3), //3 sn bekle
                        ),
                      );

                       Future.delayed(Duration(seconds: 3), () {
                        Navigator.pop(context);
                      });
                      
                    }
                  },
                  child: Text('Ekle'),
                  style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 255, 0, 0),)
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
