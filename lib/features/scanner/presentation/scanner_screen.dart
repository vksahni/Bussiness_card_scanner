import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/widgets/section_card.dart';
import '../../../providers/app_providers.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  CameraController? _cameraController;
  bool _busy = false;
  String _qrData = '';
  String? _status;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final permission = await Permission.camera.request();
    if (!permission.isGranted) {
      setState(() => _status = 'Camera permission is required.');
      return;
    }
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      setState(() => _status = 'No camera found on this device.');
      return;
    }
    final controller = CameraController(cameras.first, ResolutionPreset.high, enableAudio: false);
    await controller.initialize();
    if (mounted) {
      setState(() => _cameraController = controller);
    }
  }

  Future<void> _captureAndProcess() async {
    final controller = _cameraController;
    final user = ref.read(currentUserProvider);
    if (controller == null || !controller.value.isInitialized || user == null) {
      return;
    }
    setState(() {
      _busy = true;
      _status = 'Capturing and parsing business card...';
    });
    try {
      final shot = await controller.takePicture();
      final cropped = await ImageCropper().cropImage(
        sourcePath: shot.path,
        compressQuality: 92,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Adjust Card Crop',
            lockAspectRatio: false,
            hideBottomControls: false,
          ),
        ],
      );
      final path = cropped?.path ?? shot.path;
      final documents = await getApplicationDocumentsDirectory();
      final target = File(p.join(documents.path, p.basename(path)));
      await File(path).copy(target.path);
      final record = await ref.read(ocrParserProvider).extractFromImage(
            imageFile: target,
            userEmail: user.email,
            qrData: _qrData,
          );
      if (mounted) {
        context.push('/ocr-review', extra: record);
      }
    } catch (error) {
      setState(() => _status = 'Scanner failed: $error');
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _cameraController;
    final cameraReady = controller != null && controller.value.isInitialized;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Scanner Workspace', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('Camera capture, QR detection, crop adjustment, and OCR review are combined into one flow.'),
          const SizedBox(height: 24),
          SizedBox(
            height: 420,
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: cameraReady
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        CameraPreview(controller),
                        Positioned(
                          left: 16,
                          right: 16,
                          top: 16,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              'Align the business card inside frame. Manual crop opens after capture.',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 16,
                          bottom: 16,
                          child: FloatingActionButton.extended(
                            onPressed: _busy ? null : _captureAndProcess,
                            label: Text(_busy ? 'Processing' : 'Capture'),
                            icon: const Icon(Icons.camera_alt_rounded),
                          ),
                        ),
                      ],
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
          ),
          const SizedBox(height: 20),
          SectionCard(
            title: 'QR Auto Detection',
            subtitle: 'URLs, vCards, and deep links are captured while the camera preview is open.',
            child: SizedBox(
              height: 180,
              child: MobileScanner(
                controller: MobileScannerController(formats: const [BarcodeFormat.qrCode]),
                onDetect: (capture) {
                  final code = capture.barcodes.firstOrNull?.rawValue ?? '';
                  if (code.isNotEmpty && mounted) {
                    setState(() => _qrData = code);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_qrData.isNotEmpty) Text('QR payload: $_qrData'),
          if (_status != null) ...[
            const SizedBox(height: 8),
            Text(_status!),
          ],
        ],
      ),
    );
  }
}
