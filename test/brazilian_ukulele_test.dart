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

    test('documents root-bass exceptions', () {
      final exceptions = <String>{};

      for (final key in brazilianUkuleleDataSet.keys) {
        for (final suffix in _formulas.keys) {
          if (!_hasPracticalRootBassVoicing(key, suffix)) {
            exceptions.add('$key|$suffix');
          }
        }
      }

      expect(exceptions, _rootBassExceptions);
    });

    test('starts with beginner voicings whenever practical', () {
      for (final MapEntry(key: key, value: chords)
          in brazilianUkuleleDataSet.entries) {
        for (final chord in chords) {
          if (!_hasPracticalBeginnerVoicing(key, chord.suffix)) continue;

          final realFrets = _realFretsFor(chord.chordPositions.first);

          expect(realFrets.every((fret) => fret <= _beginnerVoicingMaxFret),
              isTrue,
              reason: '${chord.name} should prefer low-position voicings');
        }
      }
    });

    test('uses root bass as a secondary priority after beginner voicings', () {
      for (final MapEntry(key: key, value: chords)
          in brazilianUkuleleDataSet.entries) {
        for (final chord in chords) {
          if (_hasPracticalBeginnerVoicing(key, chord.suffix)) continue;
          if (_rootBassExceptions.contains('$key|${chord.suffix}')) continue;

          final realFrets = _realFretsFor(chord.chordPositions.first);

          expect(_hasRootBass(key, realFrets), isTrue,
              reason:
                  '${chord.name} should prefer tonic bass when no low voicing exists');
        }
      }
    });

    test('does not start fully open when a practical fretted voicing exists',
        () {
      for (final MapEntry(key: key, value: chords)
          in brazilianUkuleleDataSet.entries) {
        for (final chord in chords) {
          if (!_hasPracticalFrettedVoicing(key, chord.suffix)) continue;

          expect(
              _realFretsFor(chord.chordPositions.first).any((fret) => fret > 0),
              isTrue,
              reason: '${chord.name} should not start with all open strings');
        }
      }
    });

    test('uses refined first voicings for highlighted chords', () {
      expect(_firstRealFrets('D', 'major'), [0, 2, 3, 4]);
      expect(_firstRealFrets('G', 'major'), [5, 4, 3, 5]);
      expect(_firstRealFrets('G', 'm7'), [5, 3, 3, 3]);
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

    test('keeps natural elevenths in 11 chord voicings', () {
      final c11Intervals = _intervalsForRealFrets(
        _noteValues['C']!,
        _firstRealFrets('C', '11'),
      );

      expect(c11Intervals, containsAll(<int>{0, 4, 5, 7}));
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
const int _beginnerVoicingMaxFret = 5;
const int _maxLowPositionSpan = 3;
const int _maxHighPositionSpan = 4;
const Set<String> _naturalEleventhSuffixes = {'11', 'm11', 'maj11', 'mmaj11'};
const Set<String> _rootBassExceptions = {
  'A#|11',
  'B|11',
  'C|11',
  'C#|11',
  'C#|add9',
  'C#|madd9',
  'D#|11',
  'D#|13b5b9',
  'D#|6',
  'D#|7',
  'D#|7b5',
  'D#|7sus4',
  'D#|9#11',
  'D#|9b5',
  'D#|add9',
  'D#|aug7',
  'D#|madd9',
  'D#|maj11',
  'D#|maj7',
  'D#|maj7b5',
  'D#|major',
  'D#|sus4',
  'E|11',
  'E|13b5b9',
  'E|6',
  'E|7b5',
  'E|9#11',
  'E|9b5',
  'E|maj11',
  'E|maj7b5',
  'F|11',
  'F|add9',
  'F|madd9',
  'F|maj11',
  'F#|11',
  'F#|add9',
  'F#|madd9',
  'G|madd9',
  'G#|11',
  'G#|add9',
  'G#|madd9',
};
final List<List<int>> _testCandidates = _buildTestCandidates();

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

bool _hasPracticalRootBassVoicing(String key, String suffix) {
  return _hasPracticalVoicing(
    key,
    suffix,
    requireRootBass: true,
  );
}

bool _hasPracticalFrettedVoicing(String key, String suffix) {
  return _hasPracticalVoicing(
    key,
    suffix,
    requireFretted: true,
  );
}

bool _hasPracticalBeginnerVoicing(String key, String suffix) {
  return _hasPracticalVoicing(
    key,
    suffix,
    maxFret: _beginnerVoicingMaxFret,
  );
}

bool _hasPracticalVoicing(
  String key,
  String suffix, {
  bool requireRootBass = false,
  bool requireFretted = false,
  int? maxFret,
}) {
  final root = _noteValues[key]!;
  final formula = _formulas[suffix]!;
  final allowed = _pitchClasses(formula);
  final required = _requiredIntervals(suffix, formula);

  for (final frets in _testCandidates) {
    if (requireRootBass && !_hasRootBass(key, frets)) continue;
    if (requireFretted && !frets.any((fret) => fret > 0)) continue;
    if (maxFret != null && frets.any((fret) => fret > maxFret)) continue;

    final intervals = _intervalsForRealFrets(root, frets);
    if (!intervals.every(allowed.contains)) continue;
    if (!required.every(intervals.contains)) continue;
    if (allowed.length <= 4 && !intervals.containsAll(allowed)) continue;

    return true;
  }

  return false;
}

Set<int> _intervalsForRealFrets(int root, List<int> frets) {
  return {
    for (var stringIndex = 0; stringIndex < frets.length; stringIndex++)
      (_tuning[stringIndex] + frets[stringIndex] - root) % 12,
  };
}

bool _hasRootBass(String key, List<int> realFrets) {
  final root = _noteValues[key]!;
  return (_tuning.first + realFrets.first - root) % 12 == 0;
}

List<List<int>> _buildTestCandidates() {
  final candidates = <List<int>>[];

  for (var first = 0; first <= 12; first++) {
    for (var second = 0; second <= 12; second++) {
      for (var third = 0; third <= 12; third++) {
        for (var fourth = 0; fourth <= 12; fourth++) {
          final frets = [first, second, third, fourth];
          if (_isPlayable(frets)) {
            candidates.add(frets);
          }
        }
      }
    }
  }

  return candidates;
}

bool _isPlayable(List<int> frets) {
  final fretted = frets.where((fret) => fret > 0).toList();
  if (fretted.isEmpty) return true;

  if (fretted.toSet().length > 4) return false;

  final minFret = fretted.reduce((a, b) => a < b ? a : b);
  final maxFret = fretted.reduce((a, b) => a > b ? a : b);
  final spanLimit = minFret <= 4 ? _maxLowPositionSpan : _maxHighPositionSpan;

  if (maxFret - minFret > spanLimit) return false;
  if (frets.contains(0) && maxFret > _maxOpenVoicingFret) return false;

  return true;
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
