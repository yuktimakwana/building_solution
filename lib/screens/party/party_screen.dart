import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duplicate_building_solution/dialog/delete_dialog.dart';
import 'package:duplicate_building_solution/model/party_model.dart';
import 'package:duplicate_building_solution/screens/party/party_floating_btn.dart';
import 'package:duplicate_building_solution/screens/party/party_recycle_bin.dart';
import 'package:duplicate_building_solution/screens/project/project_screen.dart';
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

class PartyScreen extends StatefulWidget {
  const PartyScreen({super.key});

  @override
  State<PartyScreen> createState() => _PartyScreenState();
}

class _PartyScreenState extends State<PartyScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final TextEditingController partyNameController = TextEditingController();
  final TextEditingController partyDescController = TextEditingController();

  Stream<QuerySnapshot>? _firstPageStream;
  final List<DocumentSnapshot> _extraItems = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  static const int _pageSize = 10;
  String _searchTerm = '';

  List<PartyModel> partyModel = [];

  @override
  void initState() {
    super.initState();
    FirebaseRef.init();

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
    _extraItems.clear();
    _lastDocument = null;
    _hasMore = true;
  }

  void _initStream() {
    Query baseQuery = FirebaseRef.partyUserDoc
        .where('party_deleted', isEqualTo: 'no')
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
          .where('party_deleted', isEqualTo: 'no')
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

      if (_lastDocument != null) {
        q = q.startAfterDocument(_lastDocument!);
      }

      final snap = await q.get();

      if (snap.docs.isNotEmpty) {
        _extraItems.addAll(snap.docs);
        _lastDocument = snap.docs.last;
        if (snap.docs.length < _pageSize) _hasMore = false;
      } else {
        _hasMore = false;
      }

      debugPrint("Loaded more docs, total now: ${_extraItems.length}");
      debugPrint("Last doc id: ${_lastDocument?.id}");
      setState(() {});
    } catch (e) {
      debugPrint('Load more error: $e');
    } finally {
      _isLoadingMore = false;
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        (_scrollController.position.maxScrollExtent - 200)) {
      _loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    partyNameController.dispose();
    partyDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firstPageStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return errorWidget(context);
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget(context);
        }

        final firstPageDocs = snapshot.data?.docs ?? [];
        final combined = {
          for (var doc in [...firstPageDocs, ..._extraItems])
            if ((doc.data() as Map<String, dynamic>)['party_deleted'] == 'no')
              doc.id: doc,
        }.values.toList();

        partyModel = combined
            .map(
              (doc) =>
                  PartyModel.fromMap(doc.data() as Map<String, dynamic>)
                    ..partyName = doc.id,
            )
            .toList();

        _hasMore = firstPageDocs.length == _pageSize;

        print('party------${partyModel.length}');

        if (combined.isEmpty) {
          return NoProjectFound(
            image: ImageConstant.noPartyImage,
            title: TextConstant.noAnyPartyYet,
            subTitle: TextConstant.yourPartyAppearHere,
          );
        }

        return Scaffold(
          appBar: appBarWidget(
            leadingPress: () {
              pageTransition(context, const PartyRecycleBin());
            },
            searchEditingController: _searchController,
            onClose: () {
              _searchController.clear();
              FocusScope.of(context).unfocus();
              setState(() => _searchTerm = '');
              _resetPaging();
              _initStream();
            },
            context: context,
            title: TextConstant.party,
            color: ColorConstant.greenColor,
          ),
          body: Column(
            children: [
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: combined.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == combined.length) {
                      // Show loading only if more data exists and currently fetching
                      if (_isLoadingMore) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: loadingWidget(context),
                        );
                      } else {
                        return const SizedBox(height: 30);
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
                        color: ColorConstant.naturalWhiteColor,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          horizontalTitleGap: 6,
                          onTap: () {
                            pageTransition(
                              context,
                              ProjectScreen(partyName: partyName),
                            );
                          },
                          leading: DefaultImage(
                            title: ImageConstant.partyImage,
                          ),
                          title: Text(partyName),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: ColorConstant.pastelRedColor,
                            ),
                            onPressed: () async {
                              deleteDialog(
                                deleteButtonText: TextConstant.moveToRecycleBin,
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await FirebaseRef.partyUserDoc
                                      .doc(doc.id)
                                      .update({'party_deleted': 'yes'});
                                  _extraItems.removeWhere(
                                    (d) => d.id == doc.id,
                                  );

                                  setState(() {});
                                  // FocusScope.of(context).unfocus();
                                },
                                title: TextConstant.movePartyRecycle,
                                context: context,
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // ElevatedButton(
              //   onPressed: () async {
              //     final uid = FirebaseAuth.instance.currentUser!.uid;
              //     await migratePartyDataToBuildingSolution(uid);
              //   },
              //   child: const Text('Migrate Firestore Data'),
              // ),
            ],
          ),
          floatingActionButton: floatingActionButton(
            partyNameController: partyNameController,
            partyDescController: partyDescController,
            partyModel: partyModel,
            partyScrollController: _scrollController,
          ),
        );
      },
    );
  }
}
