import 'package:duplicate_building_solution/model/record_model.dart';
import 'package:duplicate_building_solution/screens/table/table_data_screen.dart';

class RecordsState {
   final List<RecordModel> records;
   final int? selectedIndex;
   final bool buttonsEnabled;
   final FormMode mode;
   final String note;
   final String feet;
   final String inch;
   final String qty;
   final bool less;
   final num total; // computed live
   final num lineNumber; // shows in grey bar
   final bool loading;
   final String? error;
   final RecordModel? selected;


   bool get hasData => records.isNotEmpty;
   @override
   List<Object?> get props => [
      records,
      selectedIndex,
      selected,
      buttonsEnabled,
      loading,
      error,
      mode,
      note,
      feet,
      inch,
      qty,
      less,
      lineNumber,
      total,
   ];
   // RecordModel? get selected =>
   //     (selectedIndex != null && selectedIndex! >= 0 && selectedIndex! < records.length)
   //         ? records[selectedIndex!]
   //         : null;

   const RecordsState({
      required this.records,
      this.selectedIndex,
      this.buttonsEnabled = false,
      this.mode = FormMode.add,
      this.note = '',
      this.feet = '',
      this.inch = '',
      this.qty = '',
      this.less = false,
      this.total = 0,
      this.lineNumber = 1,
      this.loading = false,
      this.error,
      this.selected
   });

   RecordsState copyWith({
      List<RecordModel>? records,
      int? selectedIndex,
      bool? buttonsEnabled,
      FormMode? mode,
      String? note,
      RecordModel? selected,
      String? feet,
      String? inch,
      String? qty,
      bool? less,
      num? total,
      num? lineNumber,
      bool? loading,
      String? error,
   }) {
      return RecordsState(
         records: records ?? this.records,
         selectedIndex: selectedIndex,
         buttonsEnabled: buttonsEnabled ?? this.buttonsEnabled,
         mode: mode ?? this.mode,
         note: note ?? this.note,
         feet: feet ?? this.feet,
         inch: inch ?? this.inch,
         qty: qty ?? this.qty,
         less: less ?? this.less,
         total: total ?? this.total,
         lineNumber: lineNumber ?? this.lineNumber,
         loading: loading ?? this.loading,
         selected: selected ?? this.selected,
         error: error,
      );
   }
}