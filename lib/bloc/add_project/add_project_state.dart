part of 'add_project_bloc.dart';

@immutable
abstract class AddProjectState {}

class AddProjectInitial extends AddProjectState {}

class AddProjectComplete extends AddProjectState {
  AddProjectComplete();
}

class AddProjectError extends AddProjectState {
  final String errorMessage;

  AddProjectError({required this.errorMessage});
}
