import 'package:flutter_test/flutter_test.dart';
import 'package:guitar_chord_library/guitar_chord_library.dart';
import 'package:guitar_chord_library/src/dataset/brazilian_ukulele_dataset.dart';

void main() {
  group('BrazilianUkulele dataset', () {
    test('keeps the expected chromatic keys and suffixes', () {
      expect(
        brazilianUkuleleDataSet.keys,
        orderedEquals([
          'A',
          'A#',
          'B',
          'C',
          'C#',
          'D',
          'D#',
          'E',
          'F',
          'F#',
          'G',
          'G#',
        ]),
      );

      for (final chords in brazilianUkuleleDataSet.values) {
        expect(
            chords.map((chord) => chord.suffix), orderedEquals(_formulas.keys));
      }
    });

    test('has structurally valid positions without duplicates', () {
      for (final MapEntry(key: key, value: chords)
          in brazilianUkuleleDataSet.entries) {
        for (final chord in chords) {
          expect(chord.chordKey, key);
          expect(chord.name, '$key${chord.suffix}');
          expect(chord.chordPositions, isNotEmpty,
              reason: '${chord.name} should have generated positions');

          final seen = <String>{};
          for (final position in chord.chordPositions) {
            expect(position.baseFret, greaterThanOrEqualTo(1),
                reason: '${chord.name}: $position');

            final frets = _parse(position.frets);
            final fingers = _parse(position.fingers);

            expect(frets, hasLength(4), reason: chord.name);
            expect(fingers, hasLength(4), reason: chord.name);

            for (var i = 0; i < frets.length; i++) {
              expect(frets[i], greaterThanOrEqualTo(0),
                  reason: '${chord.name}: muted strings are not generated yet');
              if (frets[i] == 0) {
                expect(fingers[i], 0, reason: '${chord.name}: $position');
              } else {
                expect(fingers[i], greaterThanOrEqualTo(1),
                    reason: '${chord.name}: $position');
              }
            }

            final signature =
                '${position.baseFret}|${position.frets}|${position.fingers}';
            expect(seen.add(signature), isTrue,
                reason: '${chord.name} has duplicate position $signature');
          }
        }
      }
    });

    test('has human-playable position shapes', () {
      for (final chordList in brazilianUkuleleDataSet.values) {
        for (final chord in chordList) {
          for (final position in chord.chordPositions) {
            final frets = _parse(position.frets);
            final fingers = _parse(position.fingers);
            final fretted = frets.where((fret) => fret > 0).toList();
            final usedFingers =
                fingers.where((finger) => finger > 0).toSet().toList();

            expect(usedFingers, hasLength(lessThanOrEqualTo(4)),
                reason: '${chord.name}: $position');
            expect(usedFingers.every((finger) => finger <= 4), isTrue,
                reason: '${chord.name}: $position');

            if (fretted.isEmpty) continue;

            final minFret = fretted.reduce((a, b) => a < b ? a : b);
            final maxFret = fretted.reduce((a, b) => a > b ? a : b);
            final spanLimit =
                minFret <= 4 ? _maxLowPositionSpan : _maxHighPositionSpan;

            expect(maxFret - minFret, lessThanOrEqualTo(spanLimit),
                reason: '${chord.name}: $position');
            if (frets.contains(0)) {
              expect(maxFret, lessThanOrEqualTo(_maxOpenVoicingFret),
                  reason: '${chord.name}: $position');
            }
          }
        }
      }
    });

    test('contains only notes allowed by each chord formula', () {
      for (final chordList in brazilianUkuleleDataSet.values) {
        for (final chord in chordList) {
          final formula = _formulas[chord.suffix]!;
          final allowed = _pitchClasses(formula);
          final required = _requiredIntervals(chord.suffix, formula);
          final root = _noteValues[chord.chordKey]!;

          for (final position in chord.chordPositions) {
            final intervals = _intervalsFor(root, position);

            expect(intervals.every(allowed.contains), isTrue,
                reason: '${chord.name} has notes outside $allowed: $position');
            expect(required.every(intervals.contains), isTrue,
                reason:
                    '${chord.name} misses required intervals $required: $position');

            if (allowed.length <= 4) {
              expect(intervals.containsAll(allowed), isTrue,
                  reason:
                      '${chord.name} should include all $allowed: $position');
            }
          }
        }
      }
    });
  });

  group('BrazilianUkulele API', () {
    test('normalizes flat keys when fetching chord positions', () {
      final instrument =
          GuitarChordLibrary.instrument(InstrumentType.brazilianUkulele);

      for (final pair in const {
        'Db': 'C#',
        'Eb': 'D#',
        'Gb': 'F#',
        'Ab': 'G#',
        'Bb': 'A#',
      }.entries) {
        final flatPositions = instrument.getChordPositions(pair.key, 'major');
        final sharpPositions =
            instrument.getChordPositions(pair.value, 'major');

        expect(flatPositions, isNotNull, reason: pair.key);
        expect(_positionSignatures(flatPositions!),
            _positionSignatures(sharpPositions!));
      }
    });

    test('normalizes flat keys when fetching chords by key', () {
      final instrument =
          GuitarChordLibrary.instrument(InstrumentType.brazilianUkulele);

      final dbChords = instrument.getChordsByKey('Db');
      final cSharpChords = instrument.getChordsByKey('C#');
      final dbChordsUsingFlatNames = instrument.getChordsByKey('Db', true);

      expect(dbChords, isNotNull);
      expect(cSharpChords, isNotNull);
      expect(
        dbChords!.map((chord) => chord.name),
        orderedEquals(cSharpChords!.map((chord) => chord.name)),
      );
      expect(dbChordsUsingFlatNames!.first.chordKey, 'Db');
    });

    test('preserves invalid input behavior', () {
      final instrument =
          GuitarChordLibrary.instrument(InstrumentType.brazilianUkulele);

      expect(instrument.getChordPositions('H', 'major'), isNull);
      expect(instrument.getChordPositions('C', 'unknown'), isNull);
      expect(instrument.getChordsByKey('H'), isNull);
    });
  });
}

