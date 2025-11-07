import 'dart:async';
import 'package:duplicate_building_solution/model/file_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duplicate_building_solution/utils/text_constant.dart';

class GetFileProvider {
  String partyName, projectName;
  bool isRecycleBinScreen;

  GetFileProvider(
      {required this.partyName,
      required this.projectName,
      required this.isRecycleBinScreen});

  final CollectionReference fileCollectionReference =
      FirebaseFirestore.instance.collection(TextConstant.partyCollection);

  final StreamController<List<FileModel>> fileController =
      StreamController<List<FileModel>>.broadcast();

  List<List<FileModel>> allPagedResults = <List<FileModel>>[];

  static const int chatLimit = 10;
  DocumentSnapshot? _lastDocument;
  bool hasMoreData = true;

  Stream<List<FileModel>> listenToChatsRealTime() {
    _requestChats();

    return fileController.stream;
  }

  void _requestChats() {
    var pageChatQuery = fileCollectionReference
        .doc(partyName)
        .collection(TextConstant.projectCollection)
        .doc(projectName)
        .collection(TextConstant.fileCollection)
        .orderBy('file_add_on', descending: true)
        .where('file_deleted', isEqualTo: isRecycleBinScreen ? 'yes' : 'no')
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
                  FileModel.fromMap(snapshot.data()))
              .toList();

          var pageExists = currentRequestIndex < allPagedResults.length;

          if (pageExists) {
            allPagedResults[currentRequestIndex] = generalChats;
          } else {
            allPagedResults.add(generalChats);
          }

          var allChats = allPagedResults.fold<List<FileModel>>(<FileModel>[],
              (initialValue, pageItems) => initialValue..addAll(pageItems));

          fileController.add(allChats);

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
