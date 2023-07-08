import 'dart:io';

import 'package:diary_app/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/Diary.dart';
import '../util/AudiosLogic.dart';

class EntryDetailPage extends StatefulWidget {
  final DiaryEntry entry;

  EntryDetailPage(this.entry);

  @override
  _EntryDetailPageState createState() => _EntryDetailPageState();
}

final audio = AudiosLogic();

class _EntryDetailPageState extends State<EntryDetailPage> {
  bool isPlayingAudio = false;

  @override
  Widget build(BuildContext context) {
    // Convertir la fecha de String a DateTime
    final date = DateTime.parse(widget.entry.date);

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles'),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text(
                widget.entry.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              title: Text(
                'Fecha',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                DateFormat('dd MMM yyyy').format(date),
              ),
            ),
            ListTile(
              title: Text(
                'Descripción',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                widget.entry.description,
              ),
            ),
            if (widget.entry.photo.isNotEmpty) ...[
              SizedBox(height: 16),
              ListTile(
                title: Text(
                  'Foto',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Image.file(
                  File(widget.entry.photo),
                ),
              ),
            ],
            if (widget.entry.audio != '') ...[
              SizedBox(height: 16),
              ListTile(
                title: Text(
                  'Audio',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: IconButton(
                  onPressed: () {
                    if (isPlayingAudio) {
                      audio.stopAudio();
                    } else {
                      audio.playAudio(widget.entry.audio);
                    }
                    setState(() {
                      isPlayingAudio = !isPlayingAudio;
                    });
                  },
                  icon: Icon(
                    isPlayingAudio ? Icons.pause : Icons.play_arrow,
                  ),
                  color: Colors.teal,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
