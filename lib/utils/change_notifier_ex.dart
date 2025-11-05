import 'package:duplicate_building_solution/utils/globals.dart';
import 'package:duplicate_building_solution/utils/style_constant.dart';
import 'package:flutter/cupertino.dart';

class ChangeNotifierEx with ChangeNotifier {
  bool isChecked = false;

  void setChecked() {
    isChecked = true;
    notifyListeners();
  }
}

class UpdateLineNumber with ChangeNotifier {
  num id = 0;
  void setId(num newId, bool getUpdate) {
    id = newId;
    Globals.isUpdate = getUpdate;

    notifyListeners();
  }
}

class CountTotalLess with ChangeNotifier {
  bool isChecked = false;

  void setValue(num newTotal, bool checked) {
    Globals.total = newTotal;
    isChecked = checked;

    notifyListeners();
  }
}

class ErrorValidation with ChangeNotifier{
  String  isErrorText = '';

  void  setValue(String errorText){
    isErrorText = errorText;
    notifyListeners();
  }
}

class ScrollToUpOnKb with ChangeNotifier{
  bool isReverse = false;

  void  setValue(reverse){
    isReverse = reverse;
    notifyListeners();
  }
}

class AddRowNotifier with ChangeNotifier{
  List<Widget> table = [];
  int? selectedIndex;
  Function()? pageReload;

  void  setValue(List<Widget> addRow,int? index,Function() reload){
    table = addRow;
    selectedIndex = index;
    pageReload = reload;
    notifyListeners();
  }
}


class ChangeTextStyle with ChangeNotifier{
 TextStyle style = StyleConstant.smallLightTextStyle;

  void  setValue(TextStyle isStyle){
    style = isStyle;

    notifyListeners();
  }
}