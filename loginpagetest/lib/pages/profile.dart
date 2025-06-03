import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loginpagetest/pages/addshelter.dart';
import 'changeuserinfo.dart';
import 'listshelters.dart';
import 'loginpage.dart';


class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  Map<String, dynamic>? _userData;
  String _userId = '';
  List<String> statusList = ['Kapalı', 'Açık', 'Kullanıcı Onayı Bekleniyor', 'Rezerve'];
  //Map<String, dynamic>? _bookingUserData;
  bool showAddShelterButton = false;
  bool showOwnerTable = false;
  bool showTenantTable = false;

  @override
  void initState() {
    super.initState();
    _getUserData();
    //_signOut();
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut(); // Oturumu kapat
  }

  Future<void> _getUserData() async {
    _user = _auth.currentUser;
    if (_user != null) {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await _firestore.collection('Users').doc(_user!.uid).get();
      setState(() {
        _userData = documentSnapshot.data();
        _userId = _userData?['id'] ?? '';
        if (_userData?['type'] == 'Evimi ücretsiz kiraya vermek istiyorum') {
        showAddShelterButton = true;
        showOwnerTable = true;} else {showTenantTable = true;}
      });
      /*ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(showAddShelterButton.toString())),
      );    */
            }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      automaticallyImplyLeading: false, //Geri butonu olmasın
      actions: [
        IconButton(
          onPressed: () {
            _signOut();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
          icon: Icon(Icons.exit_to_app),
        ),
      ],
          backgroundColor: Color.fromARGB(255, 255, 0, 0), 
          toolbarHeight: 40,
        ),

         body: _userData == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView( //Container( 
            children: [Card(
                elevation: 2.0,
                margin: EdgeInsets.all(16.0),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  /*Padding(
                  padding: EdgeInsets.fromLTRB(25.0, 25.0, 0, 0),*/
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SvgPicture.asset(
                            'lib/pages/user_icon.svg',
                            height: 50,
                            width: 50,
                          ),
                          SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_userData?['name'] ?? ''} ${_userData?['surname'] ?? ''}',
                                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  '${_userData?['province'] ?? ''}, ${_userData?['country'] ?? ''}',
                                  style: TextStyle(fontSize: 16.0),
                                ),
                                IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ChangeUserInfoPage()),
                                    );
                                  },
                                  icon: Icon(Icons.edit),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'E-mail: ${_userData?['email'] ?? ''}',
                        style: TextStyle(fontSize: 18.0),
                      ),
                      /*SizedBox(height: 8.0),
                      Text(
                        _userData!['email'],
                        style: TextStyle(fontSize: 16.0),
                      ),*/
                      SizedBox(height: 16.0),
                      Text(
                        'Telefon Numarası: ${_userData?['phone'] ?? ''}',
                        style: TextStyle(fontSize: 18.0),
                      ),
                      /*SizedBox(height: 8.0),
                      Text(
                        _userData!['phone'],
                        style: TextStyle(fontSize: 16.0),
                      ),*/
                      SizedBox(height: 16.0),
                      Text(
                        'Kişi Sayısı: ${_userData?['numberofpeople'].toString() ?? ''}',
                        style: TextStyle(fontSize: 18.0),
                      ),
                      /*SizedBox(height: 8.0),
                      Text(
                        _userData!['numberofpeople'].toString(),
                        style: TextStyle(fontSize: 16.0),
                      ),*/
                      SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 255, 0, 0)
                             ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ShelterListPage()),
                              );
                            },
                            child: Text('Barınma Alanı Listele'),
                            
                          ),
                          SizedBox(width: 16.0),
                          Visibility(
                            visible: showAddShelterButton,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(255, 255, 0, 0)
                               ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => AddShelterPage()),
                                );
                              },
                              child: Text('Barınma Alanı Ekle'),

                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Evlerim:',
                        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.0),

                      Visibility(
                        visible: showOwnerTable,
                        child: StreamBuilder<QuerySnapshot>(
                          stream: _firestore.collection('Shelters').where('contactUser', isEqualTo: _userId).snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }
                            if (!snapshot.hasData) {
                              return CircularProgressIndicator();
                            }
                            List<DocumentSnapshot> shelterDocs = snapshot.data!.docs;
                            if (shelterDocs.isEmpty) {
                              return Text('You have no shelters.');
                            }
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: [
                                  DataColumn(label: Text('Shelter ID')),
                                  DataColumn(label: Text('Zip Code')),
                                  DataColumn(label: Text('Şehir')),
                                  DataColumn(label: Text('Kapasite')),
                                  DataColumn(label: Text('Durum')),
                                  DataColumn(label: Text(' ')),
                                ],
                                rows: shelterDocs.map((shelterDoc) {
                                  Map<String, dynamic> Shelters = shelterDoc.data() as Map<String, dynamic>;

                                  String shelterID = Shelters['id'];
                                  String zipCode = Shelters['zipCode'];
                                  String province = Shelters['province'];
                                  int capacity = Shelters['capacity'];
                                  String status = Shelters['status'];

                                  Widget statusWidget;
                                  if (status != 'Kullanıcı Onayı Bekleniyor') {
                                    statusWidget = DropdownButtonFormField<String>(
                                      value: status,
                                      items: statusList.map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) async {
                                        if (newValue != null) {
                                          await _firestore
                                              .collection('Shelters')
                                              .where('id', isEqualTo: shelterID)
                                              .get()
                                              .then((querySnapshot) {
                                            querySnapshot.docs.forEach((doc) async {
                                              await _firestore.collection('Shelters').doc(doc.id).update({
                                                'status': newValue,
                                              });
                                            });
                                          });
                                        }
                                      },
                                    );
                                  } else {
                                    statusWidget = Text(status);
                                  }

                                Widget actionsWidget;
                                  if (status == 'Kullanıcı Onayı Bekleniyor') {
                                    actionsWidget = Row(
                                      children: [
                                        IconButton(
                                        icon: Icon(Icons.info),
                                        onPressed: () async {
                                        var querySnapshot = await FirebaseFirestore.instance
                                            .collection('Bookings')
                                            .where('shelterID', isEqualTo: shelterID)
                                            .get();

                                        if (querySnapshot.docs.isNotEmpty) {
                                          var bookingDoc = querySnapshot.docs[0];
                                          var tenantID = bookingDoc['tenantID'];
                                          
                                          var userSnapshot = await FirebaseFirestore.instance
                                              .collection('Users')
                                              .where('id', isEqualTo: tenantID)
                                              .get();
                                          
                                          if (userSnapshot.docs.isNotEmpty) {
                                            var userDoc = userSnapshot.docs[0];
                                            var userName = userDoc['name'];
                                            var userSurname = userDoc['surname'];
                                            var userEmail = userDoc['email'];
                                            var userPhone = userDoc['phone'];
                                            var userProvince = userDoc['province'];
                                            var userNumberofPeople = userDoc['numberofpeople'];

                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text('Kullanıcı Bilgileri'),
                                                  content: Text(
                                                    'Ad: $userName\n'  
                                                    'Soyad: $userSurname \n'
                                                    'E-posta: $userEmail\n'
                                                    'Telefon Numarası: $userPhone\n'
                                                    'Şehir: $userProvince\n'
                                                    'Kişi Sayısı: $userNumberofPeople\n'
                                                    ),
                                                  actions: [
                                                    TextButton(
                                                      child: Text('Kapat'),
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          }
                                        }
                                      },

                                      ),

                                        SizedBox(width: 8.0),
                                        ElevatedButton(
                                          onPressed: () async {
                                            await _firestore
                                              .collection('Shelters')
                                              .where('id', isEqualTo: shelterID)
                                              .get()
                                              .then((querySnapshot) {
                                            querySnapshot.docs.forEach((doc) async {
                                              await doc.reference.update({
                                                'status': 'Rezerve',
                                              });
                                            });
                                          });
                                          await _firestore
                                            .collection('Bookings')
                                            .where('shelterID', isEqualTo: shelterID)
                                            .get()
                                            .then((querySnapshot) {
                                          querySnapshot.docs.forEach((doc) async {
                                            await doc.reference.update({
                                              'status': 'Rezerve',
                                            });
                                          });
                                        });
                                          },
                                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.green)),
                                          child: Text('Kabul Et'),
                                        ),
                                        SizedBox(width: 8.0),
                                        ElevatedButton(
                                          onPressed: () async {
                                            await _firestore
                                              .collection('Shelters')
                                              .where('id', isEqualTo: shelterID)
                                              .get()
                                              .then((querySnapshot) {
                                            querySnapshot.docs.forEach((doc) async {
                                              await doc.reference.update({
                                                'status': 'Kapalı',
                                              });
                                            });
                                          });
                                          await _firestore
                                            .collection('Bookings')
                                            .where('shelterID', isEqualTo: shelterID)
                                            .get()
                                            .then((querySnapshot) {
                                          querySnapshot.docs.forEach((doc) async {
                                            await doc.reference.update({
                                              'status': 'Kapalı',
                                            });
                                          });
                                        });
                                          },
                                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
                                          child: Text('Reddet'),
                                        ),
                                      ],
                                    );
                                  } else {
                                    actionsWidget = IconButton(
                                      icon: Icon(Icons.info),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Popup'),
                                              content: Text('--'),
                                              actions: [
                                                TextButton(
                                                  child: Text('Tamam'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    );
                                  }

                                  return DataRow(cells: [
                                    DataCell(Text(shelterID)),
                                    DataCell(Text(zipCode)),
                                    DataCell(Text(province)),
                                    DataCell(Text(capacity.toString())),
                                    DataCell(statusWidget),
                                    DataCell(actionsWidget),
                                  ]);
                                }).toList(),
                              ),
                            );
                          },
                        ),
                        ),// Owner tablosu görüntülenir
                        
                      Visibility(
                        visible: showTenantTable,
                        child: StreamBuilder<QuerySnapshot>(
                          stream: _firestore.collection('Bookings').where('tenantID', isEqualTo: _userId).snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }
                            if (!snapshot.hasData) {
                              return CircularProgressIndicator();
                            }
                            List<DocumentSnapshot> bookingDocs = snapshot.data!.docs;
                            if (bookingDocs.isEmpty) {
                              return Text('You have no shelters.');
                            }
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: [
                                  DataColumn(label: Text('Shelter ID')),
                                  DataColumn(label: Text('Owner ID')),
                                  DataColumn(label: Text('Durum')),

                                ],
                                rows: bookingDocs.map((bookingDoc) {
                                  Map<String, dynamic> Bookings = bookingDoc.data() as Map<String, dynamic>;

                                  String shelterID = Bookings['shelterID'];
                                  String ownerID = Bookings['ownerID'];
                                  String status = Bookings['status'];
                                  
                                  return DataRow(cells: [
                                    DataCell(Text(shelterID)),
                                    DataCell(Text(ownerID)),
                                    DataCell(Text(status)),

                                  ]);
                                }).toList(),
                              ),
                            );
                          },
                        ),
                        ) 

                    ],
                  ),
                ),
             )]));

  }
}
