import 'dart:io';
import 'package:image_picker/image_picker.dart';

typedef StateUpdateCallback = void Function();

class FotosLogic {
  File? img;
  StateUpdateCallback? stateUpdateCallback;

  void tomarFoto(ImageSource source) async {
    ImagePicker imagePicker = ImagePicker();

    var image = await imagePicker.pickImage(source: source);
    if (stateUpdateCallback != null) {
      img = image != null ? File(image.path) : null;
      stateUpdateCallback!(); // Llamada a la función de devolución de llamada para actualizar el estado
    }
  }
}
