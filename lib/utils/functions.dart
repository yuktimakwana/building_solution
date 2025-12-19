import 'package:cloud_firestore/cloud_firestore.dart';
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

class FirebaseRef {
  static const String collectionName = 'party';
  static late String uid;
  static late CollectionReference<Map<String, dynamic>> partyUserDoc;

  static Future<void> init() async {
    final user = FirebaseAuth.instance.currentUser;
    uid = user?.uid ?? '';

    partyUserDoc = FirebaseFirestore.instance
        .collection('building_solution')
        .doc(uid.isEmpty ? 'default_user' : uid)
        .collection(collectionName);
  }
}

/// Copies all documents (and subcollections) from [sourcePath] to [destinationPath]

Future<void> migratePartyDataToBuildingSolution(String uid) async {
  final firestore = FirebaseFirestore.instance;

  // Old root
  final oldRoot = firestore.collection('party');

  // New root
  final newRoot = firestore.collection('building_solution').doc(uid);

  print('🚀 Starting migration for UID: $uid');

  // Get all party documents
  final partySnapshot = await oldRoot.get();
  if (partySnapshot.docs.isEmpty) {
    print('⚠️ No party documents found.');
    return;
  }

  for (final partyDoc in partySnapshot.docs) {
    final partyData = partyDoc.data();
    await newRoot.collection('party').doc(partyDoc.id).set(partyData);
    print('📁 Copied Party: ${partyDoc.id}');

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
      print('📄 Copied Project: ${projectDoc.id}');

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
        print('📦 Copied File: ${fileDoc.id}');

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
        print('🧾 Copied all records for File: ${fileDoc.id}');
      }
    }
  }

  print('✅ Migration completed successfully for UID: $uid');
}
