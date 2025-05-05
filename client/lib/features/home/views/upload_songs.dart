import 'dart:developer';
import 'dart:io';

import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/widgets/custom_field.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/auth/widgets/utils.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:client/features/home/views/widgets/audio_wave.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UploadSongsPage extends ConsumerStatefulWidget {
  const UploadSongsPage({super.key});

  @override
  ConsumerState<UploadSongsPage> createState() => _UploadSongsPageState();
}

class _UploadSongsPageState extends ConsumerState<UploadSongsPage> {
  List<TextEditingController> controllers =
      List.generate(2, (index) => TextEditingController());

  Color selectedColor = Pallete.cardColor;

  File? selectedImage;
  File? selectedAudio;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void selectAudio() async {
    final audio = await pickAudio();

    if (audio != null) {
      selectedAudio = audio;
    }
    setState(() {});
  }

  void selectImage() async {
    final image = await pickImage();
    if (image != null) {
      selectedImage = image;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref
        .watch(homeViewmodelProvider.select((val) => val?.isLoading == true));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {},
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
          ),
        ),
        title: Text('Upload Song'),
        actions: [
          IconButton(
            onPressed: () async {
              if (_formKey.currentState!.validate() &&
                  selectedAudio != null &&
                  selectedImage != null) {
                await ref.read(homeViewmodelProvider.notifier).uploadSong(
                      selectedaudio: selectedAudio!,
                      selectedThumbnail: selectedImage!,
                      songName: controllers[1].text,
                      artist: controllers[0].text,
                      selectedColor: selectedColor,
                    );

                for (var controller in controllers) {
                  controller.clear();
                }

                selectedAudio == null;
                selectedImage == null;
                setState(() {});
              } else {
                showSnackBar(
                  content: 'Missing fields',
                  context: context,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                );
              }
            },
            icon: Icon(Icons.done),
          ),
        ],
      ),
      body: isLoading
          ? LoaderWidget()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    spacing: 20,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      GestureDetector(
                        onTap: selectImage,
                        child: SizedBox(
                          width: double.maxFinite,
                          height: 150,
                          child: selectedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    selectedImage!,
                                    height: 150,
                                    width: double.maxFinite,
                                    fit: BoxFit.fitHeight,
                                  ),
                                )
                              : DottedBorder(
                                  radius: Radius.circular(10),
                                  strokeCap: StrokeCap.round,
                                  dashPattern: [10, 4],
                                  color: Pallete.borderColor,
                                  child: Center(
                                    child: Column(
                                      spacing: 10,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.folder_open,
                                          size: 40,
                                        ),
                                        Text(
                                          'Select the thumbnail',
                                          style: TextStyle(
                                            fontSize: 15,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      selectedAudio != null
                          ? AudioWave(path: selectedAudio!.path)
                          : CustomField(
                              onTap: selectAudio,
                              readOnly: true,
                              hintText: 'Pick Song',
                            ),
                      CustomField(
                        controller: controllers[0],
                        hintText: 'Arist name',
                        validator: (val) =>
                            val!.isEmpty ? 'Arists name is required' : null,
                      ),
                      CustomField(
                        controller: controllers[1],
                        hintText: 'Song name',
                        validator: (val) =>
                            val!.isEmpty ? 'Song name is required' : null,
                      ),
                      ColorPicker(
                        pickersEnabled: {ColorPickerType.wheel: true},
                        color: selectedColor,
                        onColorChanged: (Color color) {
                          setState(() {
                            selectedColor = color;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
