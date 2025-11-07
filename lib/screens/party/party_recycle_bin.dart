import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duplicate_building_solution/dialog/delete_dialog.dart';
import 'package:duplicate_building_solution/utils/color_constant.dart';
import 'package:duplicate_building_solution/utils/functions.dart';
import 'package:duplicate_building_solution/utils/image_constant.dart';
import 'package:duplicate_building_solution/utils/text_constant.dart';
import 'package:duplicate_building_solution/widgets/app_bar_widget.dart';
import 'package:duplicate_building_solution/widgets/default_image.dart';
import 'package:duplicate_building_solution/widgets/error_widget.dart';
import 'package:duplicate_building_solution/widgets/loading_widget.dart';
import 'package:duplicate_building_solution/widgets/no_project_found.dart';
import 'package:flutter/material.dart';

class PartyRecycleBin extends StatefulWidget {
  const PartyRecycleBin({super.key});

  @override
  State<PartyRecycleBin> createState() => _PartyRecycleBinState();
}

class _PartyRecycleBinState extends State<PartyRecycleBin> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Stream<QuerySnapshot>? _firstPageStream;
  final List<DocumentSnapshot> _items = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  static const int _pageSize = 10;
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _initStream();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text.trim().toLowerCase();
      });
      _resetPaging();
      _initStream();
    });
  }

  void _resetPaging() {
    _items.clear();
    _lastDocument = null;
    _hasMore = true;
  }


  void _initStream() async {
    Query baseQuery = FirebaseRef.partyUserDoc
        .where('party_deleted', isEqualTo: 'yes')
        .orderBy('party_add_on', descending: true)
        .limit(_pageSize);

    if (_searchTerm.isNotEmpty) {
      baseQuery = baseQuery
          .where('party_name_lower', isGreaterThanOrEqualTo: _searchTerm)
          .where('party_name_lower', isLessThanOrEqualTo: '$_searchTerm\uf8ff');
    }

    setState(() {
      _firstPageStream = baseQuery.snapshots();
    });
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    try {
      Query q = FirebaseRef.partyUserDoc
          .where('party_deleted', isEqualTo: 'yes')
          .orderBy('party_add_on', descending: true)
          .limit(_pageSize);

      if (_searchTerm.isNotEmpty) {
        q = q
            .where('party_name_lower', isGreaterThanOrEqualTo: _searchTerm)
            .where(
              'party_name_lower',
              isLessThanOrEqualTo: '$_searchTerm\uf8ff',
            );
      }

      if (_lastDocument != null){ q = q.startAfterDocument(_lastDocument!);}

      final snap = await q.get();
      if (snap.docs.isNotEmpty) {
        _items.addAll(snap.docs);
        _lastDocument = snap.docs.last;
        if (snap.docs.length < _pageSize) _hasMore = false;
      } else {
        _hasMore = false;
      }
      setState(() {});
    } catch (e) {
      debugPrint('Load more error: $e');
    } finally {
      _isLoadingMore = false;
    }
  }

  void deletePermanent(String partyName) {
    deleteDialog(
      deleteButtonText: TextConstant.delete,
      context: context,
      title: TextConstant.permanentDeleteParty,
      onPressed: () {
        Navigator.pop(context);

        FirebaseRef.partyUserDoc.doc(partyName).delete();
      },
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        (_scrollController.position.maxScrollExtent - 200)) {
      _loadMore();
    }
  }

  Future<void> _restoreFromRecycleBin(DocumentSnapshot doc) async {
    await FirebaseRef.partyUserDoc.doc(doc.id).update({'party_deleted': 'no'});

  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        color: ColorConstant.greenColor,
        backPress: () {
          Navigator.pop(context);
          FocusScope.of(context).unfocus();

        },
        searchEditingController: _searchController,
        onClose: () {
          _searchController.clear();
          FocusScope.of(context).unfocus();

          setState(() {
            _searchTerm = '';
          });
          _resetPaging();
          _initStream();
        },
        context: context,
        title: TextConstant.recycleBin,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firstPageStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return errorWidget(context);
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return loadingWidget(context);
                }

                final docs = snapshot.data?.docs ?? [];
                final combined = {
                  for (var doc in [...docs, ..._items])
                    if ((doc.data() as Map<String, dynamic>)['party_deleted'] == 'yes')
                      doc.id: doc
                }.values.toList();



                _hasMore = docs.length == _pageSize;

                if (combined.isEmpty) {
                  return NoProjectFound(
                    image: ImageConstant.noPartyImage,
                    title: TextConstant.noAnyPartyYetInRB,
                    subTitle: TextConstant.yourDeletedPartyAppearHere,
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: combined.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == combined.length) {
                      if (_isLoadingMore) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: loadingWidget(context),
                        );
                      } else {
                        return const SizedBox(height: 60);
                      }
                    }

                    final doc = combined[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final partyName = data['party_name'] ?? '';

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 4.0,
                      ),
                      child: Card(
                        elevation: 4,
                        color: ColorConstant.naturalWhiteColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          horizontalTitleGap: 8,
                          leading: DefaultImage(
                            title: ImageConstant.partyImage,
                          ),

                          title: Text(partyName),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  deletePermanent(partyName);
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  color: ColorConstant.pastelRedColor,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  _restoreFromRecycleBin(doc);
                                  _items.removeWhere((d) => d.id == doc.id);

                                },
                                icon: const Icon(
                                  Icons.undo,
                                  color: ColorConstant.pastelRedColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
