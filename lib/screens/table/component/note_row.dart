import 'package:duplicate_building_solution/utils/change_notifier_ex.dart';
import 'package:duplicate_building_solution/widgets/input_field.dart';
import 'package:duplicate_building_solution/utils/style_constant.dart';
import 'package:duplicate_building_solution/utils/text_constant.dart';
import 'package:duplicate_building_solution/utils/width_constant.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NoteRow extends StatefulWidget {
  final TextEditingController txtNoteController;

  const NoteRow({super.key, required this.txtNoteController});

  @override
  State<NoteRow> createState() => _NoteRowState();
}

class _NoteRowState extends State<NoteRow> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(TextConstant.noteCap, style: StyleConstant.naturalBlackTextStyle),
        WidthConstant.sizedBoxWidth20(),
        Consumer<ScrollToUpOnKb>(
          builder: (context,scroll,child) {
            return Expanded(
              child: InputField(
                  onChanged: (value) {
                    setState(() {
                      scroll.setValue(true);
                    });
                  },
                  textInputType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  maxLines: 1,
                  hintText: TextConstant.note,
                  controller: widget.txtNoteController),
            );
          }
        )
      ],
    );
  }
}
