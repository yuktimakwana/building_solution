import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duplicate_building_solution/utils/color_constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      type: PageTransitionType.rightToLeftWithFade,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: child,
    ),
  );
}
void pageBTTransition(BuildContext context, Widget child) {
  Navigator.push(
    context,
    PageTransition(
      type: PageTransitionType.bottomToTop,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: child,
    ),
  );
}

void pageFadeTransition(BuildContext context, Widget child) {
  Navigator.push(
    context,
    PageTransition(
      type: PageTransitionType.fade,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: child,
    ),
  );
}
class FirebaseRef {
  static const String collectionName = 'party';
  static late String uid;
  static late CollectionReference<Map<String, dynamic>> partyUserDoc;
  static late DocumentReference<Map<String, dynamic>> userProfileDoc;

  static void init() {
    final user = FirebaseAuth.instance.currentUser;
    uid = user?.uid ?? '';
    print('uid-----------------$uid');
    final rootDoc = FirebaseFirestore.instance
        .collection('building_solution')
        .doc(uid.isEmpty ? 'default_user' : uid);

    partyUserDoc = rootDoc.collection(collectionName);
    userProfileDoc = rootDoc;
  }
}

/// Copies all documents (and subcollections) from [sourcePath] to [destinationPath]

Future<void> migratePartyDataToBuildingSolution(String uid) async {
  final firestore = FirebaseFirestore.instance;

  // Old root
  final oldRoot = firestore.collection('party');

  // New root
  final newRoot = firestore.collection('building_solution').doc(uid);

  // Get all party documents
  final partySnapshot = await oldRoot.get();
  if (partySnapshot.docs.isEmpty) {
    return;
  }

  for (final partyDoc in partySnapshot.docs) {
    final partyData = partyDoc.data();
    await newRoot.collection('party').doc(partyDoc.id).set(partyData);

    // Copy project subcollection
    final projectSnapshot = await partyDoc.reference
        .collection('project')
        .get();
    for (final projectDoc in projectSnapshot.docs) {
      final projectData = projectDoc.data();
      await newRoot
          .collection('party')
          .doc(partyDoc.id)
          .collection('project')
          .doc(projectDoc.id)
          .set(projectData);

      // Copy file subcollection
      final fileSnapshot = await projectDoc.reference.collection('file').get();
      for (final fileDoc in fileSnapshot.docs) {
        final fileData = fileDoc.data();
        await newRoot
            .collection('party')
            .doc(partyDoc.id)
            .collection('project')
            .doc(projectDoc.id)
            .collection('file')
            .doc(fileDoc.id)
            .set(fileData);

        // Copy records subcollection
        final recordSnapshot = await fileDoc.reference
            .collection('records')
            .get();
        for (final recordDoc in recordSnapshot.docs) {
          final recordData = recordDoc.data();
          await newRoot
              .collection('party')
              .doc(partyDoc.id)
              .collection('project')
              .doc(projectDoc.id)
              .collection('file')
              .doc(fileDoc.id)
              .collection('records')
              .doc(recordDoc.id)
              .set(recordData);
        }
      }
    }
  }
}

// ✅ Common TextFormField Widget
Widget textForms({
  required TextEditingController textEditingController,
  required TextInputAction textInputAction,
  bool obscureText = false,
  TextInputType keyboardType = TextInputType.emailAddress,
  Widget icon = const SizedBox(),
  String? Function(String?)? validator,
  required String hintText,
  List<TextInputFormatter>? inputFormatters,
  Widget? prefix,
}) {
  return TextFormField(
    controller: textEditingController,
    obscureText: obscureText,
    keyboardType: keyboardType,
    textInputAction: textInputAction,
    inputFormatters: inputFormatters,
    decoration: InputDecoration(
      hintText: hintText,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: ColorConstant.lightGreyColor),
      filled: true,
      border: const OutlineInputBorder(),
      suffixIcon: icon,
      prefixIcon: prefix,
    ),
    validator: validator,
  );
}

// ✅ Common Label Widget
Widget texts({required String titleText}) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Text(
      titleText,
      style: const TextStyle(color: Colors.white, fontSize: 16),
    ),
  );
}
