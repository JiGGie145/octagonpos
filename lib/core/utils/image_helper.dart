import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

const _imageDir = 'product_images';
const _uuid = Uuid();

/// Copies [sourceFile] into the app's documents directory under
/// `product_images/` and returns the destination path.
Future<String> saveProductImage(File sourceFile) async {
  final docs = await getApplicationDocumentsDirectory();
  final dir = Directory(p.join(docs.path, _imageDir));
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  final ext = p.extension(sourceFile.path);
  final destPath = p.join(dir.path, '${_uuid.v4()}$ext');
  await sourceFile.copy(destPath);
  return destPath;
}

/// Deletes a previously saved product image at [path].
/// No-op if the file doesn't exist.
Future<void> deleteProductImage(String path) async {
  final file = File(path);
  if (await file.exists()) {
    await file.delete();
  }
}

/// Returns `true` when [path] points to a local file rather than a URL.
bool isLocalImagePath(String path) =>
    path.startsWith('/') || path.startsWith('file://');
