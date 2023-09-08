import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(FlutlerApp());
}

class FlutlerApp extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FlutlerHome(),
    );
  }
}

class Record {
  String title;
  int elapsedTime;
  List<String> notes;

  Record(this.title, this.elapsedTime, this.notes);
}

class FlutlerHome extends StatefulWidget {
  @override
  _FlutlerHomeState createState() => _FlutlerHomeState();
}

class _FlutlerHomeState extends State<FlutlerHome> {
  int elapsedTime = 0;
  late DateTime startTime;
  bool isRunning = false;
  String title = "";
  List<Record> records = [];
  Timer? timer;
  String selectedRecord = "";
  double distance = 0;
  double actionButtonWidth = 100; // Buton genişliği

  void startTimer() {
    startTime = DateTime.now().subtract(Duration(milliseconds: elapsedTime));
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        elapsedTime = DateTime.now().difference(startTime).inMilliseconds;
      });
    });
    setState(() {
      isRunning = true;
    });
  }

  void stopTimer() {
    setState(() {
      isRunning = false;
    });

    timer?.cancel();
    elapsedTime = DateTime.now().difference(startTime).inMilliseconds;
  }

  void saveRecord() {
    if (title.trim().isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Başlık Hatası'),
          content: Text('Lütfen bir başlık girin.'),
          actions: [
            TextButton(
              child: Text('Tamam'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
      return;
    }
    records.add(Record(title, elapsedTime, []));
    setState(() {
      title = "";
      elapsedTime = 0;
    });
  }

  String formatTime(int milliseconds) {
    int seconds = (milliseconds / 1000).truncate();
    int minutes = (seconds / 60).truncate();
    seconds %= 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void addNote() {
    showDialog(
      context: context,
      builder: (context) {
        String note = "";
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text('Not Ekle'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      note = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Not',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
                    labelStyle: TextStyle(fontSize: 14.0),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'İptal',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (selectedRecord.isNotEmpty) {
                    int index = records.indexWhere((record) => record.title == selectedRecord);
                    records[index].notes.add(note);
                    setState(() {});
                    Navigator.of(context).pop();
                  }
                },
                child: Text(
                  'Kaydet',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void deleteNote(int recordIndex, int noteIndex) {
    setState(() {
      records[recordIndex].notes.removeAt(noteIndex);
    });
  }

  void editNote(int recordIndex, int noteIndex) {
    String note = records[recordIndex].notes[noteIndex];
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text('Not Düzenle'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: TextEditingController(text: note),
                  onChanged: (value) {
                    setState(() {
                      note = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Not',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
                    labelStyle: TextStyle(fontSize: 14.0),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('İptal'),
              ),
              TextButton(
                onPressed: () {
                  records[recordIndex].notes[noteIndex] = note;
                  setState(() {});
                  Navigator.of(context).pop();
                },
                child: Text('Kaydet'),
              ),
            ],
          ),
        );
      },
    );
  }

  void deleteRecord(int index) {
    setState(() {
      records.removeAt(index);
    });
  }

  void calculateSpeed() {
    showDialog(
      context: context,
      builder: (context) {
        double enteredDistance = 0;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Hız Hesapla'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        enteredDistance = double.tryParse(value) ?? 0;
                      });
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Mesafe (metre)',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
                      labelStyle: TextStyle(fontSize: 14.0),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      double meterPerSecond = (enteredDistance / (elapsedTime / 1000)).toDouble();
                      double kilometerPerHour = (meterPerSecond * 3.6).toDouble();

                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Hız Sonuçları'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Mesafe: $enteredDistance metre'),
                                Text('Süre: ${formatTime(elapsedTime)}'),
                                Text('Hızlar:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                Text('Metre/Saniye: $meterPerSecond m/s'),
                                Text('Kilometre/Saat: $kilometerPerHour km/h'),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  'Kapat',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text(
                      'Hız Hesapla',
                      style: TextStyle(fontSize: 14.0),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red[100],
                      minimumSize: Size(100, 50), // Buton genişliği
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'İptal',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RİTMOOOO'),
        backgroundColor: Colors.red[100],
      ),
      backgroundColor: Colors.grey[300],

      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                formatTime(elapsedTime),
                style: TextStyle(fontSize: 48.0),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: isRunning ? null : startTimer,
                    child: Text('Başlat'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red[100],
                    ),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: isRunning ? stopTimer : null,
                    child: Text('Durdur'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red[100],
                    ),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: isRunning ? null : saveRecord,
                    child: Text('Kaydet'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red[100],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextField(
                onChanged: (value) {
                  setState(() {
                    title = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Başlık',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
                  labelStyle: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: colors[index % colors.length],
                      child: ListTile(
                        title: Text(records[index].title),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            deleteRecord(index);
                          },
                        ),
                        onTap: () {
                          setState(() {
                            selectedRecord = records[index].title;
                          });
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Açıklama'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(records[index].title),
                                    Text('Geçen Süre: ${formatTime(records[index].elapsedTime)}'),
                                    ElevatedButton(
                                      onPressed: () {
                                        calculateSpeed();
                                      },
                                      child: Text(
                                        'Hız Hesapla',
                                        style: TextStyle(fontSize: 14.0),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.red[100],
                                        minimumSize: Size(150,40), // Buton genişliği
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        addNote();
                                      },
                                      child: Text(
                                        'Not Ekle',
                                        style: TextStyle(fontSize: 14.0,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.red[100],
                                        minimumSize: Size(150, 40), // Buton genişliği
                                      ),
                                    ),
                                    SizedBox(height: 8),

                                    Container(
                                      height: 2,
                                      width: double.infinity,
                                      color: Colors.white,
                                      margin: EdgeInsets.symmetric(vertical: 8),
                                    ),

                                    Text('Notlar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    Column(
                                      children: records[index].notes.asMap().entries.map((entry) {
                                        int noteIndex = entry.key;
                                        String note = entry.value;
                                        return Column(
                                          children: <Widget>[
                                            ListTile(
                                              title: Text(note),
                                              trailing: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon: Icon(Icons.edit),
                                                    onPressed: () {
                                                      editNote(index, noteIndex);
                                                    },
                                                  ),
                                                  IconButton(
                                                    icon: Icon(Icons.delete),
                                                    onPressed: () {
                                                      deleteNote(index, noteIndex);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (noteIndex < records[index].notes.length - 1) Divider(
                                              thickness: 2,
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      'İptal',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

List<Color> colors = [Colors.purple[100]!, Colors.deepPurple[100]!, Colors.indigo[100]!, Colors.blue[100]!, Colors.lightBlue[100]!];
