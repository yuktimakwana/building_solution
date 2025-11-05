part of 'add_party_bloc.dart';

@immutable
abstract class AddPartyEvent {}

class NewAddPartyEvent extends AddPartyEvent {
  final String partyName, partyDesc, partyDeleted, partyNameLower;

  NewAddPartyEvent(
      {required this.partyName,
      required this.partyDesc,
      required this.partyDeleted,
      required this.partyNameLower});
}
