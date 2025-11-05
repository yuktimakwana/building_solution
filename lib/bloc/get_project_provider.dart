import 'dart:async';

import 'package:duplicate_building_solution/model/project_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GetProjectsProvider {
  String partyName;
  bool isRecycleBinScreen;

  GetProjectsProvider(
      {required this.partyName, required this.isRecycleBinScreen});

  final CollectionReference projectCollectionReference =
      FirebaseFirestore.instance.collection('party');

  final StreamController<List<ProjectModel>> projectController =
      StreamController<List<ProjectModel>>.broadcast();

  List<List<ProjectModel>> allPagedResults = <List<ProjectModel>>[];

  static const int chatLimit = 10;
  DocumentSnapshot? _lastDocument;
  bool hasMoreData = true;

  Stream<List<ProjectModel>> listenToChatsRealTime() {
    _requestChats();

    return projectController.stream;
  }

  void _requestChats() {
    var pageChatQuery = projectCollectionReference
        .doc(partyName)
        .collection('project')
        .orderBy('project_add_on', descending: true)
        .where('project_deleted', isEqualTo: isRecycleBinScreen ? 'yes' : 'no')
        .limit(chatLimit);

    if (_lastDocument != null) {
      pageChatQuery = pageChatQuery.startAfterDocument(_lastDocument!);
    }

    if (!hasMoreData) return;

    var currentRequestIndex = allPagedResults.length;

    pageChatQuery.snapshots().listen(
      (snapshot) {
        if (snapshot.docs.isNotEmpty) {
          var generalChats = snapshot.docs
              .map((snapshot) =>
                  ProjectModel.fromMap(snapshot.data()))
              .toList();

          var pageExists = currentRequestIndex < allPagedResults.length;

          if (pageExists) {
            allPagedResults[currentRequestIndex] = generalChats;
          } else {
            allPagedResults.add(generalChats);
          }

          var allChats = allPagedResults.fold<List<ProjectModel>>(
              <ProjectModel>[],
              (initialValue, pageItems) => initialValue..addAll(pageItems));

          projectController.add(allChats);

          if (currentRequestIndex == allPagedResults.length - 1) {
            _lastDocument = snapshot.docs.last;
          }

          hasMoreData = generalChats.length == chatLimit;
        }
      },
    );
  }

  void requestMoreData() => _requestChats();
}
