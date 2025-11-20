import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duplicate_building_solution/offline/json_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Offline JSON codec', () {
    test('encodes and decodes Firestore Timestamp values', () {
      final original = {
        'time': Timestamp.fromMillisecondsSinceEpoch(123456789),
      };

      final encoded = encodeForStorage(original);
      expect(encoded['time'], isA<Map<String, dynamic>>());

      final decoded = decodeFromStorage(encoded);
      expect(decoded['time'], isA<Timestamp>());
      expect(
        (decoded['time'] as Timestamp).millisecondsSinceEpoch,
        equals(123456789),
      );
    });

    test('keeps nested structures intact', () {
      final original = {
        'list': [
          {
            'nested': Timestamp.fromMillisecondsSinceEpoch(1),
          },
        ],
        'child': {
          'value': Timestamp.fromMillisecondsSinceEpoch(2),
        },
      };

      final decoded = decodeFromStorage(encodeForStorage(original));
      final nested = decoded['list'] as List<dynamic>;
      expect(
        (nested.first['nested'] as Timestamp).millisecondsSinceEpoch,
        equals(1),
      );
      expect(
        ((decoded['child'] as Map)['value'] as Timestamp)
            .millisecondsSinceEpoch,
        equals(2),
      );
    });
  });
}


