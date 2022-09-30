import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:kin_music_player_app/components/on_snapshot_error.dart';
import 'package:kin_music_player_app/constants.dart';
import 'package:kin_music_player_app/screens/playlist/components/playlist_body.dart';
import 'package:kin_music_player_app/screens/playlist/components/playlist_title.dart';
import 'package:kin_music_player_app/services/network/model/playlist_info.dart';
import 'package:kin_music_player_app/services/provider/playlist_provider.dart';
import 'package:kin_music_player_app/size_config.dart';
import 'package:provider/provider.dart';

import '../../components/kin_progress_indicator.dart';

class PlaylistsScreen extends StatefulWidget {
  const PlaylistsScreen({Key? key}) : super(key: key);

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen>
  {
  late PlayListProvider playListProvider;
  static const _pageSize = 1;
  final PagingController<int, PlaylistInfo> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    playListProvider = Provider.of(context, listen: false);

    _pagingController.addPageRequestListener(
      (pageKey) {
        _fetchMorePlaylists(pageKey);
      },
    );
    super.initState();
  }

  void refreshFunction() {
    _pagingController.refresh();
    setState(() {});
  }

  Future _fetchMorePlaylists(int pageKey) async {
    try {
      final newItems = await playListProvider.getPlayList(pageKey: pageKey);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }



  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  
    // text controller
    TextEditingController playlistNameController = TextEditingController();
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: SafeArea(
        child: FutureBuilder(
          future: playListProvider.getPlayList(),
          builder: (context, AsyncSnapshot<List<PlaylistInfo>> snapshot) {
            // loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: KinProgressIndicator(),
              );
            }

            // data loaded
            else if (snapshot.hasData && !snapshot.hasError) {
              return Container(
                padding: const EdgeInsets.fromLTRB(0, 24, 0, 36),
                child: RefreshIndicator(
                  onRefresh: () async {
                    _pagingController.refresh();
                  },
                  backgroundColor: refreshIndicatorBackgroundColor,
                  color: refreshIndicatorForegroundColor,
                  child: PagedListView<int, PlaylistInfo>(
                    pagingController: _pagingController,
                    builderDelegate: PagedChildBuilderDelegate<PlaylistInfo>(
                      animateTransitions: true,
                      transitionDuration: const Duration(milliseconds: 500),
                      noItemsFoundIndicatorBuilder: (context) => SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: const Center(
                          child: Text(
                            "No Playlist",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      noMoreItemsIndicatorBuilder: (_) => Container(
                        padding: const EdgeInsets.fromLTRB(0, 16, 0, 32),
                        child: const Center(
                          child: Text(
                            "No More Playlists",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      firstPageProgressIndicatorBuilder: (_) =>
                          const KinProgressIndicator(),
                      newPageProgressIndicatorBuilder: (_) =>
                          const KinProgressIndicator(),
                      itemBuilder: ((context, item, index) {
                        return InkWell(
                          onTap: () {
                            // go to detail page
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PlaylistBody(
                                  playlistId: item.id,
                                  playlistName: item.name,
                                ),
                              ),
                            );
                          },
                          child: PlaylistTitleDisplay(
                            playlistInfo: item,
                            refreshFunction: refreshFunction,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              );
            }

            // error
            else {
              return OnSnapshotError(error: snapshot.error.toString());
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kSecondaryColor,
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) {
              return Consumer<PlayListProvider>(
                builder: (BuildContext context, playListProvider, _) {
                  return SimpleDialog(
                    backgroundColor: kPopupMenuBackgroundColor,
                    insetPadding: const EdgeInsets.symmetric(horizontal: 20),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 30, horizontal: 30),
                    elevation: 10,
                    children: playListProvider.isLoading == false
                        ? [
                            // title
                            Text(
                              "Create Playlist",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            // spacer
                            const SizedBox(
                              height: 20,
                            ),

                            // Input
                            TextField(
                              controller: playlistNameController,
                              cursorColor: kGrey,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 0),
                                hintText: "Playlist Name",
                                hintStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 3,
                                    color: kSecondaryColor.withOpacity(0.5),
                                  ),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 3,
                                    color: kSecondaryColor,
                                  ),
                                ),
                              ),
                            ),

                            // Spacer
                            const SizedBox(
                              height: 48,
                            ),

                            // controls
                            Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.symmetric(
                                horizontal: getProportionateScreenWidth(20),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Cancel Button
                                  InkWell(
                                    onTap: () async {
                                      Navigator.pop(context, true);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4, horizontal: 16),
                                      child: const Text(
                                        "Cancel",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Separator

                                  // Create Button
                                  InkWell(
                                    onTap: () async {
                                      // empty text
                                      if (playlistNameController.text == "") {
                                        kShowToast(
                                            message: "Invalid Playlist name");
                                      } else {
                                        await playListProvider.createPlayList(
                                          playlistName:
                                              playlistNameController.text,
                                        );
                                        await playListProvider.getPlayList();
                                        playlistNameController.text = "";

                                        Navigator.pop(context, true);
                                        refersh();
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                        horizontal: 16,
                                      ),
                                      child: const Text(
                                        "Create",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ]
                        : [
                            const Center(
                              child: KinProgressIndicator(),
                            )
                          ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void refersh() {
    _pagingController.refresh();
  }
}
