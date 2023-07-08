import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:diary_app/main.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class AudiosLogic {
  Future initRecorder() async {
    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      throw 'El permiso no fue concedido';
    }

    await audioRecorder.openRecorder();
    isRecorderReady = true;
    audioRecorder.setSubscriptionDuration(
      const Duration(milliseconds: 500),
    );
  }

  Future grabarAudio() async {
    if (!isRecorderReady) return;
    String timeStamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    String fileName = 'audio_$timeStamp';
    await audioRecorder.startRecorder(toFile: fileName);
  }

  Future playAudio(String fileRoute) async {
    final file = File(fileRoute);

    if (!file.existsSync()) {
      print('El archivo de audio no existe');
      return;
    }

    await audioPlayer.play(DeviceFileSource(fileRoute));
  }

  Future stopAudio() async {
    await audioPlayer.stop();
  }

  Future pararAudio() async {
    if (!isRecorderReady) return;
    final path = await audioRecorder.stopRecorder();

    final audioFile = File(path!);
    pathAudio = audioFile.path;
    print('Route: $audioFile');
  }
}
