import 'package:flutter/cupertino.dart';

class Globals {
  static String clientError = "Something went wrong";

  static TextEditingController txtNoteController = TextEditingController();
  static TextEditingController txtFeetController = TextEditingController();
  static TextEditingController txtInchController = TextEditingController();
  static TextEditingController txtQtyController = TextEditingController();

  static FocusNode txtFeetFocusNode =  FocusNode();

  static bool isScrollToUp = false;


  static bool isUpdate = false;
  static num tableId = 0;
  static num extraId = 0.1;

  static String partyCollection = 'party';
  static String projectCollection = 'project';
  static String fileCollection = 'file';
  static String recordsCollection = 'records';

  static String idColumn = 'no';
  static String noteColumn = 'note';
  static String rftColumn = 'rft';
  static String inchColumn = 'inch';
  static String qtyColumn = 'qty';
  static String totalColumn = 'total';
  static String lessColumn = 'less';
  static String feetColumn = 'feet';
  static String dataAddOnColumn = 'data_add_on';

  static bool isPartyValidation = false;

  static Map<int, TableColumnWidth> columnWidth = {
    0: const FractionColumnWidth(0.1),
    1: const FractionColumnWidth(0.3),
  };

  static num total = 0;

}
