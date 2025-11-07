import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duplicate_building_solution/dialog/delete_dialog.dart';
import 'package:duplicate_building_solution/model/file_model.dart';
import 'package:duplicate_building_solution/screens/file/file_floating_btn.dart';
import 'package:duplicate_building_solution/screens/file/file_recycle_bin.dart';
import 'package:duplicate_building_solution/screens/project/project_screen.dart';
import 'package:duplicate_building_solution/screens/table/record_screen.dart';
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

class FileScreen extends StatefulWidget {
  final String partyName, projectName;

  const FileScreen({
    super.key,
    required this.partyName,
    required this.projectName,
  });

  @override
  State<FileScreen> createState() => _FileScreenState();
}

class _FileScreenState extends State<FileScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final TextEditingController fileNameController = TextEditingController();
  final TextEditingController fileDescController = TextEditingController();

  Stream<QuerySnapshot>? _firstPageStream;
  late CollectionReference fireAuth;
  final List<DocumentSnapshot> _extraItems = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  static const int _pageSize = 10;
  String _searchTerm = '';

  List<FileModel> fileModel = [];

  @override
  void initState() {
    super.initState();
    fireAuth = FirebaseRef.partyUserDoc
        .doc(widget.partyName)
        .collection('project')
        .doc(widget.projectName)
        .collection('file');
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
    Query baseQuery = fireAuth
        .where('file_deleted', isEqualTo: 'no')
        .orderBy('file_add_on', descending: true)
        .limit(_pageSize);

    if (_searchTerm.isNotEmpty) {
      baseQuery = baseQuery
          .where('file_name_lower', isGreaterThanOrEqualTo: _searchTerm)
          .where('file_name_lower', isLessThanOrEqualTo: '$_searchTerm\uf8ff');
    }

    setState(() {
      _firstPageStream = baseQuery.snapshots();
    });
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;

    try {
      Query q = fireAuth
          .where('file_deleted', isEqualTo: 'no')
          .orderBy('file_add_on', descending: true)
          .limit(_pageSize);

      if (_searchTerm.isNotEmpty) {
        q = q
            .where('file_name_lower', isGreaterThanOrEqualTo: _searchTerm)
            .where(
              'file_name_lower',
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
    fileNameController.dispose();
    fileDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        pageTransition(context, ProjectScreen(partyName: widget.partyName));
      },

      child: Scaffold(
        appBar: appBarWidget(
          searchEditingController: _searchController,
          onClose: () {
            _searchController.clear();
            FocusScope.of(context).unfocus();
            setState(() => _searchTerm = '');
            _resetPaging();
            _initStream();
          },
          leadingPress: () {
            pageTransition(
              context,
              FileRecycleBinScreen(
                partyName: widget.partyName,
                projectName: widget.projectName,
              ),
            );
          },
          context: context,
          title: widget.projectName,
          color: ColorConstant.greenColor,
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

                  final firstPageDocs = snapshot.data?.docs ?? [];
                  final combined = {
                    for (var doc in [...firstPageDocs, ..._extraItems])
                      if ((doc.data()
                              as Map<String, dynamic>)['file_deleted'] ==
                          'no')
                        doc.id: doc,
                  }.values.toList();

                  _hasMore = firstPageDocs.length == _pageSize;

                  if (combined.isEmpty) {
                    return NoProjectFound(
                      image: ImageConstant.noFileImage,
                      title: TextConstant.noAnyFileYet,
                      subTitle: TextConstant.yourFileAppearHere,
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
                          return const SizedBox(height: 30);
                        }
                      }

                      final doc = combined[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final fileName = data['file_name'] ?? '';

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
                            horizontalTitleGap: 8,
                            onTap: () {
                              pageTransition(
                                context,
                                RecordsScreen(
                                  fileName: fileName,
                                  projectName: widget.projectName,
                                  partyName: widget.partyName,
                                ),
                              );
                            },
                            leading: DefaultImage(
                              title: ImageConstant.fileImage,
                            ),
                            title: Text(fileName),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: ColorConstant.pastelRedColor,
                              ),
                              onPressed: () async {
                                deleteDialog(
                                  deleteButtonText:
                                      TextConstant.moveToRecycleBin,
                                  onPressed: () async {
                                    Navigator.pop(context);

                                    await fireAuth.doc(doc.id).update({
                                      'file_deleted': 'yes',
                                    });

                                    _extraItems.removeWhere(
                                      (d) => d.id == doc.id,
                                    );

                                    setState(() {});
                                    FocusScope.of(context).unfocus();
                                  },
                                  title: TextConstant.moveFileRecycle,
                                  context: context,
                                );
                              },
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
        floatingActionButton: fileFloatingBtn(
          fileNameController: fileNameController,
          fileDescController: fileDescController,
          fileModel: fileModel,
          partyName: widget.partyName,
          projectName: widget.projectName,
          fileScrollController: _scrollController,
        ),
      ),
    );
  }
}
