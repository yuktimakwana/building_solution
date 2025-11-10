
part of 'record_bloc.dart';

abstract class RecordsEvent {}

class RecordsSubscribe extends RecordsEvent {}

class RecordsOnStream extends RecordsEvent {
  final List<RecordModel> records;
  RecordsOnStream(this.records);
}

class RecordsRowSelected extends RecordsEvent {
  final int index;
  RecordsRowSelected(this.index);
}

class RecordsEditPressed extends RecordsEvent {}

class RecordsAddRowPressed extends RecordsEvent {}

class RecordsResetPressed extends RecordsEvent {}

class RecordsNextPressed extends RecordsEvent {}

class RecordsNoteChanged extends RecordsEvent {
  final String v;
  RecordsNoteChanged(this.v);
}

class RecordsFeetChanged extends RecordsEvent {
  final String v;
  RecordsFeetChanged(this.v);
}

class RecordsInchChanged extends RecordsEvent {
  final String v;
  RecordsInchChanged(this.v);
}

class RecordsQtyChanged extends RecordsEvent {
  final String v;
  RecordsQtyChanged(this.v);
}

class RecordsLessToggled extends RecordsEvent {
  final bool v;
  RecordsLessToggled(this.v);
}
class RecordsStreamError extends RecordsEvent {
  final String message;
  RecordsStreamError(this.message);
}
