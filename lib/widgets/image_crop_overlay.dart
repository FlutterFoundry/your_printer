import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class ImageCropOverlay extends StatefulWidget {
  final String imagePath;
  final Rect? initialCrop;
  final ValueChanged<Rect> onCropChanged;

  const ImageCropOverlay({
    super.key,
    required this.imagePath,
    this.initialCrop,
    required this.onCropChanged,
  });

  @override
  State<ImageCropOverlay> createState() => _ImageCropOverlayState();
}

class _ImageCropOverlayState extends State<ImageCropOverlay> {
  ui.Image? _image;
  Rect? _cropRect;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final bytes = await File(widget.imagePath).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      setState(() {
        _image = frame.image;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null || _image == null) {
      return Center(
        child: Text(_error ?? 'Failed to load image',
            style: const TextStyle(color: Color(0xFF9E9E9E))),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final image = _image!;
        final imageAspect = image.width / image.height;
        final containerAspect = constraints.maxWidth / constraints.maxHeight;

        double displayWidth, displayHeight;
        if (imageAspect > containerAspect) {
          displayWidth = constraints.maxWidth;
          displayHeight = displayWidth / imageAspect;
        } else {
          displayHeight = constraints.maxHeight;
          displayWidth = displayHeight * imageAspect;
        }

        final scaleX = image.width.toDouble() / displayWidth;
        final scaleY = image.height.toDouble() / displayHeight;

        if (_cropRect == null || widget.initialCrop != null) {
          final initial = widget.initialCrop;
          if (initial != null) {
            _cropRect = Rect.fromLTWH(
              initial.left / scaleX,
              initial.top / scaleY,
              initial.width / scaleX,
              initial.height / scaleY,
            );
          } else {
            _cropRect = Rect.fromLTWH(
              displayWidth * 0.1,
              displayHeight * 0.1,
              displayWidth * 0.8,
              displayHeight * 0.8,
            );
          }
        }

        return GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              _cropRect = _constrainRect(
                _cropRect!.translate(
                  details.delta.dx / scaleX * scaleX,
                  details.delta.dy / scaleY * scaleY,
                ),
                displayWidth,
                displayHeight,
              );
            });
            _emitCrop(scaleX, scaleY);
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              RawImage(
                image: image,
                width: displayWidth,
                height: displayHeight,
                fit: BoxFit.contain,
                color: Colors.white,
                colorBlendMode: BlendMode.dstIn,
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _DimPainter(_cropRect!, displayWidth, displayHeight),
                  ),
                ),
              ),
              Positioned(
                left: _cropRect!.left,
                top: _cropRect!.top,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _cropRect = _constrainRect(
                        Rect.fromLTWH(
                          _cropRect!.left + details.delta.dx,
                          _cropRect!.top,
                          _cropRect!.width - details.delta.dx,
                          _cropRect!.height,
                        ),
                        displayWidth,
                        displayHeight,
                      );
                    });
                    _emitCrop(scaleX, scaleY);
                  },
                  child: _handle(),
                ),
              ),
              Positioned(
                left: _cropRect!.right - 16,
                top: _cropRect!.top,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _cropRect = _constrainRect(
                        Rect.fromLTWH(
                          _cropRect!.left,
                          _cropRect!.top,
                          _cropRect!.width + details.delta.dx,
                          _cropRect!.height,
                        ),
                        displayWidth,
                        displayHeight,
                      );
                    });
                    _emitCrop(scaleX, scaleY);
                  },
                  child: _handle(),
                ),
              ),
              Positioned(
                left: _cropRect!.left,
                top: _cropRect!.bottom - 16,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _cropRect = _constrainRect(
                        Rect.fromLTWH(
                          _cropRect!.left,
                          _cropRect!.top + details.delta.dy,
                          _cropRect!.width,
                          _cropRect!.height - details.delta.dy,
                        ),
                        displayWidth,
                        displayHeight,
                      );
                    });
                    _emitCrop(scaleX, scaleY);
                  },
                  child: _handle(),
                ),
              ),
              Positioned(
                left: _cropRect!.right - 16,
                top: _cropRect!.bottom - 16,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _cropRect = _constrainRect(
                        Rect.fromLTWH(
                          _cropRect!.left,
                          _cropRect!.top,
                          _cropRect!.width + details.delta.dx,
                          _cropRect!.height + details.delta.dy,
                        ),
                        displayWidth,
                        displayHeight,
                      );
                    });
                    _emitCrop(scaleX, scaleY);
                  },
                  child: _handle(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _handle() {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: const Color(0xFFFE7114),
        border: Border.all(color: Colors.white, width: 2),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Rect _constrainRect(Rect rect, double maxW, double maxH) {
    double left = rect.left.clamp(0.0, maxW - 40);
    double top = rect.top.clamp(0.0, maxH - 40);
    double right = rect.right.clamp(left + 40, maxW);
    double bottom = rect.bottom.clamp(top + 40, maxH);
    return Rect.fromLTRB(left, top, right, bottom);
  }

  void _emitCrop(double scaleX, double scaleY) {
    if (_cropRect == null) return;
    widget.onCropChanged(Rect.fromLTWH(
      _cropRect!.left * scaleX,
      _cropRect!.top * scaleY,
      _cropRect!.width * scaleX,
      _cropRect!.height * scaleY,
    ));
  }
}

class _DimPainter extends CustomPainter {
  final Rect cropRect;
  final double totalWidth;
  final double totalHeight;

  _DimPainter(this.cropRect, this.totalWidth, this.totalHeight);

  @override
  void paint(Canvas canvas, Size size) {
    final dimPaint = Paint()..color = Colors.black.withValues(alpha: 0.55);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, totalWidth, cropRect.top),
      dimPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, cropRect.bottom, totalWidth, totalHeight - cropRect.bottom),
      dimPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, cropRect.top, cropRect.left, cropRect.height),
      dimPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(cropRect.right, cropRect.top,
          totalWidth - cropRect.right, cropRect.height),
      dimPaint,
    );

    final borderPaint = Paint()
      ..color = const Color(0xFFFE7114)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(cropRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _DimPainter oldDelegate) => true;
}
