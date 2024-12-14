import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detection.dart';
import 'package:image/image.dart' as img;

class CameraPage extends StatefulWidget {
  final String plantId;

  const CameraPage({super.key, required this.plantId});

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  XFile? _capturedImage;
  final Color customGreen = const Color.fromRGBO(63, 107, 81, 1);
  final DetectionService _detectionService = DetectionService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      print('No cameras found');
      return;
    }

    _cameraController = CameraController(cameras[0], ResolutionPreset.high);
    try {
      _initializeControllerFuture = _cameraController!.initialize();
      await _initializeControllerFuture;
    } catch (e) {
      print('Error initializing camera: $e');
    }

    setState(() {});
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      print('Camera is not initialized');
      return;
    }

    await _initializeControllerFuture;
    try {
      _capturedImage = await _cameraController!.takePicture();
      setState(() {});
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  Future<void> _sendImageToAPI(File image) async {
    setState(() {
      _isLoading = true;
    });

    try {
      File processedImage = await _rotateAndCropImageToSquare(File(_capturedImage!.path));
      var healthData = await _detectionService.healthDetection(processedImage);
      var currentDate = DateTime.now();
      var currentDateOnly = DateTime(currentDate.year, currentDate.month, currentDate.day);

      String statusLowerCase = healthData['status'].toLowerCase();
      await _firestore.collection('plants').doc(widget.plantId).update({
        'plant_health': statusLowerCase,
        'last_health_check': currentDateOnly,
      });

      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data uploaded and updated successfully!')));
    } catch (e) {
      print('Error sending data: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }



  Future<File> _rotateAndCropImageToSquare(File imageFile) async {
    final image = img.decodeImage(await imageFile.readAsBytes());

    if (image == null) {
      throw Exception("Failed to decode image");
    }

    img.Image rotatedImage = image;
    if (image.width > image.height) {
      rotatedImage = img.copyRotate(image, 90);
    }

    int cropSize = rotatedImage.width < rotatedImage.height
        ? rotatedImage.width
        : rotatedImage.height;

    int xOffset = (rotatedImage.width - cropSize) ~/ 2;
    int yOffset = (rotatedImage.height - cropSize) ~/ 2;

    final squareImage = img.copyCrop(rotatedImage, xOffset, yOffset, cropSize, cropSize);

    final processedFilePath = imageFile.path.replaceAll(".jpg", "_processed.jpg");
    final processedFile = File(processedFilePath);
    await processedFile.writeAsBytes(img.encodeJpg(squareImage));
    return processedFile;
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Widget _buildConfirmationPage() {
    return Scaffold(
      appBar: AppBar(title: const Text("Confirm Image")),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Center(
                  child: ClipRect(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.file(
                        File(_capturedImage!.path),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _sendImageToAPI(File(_capturedImage!.path)),
                    icon: const Icon(Icons.send),
                    label: const Text(
                      'Send',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: customGreen, iconColor: Colors.white, minimumSize: Size(150, 50)),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _capturedImage = null;
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text(
                      'Retake',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: customGreen, iconColor: Colors.white, minimumSize: Size(150, 50)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
          if (_isLoading)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.black.withOpacity(0.6),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 20),
                    Text(
                      "Detecting plant health, please wait...",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_capturedImage != null) {
      return _buildConfirmationPage();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                Positioned.fill(
                  child: CameraPreview(_cameraController!),
                ),

                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double sideLength = constraints.maxWidth * 0.75;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Container(
                              width: sideLength,
                              height: sideLength,
                              decoration: BoxDecoration(
                                border: Border.all(color: customGreen, width: 2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Align your plant within the box",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    },
                  ),
                ),

                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: FloatingActionButton(
                      onPressed: _captureImage,
                      backgroundColor: customGreen,
                      child: const Icon(Icons.camera_alt, size: 35, color: Colors.white),
                    ),
                  ),
                ),

                Positioned(
                  top: 40,
                  left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
