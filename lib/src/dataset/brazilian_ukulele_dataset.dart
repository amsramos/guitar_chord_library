import '../chord.dart';

/// Cavaquinho brasileiro dataset, tuning `D G B D` (low to high).
///
/// Positions are generated from a validated candidate search anchored by
/// `_preferredVoicings`, a table of classic shapes used by the cavaquinho
/// community. Selection policy:
///
/// * Classic (preferred) shapes always come first, in table order.
/// * Remaining slots are filled with validated generated shapes, ordered by
///   neck position (lowest fret region first).
/// * Generated shapes avoid open-string-heavy voicings (at most 1 open
///   string, never between fretted strings) and unplayable stretches.
/// * Four-note chords must be complete; the perfect fifth may be omitted in
///   fully fretted shapes for `_fifthOptionalSuffixes` (standard practice).
/// * Five-plus-note chords may omit notes but keep their defining intervals;
///   rootless voicings are accepted only for these jazz extensions.
/// * `dim` and `dim7` accept the diminished seventh (community plays `dim`
///   as `dim7`).
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
const int _maxGeneratedFret = 14;
const int _maxOpenVoicingFret = 7;
const int _maxLowPositionSpan = 3;
const int _maxHighPositionSpan = 4;
const int _positionsPerChord = 4;
const int _allOpenPosition = 99;

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

/// Four-note chords whose perfect fifth may be omitted in fully fretted
/// generated shapes. The fifth never defines these qualities.
const Set<String> _fifthOptionalSuffixes = {
  '7',
  'm7',
  'maj7',
  'mmaj7',
  '7sus4',
  '11',
  'add9',
  'madd9',
};

