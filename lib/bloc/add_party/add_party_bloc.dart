import 'package:duplicate_building_solution/repository/add_party_repository.dart';
import 'package:duplicate_building_solution/utils/text_constant.dart';
import 'package:duplicate_building_solution/model/party_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'add_party_event.dart';

part 'add_party_state.dart';

class AddPartyBloc extends Bloc<AddPartyEvent, AddPartyState> {
  AddPartyRepository addPartyRepository;

  AddPartyBloc({required this.addPartyRepository}) : super(AddPartyInitial()) {
    on<NewAddPartyEvent>(addParty);
  }

  void addParty(NewAddPartyEvent event, Emitter<AddPartyState> emit) async {
    try {
      await addPartyRepository.addParty(
        partyName: event.partyName,
        partyNameLower: event.partyNameLower,
        partyDescription: event.partyDesc,
        partyDeleted: event.partyDeleted,
      );

      final newParty = PartyModel(
        partyName: event.partyName,
        partyDesc: event.partyDesc,
        partyDeleted: event.partyDeleted,
        partyNameLower: event.partyNameLower,
        partyAddOn:
            Timestamp.now(), // Approximate timestamp for immediate UI update
      );

      emit(AddPartyComplete(party: newParty));
    } catch (e) {
      emit(AddPartyError(errorMessage: TextConstant.clientError));
    }
  }
}
