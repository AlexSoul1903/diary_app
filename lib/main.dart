import 'package:audioplayers/audioplayers.dart';
import 'package:diary_app/NavBar.dart';
import 'package:diary_app/util/AudiosLogic.dart';
import 'package:diary_app/util/DatesLogic.dart';
import 'package:diary_app/util/EntriesDbLogic.dart';
import 'package:diary_app/views/Contratame.dart';
import 'package:diary_app/views/EntryDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'models/DbManager.dart';
import 'models/Diary.dart';
import 'package:intl/intl.dart';
import 'util/FotosLogic.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Diary App',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          hintColor: Colors.deepPurple,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => MyHomePage(),
          '/Contratame': (context) => Contratame(),
        });
  }
}

final formKey = GlobalKey<FormState>();
final audioRecorder = FlutterSoundRecorder();
final audioPlayer = AudioPlayer();
String pathAudio = '';
bool isRecorderReady = false;
DateLogic dateLogic = DateLogic();
FotosLogic fotosLogic = FotosLogic();
EntriesDbLogic entriesDbLogic = EntriesDbLogic();

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

final DbManager dbManager = DbManager();

class _MyHomePageState extends State<MyHomePage> {
  void actualizarEstado() {
    setState(() {});
  }

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final audio = AudiosLogic();
  DiaryEntry? selectedEntry;

  @override
  void initState() {
    super.initState();
    fotosLogic.stateUpdateCallback = actualizarEstado;
    dateLogic.stateUpdateCallback = actualizarEstado;
    audio.initRecorder();
    entriesDbLogic.loadEntriesList();
    entriesDbLogic.stateUpdateCallback = actualizarEstado;

    if (dateLogic.selectedDate == null) {
      dateLogic.selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  final titleFilterController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavBar(),
      appBar: AppBar(
        title: Text('Diary App'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: <Widget>[
          Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Título",
                  ),
                  controller: titleController,
                  validator: (val) => val!.isNotEmpty
                      ? null
                      : 'El titulo no puede estar vacío.',
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Descripción",
                  ),
                  controller: descriptionController,
                  validator: (val) => val!.isNotEmpty
                      ? null
                      : 'La descripción no puede estar vacia.',
                ),
                SizedBox(height: 16),
                Container(
                  height: 280.0,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: fotosLogic.img == null
                        ? Text(
                            'No hay imagen',
                            textAlign: TextAlign.center,
                          )
                        : Image.file(fotosLogic.img!),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Fecha: ${DateFormat('dd MMM yyyy').format(dateLogic.selectedDate ?? DateTime.now())}',
                  style: TextStyle(fontSize: 16),
                ),
                ElevatedButton(
                  onPressed: () {
                    dateLogic.selectDate(context);
                  },
                  child: Text('Seleciona una fecha'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    entriesDbLogic.saveEntry(
                      context,
                      titleController.text,
                      descriptionController.text,
                      selectedEntry,
                      dateLogic.selectedDate ?? DateTime.now(),
                    );
                    titleController.clear();
                    descriptionController.clear();
                  },
                  child: Text('Guardar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    entriesDbLogic.deleteAllEntries(context);
                  },
                  child: Text('Borrar todo.'),
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Filtrar por título',
                  ),
                  controller: titleFilterController,
                  onChanged: (value) {
                    entriesDbLogic.filterEntriesByTitle(value);
                  },
                ),
                SizedBox(height: 16),
                if (audioRecorder.isRecording)
                  Center(
                    child: StreamBuilder<RecordingDisposition>(
                      stream: audioRecorder.onProgress,
                      builder: ((context, snapshot) {
                        final duration = snapshot.hasData
                            ? snapshot.data!.duration
                            : Duration.zero;

                        String dosDigitos(int n) => n.toString().padLeft(6);
                        final dosMinutosDigito =
                            dosDigitos(duration.inMinutes.remainder(60));
                        final dosSegundosDigito =
                            dosDigitos(duration.inSeconds.remainder(60));

                        return Text(
                          '$dosMinutosDigito:$dosSegundosDigito',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }),
                    ),
                  ),
                SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: entriesDbLogic.entriesList.length,
                  itemBuilder: (BuildContext context, int index) {
                    DiaryEntry entry = entriesDbLogic.entriesList[index];
                    DateTime date = DateFormat('yyyy-MM-dd').parse(entry.date);
                    String formattedDate =
                        DateFormat('yyyy-MM-dd').format(date);

                    return ListTile(
                      title: Text(entry.title),
                      subtitle: Text(formattedDate),
                      trailing: IconButton(
                        onPressed: () {
                          setState(() {
                            entriesDbLogic.deleteEntry(context, entry);
                          });
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EntryDetailPage(entry),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FloatingActionButton(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            child: Icon(Icons.photo_camera),
            onPressed: () {
              fotosLogic.tomarFoto(ImageSource.camera);
            },
          ),
          SizedBox(width: 16),
          FloatingActionButton(
            backgroundColor: Colors.brown,
            foregroundColor: Colors.white,
            child: Icon(Icons.photo_library),
            onPressed: () {
              fotosLogic.tomarFoto(ImageSource.gallery);
            },
          ),
          SizedBox(width: 16),
          FloatingActionButton(
            backgroundColor: audioRecorder.isRecording
                ? const Color.fromARGB(255, 189, 36, 25)
                : const Color.fromARGB(255, 196, 15, 75),
            foregroundColor: Colors.white,
            child: Icon(
              audioRecorder.isRecording ? Icons.stop : Icons.mic,
              size: 15,
            ),
            onPressed: () async {
              audioRecorder.isRecording
                  ? await audio.pararAudio()
                  : await audio.grabarAudio();

              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}
