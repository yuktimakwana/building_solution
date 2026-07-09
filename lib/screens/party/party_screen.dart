import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:duplicate_building_solution/dialog/delete_dialog.dart';
import 'package:duplicate_building_solution/model/party_model.dart';
import 'package:duplicate_building_solution/offline/offline_status.dart';
import 'package:duplicate_building_solution/offline/offline_sync_service.dart';
import 'package:duplicate_building_solution/screens/party/party_floating_btn.dart';
import 'package:duplicate_building_solution/screens/party/party_recycle_bin.dart';
import 'package:duplicate_building_solution/screens/profile/profile_screen.dart';
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
import 'package:duplicate_building_solution/widgets/sync_status_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  final OfflineSyncService _syncService = OfflineSyncService.instance;
  late final Stream<List<Map<String, dynamic>>> _cachedPartiesStream;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _onlineSubscription;
  QueryDocumentSnapshot<Map<String, dynamic>>? _lastDocument;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  static const int _pageSize = 10;
  String _searchTerm = '';

  List<PartyModel> partyModel = [];

  @override
  void initState() {
    super.initState();
    FirebaseRef.init();
    _cachedPartiesStream = _syncService.watchCachedParties();
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
        table: 'parties',
        snapshot: snapshot,
        idBuilder: (doc) => doc.id,
      );
      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
        _hasMore = snapshot.docs.length == _pageSize;
      } else {
        _hasMore = false;
      }
      if (mounted) {
        setState(() {});
      }
    }, onError: (err) => debugPrint('Party stream error: $err'));
  }

  Query<Map<String, dynamic>> _buildBaseQuery() {
    Query<Map<String, dynamic>> baseQuery = FirebaseRef.partyUserDoc
        .where('party_deleted', isEqualTo: 'no')
        .orderBy('party_add_on', descending: true)
        .limit(_pageSize);

    if (_searchTerm.isNotEmpty) {
      baseQuery = baseQuery
          .where('party_name_lower', isGreaterThanOrEqualTo: _searchTerm)
          .where('party_name_lower', isLessThanOrEqualTo: '$_searchTerm\uf8ff');
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
          table: 'parties',
          snapshot: snap,
          idBuilder: (doc) => doc.id,
        );
      } else {
        _hasMore = false;
      }

      debugPrint("Loaded more party docs. Last doc id: ${_lastDocument?.id}");
      if (mounted) {
        setState(() {});
      }
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
    partyNameController.dispose();
    partyDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (c, _) {
        SystemNavigator.pop();
      },
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _cachedPartiesStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return errorWidget(context);
          }
          if (!snapshot.hasData) {
            return loadingWidget(context);
          }

          final entries = _buildPartyEntries(snapshot.data!);
          partyModel = entries.map((entry) => entry.model).toList();

          return Scaffold(
            appBar: appBarWidget(
              leadingPress: () {
                pageTransition(context, const PartyRecycleBin());
              },
              action: [
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: FirebaseRef.userProfileDoc.snapshots(),
                  builder: (context, profileSnap) {
                    final data = profileSnap.data?.data() ?? {};
                    final user = FirebaseAuth.instance.currentUser;
                    final displayName = data['displayName'] ?? user?.displayName ?? '';
                    final photoUrl = data['image_url'] ?? data['photoUrl'] ?? user?.photoURL;

                    return GestureDetector(
                      onTap: () {
                        pageTransition(context, const ProfileScreen());
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: ColorConstant.naturalWhiteColor,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: ColorConstant.greenColor,
                            backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                                ? NetworkImage(photoUrl)
                                : null,
                            child: (photoUrl == null || photoUrl.isEmpty)
                                ? Text(
                                    displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
              searchEditingController: _searchController,
              onClose: () {
                _searchController.clear();
                FocusScope.of(context).unfocus();
                setState(() => _searchTerm = '');
                _initStream();
              },
              context: context,
              title: TextConstant.party,
              color: ColorConstant.greenColor,
            ),
            body: entries.isEmpty
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    NoProjectFound(
                        image: ImageConstant.noPartyImage,
                        title: TextConstant.noAnyPartyYet,
                        subTitle: TextConstant.yourPartyAppearHere,
                      ),
                  ],
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
                            final partyName = entry.model.partyName ?? '';
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
                                          await _syncService.markPartyDeleted(
                                            partyName: partyName,
                                            deleted: true,
                                          );
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
      ),
    );
  }

  List<({PartyModel model, SyncStatus status, Map<String, dynamic> raw})>
  _buildPartyEntries(List<Map<String, dynamic>> rawData) {
    final filtered =
        rawData.where((data) {
          final deleted = (data['party_deleted'] ?? 'no') as String;
          if (deleted == 'yes') return false;
          if (_searchTerm.isEmpty) return true;
          final nameLower = (data['party_name_lower'] ?? '') as String;
          return nameLower.startsWith(_searchTerm);
        }).toList()..sort(
          (a, b) => _extractMillis(
            b['party_add_on'],
          ).compareTo(_extractMillis(a['party_add_on'])),
        );

    return filtered
        .map(
          (data) => (
            model: _mapToPartyModel(data),
            status: SyncStatusX.fromValue(
              data['__sync_status'] as String? ?? SyncStatus.synced.value,
            ),
            raw: data,
          ),
        )
        .toList();
  }

  PartyModel _mapToPartyModel(Map<String, dynamic> raw) {
    final cleaned = _cleanData(raw);
    final model = PartyModel.fromMap(cleaned);
    model.partyName = cleaned['party_name'] ?? raw['__entity_id'] as String?;
    model.partyDeleted = cleaned['party_deleted'];
    return model;
  }

  Map<String, dynamic> _cleanData(Map<String, dynamic> raw) {
    final cleaned = Map<String, dynamic>.from(raw);
    cleaned.removeWhere((key, _) => key.toString().startsWith('__'));
    return cleaned;
  }

  int _extractMillis(dynamic value) {
    if (value is Timestamp) {
      return value.millisecondsSinceEpoch;
    } else if (value is DateTime) {
      return value.millisecondsSinceEpoch;
    } else if (value is int) {
      return value;
    }
    return 0;
  }
}
