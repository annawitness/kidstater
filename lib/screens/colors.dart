import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:kidstarter/constant.dart';
import 'package:kidstarter/entities/color.dart';
import 'package:kidstarter/widgets/page_header.dart';
import 'package:kidstarter/widgets/tile_card.dart';

Future<List<ColorEntity>> _fetchColors() async {
  String jsonString = await rootBundle.loadString('assets/data/colors.json');
  final jsonParsed = json.decode(jsonString);

  return jsonParsed
      .map<ColorEntity>((json) => ColorEntity.fromJson(json))
      .toList();
}

class ColorsScreen extends StatefulWidget {
  final String title;
  final Color primaryColor;
  final Color secondaryColor;

  const ColorsScreen({
    required this.title,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  _ColorsScreenState createState() => _ColorsScreenState();
}

class _ColorsScreenState extends State<ColorsScreen> {
  late Future<List<ColorEntity>> _colorsFuture;
  late FlutterSoundPlayer _soundPlayer;
  int _selectedIndex = -1; // Initialize to -1 to denote no selection

  @override
  void initState() {
    super.initState();

    _colorsFuture = _fetchColors();
    _soundPlayer = FlutterSoundPlayer();
  }

  void _playAudio(String audioPath) async {
    try {
      // Load audio file from assets
      ByteData byteData = await rootBundle.load('assets/audio/$audioPath');
      Uint8List buffer = byteData.buffer.asUint8List();

      // Start playing audio
      await _soundPlayer.startPlayer(
        fromDataBuffer: buffer,
        codec: Codec.mp3, // Specify the codec if necessary
        sampleRate: 44100, // Specify the sample rate
        numChannels: 1, // Specify the number of channels
      );
    } catch (e) {
      print('Error playing audio: $e');
      // Handle error
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
            child: FutureBuilder<List<ColorEntity>>(
              future: _colorsFuture,
              builder: (context, AsyncSnapshot<List<ColorEntity>> snapshot) {
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
                            title: snapshot.data != null &&
                                    index < snapshot.data!.length
                                ? snapshot.data![index].name
                                : '',
                            textColor: snapshot.data![index].name == 'White'
                                ? kTitleTextColor
                                : Colors.white,
                            backgroundColor: Color(
                                int.tryParse(snapshot.data![index].code) ?? 0),
                            fontSizeBase: 30,
                            fontSizeActive: 40,
                            onTap: () {
                              setState(() {
                                _selectedIndex = index;
                              });
                              _playAudio(snapshot.data != null &&
                                      index < snapshot.data!.length
                                  ? snapshot.data![index].audio
                                  : '');
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
  void dispose() {
    _soundPlayer.closePlayer(); // Release resources
    super.dispose();
  }
}
