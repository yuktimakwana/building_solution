import 'package:duplicate_building_solution/utils/style_constant.dart';
import 'package:duplicate_building_solution/widgets/material_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputField extends StatefulWidget {
  final int maxLines;
  final String hintText;
  final TextEditingController controller;
  final Function(String)? onChanged;
  final Function(String)? onFieldSubmitted;
  final TextInputAction textInputAction;
  final TextInputType textInputType;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? filteringTextInputFormatter;

  const InputField(
      {super.key,
      required this.maxLines,
      required this.hintText,
      this.onChanged,
      this.onFieldSubmitted,
      this.focusNode,
      required this.textInputType,
      this.filteringTextInputFormatter,
      required this.textInputAction,
      required this.controller});

  @override
  State<InputField> createState() => InputFieldState();
}

class InputFieldState extends State<InputField> {
  void pageReload() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialWidget(
      child: TextFormField(
        focusNode: widget.focusNode,
        onFieldSubmitted: widget.onFieldSubmitted,
        textCapitalization: TextCapitalization.words,
        textInputAction: widget.textInputAction,
        onChanged: widget.onChanged,
        controller: widget.controller,
        inputFormatters: widget.filteringTextInputFormatter,
        keyboardType: widget.textInputType,
        maxLines: widget.maxLines,
        decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: StyleConstant.mediumLightTextStyle,
            contentPadding:
                const EdgeInsets.only(bottom: 0, left: 10, top: 10)),
      ),
    );
  }
}