/// Classic shapes played by the cavaquinho community (real frets, `D G B D`).
/// These anchor the first positions of each chord, in table order.
const Map<String, Map<String, List<List<int>>>> _preferredVoicings = {
  'major': {
    'C': [
      [2, 0, 1, 2],
    ],
    'C#': [
      [3, 1, 2, 3],
    ],
    'D': [
      [0, 2, 3, 4],
    ],
    'D#': [
      [5, 3, 4, 5],
    ],
    'E': [
      [2, 1, 0, 2],
    ],
    'F': [
      [3, 2, 1, 3],
    ],
    'F#': [
      [4, 3, 2, 4],
    ],
    'G': [
      [5, 4, 3, 5],
      [0, 0, 0, 0],
    ],
    'G#': [
      [1, 1, 1, 1],
    ],
    'A': [
      [2, 2, 2, 2],
    ],
    'A#': [
      [3, 3, 3, 3],
      [0, 3, 3, 3],
    ],
    'B': [
      [4, 4, 4, 4],
    ],
  },
  'minor': {
    'C': [
      [1, 0, 1, 1],
    ],
    'C#': [
      [2, 1, 2, 2],
    ],
    'D': [
      [0, 2, 3, 3],
    ],
    'D#': [
      [1, 3, 4, 4],
    ],
    'E': [
      [2, 0, 0, 2],
    ],
    'F': [
      [3, 1, 1, 3],
    ],
    'F#': [
      [4, 2, 2, 4],
    ],
    'G': [
      [5, 3, 3, 5],
    ],
    'G#': [
      [1, 1, 0, 1],
    ],
    'A': [
      [2, 2, 1, 2],
    ],
    'A#': [
      [3, 3, 2, 3],
    ],
    'B': [
      [4, 4, 3, 4],
      [0, 4, 3, 4],
    ],
  },
  '7': {
    'C': [
      [2, 3, 1, 2],
    ],
    'C#': [
      [3, 4, 2, 3],
    ],
    'D': [
      [0, 2, 1, 4],
    ],
    'D#': [
      [5, 6, 4, 5],
    ],
    'E': [
      [0, 1, 0, 2],
      [2, 1, 0, 0],
    ],
    'F': [
      [1, 2, 1, 3],
    ],
    'F#': [
      [2, 3, 2, 4],
    ],
    'G': [
      [0, 0, 0, 3],
    ],
    'G#': [
      [1, 1, 1, 4],
    ],
    'A': [
      [2, 2, 2, 5],
    ],
    'A#': [
      [3, 3, 3, 6],
    ],
    'B': [
      [1, 2, 0, 1],
      [4, 4, 4, 7],
    ],
  },
  'm7': {
    'C': [
      [1, 3, 1, 1],
    ],
    'C#': [
      [2, 4, 2, 2],
    ],
    'D': [
      [0, 2, 1, 3],
    ],
    'D#': [
      [1, 3, 2, 4],
    ],
    'E': [
      [0, 0, 0, 2],
    ],
    'F': [
      [1, 1, 1, 3],
    ],
    'F#': [
      [2, 2, 2, 4],
    ],
    'G': [
      [5, 3, 3, 3],
    ],
    'G#': [
      [4, 4, 4, 6],
    ],
    'A': [
      [5, 5, 5, 7],
    ],
    'A#': [
      [6, 6, 6, 8],
    ],
    'B': [
      [0, 2, 0, 4],
      [7, 7, 7, 9],
    ],
  },
  'maj7': {
    'C': [
      [2, 5, 0, 5],
    ],
    'C#': [
      [6, 6, 6, 10],
    ],
    'D': [
      [0, 2, 2, 4],
    ],
    'D#': [
      [0, 3, 4, 5],
    ],
    'E': [
      [1, 1, 0, 2],
    ],
    'F': [
      [2, 2, 1, 3],
    ],
    'F#': [
      [3, 3, 2, 4],
    ],
    'G': [
      [0, 0, 0, 4],
    ],
    'G#': [
      [5, 5, 4, 6],
    ],
    'A': [
      [6, 6, 5, 7],
    ],
    'A#': [
      [7, 7, 6, 8],
    ],
    'B': [
      [1, 3, 0, 4],
    ],
  },
  '6': {
    'C': [
      [2, 2, 1, 2],
    ],
    'C#': [
      [3, 3, 2, 3],
    ],
    'D': [
      [0, 2, 0, 4],
    ],
    'D#': [
      [1, 0, 1, 1],
    ],
    'E': [
      [2, 1, 2, 2],
    ],
    'F': [
      [0, 2, 1, 3],
    ],
    'F#': [
      [1, 3, 2, 4],
    ],
    'G': [
      [0, 0, 0, 2],
    ],
    'G#': [
      [1, 1, 1, 3],
    ],
    'A': [
      [2, 2, 2, 4],
    ],
    'A#': [
      [3, 3, 3, 5],
    ],
    'B': [
      [1, 1, 0, 4],
      [4, 4, 4, 6],
    ],
  },
  'm6': {
    'C': [
      [1, 2, 1, 1],
    ],
    'C#': [
      [2, 3, 2, 2],
    ],
    'D': [
      [0, 2, 0, 3],
    ],
    'D#': [
      [1, 3, 1, 4],
    ],
    'E': [
      [2, 0, 2, 2],
      [2, 4, 2, 5],
    ],
    'F': [
      [3, 1, 3, 3],
      [3, 5, 3, 6],
    ],
    'F#': [
      [4, 2, 4, 4],
      [4, 6, 4, 7],
    ],
    'G': [
      [5, 3, 3, 2],
    ],
    'G#': [
      [6, 4, 4, 3],
    ],
    'A': [
      [2, 2, 1, 4],
    ],
    'A#': [
      [3, 3, 2, 5],
    ],
    'B': [
      [4, 4, 3, 6],
    ],
  },
  '9': {
    'C': [
      [0, 3, 1, 2],
    ],
    'C#': [
      [1, 4, 2, 3],
    ],
    'D': [
      [2, 5, 3, 4],
    ],
    'D#': [
      [3, 6, 4, 5],
    ],
    'E': [
      [4, 7, 5, 6],
    ],
    'F': [
      [5, 8, 6, 7],
    ],
    'F#': [
      [6, 9, 7, 8],
    ],
    'G': [
      [5, 4, 6, 7],
    ],
    'G#': [
      [6, 5, 7, 8],
    ],
    'A': [
      [7, 6, 8, 9],
    ],
    'A#': [
      [8, 7, 9, 10],
    ],
    'B': [
      [9, 8, 10, 11],
    ],
  },
  'dim': {
    'C': [
      [4, 5, 4, 4],
      [1, 2, 1, 4],
    ],
    'C#': [
      [5, 6, 5, 5],
      [2, 3, 2, 5],
    ],
    'D': [
      [0, 1, 3, 3],
      [0, 1, 0, 3],
    ],
    'D#': [
      [1, 2, 4, 4],
      [1, 2, 1, 4],
    ],
    'E': [
      [2, 3, 5, 5],
      [2, 3, 2, 5],
    ],
    'F': [
      [3, 4, 6, 6],
      [3, 4, 3, 6],
    ],
    'F#': [
      [4, 5, 7, 7],
      [1, 2, 1, 4],
    ],
    'G': [
      [5, 6, 8, 8],
      [2, 3, 2, 5],
    ],
    'G#': [
      [0, 1, 0, 0],
      [0, 1, 0, 3],
    ],
    'A': [
      [1, 2, 1, 1],
      [1, 2, 1, 4],
    ],
    'A#': [
      [2, 3, 2, 2],
      [2, 3, 2, 5],
    ],
    'B': [
      [3, 4, 3, 3],
      [3, 4, 3, 6],
    ],
  },
  'dim7': {
    'C': [
      [1, 2, 1, 4],
    ],
    'C#': [
      [2, 3, 2, 5],
    ],
    'D': [
      [0, 1, 0, 3],
    ],
    'D#': [
      [1, 2, 1, 4],
    ],
    'E': [
      [2, 3, 2, 5],
    ],
    'F': [
      [3, 4, 3, 6],
    ],
    'F#': [
      [1, 2, 1, 4],
    ],
    'G': [
      [2, 3, 2, 5],
    ],
    'G#': [
      [0, 1, 0, 3],
    ],
    'A': [
      [1, 2, 1, 4],
    ],
    'A#': [
      [2, 3, 2, 5],
    ],
    'B': [
      [3, 4, 3, 6],
    ],
  },
  'aug': {
    'C': [
      [2, 1, 1, 2],
    ],
    'C#': [
      [3, 2, 2, 3],
    ],
    'D': [
      [4, 3, 3, 4],
    ],
    'D#': [
      [1, 0, 0, 1],
    ],
    'E': [
      [2, 1, 1, 2],
    ],
    'F': [
      [3, 2, 2, 3],
    ],
    'F#': [
      [4, 3, 3, 4],
    ],
    'G': [
      [1, 0, 0, 1],
    ],
    'G#': [
      [2, 1, 1, 2],
    ],
    'A': [
      [3, 2, 2, 3],
    ],
    'A#': [
      [4, 3, 3, 4],
    ],
    'B': [
      [1, 0, 0, 1],
    ],
  },
  '11': {
    'C': [
      [2, 0, 1, 3],
    ],
  },
  'add9': {
    'C': [
      [0, 0, 1, 2],
    ],
  },
  'm9': {
    'C': [
      [0, 3, 1, 1],
    ],
  },
  'sus2': {
    'C': [
      [0, 0, 1, 0],
    ],
  },
  'sus4': {
    'C': [
      [3, 0, 1, 3],
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
  final preferred = <_Candidate>[
    for (final frets in _preferredVoicings[suffix]?[key] ?? const <List<int>>[])
      _Candidate(frets),
  ];

  for (final candidate in preferred) {
    if (!_isValidVoicing(candidate, root, suffix, isPreferred: true)) {
      throw StateError(
          'Invalid preferred $key$suffix voicing: ${candidate.frets}');
    }
  }

  final preferredMirrors = {
    for (final candidate in preferred) candidate.mirrorSignature,
  };

  // Deduplicate mirrored shapes: strings 1 and 4 are both D, so swapping
  // their frets produces the same notes. Keep the better-quality shape.
  final generated = <String, _Candidate>{};
  for (final candidate in _allCandidates) {
    if (!_isValidVoicing(candidate, root, suffix, isPreferred: false)) {
      continue;
    }

    final mirror = candidate.mirrorSignature;
    if (preferredMirrors.contains(mirror)) continue;

    final existing = generated[mirror];
    if (existing == null ||
        _compareQuality(candidate, existing, root, suffix) < 0) {
      generated[mirror] = candidate;
    }
  }

  final buckets = <int, List<_Candidate>>{};
  for (final candidate in generated.values) {
    buckets.putIfAbsent(candidate.position, () => []).add(candidate);
  }
  for (final bucket in buckets.values) {
    bucket.sort((a, b) => _compareQuality(a, b, root, suffix));
  }

  final chosen = preferred.take(_positionsPerChord).toList();
  final bucketPositions = buckets.keys.toList()..sort();

  // One shape per neck region first, from the lowest region up.
  for (final position in bucketPositions) {
    if (chosen.length >= _positionsPerChord) break;
    chosen.add(buckets[position]!.first);
  }

  if (chosen.length < _positionsPerChord) {
    final rest = <_Candidate>[
      for (final position in bucketPositions) ...buckets[position]!.skip(1),
    ];
    rest.sort((a, b) => _comparePositionThenQuality(a, b, root, suffix));
    for (final candidate in rest) {
      if (chosen.length >= _positionsPerChord) break;
      chosen.add(candidate);
    }
  }

  final preferredCount = preferred.length > _positionsPerChord
      ? _positionsPerChord
      : preferred.length;
  final tail = chosen.sublist(preferredCount)
    ..sort((a, b) => _comparePositionThenQuality(a, b, root, suffix));

  final positions = <ChordPosition>[];
  final signatures = <String>{};
  for (final candidate in chosen.take(preferredCount).followedBy(tail)) {
    _addPosition(positions, signatures, candidate.frets);
  }

  return positions;
}

int _allowedIntervalMask(String suffix) {
  var mask = _pitchClassMask(_formulas[suffix]!);

  // The community plays dim as dim7; accept the diminished seventh.
  if (suffix == 'dim' || suffix == 'dim7') {
    mask |= (1 << 3) | (1 << 6) | (1 << 9);
  }

  return mask;
}

bool _isValidVoicing(
  _Candidate candidate,
  int root,
  String suffix, {
  required bool isPreferred,
}) {
  if (!_isPlayable(candidate)) return false;

  final formulaMask = _pitchClassMask(_formulas[suffix]!);
  final noteCount = _bitCount(formulaMask);
  final allowed = _allowedIntervalMask(suffix);
  final required = _requiredIntervalMask(suffix, _formulas[suffix]!);
  final intervals = candidate.intervalMaskFrom(root);

  if (intervals & ~allowed != 0) return false;

  if (noteCount >= 5 && !isPreferred) {
    // Jazz extensions may drop the root (documented rootless voicings).
    final rootless = required & ~1;
    if (intervals & required != required && intervals & rootless != rootless) {
      return false;
    }
  } else {
    if (intervals & required != required) return false;
  }

  if (noteCount <= 4 && !isPreferred) {
    var must = formulaMask;
    if (suffix == 'dim') {
      must = (1 << 0) | (1 << 3) | (1 << 6);
    }
    if (_fifthOptionalSuffixes.contains(suffix) && !candidate.hasOpenStrings) {
      must &= ~(1 << 7);
    }
    if (intervals & must != must) return false;
  }

  if (!isPreferred) {
    // Avoid open-string-heavy shapes in generated voicings.
    if (candidate.openCount >= 2) return false;
    if (candidate.hasInteriorOpen) return false;
  }

  return true;
}

int _compareQuality(_Candidate a, _Candidate b, int root, String suffix) {
  final formulaMask = _pitchClassMask(_formulas[suffix]!);

  int rooted(_Candidate candidate) =>
      candidate.intervalMaskFrom(root) & 1 != 0 ? 0 : 1;
  int complete(_Candidate candidate) =>
      candidate.intervalMaskFrom(root) & formulaMask == formulaMask ? 0 : 1;

  final comparisons = [
    rooted(a).compareTo(rooted(b)),
    complete(a).compareTo(complete(b)),
    a.difficulty.compareTo(b.difficulty),
    a.sum.compareTo(b.sum),
    a.signature.compareTo(b.signature),
  ];

  return comparisons.firstWhere((comparison) => comparison != 0,
      orElse: () => 0);
}

int _comparePositionThenQuality(
    _Candidate a, _Candidate b, int root, String suffix) {
  final position = a.position.compareTo(b.position);
  if (position != 0) return position;

  return _compareQuality(a, b, root, suffix);
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

  if (_ninthSuffixes.contains(suffix)) {
    required |= 1 << 2;
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

class _Candidate {
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

  late final int sum = frets.reduce((a, b) => a + b);

  late final int openCount = frets.where((fret) => fret == 0).length;

  bool get hasOpenStrings => openCount > 0;

  /// Open string with fretted strings on both sides (hard to keep clean).
  late final bool hasInteriorOpen = _computeInteriorOpen();

  bool _computeInteriorOpen() {
    for (var stringIndex = 1; stringIndex < frets.length - 1; stringIndex++) {
      if (frets[stringIndex] != 0) continue;

      final hasFrettedBefore =
          frets.sublist(0, stringIndex).any((fret) => fret > 0);
      final hasFrettedAfter =
          frets.sublist(stringIndex + 1).any((fret) => fret > 0);
      if (hasFrettedBefore && hasFrettedAfter) return true;
    }

    return false;
  }

  late final int span = _computeSpan();

  int _computeSpan() {
    final positiveFrets = frets.where((fret) => fret > 0).toList();
    if (positiveFrets.isEmpty) return 0;

    final min = positiveFrets.reduce((a, b) => a < b ? a : b);
    final max = positiveFrets.reduce((a, b) => a > b ? a : b);
    return max - min;
  }

  /// Fret region of the shape on the neck; all-open shapes sort last.
  late final int position = _computePosition();

  int _computePosition() {
    final positiveFrets = frets.where((fret) => fret > 0).toList();
    if (positiveFrets.isEmpty) return _allOpenPosition;

    return positiveFrets.reduce((a, b) => a < b ? a : b);
  }

  late final int fingerCount =
      _fingersFor(frets).where((finger) => finger > 0).toSet().length;

  late final int difficulty =
      fingerCount + span + (openCount >= 2 ? 1 : 0);

  /// Signature treating strings 1 and 4 (both D) as interchangeable.
  late final String mirrorSignature = frets[0] <= frets[3]
      ? '${frets[0]} ${frets[1]} ${frets[2]} ${frets[3]}'
      : '${frets[3]} ${frets[1]} ${frets[2]} ${frets[0]}';

  String get signature => _signature;
}
