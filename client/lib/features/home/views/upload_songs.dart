import 'dart:io';

import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/core/widgets/music_theme.dart';
import 'package:client/core/widgets/utils.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:client/features/home/views/home_page.dart';
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

class _UploadSongsPageState extends ConsumerState<UploadSongsPage>
    with SingleTickerProviderStateMixin {
  List<TextEditingController> controllers =
      List.generate(2, (index) => TextEditingController());

  Color selectedColor = Pallete.cardColor;

  File? selectedImage;
  File? selectedAudio;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    _animationController.dispose();
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

  void _uploadSong() async {
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

      setState(() {
        selectedAudio = null;
        selectedImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          backgroundColor: selectedColor.withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              const Text(
                'Song uploaded successfully!',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );

      Navigator.push(context, MaterialPageRoute(builder: (_) => HomePage()));
    } else {
      showSnackBar(
        content: 'Please complete all required fields',
        context: context,
        backgroundColor: Colors.red.shade400,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref
        .watch(homeViewmodelProvider.select((val) => val?.isLoading == true));

    return MusicThemeBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_outlined,
                color: Colors.white,
              ),
            ),
          ),
          title: const Text(
            'Upload Your Track',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          actions: [
            GestureDetector(
              onTap: _uploadSong,
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.cloud_upload_outlined,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        body: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    selectedColor.withValues(alpha: 0.5),
                    selectedColor
                        .withBlue((selectedColor.blue + 40).clamp(0, 255))
                        .withValues(alpha: 0.5),
                    Colors.black.withValues(alpha: 0.5),
                  ],
                ),
              ),
              child: Opacity(
                opacity: _animation.value,
                child: child,
              ),
            );
          },
          child: isLoading
              ? const Center(child: LoaderWidget())
              : SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            const Text(
                              'Add Cover Art',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: selectImage,
                              child: Container(
                                height: 220,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: selectedImage != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(24),
                                        child: Image.file(
                                          selectedImage!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : DottedBorder(
                                        radius: const Radius.circular(24),
                                        strokeCap: StrokeCap.round,
                                        dashPattern: const [8, 8],
                                        color: Colors.white70,
                                        borderType: BorderType.RRect,
                                        padding: const EdgeInsets.all(1),
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  color: Colors.white12,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.image_outlined,
                                                  size: 40,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              const Text(
                                                'Select Cover Art',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Recommended size: 1000 x 1000 px',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.7),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            const Text(
                              'Add Audio Track',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: selectedAudio != null
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: selectedColor.withValues(
                                                    alpha: 0.3),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.music_note,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                selectedAudio!.path
                                                    .split('/')
                                                    .last,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  selectedAudio = null;
                                                });
                                              },
                                              icon: const Icon(
                                                Icons.close,
                                                color: Colors.white70,
                                                size: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          height: 80,
                                          child: AudioWave(
                                              path: selectedAudio!.path),
                                        ),
                                      ],
                                    )
                                  : InkWell(
                                      onTap: selectAudio,
                                      borderRadius: BorderRadius.circular(24),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: selectedColor.withValues(
                                                    alpha: 0.3),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.audiotrack,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            const Text(
                                              'Select Audio File',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 32),
                            const Text(
                              'Track Details',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildCustomField(
                              controllers[0],
                              'Artist Name',
                              Icons.person_outline,
                              (val) => val!.isEmpty
                                  ? 'Artist name is required'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            _buildCustomField(
                              controllers[1],
                              'Track Title',
                              Icons.music_note_outlined,
                              (val) => val!.isEmpty
                                  ? 'Track title is required'
                                  : null,
                            ),
                            const SizedBox(height: 32),
                            const Text(
                              'Theme Color',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: ColorPicker(
                                pickersEnabled: const {
                                  ColorPickerType.wheel: true
                                },
                                enableShadesSelection: false,
                                showColorCode: true,
                                colorCodeHasColor: true,
                                copyPasteBehavior:
                                    const ColorPickerCopyPasteBehavior(
                                  copyFormat: ColorPickerCopyFormat.hexRRGGBB,
                                ),
                                heading: Text(
                                  'Select Theme Color',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                color: selectedColor,
                                onColorChanged: (Color color) {
                                  setState(() {
                                    selectedColor = color;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 40),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _uploadSong,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: selectedColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.cloud_upload_outlined),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Upload Track',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildCustomField(
    TextEditingController controller,
    String hintText,
    IconData icon,
    String? Function(String?)? validator,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
          prefixIcon: Icon(icon, color: Colors.white70),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
