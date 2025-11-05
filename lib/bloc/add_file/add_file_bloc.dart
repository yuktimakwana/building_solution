import 'package:duplicate_building_solution/repository/add_file_repository.dart';
import 'package:duplicate_building_solution/utils/globals.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'add_file_event.dart';

part 'add_file_state.dart';

class AddFileBloc extends Bloc<AddFileEvent, AddFileState> {
  AddFileRepository addFileRepository;

  AddFileBloc({required this.addFileRepository}) : super(AddFileInitial()) {
    on<NewAddFileEvent>(addFile);
  }

  void addFile(NewAddFileEvent event, Emitter<AddFileState> emit) async {
    try {
      await addFileRepository.addFile(
          fileDeleted:event.fileDeleted,
          fileName: event.fileName,
          fileNameLower: event.fileNameLower,
          fileDescription: event.fileDesc,
          projectName: event.projectName,
          partyName: event.partyName);

      emit(AddFileComplete());
    } catch (e) {
      emit(AddFileError(errorMessage: Globals.clientError));
    }
  }
}
