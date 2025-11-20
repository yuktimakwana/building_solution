part of 'add_party_bloc.dart';

@immutable
abstract class AddPartyState {}

class AddPartyInitial extends AddPartyState {}

class AddPartyComplete extends AddPartyState {
  final PartyModel party;
  AddPartyComplete({required this.party});
}

class AddPartyError extends AddPartyState {
  final String errorMessage;
  AddPartyError({required this.errorMessage});
}
