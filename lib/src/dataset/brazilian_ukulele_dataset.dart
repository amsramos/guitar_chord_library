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

const List<int> _brazilianUkuleleTuning = [2, 7, 11, 2];
const int _maxGeneratedFret = 12;
const int _maxOpenVoicingFret = 7;
const int _beginnerVoicingMaxFret = 5;
const int _maxLowPositionSpan = 3;
const int _maxHighPositionSpan = 4;
const int _positionsPerChord = 4;
const Map<String, Map<String, List<List<int>>>> _preferredVoicings = {
  'A': {
    'major': [
      [2, 2, 2, 2],
    ],
    'minor': [
      [2, 2, 1, 2],
    ],
    'aug': [
      [3, 2, 2, 3],
    ],
    'dim': [
      [1, 2, 1, 1],
    ],
    '6': [
      [2, 2, 2, 4],
    ],
    '7': [
      [2, 2, 2, 5],
    ],
    'maj7': [
      [6, 6, 5, 7],
    ],
    'm7': [
      [5, 5, 5, 7],
    ],
  },
  'A#': {
    'major': [
      [0, 3, 3, 3],
    ],
    'minor': [
      [3, 3, 2, 3],
    ],
    'aug': [
      [0, 3, 3, 4],
    ],
    'dim': [
      [2, 3, 2, 2],
    ],
    '6': [
      [3, 3, 3, 5],
    ],
    '7': [
      [0, 3, 6, 6],
    ],
    'maj7': [
      [7, 7, 6, 8],
    ],
    'm7': [
      [6, 6, 6, 8],
    ],
  },
  'B': {
    'major': [
      [4, 4, 4, 4],
    ],
    'minor': [
      [0, 4, 0, 4],
    ],
    'aug': [
      [1, 0, 0, 1],
    ],
    'dim': [
      [0, 4, 0, 3],
    ],
    '6': [
      [1, 1, 0, 4],
    ],
    '7': [
      [1, 2, 0, 4],
    ],
    'maj7': [
      [1, 3, 0, 4],
    ],
    'm7': [
      [0, 2, 0, 4],
    ],
  },
  'C': {
    'major': [
      [2, 0, 1, 2],
    ],
    'minor': [
      [1, 0, 1, 1],
    ],
    'aug': [
      [2, 1, 1, 2],
    ],
    'dim': [
      [4, 5, 4, 4],
    ],
    '6': [
      [5, 5, 5, 7],
    ],
    '7': [
      [5, 5, 5, 8],
    ],
    'maj7': [
      [2, 5, 0, 5],
    ],
    'm7': [
      [10, 8, 8, 8],
    ],
    '11': [
      [2, 0, 1, 3],
    ],
    '9': [
      [0, 3, 1, 2],
    ],
    'add9': [
      [0, 0, 1, 2],
    ],
    'dim7': [
      [1, 2, 1, 4],
    ],
    'm9': [
      [0, 3, 1, 1],
    ],
    'sus2': [
      [0, 0, 1, 0],
    ],
    'sus4': [
      [3, 0, 1, 3],
    ],
  },
  'C#': {
    'major': [
      [3, 1, 2, 3],
    ],
    'minor': [
      [2, 1, 2, 2],
    ],
    'aug': [
      [3, 2, 2, 3],
    ],
    'dim': [
      [2, 0, 2, 2],
    ],
    '6': [
      [6, 6, 6, 8],
    ],
    '7': [
      [3, 6, 0, 6],
    ],
    'maj7': [
      [10, 6, 6, 6],
    ],
    'm7': [
      [6, 6, 5, 9],
    ],
  },
  'D': {
    'major': [
      [0, 2, 3, 4],
    ],
    'minor': [
      [0, 2, 3, 3],
    ],
    'aug': [
      [0, 3, 3, 4],
    ],
    'dim': [
      [0, 1, 3, 3],
    ],
    '6': [
      [0, 2, 0, 4],
    ],
    '7': [
      [0, 2, 1, 4],
    ],
    'maj7': [
      [0, 2, 2, 4],
    ],
    'm7': [
      [0, 2, 1, 3],
    ],
  },
  'D#': {
    'major': [
      [5, 3, 4, 5],
    ],
    'minor': [
      [4, 3, 4, 4],
    ],
    'aug': [
      [1, 0, 0, 1],
    ],
    'dim': [
      [4, 2, 4, 4],
    ],
    '6': [
      [10, 8, 8, 8],
    ],
    '7': [
      [11, 8, 8, 8],
    ],
    'maj7': [
      [0, 3, 4, 5],
    ],
    'm7': [
      [1, 3, 2, 4],
    ],
  },
  'E': {
    'major': [
      [2, 1, 0, 2],
    ],
    'minor': [
      [2, 0, 0, 2],
    ],
    'aug': [
      [2, 1, 1, 2],
    ],
    'dim': [
      [5, 3, 5, 5],
    ],
    '6': [
      [6, 6, 5, 9],
    ],
    '7': [
      [0, 1, 0, 2],
    ],
    'maj7': [
      [1, 1, 0, 2],
    ],
    'm7': [
      [0, 0, 0, 2],
    ],
  },
  'F': {
    'major': [
      [3, 2, 1, 3],
    ],
    'minor': [
      [3, 1, 1, 3],
    ],
    'aug': [
      [3, 2, 2, 3],
    ],
    'dim': [
      [3, 1, 0, 3],
    ],
    '6': [
      [0, 2, 1, 3],
    ],
    '7': [
      [1, 2, 1, 3],
    ],
    'maj7': [
      [2, 2, 1, 3],
    ],
    'm7': [
      [1, 1, 1, 3],
    ],
  },
  'F#': {
    'major': [
      [4, 3, 2, 4],
    ],
    'minor': [
      [4, 2, 2, 4],
    ],
    'aug': [
      [0, 3, 3, 4],
    ],
    'dim': [
      [4, 2, 1, 4],
    ],
    '6': [
      [1, 3, 2, 4],
    ],
    '7': [
      [2, 3, 2, 4],
    ],
    'maj7': [
      [3, 3, 2, 4],
    ],
    'm7': [
      [2, 2, 2, 4],
    ],
  },
  'G': {
    'major': [
      [5, 4, 3, 5],
    ],
    'minor': [
      [0, 3, 3, 5],
    ],
    'aug': [
      [1, 0, 0, 1],
    ],
    'dim': [
      [5, 3, 2, 5],
    ],
    '6': [
      [0, 0, 0, 2],
    ],
    '7': [
      [0, 0, 0, 3],
    ],
    'maj7': [
      [0, 0, 0, 4],
    ],
    'm7': [
      [5, 3, 3, 3],
    ],
  },
  'G#': {
    'major': [
      [1, 1, 1, 1],
    ],
    'minor': [
      [1, 1, 0, 1],
    ],
    'aug': [
      [2, 1, 1, 2],
    ],
    'dim': [
      [0, 1, 0, 0],
    ],
    '6': [
      [1, 1, 1, 3],
    ],
    '7': [
      [1, 1, 1, 4],
    ],
    'maj7': [
      [5, 5, 4, 6],
    ],
    'm7': [
      [1, 1, 0, 4],
    ],
  },
};
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
  final candidates = <_RankedCandidate>[];
  final candidateSignatures = <String>{};
  final positions = <ChordPosition>[];
  final signatures = <String>{};

  for (final frets in _preferredVoicings[key]?[suffix] ?? const <List<int>>[]) {
    final candidate = _Candidate(frets);

    if (!_isValidCandidate(
      candidate,
      root,
      allowedIntervals,
      requiredIntervals,
      requiresCompleteVoicing,
    )) {
      throw StateError('Invalid preferred $key$suffix voicing: $frets');
    }

    _addCandidate(candidates, candidateSignatures, candidate, true);
  }

  for (final candidate in _allCandidates) {
    if (_isValidCandidate(
      candidate,
      root,
      allowedIntervals,
      requiredIntervals,
      requiresCompleteVoicing,
    )) {
      _addCandidate(candidates, candidateSignatures, candidate, false);
    }
  }

  candidates.sort((a, b) => _compareCandidatesForRoot(root, a, b));

  for (final candidate in candidates) {
    _addPosition(positions, signatures, candidate.candidate.frets);
    if (positions.length == _positionsPerChord) break;
  }

  return positions;
}

