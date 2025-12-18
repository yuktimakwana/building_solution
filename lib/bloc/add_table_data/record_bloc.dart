import 'dart:async';

import 'package:duplicate_building_solution/model/record_model.dart';
import 'package:duplicate_building_solution/repository/record_repository.dart';
import 'package:duplicate_building_solution/screens/table/table_data_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'record_event.dart';

part 'record_state.dart';

class RecordsBloc extends Bloc<RecordsEvent, RecordsState> {
  RecordsBloc(this.repo) : super(const RecordsState(records: [])) {
    on<RecordsSubscribe>(_onSub);
    on<RecordsOnStream>(_onStream);
    on<RecordsRowSelected>(_onRowSelected);
    on<RecordsEditPressed>(_onEdit);
    on<RecordsAddRowPressed>(_onAddRowAfter);
    on<RecordsResetPressed>(_onReset);
    on<RecordsNextPressed>(_onNext);
    on<RecordsStreamError>(_onStreamError);
    on<RecordsNoteChanged>((e, emit) => _recompute(emit, note: e.v));
    on<RecordsFeetChanged>((e, emit) => _recompute(emit, feet: e.v));
    on<RecordsInchChanged>((e, emit) => _recompute(emit, inch: e.v));
    on<RecordsQtyChanged>((e, emit) => _recompute(emit, qty: e.v));
    on<RecordsLessToggled>((e, emit) => _recompute(emit, less: e.v));
  }

  final RecordsRepository repo;
  StreamSubscription? _sub;

  Future<void> _onSub(RecordsSubscribe e, Emitter<RecordsState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    await _sub?.cancel();

    _sub = repo.watchAll().listen(
      (recs) => add(RecordsOnStream(recs)),
      onError: (err) {
        add(RecordsStreamError(err.toString()));
      },
    );
  }

  void _onStreamError(RecordsStreamError e, Emitter<RecordsState> emit) {
    emit(state.copyWith(loading: false, error: e.message));
  }

  void _onStream(RecordsOnStream e, Emitter<RecordsState> emit) {
    // default Line # = last integer + 1 (if no rows => 1)
    final nextInt = e.records.isEmpty
        ? 1
        : (e.records
                  .map((r) => r.idColumn.floor())
                  .fold<int>(0, (p, c) => c > p ? c : p) +
              1);
    emit(
      state.copyWith(
        records: e.records,
        loading: false,
        lineNumber: nextInt,
        buttonsEnabled: false,
        selectedIndex: null,
        mode: FormMode.add,
      ),
    );
  }

  void _onRowSelected(RecordsRowSelected e, Emitter<RecordsState> emit) {
    if (e.index < 0 || e.index >= state.records.length) return;
    final selectedRecord = state.records[e.index];
    print(
      'Row selected: ${selectedRecord.docId}, line: ${selectedRecord.idColumn}',
    );

    emit(
      state.copyWith(
        selectedIndex: e.index,
        selected: selectedRecord, // 👈 save the actual selected record
        buttonsEnabled: true,
        mode: FormMode.add,
      ),
    );
  }

  void _onEdit(RecordsEditPressed e, Emitter<RecordsState> emit) {
    final sel = state.selected;
    if (sel == null) return;

    print('Edit selected: $sel');

    // Prefill fields, lock in existing line number
    _recompute(
      emit,
      mode: FormMode.edit,
      lineNumber: sel.idColumn,
      note: sel.note,
      feet: sel.feet,
      inch: sel.inch,
      qty: sel.qty.abs().toString(),
      less: sel.qty < 0,
    );
  }

  void _onAddRowAfter(RecordsAddRowPressed e, Emitter<RecordsState> emit) {
    final sel = state.selected;
    if (sel == null) return;
    final newLine = num.parse((sel.idColumn + 0.1).toStringAsFixed(1));
    // Start with empty fields
    _recompute(
      emit,
      mode: FormMode.insertAfter,
      lineNumber: newLine,
      note: '',
      feet: '',
      inch: '',
      qty: '',
      less: false,
    );
  }

  void _onReset(RecordsResetPressed e, Emitter<RecordsState> emit) {
    // Clear fields and set line number to last integer + 1
    final nextInt = state.records.isEmpty
        ? 1
        : (state.records
                  .map((r) => r.idColumn.floor())
                  .fold<int>(0, (p, c) => c > p ? c : p) +
              1);
    _recompute(
      emit,
      mode: FormMode.add,
      lineNumber: nextInt,
      note: '',
      feet: '',
      inch: '',
      qty: '',
      buttonsEnabled: false,
      clearSelection: true,
      selectedIndex: null,
      less: false,
    );
  }

