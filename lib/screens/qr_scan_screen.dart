import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zxing2/qrcode.dart';
import 'package:utammys_mobile_app/utils/logger.dart';

/// Decodifica un QR desde los bytes BGRA de un frame (corre en un isolate).
String? _decodeQrFromBgra(Map<String, dynamic> args) {
  final bytes = args['bytes'] as Uint8List;
  final w = args['w'] as int;
  final h = args['h'] as int;
  final bpr = args['bpr'] as int;

  final pixels = Int32List(w * h);
  for (int y = 0; y < h; y++) {
    final rowStart = y * bpr;
    final outStart = y * w;
    for (int x = 0; x < w; x++) {
      final i = rowStart + (x << 2); // 4 bytes por pixel (BGRA)
      final b = bytes[i];
      final g = bytes[i + 1];
      final r = bytes[i + 2];
      pixels[outStart + x] = 0xFF000000 | (r << 16) | (g << 8) | b;
    }
  }

  try {
    final source = RGBLuminanceSource(w, h, pixels);
    final bitmap = BinaryBitmap(HybridBinarizer(source));
    final result = QRCodeReader().decode(bitmap);
    return result.text;
  } catch (_) {
    return null;
  }
}

/// Escanea un QR en vivo con la cámara y devuelve (Navigator.pop) el texto.
/// Compatible con simulador arm64 (en simulador no hay cámara → aviso).
class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  CameraController? _controller;
  bool _initializing = true;
  String? _initError;

  bool _handled = false;
  bool _decoding = false;
  DateTime _lastAttempt = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _initializing = false;
          _initError = 'No hay cámara disponible en este dispositivo.';
        });
        return;
      }
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        back,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.bgra8888,
      );
      await controller.initialize();
      await controller.startImageStream(_onFrame);
      if (!mounted) return;
      setState(() {
        _controller = controller;
        _initializing = false;
      });
    } catch (e) {
      logDebug('[QrScan] init error: $e');
      setState(() {
        _initializing = false;
        _initError = 'No se pudo abrir la cámara en este dispositivo.';
      });
    }
  }

  Future<void> _onFrame(CameraImage image) async {
    if (_handled || _decoding) return;
    final now = DateTime.now();
    if (now.difference(_lastAttempt).inMilliseconds < 250) return;
    _lastAttempt = now;
    _decoding = true;
    try {
      final plane = image.planes.first;
      final text = await compute(_decodeQrFromBgra, {
        'bytes': plane.bytes,
        'w': image.width,
        'h': image.height,
        'bpr': plane.bytesPerRow,
      });
      if (!_handled && text != null && text.isNotEmpty) {
        _handled = true;
        await _controller?.stopImageStream();
        if (mounted) Navigator.pop(context, text);
      }
    } catch (e) {
      logDebug('[QrScan] decode error: $e');
    } finally {
      _decoding = false;
    }
  }

  @override
  void dispose() {
    final c = _controller;
    _controller = null;
    if (c != null) {
      if (c.value.isStreamingImages) {
        c.stopImageStream().catchError((_) {});
      }
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Escanear QR', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  /// Cámara a pantalla completa SIN deformar: escala el preview (en su tamaño
  /// real) con BoxFit.cover para cubrir el área disponible recortando el exceso.
  Widget _fullScreenPreview() {
    final controller = _controller!;
    final preview = controller.value.previewSize;
    if (!controller.value.isInitialized || preview == null) {
      return const ColoredBox(color: Colors.black);
    }
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          // previewSize es horizontal; se invierte para retrato manteniendo
          // el mismo aspect ratio que usa CameraPreview.
          width: preview.height,
          height: preview.width,
          child: CameraPreview(controller),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_initializing) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    if (_controller == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.no_photography_outlined,
                  color: Colors.white54, size: 56),
              const SizedBox(height: 16),
              Text(
                _initError ?? 'Cámara no disponible.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              const Text(
                'Puedes agregar el pedido ingresando el código manualmente.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(child: _fullScreenPreview()),
        // Marco guía centrado, con overlay oscuro alrededor (spotlight).
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 3),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 0,
                  spreadRadius: 2000,
                ),
              ],
            ),
          ),
        ),
        const Positioned(
          bottom: 60,
          left: 24,
          right: 24,
          child: Text(
            'Apunta la cámara al código QR de tu correo.\nLo detectamos automáticamente.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
          ),
        ),
      ],
    );
  }
}
