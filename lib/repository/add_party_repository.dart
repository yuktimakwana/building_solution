import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duplicate_building_solution/utils/functions.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddPartyRepository {
  Future<void> addParty({
    required String partyName,
    required String partyNameLower,
    required String partyDescription,
    required String partyDeleted,
  }) async {
    try {
      final fireCloud = FirebaseRef.partyUserDoc.doc(partyName);

      final body = {
        'party_name': partyName,
        'party_name_lower': partyNameLower,
        'party_description': partyDescription,
        'party_deleted': partyDeleted,
        'party_add_on': Timestamp.now(),
      };
      await fireCloud.set(body);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print("Failed with error '${e.code}' : ${e.message}");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
