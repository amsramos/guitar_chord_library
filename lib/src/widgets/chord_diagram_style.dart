import 'package:flutter/widgets.dart';

@immutable
class ChordDiagramStyle {
  const ChordDiagramStyle({
    this.size = const Size(132, 176),
    this.padding = const EdgeInsets.fromLTRB(18, 10, 18, 14),
    this.backgroundColor = const Color(0x00000000),
    this.stringColor = const Color(0xFF1F2933),
    this.stringStrokeWidth = 1.6,
    this.fretColor = const Color(0xFF6B7280),
    this.fretStrokeWidth = 1.2,
    this.nutColor = const Color(0xFF111827),
    this.nutStrokeWidth = 4,
    this.fingerColor = const Color(0xFF2563EB),
    this.fingerBorderColor = const Color(0xFFFFFFFF),
    this.fingerBorderWidth = 1.2,
    this.fingerRadius = 10,
    this.fingerTextStyle = const TextStyle(
      color: Color(0xFFFFFFFF),
      fontSize: 11,
      fontWeight: FontWeight.w700,
    ),
    this.titleTextStyle = const TextStyle(
      color: Color(0xFF111827),
      fontSize: 16,
      fontWeight: FontWeight.w700,
    ),
    this.baseFretTextStyle = const TextStyle(
      color: Color(0xFF374151),
      fontSize: 11,
      fontWeight: FontWeight.w600,
    ),
    this.openStringTextStyle = const TextStyle(
      color: Color(0xFF111827),
      fontSize: 14,
      fontWeight: FontWeight.w700,
    ),
    this.mutedStringTextStyle = const TextStyle(
      color: Color(0xFF991B1B),
      fontSize: 14,
      fontWeight: FontWeight.w700,
    ),
    this.showFingerNumbers = true,
    this.showBaseFret = true,
  });

  final Size size;
  final EdgeInsets padding;
  final Color backgroundColor;
  final Color stringColor;
  final double stringStrokeWidth;
  final Color fretColor;
  final double fretStrokeWidth;
  final Color nutColor;
  final double nutStrokeWidth;
  final Color fingerColor;
  final Color fingerBorderColor;
  final double fingerBorderWidth;
  final double fingerRadius;
  final TextStyle fingerTextStyle;
  final TextStyle titleTextStyle;
  final TextStyle baseFretTextStyle;
  final TextStyle openStringTextStyle;
  final TextStyle mutedStringTextStyle;
  final bool showFingerNumbers;
  final bool showBaseFret;

  ChordDiagramStyle copyWith({
    Size? size,
    EdgeInsets? padding,
    Color? backgroundColor,
    Color? stringColor,
    double? stringStrokeWidth,
    Color? fretColor,
    double? fretStrokeWidth,
    Color? nutColor,
    double? nutStrokeWidth,
    Color? fingerColor,
    Color? fingerBorderColor,
    double? fingerBorderWidth,
    double? fingerRadius,
    TextStyle? fingerTextStyle,
    TextStyle? titleTextStyle,
    TextStyle? baseFretTextStyle,
    TextStyle? openStringTextStyle,
    TextStyle? mutedStringTextStyle,
    bool? showFingerNumbers,
    bool? showBaseFret,
  }) {
    return ChordDiagramStyle(
      size: size ?? this.size,
      padding: padding ?? this.padding,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      stringColor: stringColor ?? this.stringColor,
      stringStrokeWidth: stringStrokeWidth ?? this.stringStrokeWidth,
      fretColor: fretColor ?? this.fretColor,
      fretStrokeWidth: fretStrokeWidth ?? this.fretStrokeWidth,
      nutColor: nutColor ?? this.nutColor,
      nutStrokeWidth: nutStrokeWidth ?? this.nutStrokeWidth,
      fingerColor: fingerColor ?? this.fingerColor,
      fingerBorderColor: fingerBorderColor ?? this.fingerBorderColor,
      fingerBorderWidth: fingerBorderWidth ?? this.fingerBorderWidth,
      fingerRadius: fingerRadius ?? this.fingerRadius,
      fingerTextStyle: fingerTextStyle ?? this.fingerTextStyle,
      titleTextStyle: titleTextStyle ?? this.titleTextStyle,
      baseFretTextStyle: baseFretTextStyle ?? this.baseFretTextStyle,
      openStringTextStyle: openStringTextStyle ?? this.openStringTextStyle,
      mutedStringTextStyle: mutedStringTextStyle ?? this.mutedStringTextStyle,
      showFingerNumbers: showFingerNumbers ?? this.showFingerNumbers,
      showBaseFret: showBaseFret ?? this.showBaseFret,
    );
  }
}
