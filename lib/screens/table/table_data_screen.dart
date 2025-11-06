import 'package:duplicate_building_solution/bloc/add_table_data/record_bloc.dart';
import 'package:duplicate_building_solution/bloc/add_table_data/record_event.dart';
import 'package:duplicate_building_solution/bloc/add_table_data/record_state.dart';
import 'package:duplicate_building_solution/screens/table/component/green_btn.dart';
import 'package:duplicate_building_solution/screens/table/component/grey_bar_btn.dart';
import 'package:duplicate_building_solution/screens/table/component/labeled_field.dart';
import 'package:duplicate_building_solution/screens/table/component/records_table.dart';
import 'package:duplicate_building_solution/screens/table/component/shadow_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum FormMode { add, edit, insertAfter }

class TableDataScreen extends StatefulWidget {
  const TableDataScreen({super.key});

  @override
  State<TableDataScreen> createState() => _TableDataScreenState();
}

class _TableDataScreenState extends State<TableDataScreen> {
  final _noteCtrl = TextEditingController();
  final _feetCtrl = TextEditingController();
  final _inchCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();

  @override
  void dispose() {
    _noteCtrl.dispose();
    _feetCtrl.dispose();
    _inchCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RecordsBloc>();
    return BlocConsumer<RecordsBloc, RecordsState>(
      listenWhen: (p, c) =>
          p.note != c.note ||
          p.feet != c.feet ||
          p.inch != c.inch ||
          p.qty != c.qty ||
          p.less != c.less ||
          p.mode != c.mode ||
          p.lineNumber != c.lineNumber,
      listener: (_, s) {
        // Keep controllers in sync with BLoC state
        if (_noteCtrl.text != s.note) _noteCtrl.text = s.note;
        if (_feetCtrl.text != s.feet) _feetCtrl.text = s.feet;
        if (_inchCtrl.text != s.inch) _inchCtrl.text = s.inch;
        if (_qtyCtrl.text != s.qty) _qtyCtrl.text = s.qty;
      },
      builder: (context, state) {
        final hasData = state.hasData;
        final theme = Theme.of(context);
        final green = const Color(0xFF8BC34A);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: green,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            centerTitle: true,
            title: const Text('File', style: TextStyle(color: Colors.white)),
            actions: [
              if (hasData)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Center(
                    child: Text(
                      'VIEW',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
            elevation: 0,
          ),
          body: AbsorbPointer(
            absorbing: state.loading,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (hasData)
                    RecordsTable(
                      records: state.records,
                      selectedIndex: state.selectedIndex,
                      onTapRow: (i) => bloc.add(RecordsRowSelected(i)),
                    )
                  else
                    const SizedBox.shrink(),

                  const SizedBox(height: 12),

                  // Grey bar (Line # + Edit/Add Row)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Line #: ${state.lineNumber}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        GreyBarBtn(
                          label: 'Edit',
                          enabled: state.buttonsEnabled,
                          onPressed: () => bloc.add(RecordsEditPressed()),
                        ),
                        const SizedBox(width: 8),
                        GreyBarBtn(
                          label: 'Add Row',
                          enabled: state.buttonsEnabled,
                          onPressed: () => bloc.add(RecordsAddRowPressed()),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  LabeledField(
                    label: 'NOTE:',
                    child: ShadowTextField(
                      controller: _noteCtrl,
                      hint: 'Note',
                      keyboardType: TextInputType.text,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r"[a-zA-Z0-9\s\-\._]"),
                        ),
                      ],
                      onChanged: (v) => bloc.add(RecordsNoteChanged(v)),
                    ),
                  ),

                  const SizedBox(height: 12),

                  LabeledField(
                    label: 'RFT:',
                    child: Row(
                      children: [
                        Expanded(
                          child: ShadowTextField(
                            controller: _feetCtrl,
                            hint: 'Feet',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: false,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}'),
                              ),
                            ],
                            onChanged: (v) => bloc.add(RecordsFeetChanged(v)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ShadowTextField(
                            controller: _inchCtrl,
                            hint: 'Inch',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: false,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}'),
                              ),
                            ],
                            onChanged: (v) => bloc.add(RecordsInchChanged(v)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: LabeledField(
                          label: 'QTY:',
                          child: ShadowTextField(
                            controller: _qtyCtrl,
                            hint: 'Qty',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: false,
                              signed: false,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+'),
                              ),
                            ],
                            onChanged: (v) => bloc.add(RecordsQtyChanged(v)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Text('LESS:', style: theme.textTheme.titleMedium),
                            const SizedBox(width: 8),
                            Checkbox(
                              value: state.less,
                              onChanged: (v) =>
                                  bloc.add(RecordsLessToggled(v ?? false)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('Total:', style: theme.textTheme.titleMedium),
                      const SizedBox(width: 8),
                      Text(
                        state.records.isEmpty &&
                                state.feet.isEmpty &&
                                state.inch.isEmpty &&
                                state.qty.isEmpty
                            ? ''
                            : '${state.total.toStringAsFixed(2)} Feet',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: GreenButton(
                          label: 'RESET',
                          onPressed: () => bloc.add(RecordsResetPressed()),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: GreenButton(
                          label: 'NEXT',
                          onPressed: () => bloc.add(RecordsNextPressed()),
                        ),
                      ),
                    ],
                  ),

                  if (state.error != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      state.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
