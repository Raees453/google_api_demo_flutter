import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/youtube/v3.dart';

class YouTubeVideosScreen extends StatefulWidget {
  const YouTubeVideosScreen({Key? key}) : super(key: key);

  @override
  State<YouTubeVideosScreen> createState() => _YouTubeVideosScreenState();
}

class _YouTubeVideosScreenState extends State<YouTubeVideosScreen> {
  var _currentUser, _favVideos;
  bool _isLoading = false;
  bool _loginFailed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: _loginFailed
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Center(
                    child: ElevatedButton(
                      onPressed: signIn,
                      child: const Text('Sign In with Google'),
                    ),
                  ),
                  _currentUser == null ? const SizedBox() : _buildUserTile(),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : _favVideos == null
                          ? const SizedBox()
                          : SizedBox(
                              height: MediaQuery.of(context).size.height * 0.9,
                              child: _videosBuilder(),
                            ),
                ],
              ),
      ),
    );
  }

  _buildUserTile() {
    return ListTile(
      leading: GoogleUserCircleAvatar(
        identity: _currentUser,
      ),
      title: Text(_currentUser!.displayName ?? ''),
      subtitle: Text(_currentUser!.email),
    );
  }

  _videosBuilder() {
    return ListView.builder(
      itemBuilder: (_, index) {
        final video = _favVideos![index] as PlaylistItemSnippet;
        return ListTile(
          leading: Image.network(
            video.thumbnails!.standard != null
                ? video.thumbnails!.standard!.url!
                : 'https://static6.depositphotos.com/1002881/580/i/600/depositphotos_5804811-stock-photo-error-404.jpg',
          ),
          title: Text(video.title ?? '?'),
          subtitle: Text(video.publishedAt?.toString() ?? '?'),
        );
      },
      itemCount: _favVideos!.length,
    );
  }

  signIn() async {
    final googleSignIn = GoogleSignIn(
      scopes: [YouTubeApi.youtubeReadonlyScope],
    );

    googleSignIn.signIn();

    googleSignIn.onCurrentUserChanged.listen((event) {
      setState(() {
        _currentUser = event;
        _isLoading = true;
      });

      if (_currentUser != null) {
        _buildVideos(googleSignIn);
      }
    });
  }

  _buildVideos(GoogleSignIn googleSignIn) async {
    var authClient = await googleSignIn.authenticatedClient();
    if (authClient == null) {
      setState(() {
        _loginFailed = true;
      });
      return;
    }

    var youTubeApi = YouTubeApi(authClient);

    final favourites =
        await youTubeApi.playlistItems.list(['snippet'], playlistId: 'LL');

    setState(() {
      _favVideos = favourites.items!.map((e) => e.snippet!).toList();
      _isLoading = false;
    });
  }
}
