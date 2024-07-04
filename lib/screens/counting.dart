import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:kidstarter/entities/number.dart';
import 'package:kidstarter/widgets/page_header.dart';
import 'package:kidstarter/widgets/tile_card.dart';

Future<List<NumberEntity>> _fetchNumbers() async {
  String jsonString = await rootBundle.loadString('assets/data/numbers.json');
  final jsonParsed = json.decode(jsonString);

  return jsonParsed
      .map<NumberEntity>((json) => NumberEntity.fromJson(json))
      .toList();
}

class CountingScreen extends StatefulWidget {
  final String title;
  final Color primaryColor;
  final Color secondaryColor;

  const CountingScreen({
    Key? key,
    required this.title,
    required this.primaryColor,
    required this.secondaryColor,
  }) : super(key: key);

  @override
  _CountingScreenState createState() => _CountingScreenState();
}

class _CountingScreenState extends State<CountingScreen> {
  late Future<List<NumberEntity>> _numbersFuture;
  late FlutterSoundPlayer _soundPlayer;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _numbersFuture = _fetchNumbers();
    _soundPlayer = FlutterSoundPlayer();
  }

  void _playAudio(String audioPath) async {
    try {
      ByteData byteData = await rootBundle.load('assets/audio/$audioPath');
      Uint8List buffer = byteData.buffer.asUint8List();

      await _soundPlayer.startPlayer(
        fromDataBuffer: buffer,
        codec: Codec.mp3,
      );
    } catch (e) {
      print('Error playing audio: $e');
      // Gérer l'erreur selon vos besoins
    }
  }

  Color getIndexColor(int index) {
    // Exemple de logique pour obtenir la couleur en fonction de l'index
    if (index % 2 == 0) {
      return Colors.blue; // Par exemple, couleur bleue pour les index pairs
    } else {
      return Colors.red; // Par exemple, couleur rouge pour les index impairs
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
            child: FutureBuilder<List<NumberEntity>>(
              future: _numbersFuture,
              builder: (context, AsyncSnapshot<List<NumberEntity>> snapshot) {
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
                            title: snapshot.data![index].text,
                            textColor: getIndexColor(
                                index), // Utilisation de getIndexColor ici
                            onTap: () {
                              setState(() {
                                _selectedIndex = index;
                              });
                              _playAudio(snapshot.data![index].audio);
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

  @override
  @override
  void dispose() {
    _soundPlayer.stopPlayer(); // Arrêter la lecture audio si elle est en cours
    super.dispose();
  }
}
