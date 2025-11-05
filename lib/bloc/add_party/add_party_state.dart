part of 'add_party_bloc.dart';

@immutable
abstract class AddPartyState {}

class AddPartyInitial extends AddPartyState {}

class AddPartyLoading extends AddPartyState {}

class AddPartyComplete extends AddPartyState {}

class AddPartyError extends AddPartyState {
  final String errorMessage;

  AddPartyError({required this.errorMessage});
}
