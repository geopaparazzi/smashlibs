import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

/// A TileProvider that renders tiles client-side with their `z/x/y`
/// coordinates and a visible border. Handy for debugging.
class DebugTileProvider extends TileProvider {
  final int tileSize;

  DebugTileProvider({this.tileSize = 256});

  @override
  ImageProvider getImage(TileCoordinates coords, TileLayer options) {
    return _DebugTileImage(
      x: coords.x.round(),
      y: coords.y.round(),
      z: coords.z.round(),
      tileSize: tileSize,
    );
  }

  // If you want cancelable loading, you can also override
  // getImageWithCancelLoadingSupport(...) later.
}

class _DebugTileImage extends ImageProvider<_DebugTileImage> {
  final int x, y, z, tileSize;

  const _DebugTileImage({
    required this.x,
    required this.y,
    required this.z,
    required this.tileSize,
  });

  @override
  Future<_DebugTileImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<_DebugTileImage>(this);

  @override
  ImageStreamCompleter loadImage(
    _DebugTileImage key,
    ImageDecoderCallback decode,
  ) {
    return OneFrameImageStreamCompleter(_loadAsync());
  }

  Future<ImageInfo> _loadAsync() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(tileSize.toDouble(), tileSize.toDouble());

    // Background
    // final bg = Paint()..color = const Color(0xFFEFEFEF);
    // canvas.drawRect(Offset.zero & size, bg);

    // Border
    final border = Paint()
      ..color = const Color(0xFFDD3333)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(Offset.zero & size, border);

    // Label
    final label = 'z:$z x:$x y:$y';
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Label background
    const pad = 6.0;
    final textRect = Rect.fromLTWH(
      6,
      104,
      tp.width + pad * 2,
      tp.height + pad * 2,
    );
    final textBg = Paint()..color = Colors.white.withOpacity(0.75);
    canvas.drawRRect(
      RRect.fromRectAndRadius(textRect, const Radius.circular(6)),
      textBg,
    );
    tp.paint(canvas, Offset(textRect.left + pad, textRect.top + pad));

    // Commit picture -> image -> bytes -> codec -> frame
    final picture = recorder.endRecording();
    final image = await picture.toImage(tileSize, tileSize);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = Uint8List.view(byteData!.buffer);
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return ImageInfo(image: frame.image, scale: 1.0);
  }

  @override
  bool operator ==(Object other) =>
      other is _DebugTileImage &&
      other.x == x &&
      other.y == y &&
      other.z == z &&
      other.tileSize == tileSize;

  @override
  int get hashCode => Object.hash(x, y, z, tileSize);
}
