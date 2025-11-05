import 'package:duplicate_building_solution/utils/change_notifier_ex.dart';
import 'package:duplicate_building_solution/utils/functions.dart';
import 'package:duplicate_building_solution/widgets/input_field.dart';
import 'package:duplicate_building_solution/utils/globals.dart';
import 'package:duplicate_building_solution/utils/height_constant.dart';
import 'package:duplicate_building_solution/utils/style_constant.dart';
import 'package:duplicate_building_solution/utils/text_constant.dart';
import 'package:duplicate_building_solution/utils/width_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class TotalRow extends StatefulWidget {
  final TextEditingController txtQtyController,
      txtFeetController,
      txtInchController;

  const TotalRow({
    super.key,
    required this.txtQtyController,
    required this.txtInchController,
    required this.txtFeetController,
  });

  @override
  State<TotalRow> createState() => TotalRowState();
}

class TotalRowState extends State<TotalRow> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CountTotalLess>(
      builder: (context, count, child) {
        return Column(
          children: [
            Row(
              children: [
                Text(
                  TextConstant.qtyCap,
                  style: StyleConstant.naturalBlackTextStyle,
                ),
                WidthConstant.sizedBoxWidth20(),
                Expanded(
                  child: InputField(
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    onChanged: (value) {
                      setState(() {
                        getTotal();
                        count.setValue(Globals.total, count.isChecked);
                      });
                    },
                    textInputType: TextInputType.number,
                    filteringTextInputFormatter: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    textInputAction: TextInputAction.done,
                    maxLines: 1,
                    hintText: TextConstant.qty,
                    controller: widget.txtQtyController,
                  ),
                ),
                WidthConstant.sizedBoxWidth20(),
                Text(
                  TextConstant.less,
                  style: StyleConstant.naturalBlackTextStyle,
                ),
                WidthConstant.sizedBoxWidth20(),
                Checkbox(
                  value: count.isChecked,
                  onChanged: (value) {
                    setState(() {
                      count.setValue(Globals.total, value ?? false);
                      bool checked = value ?? false;
                      int qty = Globals.txtQtyController.text.isNotEmpty
                          ? int.parse(Globals.txtQtyController.text)
                          : 1;
                      if (checked) {
                        Globals.txtQtyController.text = (qty * (-1)).toString();
                      } else {
                        Globals.txtQtyController.text = (qty * (-1)).toString();
                      }
                    });
                  },
                ),
              ],
            ),
            HeightConstant.sizedBoxHeight10(),
            Row(
              children: [
                Text(
                  TextConstant.total,
                  style: StyleConstant.naturalBlackTextStyle,
                ),
                WidthConstant.sizedBoxWidth20(),
                Text(
                  '${Globals.total.toStringAsFixed(2)} ${TextConstant.feet}',
                  style: StyleConstant.mediumDarkTextStyle,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
