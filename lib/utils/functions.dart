import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duplicate_building_solution/utils/globals.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:page_transition/page_transition.dart';

class ScreenSize {
  BuildContext context;

  ScreenSize(this.context);

  double get width => MediaQuery.of(context).size.width;

  double get height => MediaQuery.of(context).size.height;
}

void pageTransition(BuildContext context, Widget child) {
  Navigator.push(
    context,
    PageTransition(
      type: PageTransitionType.theme,
      duration: const Duration(milliseconds: 200),
      alignment: Alignment.centerLeft,
      child: child,
    ),
  );
}

void getTotal() {
  Globals.total =
      (num.parse(
        Globals.txtQtyController.text.isEmpty
            ? '1'
            : Globals.txtQtyController.text,
      )) *
      (num.parse(
            Globals.txtFeetController.text.isEmpty
                ? '0'
                : Globals.txtFeetController.text,
          ) +
          (num.parse(
                Globals.txtInchController.text.isEmpty
                    ? '0'
                    : Globals.txtInchController.text,
              ) /
              12));
}

class FirebaseRef {
  static const String collectionName = 'party';
  static late String uid;
  static late CollectionReference partyUserDoc;
 // static late CollectionReference projectUserDoc;
 // static late CollectionReference fileUserDoc;

  static Future<void> init() async {
    final user = FirebaseAuth.instance.currentUser;
    uid = user?.uid ?? '';

    partyUserDoc = FirebaseFirestore.instance
        .collection('building_solution')
        .doc(uid)
        .collection(collectionName);

  }
}
