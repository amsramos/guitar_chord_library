import 'package:guitar_chord_library/src/instrument/brazilian_ukulele.dart';

import 'instrument/ukulele.dart';
import 'instrument/instrument.dart';
import 'instrument/guitar.dart';

class GuitarChordLibrary {
  /// No need to get instance
  GuitarChordLibrary._();

  /// Store the instrument information
  /// Guitar and Ukulele are supported right now
  static Instrument? _instrument;

  /// Choose your instrument
  /// [InstrumentType] is optional default is [InstrumentType.guitar]
  /// [InstrumentType.guitar], [InstrumentType.ukulele] and [InstrumentType.brazilianUkulele]
  static Instrument instrument([InstrumentType type = InstrumentType.guitar]) {
    switch (type) {
      case InstrumentType.guitar:
        if (_instrument != null && _instrument is Guitar) {
          return _instrument!;
        }
        return _instrument = Guitar();
      case InstrumentType.ukulele:
        if (_instrument != null && _instrument is Ukulele) {
          return _instrument!;
        }
        return _instrument = Ukulele();
      case InstrumentType.brazilianUkulele:
        if (_instrument != null && _instrument is BrazilianUkulele) {
          return _instrument!;
        }
        return _instrument = BrazilianUkulele();
    }
  }
}

/// Instrument Type
enum InstrumentType { guitar, ukulele, brazilianUkulele }
