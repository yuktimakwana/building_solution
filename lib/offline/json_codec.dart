import 'package:cloud_firestore/cloud_firestore.dart';

const _typeKey = '__offline_type__';

Map<String, dynamic> encodeForStorage(Map<String, dynamic> input) {
  return input.map((key, value) => MapEntry(key, _encodeValue(value)));
}

Map<String, dynamic> decodeFromStorage(Map<String, dynamic> input) {
  return input.map((key, value) => MapEntry(key, _decodeValue(value)));
}

dynamic _encodeValue(dynamic value) {
  if (value == null || value is num || value is String || value is bool) {
    return value;
  }
  if (value is Timestamp) {
    return {
      _typeKey: 'timestamp',
      'seconds': value.seconds,
      'nanoseconds': value.nanoseconds,
    };
  }
  if (value is DateTime) {
    return {_typeKey: 'datetime', 'value': value.toIso8601String()};
  }
  if (value is Iterable) {
    return value.map(_encodeValue).toList();
  }
  if (value is Map) {
    return value.map((key, v) => MapEntry(key.toString(), _encodeValue(v)));
  }
  return value.toString();
}

dynamic _decodeValue(dynamic value) {
  if (value is List) {
    return value.map(_decodeValue).toList();
  }
  if (value is Map) {
    final type = value[_typeKey];
    if (type == 'timestamp') {
      return Timestamp(
        value['seconds'] as int? ?? 0,
        value['nanoseconds'] as int? ?? 0,
      );
    }
    if (type == 'datetime') {
      return DateTime.tryParse(value['value'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
    }
    return value.map((key, v) => MapEntry(key, _decodeValue(v)));
  }
  return value;
}
