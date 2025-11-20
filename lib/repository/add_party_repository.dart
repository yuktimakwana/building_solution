import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duplicate_building_solution/offline/offline_sync_service.dart';
import 'package:flutter/foundation.dart';

class AddPartyRepository {
  final OfflineSyncService _syncService = OfflineSyncService.instance;

  Future<void> addParty({
    required String partyName,
    required String partyNameLower,
    required String partyDescription,
    required String partyDeleted,
  }) async {
    try {
      final body = {
        'party_name': partyName,
        'party_name_lower': partyNameLower,
        'party_description': partyDescription,
        'party_deleted': partyDeleted,
        'party_add_on': Timestamp.now(),
      };
      await _syncService.upsertParty(partyName: partyName, data: body);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print("Failed with error '${e.code}' : ${e.message}");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