bool _isValidCandidate(
  _Candidate candidate,
  int root,
  int allowedIntervals,
  int requiredIntervals,
  bool requiresCompleteVoicing,
) {
  final intervals = candidate.intervalMaskFrom(root);

  if (!_isPlayable(candidate)) return false;
  if (intervals & ~allowedIntervals != 0) return false;
  if (intervals & requiredIntervals != requiredIntervals) return false;
  if (requiresCompleteVoicing &&
      intervals & allowedIntervals != allowedIntervals) {
    return false;
  }

  return true;
}

void _addCandidate(
  List<_RankedCandidate> candidates,
  Set<String> signatures,
  _Candidate candidate,
  bool isPreferred,
) {
  if (signatures.add(candidate.frets.join(' '))) {
    candidates.add(_RankedCandidate(candidate, isPreferred));
  }
}

int _compareCandidatesForRoot(
    int root, _RankedCandidate a, _RankedCandidate b) {
  final candidateA = a.candidate;
  final candidateB = b.candidate;
  final comparisons = [
    _boolScore(candidateA.isBeginnerVoicing)
        .compareTo(_boolScore(candidateB.isBeginnerVoicing)),
    _boolScore(!candidateA.isAllOpen)
        .compareTo(_boolScore(!candidateB.isAllOpen)),
    _boolScore(candidateA.hasRootBass(root))
        .compareTo(_boolScore(candidateB.hasRootBass(root))),
    _boolScore(a.isPreferred).compareTo(_boolScore(b.isPreferred)),
    _boolScore(candidateA.hasMatchingOuterStrings)
        .compareTo(_boolScore(candidateB.hasMatchingOuterStrings)),
    candidateA.maxFret.compareTo(candidateB.maxFret),
    candidateA.span.compareTo(candidateB.span),
    candidateA.sum.compareTo(candidateB.sum),
    candidateA.signature.compareTo(candidateB.signature),
  ];

  return comparisons.firstWhere((comparison) => comparison != 0,
      orElse: () => 0);
}

