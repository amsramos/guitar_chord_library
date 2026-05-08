import '../chord.dart';

final Map<String, List<Chord>> brazilianUkuleleDataSet =
    _buildBrazilianUkuleleDataSet();

const List<String> _keys = [
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
];

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

const List<int> _brazilianUkuleleTuning = [2, 7, 11, 2];
const int _maxGeneratedFret = 12;
const int _maxOpenVoicingFret = 7;
const int _maxLowPositionSpan = 3;
const int _maxHighPositionSpan = 4;
const int _positionsPerChord = 4;
final List<_Candidate> _allCandidates = _buildCandidates();

Map<String, List<Chord>> _buildBrazilianUkuleleDataSet() {
  return {
    for (final key in _keys)
      key: [
        for (final suffix in _formulas.keys)
          Chord(
            name: '$key$suffix',
            chordKey: key,
            suffix: suffix,
            chordPositions: _buildPositions(key, suffix),
          ),
      ],
  };
}

List<ChordPosition> _buildPositions(String key, String suffix) {
  final root = _noteValues[key]!;
  final formula = _formulas[suffix]!;
  final allowedIntervals = _pitchClassMask(formula);
  final requiredIntervals = _requiredIntervalMask(suffix, formula);
  final requiresCompleteVoicing = _bitCount(allowedIntervals) <= 4;
  final candidates = <_Candidate>[];

  for (final candidate in _allCandidates) {
    final intervals = candidate.intervalMaskFrom(root);

    if (intervals & ~allowedIntervals != 0) continue;
    if (intervals & requiredIntervals != requiredIntervals) continue;
    if (requiresCompleteVoicing &&
        intervals & allowedIntervals != allowedIntervals) {
      continue;
    }

    candidates.add(candidate);
  }

  candidates.sort();

  return candidates
      .take(_positionsPerChord)
      .map(
        (candidate) => ChordPosition(
          baseFret: 1,
          frets: candidate.frets.join(' '),
          fingers: _fingersFor(candidate.frets).join(' '),
        ),
      )
      .toList();
}

List<_Candidate> _buildCandidates() {
  final candidates = <_Candidate>[];

  for (var first = 0; first <= _maxGeneratedFret; first++) {
    for (var second = 0; second <= _maxGeneratedFret; second++) {
      for (var third = 0; third <= _maxGeneratedFret; third++) {
        for (var fourth = 0; fourth <= _maxGeneratedFret; fourth++) {
          final candidate = _Candidate([first, second, third, fourth]);
          if (_isPlayable(candidate)) {
            candidates.add(candidate);
          }
        }
      }
    }
  }

  candidates.sort();
  return candidates;
}

int _pitchClassMask(List<int> intervals) {
  var mask = 0;

  for (final interval in intervals) {
    mask |= 1 << (interval % 12);
  }

  return mask;
}

int _bitCount(int value) {
  var count = 0;
  var remaining = value;

  while (remaining != 0) {
    count += remaining & 1;
    remaining >>= 1;
  }

  return count;
}

bool _isPlayable(_Candidate candidate) {
  final fretted = candidate.frets.where((fret) => fret > 0).toList();
  if (fretted.isEmpty) return true;

  final distinctFrets = fretted.toSet();
  if (distinctFrets.length > 4) return false;

  final minFret = fretted.reduce((a, b) => a < b ? a : b);
  final maxFret = fretted.reduce((a, b) => a > b ? a : b);
  final span = maxFret - minFret;
  final spanLimit = minFret <= 4 ? _maxLowPositionSpan : _maxHighPositionSpan;

  if (span > spanLimit) return false;
  if (candidate.frets.contains(0) && maxFret > _maxOpenVoicingFret) {
    return false;
  }

  return true;
}

int _requiredIntervalMask(String suffix, List<int> formula) {
  final intervals = _pitchClassMask(formula);
  var required = 1;

  if (suffix == 'sus2') {
    required |= 1 << 2;
  } else if (suffix.contains('sus4')) {
    required |= 1 << 5;
  } else if (suffix == 'dim' ||
      suffix == 'dim7' ||
      suffix.startsWith('m') && !suffix.startsWith('maj')) {
    required |= 1 << 3;
  } else if (suffix.contains('aug') || suffix.contains('#5')) {
    required |= 1 << 8;
  } else if (intervals & (1 << 4) != 0) {
    required |= 1 << 4;
  }

  if (suffix == 'dim' ||
      suffix == 'dim7' ||
      suffix.contains('b5') ||
      suffix.contains('#11')) {
    required |= 1 << 6;
  }

  if (suffix.contains('7') ||
      suffix.contains('9') ||
      suffix.contains('11') ||
      suffix.contains('13') ||
      suffix == 'alt') {
    if (intervals & (1 << 10) != 0) {
      required |= 1 << 10;
    } else if (intervals & (1 << 11) != 0) {
      required |= 1 << 11;
    }
  }

  return required;
}

List<int> _fingersFor(List<int> frets) {
  final positiveFrets = frets.where((fret) => fret > 0).toSet().toList()
    ..sort();
  final fingerByFret = {
    for (var i = 0; i < positiveFrets.length; i++) positiveFrets[i]: i + 1,
  };

  return [
    for (final fret in frets)
      if (fret == 0) 0 else fingerByFret[fret]!,
  ];
}

class _Candidate implements Comparable<_Candidate> {
  final List<int> frets;
  late final List<int> _intervalMasks = [
    for (var root = 0; root < 12; root++) _intervalMaskFrom(root),
  ];
  late final String _signature = frets.join(' ');

  _Candidate(this.frets);

  int intervalMaskFrom(int root) {
    return _intervalMasks[root];
  }

  int _intervalMaskFrom(int root) {
    var mask = 0;

    for (var stringIndex = 0; stringIndex < frets.length; stringIndex++) {
      final note =
          (_brazilianUkuleleTuning[stringIndex] + frets[stringIndex]) % 12;
      mask |= 1 << ((note - root) % 12);
    }

    return mask;
  }

  int get _maxFret => frets.reduce((a, b) => a > b ? a : b);

  int get _sum => frets.reduce((a, b) => a + b);

  int get _openStrings => frets.where((fret) => fret == 0).length;

  int get _span {
    final positiveFrets = frets.where((fret) => fret > 0).toList();
    if (positiveFrets.isEmpty) return 0;

    final min = positiveFrets.reduce((a, b) => a < b ? a : b);
    final max = positiveFrets.reduce((a, b) => a > b ? a : b);
    return max - min;
  }

  @override
  int compareTo(_Candidate other) {
    final comparisons = [
      _maxFret.compareTo(other._maxFret),
      _span.compareTo(other._span),
      _sum.compareTo(other._sum),
      other._openStrings.compareTo(_openStrings),
      _signature.compareTo(other._signature),
    ];

    return comparisons.firstWhere((comparison) => comparison != 0,
        orElse: () => 0);
  }
}
