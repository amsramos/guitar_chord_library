import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guitar_chord_library/guitar_chord_library.dart';

void main() {
  group('ChordDiagramStyle', () {
    test('copyWith changes only provided fields', () {
      const style = ChordDiagramStyle();
      final updated = style.copyWith(
        fingerColor: Colors.red,
        showFingerNumbers: false,
      );

      expect(updated.fingerColor, Colors.red);
      expect(updated.showFingerNumbers, isFalse);
      expect(updated.stringColor, style.stringColor);
      expect(updated.size, style.size);
    });
  });

  group('ChordDiagram', () {
    testWidgets('renders with default style and semantics', (tester) async {
      await tester.pumpWidget(
        _TestApp(
          child: ChordDiagram(
            title: 'G7',
            position: _position,
            stringCount: 4,
          ),
        ),
      );

      expect(find.byType(ChordDiagram), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(ChordDiagram)),
        matchesSemantics(
          label: 'G7 diagram, frets 0 2 1 2, fingers 0 2 1 3',
          isImage: true,
        ),
      );
    });

    testWidgets('uses caller semantic label', (tester) async {
      await tester.pumpWidget(
        _TestApp(
          child: ChordDiagram(
            position: _position,
            stringCount: 4,
            semanticLabel: 'Custom semantic chord label',
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(ChordDiagram)),
        matchesSemantics(
          label: 'Custom semantic chord label',
          isImage: true,
        ),
      );
    });

    testWidgets('applies custom size and style fields', (tester) async {
      const style = ChordDiagramStyle(
        size: Size(180, 220),
        fingerColor: Colors.orange,
        stringColor: Colors.purple,
        showFingerNumbers: false,
      );

      await tester.pumpWidget(
        _TestApp(
          child: ChordDiagram(
            title: 'Styled',
            position: _position,
            stringCount: 4,
            style: style,
          ),
        ),
      );

      final box = tester.renderObject<RenderBox>(find.byType(ChordDiagram));
      final widget = tester.widget<ChordDiagram>(find.byType(ChordDiagram));

      expect(box.size, style.size);
      expect(widget.style.fingerColor, Colors.orange);
      expect(widget.style.stringColor, Colors.purple);
      expect(widget.style.showFingerNumbers, isFalse);
    });

    testWidgets('handles malformed fret data intentionally', (tester) async {
      await tester.pumpWidget(
        _TestApp(
          child: ChordDiagram(
            title: 'Broken',
            position: ChordPosition(
              baseFret: 1,
              frets: '0 1',
              fingers: '0 1',
            ),
            stringCount: 4,
          ),
        ),
      );

      expect(find.byType(ChordDiagram), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders six-string positions', (tester) async {
      await tester.pumpWidget(
        _TestApp(
          child: ChordDiagram(
            title: 'C',
            position: ChordPosition(
              baseFret: 1,
              frets: '-1 3 2 0 1 0',
              fingers: '0 3 2 0 1 0',
            ),
            stringCount: 6,
          ),
        ),
      );

      expect(find.byType(ChordDiagram), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

final ChordPosition _position = ChordPosition(
  baseFret: 1,
  frets: '0 2 1 2',
  fingers: '0 2 1 3',
);

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: child),
    );
  }
}
