part of 'add_file_bloc.dart';

@immutable
abstract class AddFileEvent {}

class NewAddFileEvent extends AddFileEvent {
  final String fileName,
      fileDesc,
      partyName,
      projectName,
      fileDeleted,
      fileNameLower;

  NewAddFileEvent({
    required this.fileName,
    required this.fileDesc,
    required this.projectName,
    required this.partyName,
    required this.fileDeleted,
    required this.fileNameLower,
  });
}
