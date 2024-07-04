import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:kidstarter/entities/alphabet.dart';
import 'package:kidstarter/widgets/page_header.dart';
import 'package:kidstarter/widgets/tile_card.dart';

Future<List<AlphabetEntity>> _fetchAlphabets() async {
  String jsonString = await rootBundle.loadString('assets/data/alphabets.json');
  final jsonParsed = json.decode(jsonString);

  return jsonParsed
      .map<AlphabetEntity>((json) => AlphabetEntity.fromJson(json))
      .toList();
}

class AlphabetsScreen extends StatefulWidget {
  final String title;
  final Color primaryColor;
  final Color secondaryColor;

  const AlphabetsScreen({
    required this.title,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  _AlphabetsScreenState createState() => _AlphabetsScreenState();
}

class _AlphabetsScreenState extends State<AlphabetsScreen> {
  late Future<List<AlphabetEntity>> _alphabetsFuture;
  late FlutterSoundPlayer _soundPlayer;
  int _selectedIndex = -1; // Initialize to -1 to denote no selection

  @override
  void initState() {
    super.initState();
    _alphabetsFuture = _fetchAlphabets();
    _soundPlayer = FlutterSoundPlayer();
  }

  void _playAudio(String audioPath) async {
    try {
      // Load audio file from assets
      ByteData byteData = await rootBundle.load('assets/audio/$audioPath');
      Uint8List buffer = byteData.buffer.asUint8List();

      // Start playing audio from buffer
      await _soundPlayer.startPlayer(
        fromDataBuffer: buffer,
        codec: Codec.mp3,
      );
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          PageHeader(
            title: widget.title,
            primaryColor: widget.primaryColor,
            secondaryColor: widget.secondaryColor,
          ),
          Expanded(
            child: FutureBuilder<List<AlphabetEntity>>(
              future: _alphabetsFuture,
              builder: (context, AsyncSnapshot<List<AlphabetEntity>> snapshot) {
                if (snapshot.hasData) {
                  return MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20.0,
                      ),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: index % 2 == 0
                              ? const EdgeInsets.only(bottom: 20, left: 20)
                              : const EdgeInsets.only(bottom: 20, right: 20),
                          child: TileCard(
                            isActive: _selectedIndex == index,
                            title: snapshot.data![index].text ?? '',
                            textColor: getIndexColor(index),
                            onTap: () {
                              setState(() {
                                _selectedIndex = index;
                              });
                              _playAudio(snapshot.data![index].audio ?? '');
                            },
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Define the getIndexColor method
  Color getIndexColor(int index) {
    // Example logic for color selection
    if (index % 2 == 0) {
      return Colors.blue;
    } else {
      return Colors.red;
    }
  }

  @override
  void dispose() {
    _soundPlayer.closePlayer();
    super.dispose();
  }
}
