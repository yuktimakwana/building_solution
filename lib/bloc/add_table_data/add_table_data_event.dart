part of 'add_table_data_bloc.dart';

@immutable
abstract class AddTableDataEvent {}

class NewAddTableDataEvent extends AddTableDataEvent {
  final String note, partyName, projectName,fileName;
  final String? feet, inch;
  final String? total;
  final String? rft;
  final String? qty;
  final num id;
  final bool less;

  NewAddTableDataEvent(
      {required this.note,
      required this.feet,
      required this.id,
      required this.inch,
      required this.total,
      required this.rft,
      required this.partyName,
      required this.projectName,
      required this.fileName,
      required this.qty,
      required this.less});
}
