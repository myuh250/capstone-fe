import 'dart:async';
import 'dart:typed_data';
// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'image_picker_helper.dart';

Future<PickedImage?> pickImage() async {
  final completer = Completer<PickedImage?>();
  final input = html.FileUploadInputElement()..accept = 'image/*';
  input.click();

  input.onChange.listen((event) async {
    final files = input.files;
    if (files == null || files.isEmpty) {
      completer.complete(null);
      return;
    }
    final file = files.first;
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    reader.onLoadEnd.listen((_) {
      final bytes = reader.result as Uint8List;
      completer.complete(PickedImage(bytes: bytes, name: file.name));
    });
    reader.onError.listen((_) => completer.complete(null));
  });

  input.onAbort.listen((_) => completer.complete(null));

  return completer.future;
}
