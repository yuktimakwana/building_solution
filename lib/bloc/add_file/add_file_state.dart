part of 'add_file_bloc.dart';

@immutable
abstract class AddFileState {}

class AddFileInitial extends AddFileState {}

class AddFileLoading extends AddFileState {}

class AddFileComplete extends AddFileState {}

class AddFileError extends AddFileState {
  final String errorMessage;

  AddFileError({required this.errorMessage});
}