int _boolScore(bool value) => value ? 0 : 1;

class _RankedCandidate {
  final _Candidate candidate;
  final bool isPreferred;

  _RankedCandidate(this.candidate, this.isPreferred);
}

void _addPosition(
  List<ChordPosition> positions,
  Set<String> signatures,
  List<int> realFrets,
) {
  final position = _positionFromRealFrets(realFrets);
  final signature = '${position.baseFret}|${position.frets}';
  if (!signatures.add(signature)) return;

  positions.add(position);
}

ChordPosition _positionFromRealFrets(List<int> realFrets) {
  final positiveFrets = realFrets.where((fret) => fret > 0).toList();
  final maxFret =
      positiveFrets.isEmpty ? 0 : positiveFrets.reduce((a, b) => a > b ? a : b);
  final minFret =
      positiveFrets.isEmpty ? 1 : positiveFrets.reduce((a, b) => a < b ? a : b);
  final hasOpenString = realFrets.contains(0);
  final baseFret = !hasOpenString && maxFret > 4 ? minFret : 1;
  final displayedFrets = [
    for (final fret in realFrets)
      if (fret <= 0 || baseFret == 1) fret else fret - baseFret + 1,
  ];

  return ChordPosition(
    baseFret: baseFret,
    frets: displayedFrets.join(' '),
    fingers: _fingersFor(displayedFrets).join(' '),
  );
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

  if (_requiresNaturalEleventh(suffix)) {
    required |= 1 << 5;
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

bool _requiresNaturalEleventh(String suffix) {
  return suffix == '11' ||
      suffix == 'm11' ||
      suffix == 'maj11' ||
      suffix == 'mmaj11';
}

List<int> _fingersFor(List<int> frets) {
  final fingers = List.filled(frets.length, 0);
  final positiveFrets = frets.where((fret) => fret > 0).toSet().toList()
    ..sort();
  var nextFinger = 1;

  for (final fret in positiveFrets) {
    var stringIndex = 0;
    while (stringIndex < frets.length) {
      if (frets[stringIndex] != fret) {
        stringIndex++;
        continue;
      }

      while (stringIndex < frets.length && frets[stringIndex] == fret) {
        fingers[stringIndex] = nextFinger;
        stringIndex++;
      }
      nextFinger++;
    }
  }

  return fingers;
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

  bool hasRootBass(int root) {
    return (_brazilianUkuleleTuning.first + frets.first - root) % 12 == 0;
  }

  bool get isAllOpen => _maxFret == 0;

  bool get isBeginnerVoicing => _maxFret <= _beginnerVoicingMaxFret;

  bool get hasMatchingOuterStrings {
    final first = (_brazilianUkuleleTuning.first + frets.first) % 12;
    final last = (_brazilianUkuleleTuning.last + frets.last) % 12;
    return first == last;
  }

  int get maxFret => _maxFret;

  int get sum => _sum;

  int get span => _span;

  String get signature => _signature;

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
