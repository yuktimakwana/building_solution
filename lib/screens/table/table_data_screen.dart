import 'package:duplicate_building_solution/bloc/add_table_data/record_bloc.dart';
import 'package:duplicate_building_solution/offline/connectivity_notifier.dart';
import 'package:duplicate_building_solution/screens/table/component/green_btn.dart';
import 'package:duplicate_building_solution/screens/table/component/grey_bar_btn.dart';
import 'package:duplicate_building_solution/screens/table/component/labeled_field.dart';
import 'package:duplicate_building_solution/screens/table/component/records_table.dart';
import 'package:duplicate_building_solution/screens/table/component/shadow_fields.dart';
import 'package:duplicate_building_solution/screens/table/view_record_screen.dart';
import 'package:duplicate_building_solution/utils/color_constant.dart';
import 'package:duplicate_building_solution/utils/functions.dart';
import 'package:duplicate_building_solution/utils/text_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum FormMode { add, edit, insertAfter }

class TableDataScreen extends StatefulWidget {
  final String fileName, partyName, projectName;

  const TableDataScreen({
    super.key,
    required this.fileName,
    required this.partyName,
    required this.projectName,
  });

  @override
  State<TableDataScreen> createState() => _TableDataScreenState();
}

class _TableDataScreenState extends State<TableDataScreen> {
  final _noteCtrl = TextEditingController();
  final _feetCtrl = TextEditingController();
  final _inchCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _noteFocus = FocusNode();
  final _feetFocus = FocusNode();
  final _inchFocus = FocusNode();
  final _qtyFocus = FocusNode();
  final _scrollController = ScrollController();
  final _nextButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _qtyFocus.addListener(() {
      if (_qtyFocus.hasFocus) {
        // Wait for keyboard + layout rebuild
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await Future.delayed(const Duration(milliseconds: 300));

          if (!mounted) return;

          final ctx = _nextButtonKey.currentContext;
          if (ctx != null) {
            Scrollable.ensureVisible(
              ctx,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              alignment: 0.9, // 0.9 keeps NEXT button visible above keyboard
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    _feetCtrl.dispose();
    _inchCtrl.dispose();
    _qtyCtrl.dispose();
    _noteFocus.dispose();
    _feetFocus.dispose();
    _inchFocus.dispose();
    _qtyFocus.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RecordsBloc>();
    final connectivity = ConnectivityNotifier.instance;
    return BlocConsumer<RecordsBloc, RecordsState>(
      listenWhen: (p, c) {
        return p.note != c.note ||
            p.feet != c.feet ||
            p.inch != c.inch ||
            p.qty != c.qty ||
            p.less != c.less ||
            p.mode != c.mode ||
            p.lineNumber != c.lineNumber;
      },
      listener: (_, s) {
        // Keep controllers in sync with BLoC state
        if (_noteCtrl.text != s.note) _noteCtrl.text = s.note;
        if (_feetCtrl.text != s.feet) _feetCtrl.text = s.feet;
        if (_inchCtrl.text != s.inch) _inchCtrl.text = s.inch;
        if (_qtyCtrl.text != s.qty) _qtyCtrl.text = s.qty;
      },
      buildWhen: (p, c) =>
          p.selectedIndex != c.selectedIndex ||
          p.records != c.records ||
          p.mode != c.mode ||
          p.total != c.total ||
          p.lineNumber != c.lineNumber ||
          p.buttonsEnabled != c.buttonsEnabled ||
          p.loading != c.loading ||
          p.error != c.error,
      builder: (context, state) {
        final hasData = state.hasData;

        print(state.error);

        final theme = Theme.of(context);
        final green = ColorConstant.greenColor;

        return Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: true, // 👈 ensure this is true
          appBar: AppBar(
            backgroundColor: green,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: ColorConstant.naturalWhiteColor,
              ),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            centerTitle: true,
            title: Text(
              widget.fileName,
              style: TextStyle(color: ColorConstant.naturalWhiteColor),
            ),
            actions: [
              ValueListenableBuilder<bool>(
                valueListenable: connectivity,
                builder: (_, isOnline, __) {
                  if (!hasData || !isOnline) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Center(
                      child: TextButton(
                        onPressed: () {
                          pageTransition(
                            context,
                            ViewRecordsScreen(
                              projectName: widget.projectName,
                              fileName: widget.fileName,
                              partyName: widget.partyName,
                            ),
                          );
                        },
                        child: Text(
                          TextConstant.view,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: ColorConstant.naturalWhiteColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
            elevation: 0,
          ),
          body: AbsorbPointer(
            absorbing: state.loading,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
              child: Column(
                children: [
                  if (hasData)
                    RecordsTable(
                      records: state.records,
                      selectedIndex: state.selectedIndex,
                      onTapRow: (i) => context.read<RecordsBloc>().add(
                        RecordsRowSelected(i),
                      ),
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
                      vertical: 8,
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
                          label: TextConstant.addRow,
                          enabled: state.buttonsEnabled,
                          onPressed: () => bloc.add(RecordsAddRowPressed()),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  LabeledField(
                    label: TextConstant.noteCap,
                    child: ShadowTextField(
                      controller: _noteCtrl,
                      focusNode: _noteFocus,
                      textInputAction: TextInputAction.next,
                      hint: TextConstant.note,
                      keyboardType: TextInputType.text,
                      inputFormatters: [],
                      onChanged: (v) => bloc.add(RecordsNoteChanged(v)),
                    ),
                  ),

                  const SizedBox(height: 12),

                  LabeledField(
                    label: TextConstant.rftCap,
                    child: Row(
                      children: [
                        Expanded(
                          child: ShadowTextField(
                            controller: _feetCtrl,
                            hint: TextConstant.feet,
                            textInputAction: TextInputAction.next,
                            focusNode: _feetFocus,
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
                            focusNode: _inchFocus,
                            hint: TextConstant.inch,
                            textInputAction: TextInputAction.next,
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
                          label: TextConstant.qtyCap,
                          child: ShadowTextField(
                            controller: _qtyCtrl,
                            textInputAction: TextInputAction.done,
                            focusNode: _qtyFocus,
                            hint: TextConstant.qty,
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
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              TextConstant.less,
                              style: theme.textTheme.titleMedium,
                            ),
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
                      Text(
                        TextConstant.total,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(width: 35),
                      Text(
                        state.records.isEmpty &&
                                state.feet.isEmpty &&
                                state.inch.isEmpty &&
                                state.qty.isEmpty
                            ? ''
                            : '${state.total} Feet',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: ColorConstant.greenColor,
                        ),
                        child: IconButton(
                          onPressed: () => bloc.add(RecordsResetPressed()),
                          icon: Icon(
                            Icons.refresh,
                            color: ColorConstant.naturalWhiteColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        key: _nextButtonKey,
                        child: GreenButton(
                          label: 'NEXT',
                          onPressed: () {
                            bloc.add(RecordsNextPressed());

                            Future.delayed(Duration(seconds: 1), () {
                              FocusScope.of(context).requestFocus(_noteFocus);
                            });
                          },
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
