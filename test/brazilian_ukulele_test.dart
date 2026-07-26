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
          expect(chord.chordPositions.length, lessThanOrEqualTo(4),
              reason: chord.name);

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

            final signature = '${position.baseFret}|${position.frets}';
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
            final realFrets = _realFretsFor(position);
            final fretted = realFrets.where((fret) => fret > 0).toList();
            final usedFingers =
                fingers.where((finger) => finger > 0).toSet().toList();

            expect(usedFingers, hasLength(lessThanOrEqualTo(4)),
                reason: '${chord.name}: $position');
            expect(usedFingers.every((finger) => finger <= 4), isTrue,
                reason: '${chord.name}: $position');
            for (final finger in usedFingers) {
              final stringIndexes = [
                for (var i = 0; i < fingers.length; i++)
                  if (fingers[i] == finger) i,
              ];
              if (stringIndexes.length <= 1) continue;

              final firstFret = frets[stringIndexes.first];
              expect(
                stringIndexes.every((index) => frets[index] == firstFret),
                isTrue,
                reason:
                    '${chord.name}: finger $finger must stay on one fret: $position',
              );
              expect(_isContiguous(stringIndexes), isTrue,
                  reason:
                      '${chord.name}: finger $finger crosses non-adjacent strings: $position');
            }

            if (fretted.isEmpty) continue;

            final minFret = fretted.reduce((a, b) => a < b ? a : b);
            final maxFret = fretted.reduce((a, b) => a > b ? a : b);
            final spanLimit =
                minFret <= 4 ? _maxLowPositionSpan : _maxHighPositionSpan;

            expect(maxFret - minFret, lessThanOrEqualTo(spanLimit),
                reason: '${chord.name}: $position');
            if (realFrets.contains(0)) {
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
          final formulaNotes = _pitchClasses(formula);
          final allowed = _allowedIntervals(chord.suffix);
          final required = _requiredIntervals(chord.suffix, formula);
          final root = _noteValues[chord.chordKey]!;

          for (final position in chord.chordPositions) {
            final intervals = _intervalsFor(root, position);

            expect(intervals.every(allowed.contains), isTrue,
                reason: '${chord.name} has notes outside $allowed: $position');

            if (formulaNotes.length >= 5) {
              // Jazz extensions may use documented rootless voicings.
              final rootless = required.difference({0});
              expect(
                  required.every(intervals.contains) ||
                      rootless.every(intervals.contains),
                  isTrue,
                  reason:
                      '${chord.name} misses required intervals $required: $position');
            } else {
              expect(required.every(intervals.contains), isTrue,
                  reason:
                      '${chord.name} misses required intervals $required: $position');
            }

            if (formulaNotes.length <= 4) {
              var must = Set<int>.of(formulaNotes);
              if (chord.suffix == 'dim') must = {0, 3, 6};
              if (_fifthOptionalSuffixes.contains(chord.suffix)) {
                must.remove(7);
              }
              expect(intervals.containsAll(must), isTrue,
                  reason:
                      '${chord.name} should include all of $must: $position');
            }
          }
        }
      }
    });

    test('has at least 3 variations except documented rare chords', () {
      final actualExceptions = <String, int>{};

      for (final MapEntry(key: key, value: chords)
          in brazilianUkuleleDataSet.entries) {
        for (final chord in chords) {
          final count = chord.chordPositions.length;
          if (count < 3) {
            actualExceptions['$key|${chord.suffix}'] = count;
          }
        }
      }

      expect(actualExceptions, _fewVoicingExceptions,
          reason: 'documented set of chords with fewer than 3 shapes changed');
      expect(_fewVoicingExceptions.values.every((count) => count >= 1), isTrue);
    });

    test('starts every chord with its classic community shapes in order', () {
      for (final MapEntry(key: chordId, value: shapes)
          in _classicShapes.entries) {
        final [key, suffix] = chordId.split('|');
        final chord = brazilianUkuleleDataSet[key]!
            .firstWhere((chord) => chord.suffix == suffix);

        for (var i = 0; i < shapes.length; i++) {
          expect(_realFretsFor(chord.chordPositions[i]), shapes[i],
              reason:
                  '$chordId should keep classic shape ${shapes[i]} at index $i');
        }
      }
    });

    test('orders generated variations from low to high neck positions', () {
      for (final MapEntry(key: key, value: chords)
          in brazilianUkuleleDataSet.entries) {
        for (final chord in chords) {
          final classicCount =
              _classicShapes['$key|${chord.suffix}']?.length ?? 0;
          final tail = chord.chordPositions.skip(classicCount).toList();

          for (var i = 1; i < tail.length; i++) {
            expect(
              _positionOf(tail[i]),
              greaterThanOrEqualTo(_positionOf(tail[i - 1])),
              reason:
                  '${chord.name} generated shapes should ascend the neck: '
                  '${tail.map(_realFretsFor).toList()}',
            );
          }
        }
      }
    });

    test('keeps common C chords in beginner positions', () {
      expect(_firstRealFrets('C', '11'), [2, 0, 1, 3]);
      expect(_firstRealFrets('C', 'major'), [2, 0, 1, 2]);
      expect(_firstRealFrets('C', 'minor'), [1, 0, 1, 1]);
      expect(_firstRealFrets('C', 'add9'), [0, 0, 1, 2]);
      expect(_firstRealFrets('C', 'sus2'), [0, 0, 1, 0]);
      expect(_firstRealFrets('C', 'sus4'), [3, 0, 1, 3]);
      expect(_firstRealFrets('C', '9'), [0, 3, 1, 2]);
      expect(_firstRealFrets('C', 'm9'), [0, 3, 1, 1]);
      expect(_firstRealFrets('C', 'dim7'), [1, 2, 1, 4]);
    });

    test('uses refined first voicings for highlighted chords', () {
      expect(_firstRealFrets('D', 'major'), [0, 2, 3, 4]);
      expect(_firstRealFrets('G', 'major'), [5, 4, 3, 5]);
      expect(_firstRealFrets('G', 'm7'), [5, 3, 3, 3]);
    });

    test('keeps natural elevenths in 11 chord voicings', () {
      final c11Intervals = _intervalsForRealFrets(
        _noteValues['C']!,
        _firstRealFrets('C', '11'),
      );

      expect(c11Intervals, containsAll(<int>{0, 4, 5}));
      expect(c11Intervals, isNot(contains(10)),
          reason: 'C11 should not collapse to a C7 voicing');

      for (final MapEntry(key: key, value: chords)
          in brazilianUkuleleDataSet.entries) {
        for (final suffix in _naturalEleventhSuffixes) {
          final chord = chords.firstWhere((chord) => chord.suffix == suffix);

          for (final position in chord.chordPositions) {
            final intervals = _intervalsFor(_noteValues[key]!, position);

            expect(intervals, contains(5),
                reason: '${chord.name} should include its natural 11th');
          }
        }
      }
    });

    test('avoids open-string-heavy generated shapes', () {
      for (final MapEntry(key: key, value: chords)
          in brazilianUkuleleDataSet.entries) {
        for (final chord in chords) {
          final classicCount =
              _classicShapes['$key|${chord.suffix}']?.length ?? 0;

          for (final position
              in chord.chordPositions.skip(classicCount)) {
            final realFrets = _realFretsFor(position);
            final opens = realFrets.where((fret) => fret == 0).length;

            expect(opens, lessThanOrEqualTo(1),
                reason:
                    '${chord.name} generated shape has too many open strings: '
                    '$realFrets');
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
  '11': [0, 4, 7, 17],
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
const Set<String> _naturalEleventhSuffixes = {'11', 'm11', 'maj11', 'mmaj11'};

/// Suffixes that must contain a natural ninth (interval 2).
const Set<String> _ninthSuffixes = {
  '9',
  'm9',
  'maj9',
  'add9',
  'madd9',
  '69',
  'm69',
  'aug9',
  'mmaj9',
  'm9b5',
};

/// Chords whose perfect fifth may be omitted (never defines the quality).
const Set<String> _fifthOptionalSuffixes = {
  '7',
  'm7',
  'maj7',
  'mmaj7',
  '7sus4',
  '11',
  'add9',
  'madd9',
  '6',
  'm6',
};

/// Rare altered chords where the 4-string neck cannot produce 3 playable
/// complete voicings up to the 14th fret. Values are the achievable count.
const Map<String, int> _fewVoicingExceptions = {
  'A|maj7#5': 2,
  'A#|madd9': 2,
  'A#|maj7#5': 2,
  'B|7b5': 2,
  'B|maj7#5': 2,
  'B|maj7b5': 2,
  'C#|aug7': 2,
  'C#|maj7#5': 2,
  'C#|maj7b5': 2,
  'D#|aug7': 2,
  'D#|madd9': 1,
  'E|maj7b5': 2,
  'F|7b5': 2,
  'F|aug7': 2,
  'F|maj7#5': 2,
  'F|maj7b5': 1,
  'F|mmaj7b5': 2,
  'F#|maj7#5': 2,
  'F#|maj7b5': 2,
  'G|aug7': 2,
  'G|maj7#5': 2,
  'G#|maj7#5': 2,
};

/// Source of truth: classic cavaquinho shapes (real frets, `D G B D`).
/// Every chord listed here must expose these shapes first, in this order.
const Map<String, List<List<int>>> _classicShapes = {
  'C|major': [
    [2, 0, 1, 2]
  ],
  'C#|major': [
    [3, 1, 2, 3]
  ],
  'D|major': [
    [0, 2, 3, 4]
  ],
  'D#|major': [
    [5, 3, 4, 5]
  ],
  'E|major': [
    [2, 1, 0, 2]
  ],
  'F|major': [
    [3, 2, 1, 3]
  ],
  'F#|major': [
    [4, 3, 2, 4]
  ],
  'G|major': [
    [5, 4, 3, 5],
    [0, 0, 0, 0]
  ],
  'G#|major': [
    [1, 1, 1, 1]
  ],
  'A|major': [
    [2, 2, 2, 2]
  ],
  'A#|major': [
    [3, 3, 3, 3],
    [0, 3, 3, 3]
  ],
  'B|major': [
    [4, 4, 4, 4]
  ],
  'C|minor': [
    [1, 0, 1, 1]
  ],
  'C#|minor': [
    [2, 1, 2, 2]
  ],
  'D|minor': [
    [0, 2, 3, 3]
  ],
  'D#|minor': [
    [1, 3, 4, 4]
  ],
  'E|minor': [
    [2, 0, 0, 2]
  ],
  'F|minor': [
    [3, 1, 1, 3]
  ],
  'F#|minor': [
    [4, 2, 2, 4]
  ],
  'G|minor': [
    [5, 3, 3, 5]
  ],
  'G#|minor': [
    [1, 1, 0, 1]
  ],
  'A|minor': [
    [2, 2, 1, 2]
  ],
  'A#|minor': [
    [3, 3, 2, 3]
  ],
  'B|minor': [
    [4, 4, 3, 4],
    [0, 4, 3, 4]
  ],
  'C|7': [
    [2, 3, 1, 2]
  ],
  'C#|7': [
    [3, 4, 2, 3]
  ],
  'D|7': [
    [0, 2, 1, 4]
  ],
  'D#|7': [
    [5, 6, 4, 5]
  ],
  'E|7': [
    [0, 1, 0, 2],
    [2, 1, 0, 0]
  ],
  'F|7': [
    [1, 2, 1, 3]
  ],
  'F#|7': [
    [2, 3, 2, 4]
  ],
  'G|7': [
    [0, 0, 0, 3]
  ],
  'G#|7': [
    [1, 1, 1, 4]
  ],
  'A|7': [
    [2, 2, 2, 5]
  ],
  'A#|7': [
    [3, 3, 3, 6]
  ],
  'B|7': [
    [1, 2, 0, 1],
    [4, 4, 4, 7]
  ],
  'C|m7': [
    [1, 3, 1, 1]
  ],
  'C#|m7': [
    [2, 4, 2, 2]
  ],
  'D|m7': [
    [0, 2, 1, 3]
  ],
  'D#|m7': [
    [1, 3, 2, 4]
  ],
  'E|m7': [
    [0, 0, 0, 2]
  ],
  'F|m7': [
    [1, 1, 1, 3]
  ],
  'F#|m7': [
    [2, 2, 2, 4]
  ],
  'G|m7': [
    [5, 3, 3, 3]
  ],
  'G#|m7': [
    [4, 4, 4, 6]
  ],
  'A|m7': [
    [5, 5, 5, 7]
  ],
  'A#|m7': [
    [6, 6, 6, 8]
  ],
  'B|m7': [
    [0, 2, 0, 4],
    [7, 7, 7, 9]
  ],
  'C|maj7': [
    [2, 5, 0, 5]
  ],
  'C#|maj7': [
    [6, 6, 6, 10]
  ],
  'D|maj7': [
    [0, 2, 2, 4]
  ],
  'D#|maj7': [
    [0, 3, 4, 5]
  ],
  'E|maj7': [
    [1, 1, 0, 2]
  ],
  'F|maj7': [
    [2, 2, 1, 3]
  ],
  'F#|maj7': [
    [3, 3, 2, 4]
  ],
  'G|maj7': [
    [0, 0, 0, 4]
  ],
  'G#|maj7': [
    [5, 5, 4, 6]
  ],
  'A|maj7': [
    [6, 6, 5, 7]
  ],
  'A#|maj7': [
    [7, 7, 6, 8]
  ],
  'B|maj7': [
    [1, 3, 0, 4]
  ],
  'C|6': [
    [2, 2, 1, 2]
  ],
  'C#|6': [
    [3, 3, 2, 3]
  ],
  'D|6': [
    [0, 2, 0, 4]
  ],
  'D#|6': [
    [1, 0, 1, 1]
  ],
  'E|6': [
    [2, 1, 2, 2]
  ],
  'F|6': [
    [0, 2, 1, 3]
  ],
  'F#|6': [
    [1, 3, 2, 4]
  ],
  'G|6': [
    [0, 0, 0, 2]
  ],
  'G#|6': [
    [1, 1, 1, 3]
  ],
  'A|6': [
    [2, 2, 2, 4]
  ],
  'A#|6': [
    [3, 3, 3, 5]
  ],
  'B|6': [
    [1, 1, 0, 4],
    [4, 4, 4, 6]
  ],
  'C|m6': [
    [1, 2, 1, 1]
  ],
  'C#|m6': [
    [2, 3, 2, 2]
  ],
  'D|m6': [
    [0, 2, 0, 3]
  ],
  'D#|m6': [
    [1, 3, 1, 4]
  ],
  'E|m6': [
    [2, 0, 2, 2],
    [2, 4, 2, 5]
  ],
  'F|m6': [
    [3, 1, 3, 3],
    [3, 5, 3, 6]
  ],
  'F#|m6': [
    [4, 2, 4, 4],
    [4, 6, 4, 7]
  ],
  'G|m6': [
    [5, 3, 3, 2]
  ],
  'G#|m6': [
    [6, 4, 4, 3]
  ],
  'A|m6': [
    [2, 2, 1, 4]
  ],
  'A#|m6': [
    [3, 3, 2, 5]
  ],
  'B|m6': [
    [4, 4, 3, 6]
  ],
  'C|9': [
    [0, 3, 1, 2]
  ],
  'C#|9': [
    [1, 4, 2, 3]
  ],
  'D|9': [
    [2, 5, 3, 4]
  ],
  'D#|9': [
    [3, 6, 4, 5]
  ],
  'E|9': [
    [4, 7, 5, 6]
  ],
  'F|9': [
    [5, 8, 6, 7]
  ],
  'F#|9': [
    [6, 9, 7, 8]
  ],
  'G|9': [
    [5, 4, 6, 7]
  ],
  'G#|9': [
    [6, 5, 7, 8]
  ],
  'A|9': [
    [7, 6, 8, 9]
  ],
  'A#|9': [
    [8, 7, 9, 10]
  ],
  'B|9': [
    [9, 8, 10, 11]
  ],
  'C|dim': [
    [4, 5, 4, 4],
    [1, 2, 1, 4]
  ],
  'C#|dim': [
    [5, 6, 5, 5],
    [2, 3, 2, 5]
  ],
  'D|dim': [
    [0, 1, 3, 3],
    [0, 1, 0, 3]
  ],
  'D#|dim': [
    [1, 2, 4, 4],
    [1, 2, 1, 4]
  ],
  'E|dim': [
    [2, 3, 5, 5],
    [2, 3, 2, 5]
  ],
  'F|dim': [
    [3, 4, 6, 6],
    [3, 4, 3, 6]
  ],
  'F#|dim': [
    [4, 5, 7, 7],
    [1, 2, 1, 4]
  ],
  'G|dim': [
    [5, 6, 8, 8],
    [2, 3, 2, 5]
  ],
  'G#|dim': [
    [0, 1, 0, 0],
    [0, 1, 0, 3]
  ],
  'A|dim': [
    [1, 2, 1, 1],
    [1, 2, 1, 4]
  ],
  'A#|dim': [
    [2, 3, 2, 2],
    [2, 3, 2, 5]
  ],
  'B|dim': [
    [3, 4, 3, 3],
    [3, 4, 3, 6]
  ],
  'C|dim7': [
    [1, 2, 1, 4]
  ],
  'C#|dim7': [
    [2, 3, 2, 5]
  ],
  'D|dim7': [
    [0, 1, 0, 3]
  ],
  'D#|dim7': [
    [1, 2, 1, 4]
  ],
  'E|dim7': [
    [2, 3, 2, 5]
  ],
  'F|dim7': [
    [3, 4, 3, 6]
  ],
  'F#|dim7': [
    [1, 2, 1, 4]
  ],
  'G|dim7': [
    [2, 3, 2, 5]
  ],
  'G#|dim7': [
    [0, 1, 0, 3]
  ],
  'A|dim7': [
    [1, 2, 1, 4]
  ],
  'A#|dim7': [
    [2, 3, 2, 5]
  ],
  'B|dim7': [
    [3, 4, 3, 6]
  ],
  'C|aug': [
    [2, 1, 1, 2]
  ],
  'C#|aug': [
    [3, 2, 2, 3]
  ],
  'D|aug': [
    [4, 3, 3, 4]
  ],
  'D#|aug': [
    [1, 0, 0, 1]
  ],
  'E|aug': [
    [2, 1, 1, 2]
  ],
  'F|aug': [
    [3, 2, 2, 3]
  ],
  'F#|aug': [
    [4, 3, 3, 4]
  ],
  'G|aug': [
    [1, 0, 0, 1]
  ],
  'G#|aug': [
    [2, 1, 1, 2]
  ],
  'A|aug': [
    [3, 2, 2, 3]
  ],
  'A#|aug': [
    [4, 3, 3, 4]
  ],
  'B|aug': [
    [1, 0, 0, 1]
  ],
  'C|11': [
    [2, 0, 1, 3]
  ],
  'C|add9': [
    [0, 0, 1, 2]
  ],
  'C|m9': [
    [0, 3, 1, 1]
  ],
  'C|sus2': [
    [0, 0, 1, 0]
  ],
  'C|sus4': [
    [3, 0, 1, 3]
  ],
};

List<int> _parse(String values) {
  return values.split(' ').map(int.parse).toList();
}

bool _isContiguous(List<int> indexes) {
  for (var i = 1; i < indexes.length; i++) {
    if (indexes[i] != indexes[i - 1] + 1) return false;
  }

  return true;
}

Set<int> _pitchClasses(List<int> intervals) {
  return intervals.map((interval) => interval % 12).toSet();
}

Set<int> _allowedIntervals(String suffix) {
  final allowed = _pitchClasses(_formulas[suffix]!);

  // The community plays dim as dim7; accept the diminished seventh.
  if (suffix == 'dim' || suffix == 'dim7') {
    allowed.addAll({3, 6, 9});
  }

  return allowed;
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

  if (_naturalEleventhSuffixes.contains(suffix)) {
    required.add(5);
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

  if (_ninthSuffixes.contains(suffix)) {
    required.add(2);
  }

  return required;
}

Set<int> _intervalsFor(int root, ChordPosition position) {
  return _intervalsForRealFrets(root, _realFretsFor(position));
}

Set<int> _intervalsForRealFrets(int root, List<int> frets) {
  return {
    for (var stringIndex = 0; stringIndex < frets.length; stringIndex++)
      (_tuning[stringIndex] + frets[stringIndex] - root) % 12,
  };
}

int _realFret(int baseFret, int displayedFret) {
  if (displayedFret <= 0 || baseFret == 1) return displayedFret;
  return baseFret + displayedFret - 1;
}

List<int> _realFretsFor(ChordPosition position) {
  return [
    for (final fret in _parse(position.frets))
      _realFret(position.baseFret, fret),
  ];
}

/// Neck region of a shape; all-open shapes sort last.
int _positionOf(ChordPosition position) {
  final fretted =
      _realFretsFor(position).where((fret) => fret > 0).toList();
  if (fretted.isEmpty) return 99;

  return fretted.reduce((a, b) => a < b ? a : b);
}

List<int> _firstRealFrets(String key, String suffix) {
  final chord = brazilianUkuleleDataSet[key]!
      .firstWhere((chord) => chord.suffix == suffix);
  return _realFretsFor(chord.chordPositions.first);
}

List<String> _positionSignatures(List<ChordPosition> positions) {
  return [
    for (final position in positions)
      '${position.baseFret}|${position.frets}|${position.fingers}',
  ];
}
