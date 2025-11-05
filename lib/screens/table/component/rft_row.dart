import 'package:duplicate_building_solution/utils/change_notifier_ex.dart';
import 'package:duplicate_building_solution/utils/functions.dart';
import 'package:duplicate_building_solution/widgets/input_field.dart';
import 'package:duplicate_building_solution/utils/globals.dart';
import 'package:duplicate_building_solution/utils/style_constant.dart';
import 'package:duplicate_building_solution/utils/text_constant.dart';
import 'package:duplicate_building_solution/utils/width_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class RftRow extends StatefulWidget {
  final TextEditingController txtInchController, txtFeetController;

  const RftRow(
      {super.key,
      required this.txtInchController,
      required this.txtFeetController});

  @override
  State<RftRow> createState() => _RftRowState();
}

class _RftRowState extends State<RftRow> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CountTotalLess>(builder: (context, countTotal, child) {
      return Row(
        children: [
          Text(TextConstant.rftCap, style: StyleConstant.naturalBlackTextStyle),
          WidthConstant.sizedBoxWidth20(),
          Consumer<ScrollToUpOnKb>(
            builder: (context,scroll,child) {
              return Expanded(
                child: InputField(
                    onChanged: (value) {
                      setState(() {
                        getTotal();
                        countTotal.setValue(Globals.total, countTotal.isChecked);
                        scroll.setValue(true);
                      });
                    },
                    textInputType: TextInputType.number,
                    filteringTextInputFormatter: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    textInputAction: TextInputAction.next,
                    maxLines: 1,
                    focusNode: Globals.txtFeetFocusNode,
                    hintText: TextConstant.feet,
                    controller: widget.txtFeetController),
              );
            }
          ),
          WidthConstant.sizedBoxWidth20(),
          Expanded(
            child: InputField(
                onChanged: (value) {
                  getTotal();
                  countTotal.setValue(Globals.total, countTotal.isChecked);
                },
                textInputType: TextInputType.number,
                filteringTextInputFormatter: [
                  FilteringTextInputFormatter.digitsOnly
                ],
                textInputAction: TextInputAction.next,
                maxLines: 1,
                hintText: TextConstant.inch,
                controller: widget.txtInchController),
          )
        ],
      );
    });
  }
}
