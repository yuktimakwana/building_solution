import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duplicate_building_solution/dialog/delete_dialog.dart';
import 'package:duplicate_building_solution/model/project_model.dart';
import 'package:duplicate_building_solution/offline/offline_status.dart';
import 'package:duplicate_building_solution/offline/offline_sync_service.dart';
import 'package:duplicate_building_solution/screens/file/file_screen.dart';
import 'package:duplicate_building_solution/screens/project/project_floating_btn.dart';
import 'package:duplicate_building_solution/screens/project/project_recycle_bin.dart';
import 'package:duplicate_building_solution/utils/color_constant.dart';
import 'package:duplicate_building_solution/utils/functions.dart';
import 'package:duplicate_building_solution/utils/image_constant.dart';
import 'package:duplicate_building_solution/utils/text_constant.dart';
import 'package:duplicate_building_solution/widgets/app_bar_widget.dart';
import 'package:duplicate_building_solution/widgets/default_image.dart';
import 'package:duplicate_building_solution/widgets/error_widget.dart';
import 'package:duplicate_building_solution/widgets/loading_widget.dart';
import 'package:duplicate_building_solution/widgets/no_project_found.dart';
import 'package:duplicate_building_solution/widgets/sync_status_banner.dart';
import 'package:flutter/material.dart';

class ProjectScreen extends StatefulWidget {
  final String partyName;

  const ProjectScreen({super.key, required this.partyName});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final TextEditingController projectNameController = TextEditingController();
  final TextEditingController projectDescController = TextEditingController();

  late CollectionReference<Map<String, dynamic>> fireAuth;
  final OfflineSyncService _syncService = OfflineSyncService.instance;
  late final Stream<List<Map<String, dynamic>>> _cachedProjectsStream =
      _syncService.watchCachedProjects();
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _onlineSubscription;
  QueryDocumentSnapshot<Map<String, dynamic>>? _lastDocument;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  static const int _pageSize = 10;
  String _searchTerm = '';

  List<ProjectModel> projectModel = [];

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
    }, onError: (err) => debugPrint('Project stream error: $err'));
  }

  Query<Map<String, dynamic>> _buildBaseQuery() {
    Query<Map<String, dynamic>> baseQuery = fireAuth
        .where('project_deleted', isEqualTo: 'no')
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

  void _onScroll() {
    if (!_syncService.isOnline) return;
    if (_scrollController.position.pixels >=
        (_scrollController.position.maxScrollExtent - 200)) {
      _loadMore();
    }
  }

  @override
  void dispose() {
    _onlineSubscription?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    projectNameController.dispose();
    projectDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // if (didPop) return;
        // pageTransition(context, const PartyScreen());
      },
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _cachedProjectsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return errorWidget(context);
          }
          if (!snapshot.hasData) {
            return loadingWidget(context);
          }

          final entries = _buildProjectEntries(snapshot.data!);
          projectModel = entries.map((entry) => entry.model).toList();

          return Scaffold(
            appBar: appBarWidget(
              onClose: () {
                _searchController.clear();
                FocusScope.of(context).unfocus();
                setState(() => _searchTerm = '');
                _initStream();
              },
              searchEditingController: _searchController,
              leadingPress: () {
                pageTransition(
                  context,
                  ProjectRecycleBinScreen(partyName: widget.partyName),
                );
              },
              context: context,
              title: widget.partyName,
              color: ColorConstant.greenColor,
            ),
            body: entries.isEmpty
                ? NoProjectFound(
                    image: ImageConstant.noProjectImage,
                    title: TextConstant.noAnyProjectYet,
                    subTitle: TextConstant.yourProjectAppearHere,
                  )
                : Column(
                    children: [
                      const SyncStatusBanner(),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount:
                              entries.length +
                              ((_hasMore && _syncService.isOnline) ? 1 : 0),
                          itemBuilder: (context, index) {
                            final shouldShowLoader =
                                _hasMore && _syncService.isOnline;
                            if (shouldShowLoader && index == entries.length) {
                              if (_isLoadingMore) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                  ),
                                  child: loadingWidget(context),
                                );
                              } else {
                                return const SizedBox(height: 30);
                              }
                            }

                            final entry = entries[index];
                            final projectName =
                                entry.model.projectName ?? widget.partyName;
                            final syncStatus = entry.status;
                            final isPending =
                                syncStatus == SyncStatus.pending ||
                                syncStatus == SyncStatus.syncing;

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
                                      FileScreen(
                                        projectName: projectName,
                                        partyName: widget.partyName,
                                      ),
                                    );
                                  },
                                  leading: DefaultImage(
                                    title: ImageConstant.projectImage,
                                  ),
                                  title: Text(projectName),
                                  subtitle: isPending
                                      ? Text(
                                          'Pending sync',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: ColorConstant
                                                    .pastelRedColor,
                                              ),
                                        )
                                      : null,
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
                                          await _syncService.markProjectDeleted(
                                            partyName: widget.partyName,
                                            projectName: projectName,
                                            deleted: true,
                                          );
                                        },
                                        title: TextConstant.moveProjectRecycle,
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
                    ],
                  ),
            floatingActionButton: projectFloatingBtn(
              projectNameController: projectNameController,
              projectDescController: projectDescController,
              projectModel: projectModel,
              partyName: widget.partyName,
              projectScrollController: _scrollController,
            ),
          );
        },
      ),
    );
  }

  List<({ProjectModel model, SyncStatus status})> _buildProjectEntries(
    List<Map<String, dynamic>> rawData,
  ) {
    final prefix = '${widget.partyName}::';
    final filtered =
        rawData.where((data) {
          final entityId = (data['__entity_id'] ?? '') as String;
          if (!entityId.startsWith(prefix)) return false;
          final deleted = (data['project_deleted'] ?? 'no') as String;
          if (deleted == 'yes') return false;
          if (_searchTerm.isEmpty) return true;
          final lower = (data['project_name_lower'] ?? '') as String;
          return lower.startsWith(_searchTerm);
        }).toList()..sort(
          (a, b) => _extractMillis(
            b['project_add_on'],
          ).compareTo(_extractMillis(a['project_add_on'])),
        );

    return filtered
        .map(
          (data) => (
            model: _mapToProjectModel(data),
            status: SyncStatusX.fromValue(
              data['__sync_status'] as String? ?? SyncStatus.synced.value,
            ),
          ),
        )
        .toList();
  }

  ProjectModel _mapToProjectModel(Map<String, dynamic> raw) {
    final cleaned = _cleanData(raw);
    final model = ProjectModel.fromMap(cleaned);
    final entityId = (raw['__entity_id'] ?? '') as String;
    final fallbackName = entityId.contains('::')
        ? entityId.split('::').last
        : entityId;
    model.projectName = cleaned['project_name'] ?? fallbackName;
    return model;
  }

  Map<String, dynamic> _cleanData(Map<String, dynamic> raw) {
    final cleaned = Map<String, dynamic>.from(raw);
    cleaned.removeWhere((key, _) => key.toString().startsWith('__'));
    return cleaned;
  }

  int _extractMillis(dynamic value) {
    if (value is Timestamp) return value.millisecondsSinceEpoch;
    if (value is DateTime) return value.millisecondsSinceEpoch;
    if (value is int) return value;
    return 0;
  }
}
