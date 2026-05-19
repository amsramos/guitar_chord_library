import 'package:flutter/material.dart';
import 'package:guitar_chord_library/guitar_chord_library.dart';

void main() {
  runApp(const ChordLibraryExampleApp());
}

class ChordLibraryExampleApp extends StatelessWidget {
  const ChordLibraryExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        useMaterial3: true,
      ),
      home: const ChordDiagramExample(),
    );
  }
}

class ChordDiagramExample extends StatelessWidget {
  const ChordDiagramExample({super.key});

  @override
  Widget build(BuildContext context) {
    final instrument =
        GuitarChordLibrary.instrument(InstrumentType.brazilianUkulele);
    final defaultPosition = instrument.getChordPositions('G', '7')!.first;
    final compactPosition = instrument.getChordPositions('C', 'major')!.first;
    final darkPosition = instrument.getChordPositions('A', 'minor')!.first;

    return Scaffold(
      appBar: AppBar(title: const Text('Chord diagrams')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              _DiagramTile(
                label: 'Default',
                child: ChordDiagram(
                  title: 'G7',
                  position: defaultPosition,
                  stringCount: instrument.stringCount,
                ),
              ),
              _DiagramTile(
                label: 'Compact',
                child: ChordDiagram(
                  title: 'C',
                  position: compactPosition,
                  stringCount: instrument.stringCount,
                  style: const ChordDiagramStyle(
                    size: Size(104, 148),
                    padding: EdgeInsets.fromLTRB(14, 8, 14, 12),
                    fingerColor: Color(0xFF059669),
                    fingerRadius: 8,
                    showFingerNumbers: false,
                  ),
                ),
              ),
              _DiagramTile(
                label: 'Custom',
                child: ChordDiagram(
                  title: 'Am',
                  position: darkPosition,
                  stringCount: instrument.stringCount,
                  style: const ChordDiagramStyle(
                    size: Size(132, 176),
                    backgroundColor: Color(0xFF111827),
                    stringColor: Color(0xFFE5E7EB),
                    fretColor: Color(0xFF9CA3AF),
                    nutColor: Color(0xFFFFFFFF),
                    fingerColor: Color(0xFFF59E0B),
                    fingerBorderColor: Color(0xFF111827),
                    titleTextStyle: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    baseFretTextStyle: TextStyle(
                      color: Color(0xFFE5E7EB),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    openStringTextStyle: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DiagramTile extends StatelessWidget {
  const _DiagramTile({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(label, style: Theme.of(context).textTheme.labelLarge),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: child,
          ),
        ),
      ],
    );
  }
}
