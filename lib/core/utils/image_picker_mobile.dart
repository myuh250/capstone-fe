import 'package:file_picker/file_picker.dart';

import 'image_picker_helper.dart';

Future<PickedImage?> pickImage() async {
  final picked = await FilePicker.platform.pickFiles(
    type: FileType.image,
    withData: true,
  );
  if (picked == null || picked.files.isEmpty) return null;

  final file = picked.files.first;
  final bytes = file.bytes;
  if (bytes == null) return null;

  return PickedImage(bytes: bytes, name: file.name);
}
