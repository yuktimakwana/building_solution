import 'package:duplicate_building_solution/repository/add_table_data_repository.dart';
import 'package:duplicate_building_solution/utils/globals.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'add_table_data_event.dart';

part 'add_table_data_state.dart';

class AddTableDataBloc extends Bloc<AddTableDataEvent, AddTableDataState> {
  AddTableDataRepository addTableDataRepository;

  AddTableDataBloc({required this.addTableDataRepository})
      : super(AddTableDataInitial()) {
    on<NewAddTableDataEvent>(addTableData);
  }

  void addTableData(
      NewAddTableDataEvent event, Emitter<AddTableDataState> emit) async {
    emit(AddTableDataLoading());

    try {
      await addTableDataRepository.addTableData(
          id: event.id,
          note: event.note,
          feet: event.feet ?? '0',
          inch: event.inch ?? '0',
          qty: event.qty ?? '1',
          rft: event.rft ?? '0',
          total: event.total ?? '0',
          less: event.less,
          fileName: event.fileName,
          partyName: event.partyName,
          projectName: event.projectName);

      emit(AddTableDataComplete());
    } catch (error) {
      emit(AddTableDataError(errorMessage: Globals.clientError));
    }
  }
}
