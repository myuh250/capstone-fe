import 'dart:typed_data';

import 'image_picker_web.dart' if (dart.library.io) 'image_picker_mobile.dart'
    as platform_picker;

class PickedImage {
  const PickedImage({required this.bytes, required this.name});
  final Uint8List bytes;
  final String name;
}

class ImagePickerHelper {
  static Future<PickedImage?> pickImage() {
    return platform_picker.pickImage();
  }
}
