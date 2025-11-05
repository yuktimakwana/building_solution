part of 'add_table_data_bloc.dart';

@immutable
abstract class AddTableDataState {}

class AddTableDataInitial extends AddTableDataState {}
class AddTableDataLoading extends AddTableDataState {}
class AddTableDataComplete extends AddTableDataState {

}
class AddTableDataError extends AddTableDataState {
   final String errorMessage;

   AddTableDataError({required this.errorMessage});
}
