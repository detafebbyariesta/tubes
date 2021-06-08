import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tugasakhir/model/entryform.dart';
import 'dart:async';
import '../model/item.dart';
import 'package:tugasakhir/FireDatabase/Database.dart'; //pendukung program asinkron

class Home extends StatefulWidget {
  @override
  final id;
  Home(this.id);
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  int count = 0;
  List<Item> itemList;

  @override
  Widget build(BuildContext context) {
    String i = widget.id;
    if (itemList == null) {
      itemList = List<Item>();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Item'),
      ),
      body: Column(children: [
        Expanded(
          child: fireList(i),
        ),
        Container(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: double.infinity,
            child: RaisedButton(
              child: Text("Tambah Item"),
              onPressed: () async {
                var item = await navigateToEntryForm(
                    context, null, null, null, null, null, null, i, null);
              },
            ),
          ),
        ),
      ]),
    );
  }

  Future<Item> navigateToEntryForm(
      BuildContext context,
      Item item,
      String nama_pem,
      String nama_bar,
      int price,
      int stock,
      int kode,
      String id,
      String docId) async {
    var result = await Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return EntryForm(item, nama_pem, nama_bar, price, stock, kode, id, docId);
    }));
    return result;
  }

  StreamBuilder fireList(String a) {
    TextStyle textStyle = Theme.of(context).textTheme.headline5;

    return StreamBuilder<QuerySnapshot>(
      stream: DatabaseF().readItems(a),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
              alignment: Alignment.center,
              child: Text('Loading',
                  style: TextStyle(fontWeight: FontWeight.bold)));
        } else if (snapshot.hasData || snapshot.data != null) {
          return ListView.builder(
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index) {
              var noteInfo = snapshot.data.docs[index].data();
              String docID = snapshot.data.docs[index].id;
              String nama_pemb = noteInfo['name_pem'];
              String nama_bara = noteInfo['nama_bar'];
              int prices = noteInfo['price'];
              int stocks = noteInfo['stock'];
              int kodes = noteInfo['kode'];

              return Card(
                color: Colors.white,
                elevation: 2.0,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.ad_units),
                  ),
                  title: Text(
                    nama_pemb,
                    style: textStyle,
                  ),
                  subtitle: Text("Id Barang   : " +
                      kodes.toString() +
                      "\n" +
                      "Nama Barang : " +
                      nama_bara +
                      "\n" +
                      "Harga        : " +
                      prices.toString()),
                  trailing: GestureDetector(
                    child: Icon(Icons.delete),
                    onTap: () async {
//TODO 3 Panggil Fungsi untuk Delete dari DB berdasarkan Item
                      DatabaseF.deleteItem(docId: docID, uid: a);
                    },
                  ),
                  onTap: () async {
                    await navigateToEntryForm(context, null, nama_pemb,
                        nama_bara, prices, stocks, kodes, a, docID);
                  },
                ),
              );
            },
          );
        }
      },
    );
  }
}
