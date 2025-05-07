import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';

void showSnackBar(
    {required String content,
    required BuildContext context,
    Color? backgroundColor,
    Color? textColor}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          content,
          style: TextStyle(color: textColor),
        ),
        backgroundColor: backgroundColor,
      ),
    );
}

bool isPickingFile = false;

Future<File?> pickAudio() async {
  bool isCurrentPicking = false;
  try {
    if (isPickingFile) return null;
    isPickingFile = true;
    isCurrentPicking = true;

    // log('Pick audio button pressed');
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'wav',
        'aiff',
        'alac',
        'flac',
        'mp3',
        'aac',
        'wma',
        'ogg'
      ],
    );

    // log('Audio picker result: $result'); // Log the result

    if (result?.files.isNotEmpty ?? false) {
      final path = result!.files.first.path;
      // log('Picked audio path: $path'); // Log the path of the picked file
      if (path != null) {
        return File(path);
      }
    }
    return null;
  } catch (e) {
    // log('Error picking audio: $e'); // Log the error if something goes wrong
    return null;
  } finally {
    if (isCurrentPicking) isPickingFile = false;
  }
}

Future<File?> pickImage() async {
  bool isCurrentPicking = false;
  try {
    if (isPickingFile) return null;
    isPickingFile = true;
    isCurrentPicking = true;

    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result?.files.isNotEmpty ?? false) {
      final path = result!.files.first.path;
      if (path != null) return File(path);
    }
    return null;
  } catch (e) {
    return null;
  } finally {
    if (isCurrentPicking) isPickingFile = false;
  }
}

String rgbToHex(Color color) {
  return "${color.red.toRadixString(16).padLeft(2, '0')}${color.green.toRadixString(16).padLeft(2, '0')}${color.blue.toRadixString(16).padLeft(2, '0')}";
}

Color hexToColor(String hex) {
  return Color(int.parse(hex, radix: 16) + 0xFF000000);
}

Future<void> requestStoragePermission() async {
  // Request storage permission
  PermissionStatus status = await Permission.storage.request();

  // Check the status of the permission request
  if (status.isGranted) {
    log("Storage permission granted");
  } else if (status.isDenied) {
    log("Storage permission denied");
    openAppSettings();
  } else if (status.isPermanentlyDenied) {
    log("Storage permission permanently denied");
    // Optionally, open app settings to allow the user to enable the permission
    openAppSettings();
  }
}