  Future<void> _onNext(RecordsNextPressed e, Emitter<RecordsState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      // Parse values safely
      num feet =
          num.tryParse(state.feet.trim().isEmpty ? '0' : state.feet.trim()) ??
          0;
      num inch =
          num.tryParse(state.inch.trim().isEmpty ? '0' : state.inch.trim()) ??
          0;
      num rft = feet + (inch / 12);
      int qtyAbs =
          int.tryParse(state.qty.trim().isEmpty ? '1' : state.qty.trim()) ?? 1;
      int qty = state.less ? -qtyAbs : qtyAbs;
      num total = qty * rft;

      // Build record object
      final record = RecordModel(
        docId: '',
        idColumn: state.lineNumber,
        note: state.note.trim(),
        feet: feet.toString(),
        inch: inch.toString(),
        rft: rft.toStringAsFixed(2),
        qty: qty,
        total: total.toStringAsFixed(2),
      );

      if (state.mode == FormMode.edit && state.selected != null) {
        final sel = state.selected!;
        await repo.updateRecord(sel.docId, record);
      } else {
        num ln = state.lineNumber;
        while (state.records.any((r) => r.idColumn == ln)) {
          ln = num.parse((ln + 0.1).toStringAsFixed(3));
        }

        final newRecord = record.copyWith(idColumn: ln);
        await repo.addRecord(newRecord);
      }

      //  After success: clear fields, reset buttons, set next line number
      final nextInt = state.records.isEmpty
          ? 1
          : (state.records
                    .map((r) => r.idColumn.floor())
                    .fold<int>(0, (p, c) => c > p ? c : p) +
                1);

      _recompute(
        emit,
        mode: FormMode.add,
        lineNumber: nextInt,
        note: '',
        feet: '',
        inch: '',
        qty: '',
        less: false,
        buttonsEnabled: false,
        // disable Edit & Add Row after submit
        selectedIndex: null,
        clearSelection: true, // 👈 important
      );
    } catch (err) {
      emit(state.copyWith(loading: false, error: err.toString()));
    }
  }

  void _recompute(
    Emitter<RecordsState> emit, {
    String? note,
    String? feet,
    String? inch,
    String? qty,
    bool? less,
    FormMode? mode,
    num? lineNumber,
    bool? buttonsEnabled,
    int? selectedIndex,
    bool clearSelection = false,
  }) {
    final nNote = note ?? state.note;
    final nFeetStr = feet ?? state.feet;
    final nInchStr = inch ?? state.inch;
    final nQtyStr = qty ?? state.qty;
    final nLess = less ?? state.less;

    final nFeet = num.tryParse(nFeetStr.isEmpty ? '0' : nFeetStr) ?? 0;
    final nInch = num.tryParse(nInchStr.isEmpty ? '0' : nInchStr) ?? 0;
    final nRft = nFeet + (nInch / 12);
    final qAbs = int.tryParse(nQtyStr.isEmpty ? '1' : nQtyStr) ?? 1;
    final q = nLess ? -qAbs : qAbs;
    final nTotal = q * nRft;

    final nextSelectedIndex = clearSelection
        ? null
        : (selectedIndex ?? state.selectedIndex);

    emit(
      state.copyWith(
        note: nNote,
        feet: nFeetStr,
        inch: nInchStr,
        qty: nQtyStr,
        less: nLess,
        total: nTotal.toStringAsFixed(2),
        mode: mode ?? state.mode,
        lineNumber: lineNumber ?? state.lineNumber,
        buttonsEnabled: buttonsEnabled ?? state.buttonsEnabled,
        selectedIndex: nextSelectedIndex,
        loading: false,
        error: null,
      ),
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    repo.dispose();
    return super.close();
  }
}

extension on RecordModel {
  RecordModel copyWith({
    String? docId,
    num? idColumn,
    String? note,
    String? feet,
    String? inch,
    String? rft,
    int? qty,
    String? total,
  }) => RecordModel(
    docId: docId ?? this.docId,
    idColumn: idColumn ?? this.idColumn,
    note: note ?? this.note,
    feet: feet ?? this.feet,
    inch: inch ?? this.inch,
    rft: rft ?? this.rft,
    qty: qty ?? this.qty,
    total: total ?? this.total,
  );
}
