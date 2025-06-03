import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:loginpagetest/pages/mappage.dart';

class ShelterListPage extends StatefulWidget {
  @override
  _ShelterListPageState createState() => _ShelterListPageState();
}

//Users tablosundaki id kısmı için random id oluşturulması
String generateRandomId() {
  const chars = "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  final random = Random.secure();
  String id = String.fromCharCodes(Iterable.generate(15, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  return id;
}

class _ShelterListPageState extends State<ShelterListPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  List<DataRow> shelterRows = [];
  List<DataRow> filteredRows = [];
  String _searchText = '';
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  String userID = '';
  String userType = '';

  @override
  void initState() {
    super.initState();
    filterAndSortRows();
    getCurrentUser();
  }

  void getCurrentUser() async{
  User? user = auth.currentUser;
  Map<String, dynamic>? userData;

  if (user != null) {
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await firestore.collection('Users').doc(user.uid).get();
        setState(() {
        userData = documentSnapshot.data();
        userID = userData?['id'] ?? '';
        userType = userData?['type'] ?? '';
      });
    
  }
  }
  
  void filterAndSortRows() {
    filteredRows.clear();

    for (var shelter in shelterRows) {
      if (shelter.cells.any((cell) => cell.child is Text && (cell.child as Text).data!.toLowerCase().contains(_searchText.toLowerCase()))) {
        filteredRows.add(shelter);
      }
    }

    filteredRows.sort((a, b) {
      var aValue = getValueByColumnIndex(a, _sortColumnIndex);
      var bValue = getValueByColumnIndex(b, _sortColumnIndex);
      return _sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });
  }

  dynamic getValueByColumnIndex(DataRow row, int columnIndex) {
    var cellValue = row.cells[columnIndex].child;
    if (cellValue is Text) {
      return cellValue.data;
    }
    return '';
  }

  void toggleSort(int columnIndex) {
    if (_sortColumnIndex == columnIndex) {
      setState(() {
        _sortAscending = !_sortAscending;
        filterAndSortRows();
      });
    } else {
      setState(() {
        _sortColumnIndex = columnIndex;
        _sortAscending = true;
        filterAndSortRows();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
  ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Ara',
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.map),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapPage(),
                      ),
                    );
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                  filterAndSortRows();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore.collection('Shelters').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  shelterRows.clear();
                  for (var shelter in snapshot.data!.docs) {
                    var data = shelter.data() as Map<String, dynamic>?;

                    if (data != null &&
                        data.containsKey('zipCode') &&
                        data.containsKey('country') &&
                        data.containsKey('province') &&
                        data.containsKey('status') &&
                        data.containsKey('capacity') &&
                        data.containsKey('contact') &&
                        data.containsKey('address')) {
                      String zipCode = data['zipCode'];
                      String country = data['country'];
                      String province = data['province'];
                      String status = data['status'];
                      int capacity = data['capacity'];
                      String contact = data['contact'];
                      String address = data['address'];

                      DataRow row = DataRow(
                        cells: [
                          DataCell(Text(zipCode)),
                          DataCell(Text(country)),
                          DataCell(Text(province)),
                          DataCell(Text(status)),
                          DataCell(Text(capacity.toString())),
                          DataCell(Text(contact)),
                          DataCell(Text(address)),
                          DataCell(
                            userType != 'Evimi ücretsiz kiraya vermek istiyorum' && status != 'Kapalı' && status != 'Kullanıcı Onayı Bekleniyor' && status != 'Rezerve'
                                ? ElevatedButton(
                                    onPressed: () async {
                                      // Güncelleme işlemi
                                      String shelterId = shelter.id;
                                      String id = generateRandomId();
                                      String contactUserID = '';
                                      DocumentSnapshot snapshot = await firestore.collection('Shelters').doc(shelterId).get();
                                      if (snapshot.exists) {
                                        Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
                                        if (data != null && data.containsKey('contactUser')) {
                                          contactUserID = data['contactUser'];
                                          // contactUser'ı kullanın
                                        }
                                      }

                                      await firestore.collection('Shelters').doc(shelterId).update({
                                        'status': 'Kullanıcı Onayı Bekleniyor',
                                      });
                                     await firestore.collection('Bookings').doc(id).set({
                                        'id': id,
                                        'shelterID': data['id'],
                                        'tenantID': userID,
                                        'status': 'Kullanıcı Onayı Bekleniyor',
                                        'ownerID': contactUserID,
                                      });
                                    },
                                    child: Text('Rezervasyon Yap'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color.fromARGB(255, 255, 0, 0),)
                                  )
                                : Container(),
                          ),
                        ],
                      );

                      shelterRows.add(row);
                    }
                  }
                  if (shelterRows.isEmpty) {
                    return Center(
                      child: Text('No data available.'),
                    );
                  } else {
                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        sortColumnIndex: _sortColumnIndex,
                        sortAscending: _sortAscending,
                        columns: [
                          DataColumn(
                            label: Text('Zip Code'),
                            onSort: (columnIndex, ascending) {
                              setState(() {
                                _sortColumnIndex = columnIndex;
                                _sortAscending = ascending;
                                filterAndSortRows();
                              });
                            },
                          ),
                          DataColumn(
                            label: Text('Country'),
                          ),
                          DataColumn(
                            label: Text('Province'),
                            onSort: (columnIndex, ascending) {
                              setState(() {
                                _sortColumnIndex = columnIndex;
                                _sortAscending = ascending;
                                filterAndSortRows();
                              });
                            },
                          ),
                          DataColumn(
                            label: Text('Status'),
                            onSort: (columnIndex, ascending) {
                              setState(() {
                                _sortColumnIndex = columnIndex;
                                _sortAscending = ascending;
                                filterAndSortRows();
                              });
                            },
                          ),
                          DataColumn(
                            label: Text('Capacity'),
                            onSort: (columnIndex, ascending) {
                              setState(() {
                                _sortColumnIndex = columnIndex;
                                _sortAscending = ascending;
                                filterAndSortRows();
                              });
                            },
                          ),
                          DataColumn(
                            label: Text('Contact'),
                          ),
                          DataColumn(
                            label: Text('Address'),
                          ),
                          DataColumn(
                            label: Text(''),
                          ),
                        ],
                        rows: filteredRows.isNotEmpty ? filteredRows : shelterRows,
                      ),
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
