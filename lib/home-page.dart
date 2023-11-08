import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:presensi/models/home-response.dart';
import 'package:presensi/models/cons.dart';
// import 'package:presensi/listPresensi.dart';listPresensi
import 'package:presensi/qr.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as myHttp;
import 'package:presensi/login-page.dart';
import 'SimpanPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> _name, _token;
  late Future<String> _email;
  HomeResponseModel? homeResponseModel;
  Datum? hariIni;
  List<Datum> riwayat = [];
  List<dynamic> data = []; // List untuk menyimpan data dari API
  // final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  // late Future<String> _token;
  // late Future<String> _email;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchDataFromApi();
    _token = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("token") ?? "";
    });

    _name = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("name") ?? "";
    });
    _email = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("email") ?? "";
    });
  }


  Future<void> fetchDataFromApi() async {
    final response = await myHttp.get(Uri.parse('$BASE_URL/api/get-presensi-user/${await _email}'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      setState(() {
        data = jsonResponse['data'];
      });
    } else {
      throw Exception('Failed to load data from API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: fetchDataFromApi(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return SafeArea(
                  child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder(
                        future: _name,
                        builder: (BuildContext context,
                            AsyncSnapshot<String> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else {
                            if (snapshot.hasData) {
                              print(snapshot.data);
                              return Text(snapshot.data!,
                                  style: TextStyle(fontSize: 18));
                            } else {
                              return const Text("-", style: TextStyle(fontSize: 18));
                            }
                          }
                        }),
                    const SizedBox(
                      height: 20,
                    ),
                    // Container(
                    //   width: 400,
                    //   decoration: BoxDecoration(color: Colors.blue[800]),
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(16.0),
                    //     child: Column(children: [
                    //       Text(hariIni?.tanggal ?? '-',
                    //           style:
                    //               const TextStyle(color: Colors.white, fontSize: 16)),
                    //       const SizedBox(
                    //         height: 30,
                    //       ),
                    //       Row(
                    //         mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //         children: [
                    //           Column(
                    //             children: [
                    //               Text(hariIni?.masuk ?? '-',
                    //                   style: const TextStyle(
                    //                       color: Colors.white, fontSize: 24)),
                    //               const Text("Masuk",
                    //                   style: TextStyle(
                    //                       color: Colors.white, fontSize: 16))
                    //             ],
                    //           ),
                    //           Column(
                    //             children: [
                    //               Text(hariIni?.pulang ?? '-',
                    //                   style: const TextStyle(
                    //                       color: Colors.white, fontSize: 24)),
                    //               const Text("Pulang",
                    //                   style: TextStyle(
                    //                       color: Colors.white, fontSize: 16))
                    //             ],
                    //           )
                    //         ],
                    //       )
                    //     ]),
                    //   ),
                    // ),
                    const SizedBox(height: 20),
                    // const Text("Riwayat Presensi"),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     // Navigate to the second page when the button is pressed.
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(builder: (context) => listPresensi()),
                    //     );
                    //   },
                    //   child: Text('Riwayat Presensi'),
                    // ),
                    ElevatedButton(
                      onPressed: () async {
                        // Hapus data login dari SharedPreferences
                        final prefs = await SharedPreferences.getInstance();
                        prefs.remove('token');
                        prefs.remove('name');

                        // Navigasi kembali ke halaman login atau halaman awal aplikasi
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => LoginPage()), // Ganti dengan halaman login yang sesuai
                        );
                      },
                      child: Text('Logout'),
                    ),
                    Expanded(
                      child:  ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(data[index]['tanggal'] ?? "data tidak ada"), // Sesuaikan dengan struktur JSON dari API Anda
                            subtitle: Text(data[index]['masuk']  +" - "+data[index]['pulang'] ), // Sesuaikan dengan struktur JSON dari API Anda
                            onTap: () {
                              // Aksi yang akan dijalankan saat item diklik
                              // Contoh: Navigasi ke halaman detail atau tampilkan informasi tambahan
                              // Jangan lupa sesuaikan dengan kebutuhan aplikasi Anda.
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ));
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => ScanQr()))
              .then((value) {
            setState(() {});
          });
        },
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }
}
