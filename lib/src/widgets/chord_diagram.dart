import 'package:flutter/widgets.dart';

import '../chord.dart';
import 'chord_diagram_style.dart';

class ChordDiagram extends StatelessWidget {
  const ChordDiagram({
    super.key,
    required this.position,
    required this.stringCount,
    this.title,
    this.style = const ChordDiagramStyle(),
    this.semanticLabel,
  });

  final ChordPosition position;
  final int stringCount;
  final String? title;
  final ChordDiagramStyle style;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final frets = _parsePositionValues(position.frets);
    final fingers = _parsePositionValues(position.fingers);
    final validFrets = frets.length == stringCount;
    final validFingers = fingers.length == stringCount;
    final label = semanticLabel ?? _defaultSemanticLabel();

    return Semantics(
      label: label,
      image: true,
      child: SizedBox.fromSize(
        size: style.size,
        child: CustomPaint(
          painter: _ChordDiagramPainter(
            position: position,
            stringCount: stringCount,
            title: title,
            style: style,
            frets: validFrets ? frets : const [],
            fingers: validFingers ? fingers : const [],
          ),
        ),
      ),
    );
  }

  String _defaultSemanticLabel() {
    final name = title == null || title!.trim().isEmpty ? 'Chord' : title!;
    return '$name diagram, frets ${position.frets}, fingers ${position.fingers}';
  }
}

List<int> _parsePositionValues(String values) {
  final parts = values.trim().split(RegExp(r'\s+'));
  if (parts.length == 1 && parts.single.isEmpty) return const [];

  final parsed = <int>[];
  for (final part in parts) {
    final value = int.tryParse(part);
    if (value == null) return const [];
    parsed.add(value);
  }
  return parsed;
}

class _ChordDiagramPainter extends CustomPainter {
  const _ChordDiagramPainter({
    required this.position,
    required this.stringCount,
    required this.title,
    required this.style,
    required this.frets,
    required this.fingers,
  });

  final ChordPosition position;
  final int stringCount;
  final String? title;
  final ChordDiagramStyle style;
  final List<int> frets;
  final List<int> fingers;

  static const int _minimumVisibleFrets = 4;
  static const double _markerBandHeight = 18;
  static const double _titleBandHeight = 24;
  static const double _baseFretBandWidth = 22;

  @override
  void paint(Canvas canvas, Size size) {
    if (style.backgroundColor != const Color(0x00000000)) {
      canvas.drawRect(
          Offset.zero & size, Paint()..color = style.backgroundColor);
    }

    if (stringCount < 2 || frets.length != stringCount) {
      _paintInvalidState(canvas, size);
      return;
    }

    final titleHeight = _hasTitle ? _titleBandHeight : 0.0;
    final baseFretWidth =
        style.showBaseFret && position.baseFret > 1 ? _baseFretBandWidth : 0.0;
    final diagramLeft = style.padding.left + baseFretWidth;
    final diagramTop = style.padding.top + titleHeight + _markerBandHeight;
    final diagramRight = size.width - style.padding.right;
    final diagramBottom = size.height - style.padding.bottom;
    final diagramSize = Size(
      (diagramRight - diagramLeft).clamp(0, double.infinity),
      (diagramBottom - diagramTop).clamp(0, double.infinity),
    );

    if (diagramSize.width <= 0 || diagramSize.height <= 0) return;

    final visibleFrets = _visibleFretCount;
    final stringSpacing = diagramSize.width / (stringCount - 1);
    final fretSpacing = diagramSize.height / visibleFrets;

    if (_hasTitle) {
      _paintCenteredText(
        canvas,
        title!,
        style.titleTextStyle,
        Rect.fromLTWH(0, style.padding.top, size.width, _titleBandHeight),
      );
    }

    _paintOpenAndMutedMarkers(
      canvas,
      diagramLeft,
      diagramTop - _markerBandHeight,
      stringSpacing,
    );
    _paintFretboard(
      canvas,
      diagramLeft,
      diagramTop,
      diagramSize,
      stringSpacing,
      fretSpacing,
      visibleFrets,
    );
    _paintBaseFret(canvas, diagramLeft, diagramTop, fretSpacing);
    _paintFingerMarkers(
        canvas, diagramLeft, diagramTop, stringSpacing, fretSpacing);
  }

  bool get _hasTitle => title != null && title!.trim().isNotEmpty;

