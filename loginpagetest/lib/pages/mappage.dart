import 'dart:html';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps/google_maps.dart' as maps;
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

class MapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String htmlId = "7";

    //platformViewRegistry kısmının hatası olmaması için alttaki yorum satırının olması lazım silme!!1
// ignore: undefined_prefixed_name
ui.platformViewRegistry.registerViewFactory(htmlId, (int viewId) {
  final elem = DivElement()
    ..id = htmlId
    ..style.width = "100%"
    ..style.height = "100%"
    ..style.border = 'none';

  getZipCodesFromFirestore().then((zipCodes) {
    final mapOptions = maps.MapOptions()
      ..zoom = 7.5;

    final map = maps.GMap(elem, mapOptions);

    final bounds = maps.LatLngBounds();

    for (final zipCode in zipCodes) {
      //Map kısmında TR ayarlı olsun
      getCoordinatesFromZipCode(zipCode, country: 'Turkey').then((zipCodeLatlng) {
        if (zipCodeLatlng == null) {
          return;
        }
        maps.Marker(maps.MarkerOptions()
          ..position = zipCodeLatlng
          ..map = map
          ..title = zipCode.toString()
        );
        bounds.extend(zipCodeLatlng);
      });
    }
    map.fitBounds(bounds);
  });

  return elem;
});

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
        // diğer AppBar özellikleri
      ),
      body: HtmlElementView(viewType: htmlId),
    );
  }
}

//DB'den zipCode değerini alma
Future<List<String>> getZipCodesFromFirestore() async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('Shelters')
        .get();

    final zipCodes = <String>[];
    for (final document in snapshot.docs) {
      final data = document.data();
      if (data.containsKey('zipCode')) {
        final zipCode = data['zipCode'].toString();
        zipCodes.add(zipCode);
      }
    }

    return zipCodes;
  } catch (e) {
    print('Firestore Error: $e');
    return [];
  }
}

//Alınan zip kodunu kordinata çevir
Future<maps.LatLng?> getCoordinatesFromZipCode(String zipCode, {String country = 'TR'}) async {
  final apiKey = 'AIzaSyDkn9jqYOe8dslQnfUjO-lzTwvrzTkUSIM'; //Google Maps API key
  final apiUrl = Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?address=$zipCode&components=country:$country&key=$apiKey');
  final response = await http.get(apiUrl);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    if (data['results'] != null && data['results'].length > 0) {
      final result = data['results'][0];
      final location = result['geometry']['location'];

      final lat = location['lat'];
      final lng = location['lng'];

      return maps.LatLng(lat, lng);
    }
  }

  return null;
}
