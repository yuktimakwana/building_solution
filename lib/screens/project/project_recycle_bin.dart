import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duplicate_building_solution/offline/offline_sync_service.dart';
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

class ProjectRecycleBinScreen extends StatefulWidget {
  final String partyName;

  const ProjectRecycleBinScreen({super.key, required this.partyName});

  @override
  State<ProjectRecycleBinScreen> createState() =>
      _ProjectRecycleBinScreenState();
}

class _ProjectRecycleBinScreenState extends State<ProjectRecycleBinScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final OfflineSyncService _syncService = OfflineSyncService.instance;
  late final Stream<List<Map<String, dynamic>>> _cachedProjectsStream =
      _syncService.watchCachedProjects();
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _onlineSubscription;

  late CollectionReference<Map<String, dynamic>> fireAuth;

  bool _isLoadingMore = false;
  bool _hasMore = true;
  static const int _pageSize = 10;
  String _searchTerm = '';
  DocumentSnapshot? _lastDocument;

  @override
  void initState() {
    super.initState();
    fireAuth = FirebaseRef.partyUserDoc
        .doc(widget.partyName)
        .collection('project');
    _initStream();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text.trim().toLowerCase();
      });
      _initStream();
    });
  }

  void _initStream() {
    _onlineSubscription?.cancel();
    _lastDocument = null;
    _hasMore = true;

    final query = _buildBaseQuery();
    _onlineSubscription = query.snapshots().listen((snapshot) async {
      await _syncService.cacheSnapshotBatch(
        table: 'projects',
        snapshot: snapshot,
        idBuilder: (doc) => '${widget.partyName}::${doc.id}',
      );
      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
        _hasMore = snapshot.docs.length == _pageSize;
      } else {
        _hasMore = false;
      }
      if (mounted) setState(() {});
    }, onError: (err) => debugPrint('Project Recycle Bin stream error: $err'));
  }

  Query<Map<String, dynamic>> _buildBaseQuery() {
    Query<Map<String, dynamic>> baseQuery = fireAuth
        .where('project_deleted', isEqualTo: 'yes')
        .orderBy('project_add_on', descending: true)
        .limit(_pageSize);

    if (_searchTerm.isNotEmpty) {
      baseQuery = baseQuery
          .where('project_name_lower', isGreaterThanOrEqualTo: _searchTerm)
          .where(
            'project_name_lower',
            isLessThanOrEqualTo: '$_searchTerm\uf8ff',
          );
    }
    return baseQuery;
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    try {
      Query<Map<String, dynamic>> q = _buildBaseQuery();

      if (_lastDocument != null) {
        q = q.startAfterDocument(_lastDocument!);
      }

      final snap = await q.get();
      if (snap.docs.isNotEmpty) {
        _lastDocument = snap.docs.last;
        if (snap.docs.length < _pageSize) _hasMore = false;
        await _syncService.cacheSnapshotBatch(
          table: 'projects',
          snapshot: snap,
          idBuilder: (doc) => '${widget.partyName}::${doc.id}',
        );
      } else {
        _hasMore = false;
      }
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Load more error: $e');
    } finally {
      _isLoadingMore = false;
    }
  }

  void _confirmPermanentDelete(String projectName) {
    deleteDialog(
      deleteButtonText: TextConstant.delete,
      context: context,
      title: TextConstant.permanentDeleteProject,
      onPressed: () async {
        Navigator.pop(context);
        try {
          await _syncService.deleteProjectPermanently(
            partyName: widget.partyName,
            projectName: projectName,
          );
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$projectName deleted permanently.')),
          );
        } catch (err) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete $projectName: $err')),
          );
        }
      },
    );
  }

  void _onScroll() {
    if (!_syncService.isOnline) return;
    if (_scrollController.position.pixels >=
        (_scrollController.position.maxScrollExtent - 200)) {
      _loadMore();
    }
  }

  Future<void> _restoreFromRecycleBin(String projectName) async {
    await _syncService.markProjectDeleted(
      partyName: widget.partyName,
      projectName: projectName,
      deleted: false,
    );
  }

  @override
  void dispose() {
    _onlineSubscription?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        searchEditingController: _searchController,
        onClose: () {
          _searchController.clear();
          FocusScope.of(context).unfocus();

          setState(() {
            _searchTerm = '';
          });
          _initStream();
        },
        backPress: () {
          Navigator.pop(context);
          FocusScope.of(context).unfocus();
        },

        context: context,
        title: TextConstant.recycleBin,
        color: ColorConstant.greenColor,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _cachedProjectsStream,
        initialData: const [],
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return errorWidget(context);
          }
          if (!snapshot.hasData) {
            return loadingWidget(context);
          }

          final docs = _filterAndSort(snapshot.data!);

          if (docs.isEmpty) {
            return NoProjectFound(
              image: ImageConstant.noProjectImage,
              title: TextConstant.noDeleteAnyProject,
              subTitle: TextConstant.yourDeletedProjectAppearHere,
            );
          }

          return ListView.builder(
            controller: _scrollController,
            itemCount:
                docs.length + ((_hasMore && _syncService.isOnline) ? 1 : 0),
            itemBuilder: (context, index) {
              if (_hasMore && _syncService.isOnline && index == docs.length) {
                if (_isLoadingMore) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: loadingWidget(context),
                  );
                } else {
                  return const SizedBox(height: 60);
                }
              }

              final data = docs[index];
              final projectName = data['project_name'] ?? '';

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
                    leading: DefaultImage(title: ImageConstant.projectImage),
                    horizontalTitleGap: 8,
                    title: Text(projectName),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            _confirmPermanentDelete(projectName);
                          },
                          icon: const Icon(
                            Icons.delete,
                            color: ColorConstant.pastelRedColor,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _restoreFromRecycleBin(projectName);
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
    );
  }

  List<Map<String, dynamic>> _filterAndSort(
    List<Map<String, dynamic>> rawData,
  ) {
    final prefix = '${widget.partyName}::';
    return rawData.where((data) {
      final entityId = (data['__entity_id'] ?? '') as String;
      if (!entityId.startsWith(prefix)) return false;
      final deleted = (data['project_deleted'] ?? 'no') as String;
      if (deleted != 'yes') return false;
      if (_searchTerm.isEmpty) return true;
      final lower = (data['project_name_lower'] ?? '') as String;
      return lower.contains(_searchTerm);
    }).toList()..sort((a, b) {
      final aTime = a['project_add_on'];
      final bTime = b['project_add_on'];
      // Handle Timestamp, int, or null
      int aMillis = 0;
      int bMillis = 0;
      if (aTime is Timestamp)
        aMillis = aTime.millisecondsSinceEpoch;
      else if (aTime is int)
        aMillis = aTime;

      if (bTime is Timestamp)
        bMillis = bTime.millisecondsSinceEpoch;
      else if (bTime is int)
        bMillis = bTime;

      return bMillis.compareTo(aMillis);
    });
  }
}
