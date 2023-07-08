import 'package:diary_app/models/Diary.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../models/DbManager.dart';

typedef StateUpdateCallback = void Function();

class EntriesDbLogic {
  StateUpdateCallback? stateUpdateCallback;
  void saveEntry(BuildContext context, String title, String descripcion,
      DiaryEntry? selectedEntry, DateTime selectedDate) {
    String date = dateLogic.selectedDate.toString();

    if (formKey.currentState!.validate()) {
      if (selectedEntry == null) {
        DiaryEntry entry = DiaryEntry(
          title: title,
          date: date != null ? date : selectedDate.toString(),
          description: descripcion,
          photo: fotosLogic.img != null ? fotosLogic.img!.path : '',
          audio: pathAudio != '' ? pathAudio : '',
        );
        DbManager.addEntry(entry).then((_) {
          pathAudio = '';
          fotosLogic.img = null;
          dateLogic.selectedDate = DateTime.now();
          loadEntriesList();
        });
      }
    }
  }

  void filterEntriesByDate(DateTime startDate, DateTime endDate) async {
    entriesList = await DbManager.getEntriesByDate(startDate, endDate);
    stateUpdateCallback!();
  }

  List<DiaryEntry> entriesList = [];
  void loadEntriesList() async {
    List<DiaryEntry> entries = await DbManager.getEntries();

    entriesList = entries;

    stateUpdateCallback!();
  }

  void deleteEntry(BuildContext context, DiaryEntry entry) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Borrar entrada'),
          content: Text('¿Estás seguro de que quieres borrar esta entrada?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                DbManager.deleteEntry(entry.id).then((_) {
                  // Borramos la entrada seleccionada
                  loadEntriesList();
                  Navigator.pop(context);
                });
              },
              child: Text('Borrar'),
            ),
          ],
        );
      },
    );
  }

  void filterEntriesByTitle(String title) async {
    entriesList = await DbManager.getEntriesByTitle(title);
    stateUpdateCallback!();
  }

  void deleteAllEntries(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Borrar todas las entradas'),
          content:
              Text('Estas seguro de que quieres borrar todas las entradas?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                DbManager.deleteAllEntries().then((_) {
                  loadEntriesList();
                  Navigator.pop(context);
                });
              },
              child: Text('Borrar'),
            ),
          ],
        );
      },
    );
  }
}
