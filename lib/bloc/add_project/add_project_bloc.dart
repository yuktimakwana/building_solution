import 'package:duplicate_building_solution/repository/add_project_repository.dart';
import 'package:duplicate_building_solution/utils/text_constant.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'add_project_event.dart';

part 'add_project_state.dart';

class AddProjectBloc extends Bloc<AddProjectEvent, AddProjectState> {
  AddProjectRepository addProjectRepository;

  AddProjectBloc({required this.addProjectRepository})
    : super(AddProjectInitial()) {
    on<NewAddProjectEvent>(addProject);
  }

  void addProject(
    NewAddProjectEvent event,
    Emitter<AddProjectState> emit,
  ) async {
    try {
      await addProjectRepository.addProject(
        projectName: event.projectName,
        projectDeleted: event.projectDeleted,
        partyName: event.partyName,
        projectNameLower: event.projectNameLower,
        projectDescription: event.projectDescription,
      );

      emit(AddProjectComplete());
    } catch (error) {
      emit(AddProjectError(errorMessage: TextConstant.clientError));
    }
  }
}