  int get _visibleFretCount {
    final maxFret = frets
        .where((fret) => fret > 0)
        .fold<int>(0, (max, fret) => fret > max ? fret : max);
    return maxFret > _minimumVisibleFrets ? maxFret : _minimumVisibleFrets;
  }

  void _paintInvalidState(Canvas canvas, Size size) {
    _paintCenteredText(
      canvas,
      'Invalid chord',
      style.baseFretTextStyle,
      Offset.zero & size,
    );
  }

  void _paintOpenAndMutedMarkers(
    Canvas canvas,
    double left,
    double top,
    double stringSpacing,
  ) {
    for (var stringIndex = 0; stringIndex < stringCount; stringIndex++) {
      final fret = frets[stringIndex];
      if (fret != 0 && fret != -1) continue;

      final text = fret == 0 ? 'o' : 'x';
      final textStyle =
          fret == 0 ? style.openStringTextStyle : style.mutedStringTextStyle;
      final x = left + stringSpacing * stringIndex;
      _paintCenteredText(
        canvas,
        text,
        textStyle,
        Rect.fromCenter(
          center: Offset(x, top + _markerBandHeight / 2),
          width: 18,
          height: _markerBandHeight,
        ),
      );
    }
  }

  void _paintFretboard(
    Canvas canvas,
    double left,
    double top,
    Size diagramSize,
    double stringSpacing,
    double fretSpacing,
    int visibleFrets,
  ) {
    final stringPaint = Paint()
      ..color = style.stringColor
      ..strokeWidth = style.stringStrokeWidth
      ..strokeCap = StrokeCap.round;
    final fretPaint = Paint()
      ..color = style.fretColor
      ..strokeWidth = style.fretStrokeWidth
      ..strokeCap = StrokeCap.round;
    final nutPaint = Paint()
      ..color = style.nutColor
      ..strokeWidth = style.nutStrokeWidth
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < stringCount; i++) {
      final x = left + stringSpacing * i;
      canvas.drawLine(
          Offset(x, top), Offset(x, top + diagramSize.height), stringPaint);
    }

    for (var i = 0; i <= visibleFrets; i++) {
      final y = top + fretSpacing * i;
      canvas.drawLine(
        Offset(left, y),
        Offset(left + diagramSize.width, y),
        i == 0 && position.baseFret == 1 ? nutPaint : fretPaint,
      );
    }
  }

  void _paintBaseFret(
    Canvas canvas,
    double left,
    double top,
    double fretSpacing,
  ) {
    if (!style.showBaseFret || position.baseFret <= 1) return;

    _paintCenteredText(
      canvas,
      '${position.baseFret}fr',
      style.baseFretTextStyle,
      Rect.fromLTWH(
        left - _baseFretBandWidth,
        top + fretSpacing * 0.15,
        _baseFretBandWidth - 3,
        fretSpacing,
      ),
    );
  }

  void _paintFingerMarkers(
    Canvas canvas,
    double left,
    double top,
    double stringSpacing,
    double fretSpacing,
  ) {
    final fillPaint = Paint()..color = style.fingerColor;
    final borderPaint = Paint()
      ..color = style.fingerBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = style.fingerBorderWidth;

    for (var stringIndex = 0; stringIndex < stringCount; stringIndex++) {
      final fret = frets[stringIndex];
      if (fret <= 0) continue;

      final center = Offset(
        left + stringSpacing * stringIndex,
        top + fretSpacing * (fret - 0.5),
      );
      canvas.drawCircle(center, style.fingerRadius, fillPaint);
      if (style.fingerBorderWidth > 0) {
        canvas.drawCircle(center, style.fingerRadius, borderPaint);
      }

      if (!style.showFingerNumbers || fingers.isEmpty) continue;

      final finger = fingers[stringIndex];
      if (finger <= 0) continue;

      _paintCenteredText(
        canvas,
        '$finger',
        style.fingerTextStyle,
        Rect.fromCircle(center: center, radius: style.fingerRadius),
      );
    }
  }

  void _paintCenteredText(
    Canvas canvas,
    String text,
    TextStyle style,
    Rect rect,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: rect.width);
    final offset = Offset(
      rect.left + (rect.width - textPainter.width) / 2,
      rect.top + (rect.height - textPainter.height) / 2,
    );
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_ChordDiagramPainter oldDelegate) {
    return position != oldDelegate.position ||
        stringCount != oldDelegate.stringCount ||
        title != oldDelegate.title ||
        style != oldDelegate.style ||
        frets != oldDelegate.frets ||
        fingers != oldDelegate.fingers;
  }
}