const Map<String, List<int>> _formulas = {
  '11': [0, 4, 7, 10, 14, 17],
  '13': [0, 4, 7, 10, 14, 17, 21],
  '13b5b9': [0, 4, 6, 10, 13, 21],
  '13b9': [0, 4, 7, 10, 13, 17, 21],
  '6': [0, 4, 7, 9],
  '69': [0, 4, 7, 9, 14],
  '7': [0, 4, 7, 10],
  '7#9': [0, 4, 7, 10, 15],
  '7b5': [0, 4, 6, 10],
  '7b9': [0, 4, 7, 10, 13],
  '7b9#5': [0, 4, 8, 10, 13],
  '7sus4': [0, 5, 7, 10],
  '9': [0, 4, 7, 10, 14],
  '9#11': [0, 4, 7, 10, 14, 18],
  '9b5': [0, 4, 6, 10, 14],
  'add9': [0, 4, 7, 14],
  'alt': [0, 4, 10, 13, 15, 18, 20],
  'aug': [0, 4, 8],
  'aug7': [0, 4, 8, 10],
  'aug9': [0, 4, 8, 10, 14],
  'b13#9': [0, 4, 7, 10, 15, 20],
  'b13b9': [0, 4, 7, 10, 13, 20],
  'dim': [0, 3, 6],
  'dim7': [0, 3, 6, 9],
  'm11': [0, 3, 7, 10, 14, 17],
  'm6': [0, 3, 7, 9],
  'm69': [0, 3, 7, 9, 14],
  'm7': [0, 3, 7, 10],
  'm7b5': [0, 3, 6, 10],
  'm9': [0, 3, 7, 10, 14],
  'm9b5': [0, 3, 6, 10, 14],
  'madd9': [0, 3, 7, 14],
  'maj11': [0, 4, 7, 11, 14, 17],
  'maj13': [0, 4, 7, 11, 14, 17, 21],
  'maj7': [0, 4, 7, 11],
  'maj7#5': [0, 4, 8, 11],
  'maj7b5': [0, 4, 6, 11],
  'maj9': [0, 4, 7, 11, 14],
  'major': [0, 4, 7],
  'minor': [0, 3, 7],
  'mmaj11': [0, 3, 7, 11, 14, 17],
  'mmaj7': [0, 3, 7, 11],
  'mmaj7b5': [0, 3, 6, 11],
  'mmaj9': [0, 3, 7, 11, 14],
  'sus2': [0, 2, 7],
  'sus4': [0, 5, 7],
};

const Map<String, int> _noteValues = {
  'C': 0,
  'C#': 1,
  'D': 2,
  'D#': 3,
  'E': 4,
  'F': 5,
  'F#': 6,
  'G': 7,
  'G#': 8,
  'A': 9,
  'A#': 10,
  'B': 11,
};

const List<int> _tuning = [2, 7, 11, 2];
const int _maxOpenVoicingFret = 7;
const int _maxLowPositionSpan = 3;
const int _maxHighPositionSpan = 4;

List<int> _parse(String values) {
  return values.split(' ').map(int.parse).toList();
}

Set<int> _pitchClasses(List<int> intervals) {
  return intervals.map((interval) => interval % 12).toSet();
}

Set<int> _requiredIntervals(String suffix, List<int> formula) {
  final intervals = _pitchClasses(formula);
  final required = <int>{0};

  if (suffix == 'sus2') {
    required.add(2);
  } else if (suffix.contains('sus4')) {
    required.add(5);
  } else if (suffix == 'dim' ||
      suffix == 'dim7' ||
      suffix.startsWith('m') && !suffix.startsWith('maj')) {
    required.add(3);
  } else if (suffix.contains('aug') || suffix.contains('#5')) {
    required.add(8);
  } else if (intervals.contains(4)) {
    required.add(4);
  }

  if (suffix == 'dim' ||
      suffix == 'dim7' ||
      suffix.contains('b5') ||
      suffix.contains('#11')) {
    required.add(6);
  }

  if (suffix.contains('7') ||
      suffix.contains('9') ||
      suffix.contains('11') ||
      suffix.contains('13') ||
      suffix == 'alt') {
    if (intervals.contains(10)) {
      required.add(10);
    } else if (intervals.contains(11)) {
      required.add(11);
    }
  }

  return required;
}

Set<int> _intervalsFor(int root, ChordPosition position) {
  final frets = _parse(position.frets);

  return {
    for (var stringIndex = 0; stringIndex < frets.length; stringIndex++)
      (_tuning[stringIndex] +
              _realFret(position.baseFret, frets[stringIndex]) -
              root) %
          12,
  };
}

int _realFret(int baseFret, int displayedFret) {
  if (displayedFret <= 0 || baseFret == 1) return displayedFret;
  return baseFret + displayedFret - 1;
}

List<String> _positionSignatures(List<ChordPosition> positions) {
  return [
    for (final position in positions)
      '${position.baseFret}|${position.frets}|${position.fingers}',
  ];
}
