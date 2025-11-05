part of 'add_project_bloc.dart';

@immutable
abstract class AddProjectEvent {}

class NewAddProjectEvent extends AddProjectEvent {
  final String projectName,
      projectDescription,
      projectDeleted,
      partyName,
      projectNameLower;

  NewAddProjectEvent({
    required this.projectName,
    required this.projectDescription,
    required this.partyName,
    required this.projectDeleted,
    required this.projectNameLower,
  });
}
