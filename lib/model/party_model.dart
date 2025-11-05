import 'package:cloud_firestore/cloud_firestore.dart';

class PartyModel {
  String? partyName;
  String? partyNameLower;
  String? partyDesc;
  String? partyDeleted;
  Timestamp? partyAddOn;

  PartyModel({this.partyName,this.partyDeleted, this.partyAddOn, this.partyDesc,this.partyNameLower});

  Map<String, dynamic> toMap() {
    return {
      'party_name': partyName,
      'party_deleted': partyDeleted,
      'party_name_lower': partyNameLower,
      'party_add_on': partyAddOn,
      'party_description': partyDesc,
    };
  }

  static PartyModel fromMap(Map<String, dynamic> map) {
    return PartyModel(
      partyName: map['party_name'],
      partyDeleted: map['party_deleted'],
      partyNameLower: map['party_name_lower'],
      partyAddOn: map['party_add_on'],
      partyDesc: map['party_description'],
    );
  }
}
