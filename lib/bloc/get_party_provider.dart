import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duplicate_building_solution/model/party_model.dart';
import 'package:duplicate_building_solution/utils/functions.dart';
import 'package:flutter/cupertino.dart';

class GetPartyProvider with ChangeNotifier {
  List<PartyModel> parties = [];
  DocumentSnapshot? _lastDocument;
  bool hasMoreData = true;
  static const int limit = 10;

  // Initial load + pagination
  Future<void> loadParties({
    bool reset = false,
    required bool isRecycleBinScreen,
  }) async {
    Query query = FirebaseRef.partyUserDoc
        .where('party_deleted', isEqualTo: isRecycleBinScreen ? 'yes' : 'no')
        .orderBy('party_add_on', descending: true)
        .limit(limit);

    if (reset) {
      _lastDocument = null;
      hasMoreData = true;
      parties.clear();
    }

    if (!hasMoreData) return;

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    final snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      List<PartyModel> newParties = snapshot.docs
          .map((doc) => PartyModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      parties.addAll(newParties);
      _lastDocument = snapshot.docs.last;
      hasMoreData = newParties.length == limit;
    } else {
      hasMoreData = false;
    }

    notifyListeners();
  }

  Future<void> searchPartyByName(String name, bool isRecycleBinScreen) async {
    if (name.isEmpty) {
      await loadParties(reset: true, isRecycleBinScreen: isRecycleBinScreen);
      return;
    }
    final query = await FirebaseRef.partyUserDoc
        .where('party_deleted', isEqualTo: isRecycleBinScreen ? 'yes' : 'no')
        .orderBy('party_name_lower')
        .startAt([name])
        .endAt(['$name\uf8ff'])
        .get();

    parties = query.docs
        .map((doc) => PartyModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
    notifyListeners();
  }
}

// class FireStoreRepository {
//   int orderId;
//
//   FireStoreRepository({required this.orderId});
//
//   final CollectionReference _chatCollectionReference =
//       FirebaseFirestore.instance.collection('groups');
//
//   final StreamController<List<ChatModel>> _chatController =
//       StreamController<List<ChatModel>>.broadcast();
//
//   List<List<ChatModel>> allPagedResults = <List<ChatModel>>[];
//
//   static const int chatLimit = 10;
//   DocumentSnapshot? _lastDocument;
//   bool hasMoreData = true;
//
//   Stream<List<ChatModel>> listenToChatsRealTime() {
//     _requestChats();
//
//     return _chatController.stream;
//   }
//
//   void _requestChats() {
//     var pageChatQuery = _chatCollectionReference
//         .doc('$orderId')
//         .collection('messages')
//         .orderBy('time', descending: true)
//         .limit(chatLimit);
//
//     if (_lastDocument != null) {
//       pageChatQuery = pageChatQuery.startAfterDocument(_lastDocument!);
//     }
//
//     if (!hasMoreData) return;
//
//     var currentRequestIndex = allPagedResults.length;
//
//     pageChatQuery.snapshots().listen(
//       (snapshot) {
//         if (snapshot.docs.isNotEmpty) {
//           var generalChats = snapshot.docs
//               .map((snapshot) => ChatModel.fromMap(snapshot.data()))
//               .toList();
//
//           var pageExists = currentRequestIndex < allPagedResults.length;
//
//           if (pageExists) {
//             allPagedResults[currentRequestIndex] = generalChats;
//           } else {
//             allPagedResults.add(generalChats);
//           }
//
//           var allChats = allPagedResults.fold<List<ChatModel>>(<ChatModel>[],
//               (initialValue, pageItems) => initialValue..addAll(pageItems));
//
//           _chatController.add(allChats);
//
//           if (currentRequestIndex == allPagedResults.length - 1) {
//             _lastDocument = snapshot.docs.last;
//           }
//
//           hasMoreData = generalChats.length == chatLimit;
//         }
//       },
//     );
//   }
//
//   void requestMoreData() => _requestChats();
// }
