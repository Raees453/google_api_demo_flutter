import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreen();
}

class _CalendarScreen extends State<CalendarScreen> {
  var _currentUser, _favVideos;
  bool _isLoading = false;
  bool _loginFailed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: _loginFailed
            ? Center(child: const Text('Some Error Occurred'))
            : Column(
                children: [
                  _currentUser != null
                      ? const SizedBox()
                      : Center(
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
                              child: _calendarsBuilder(),
                            ),
                ],
              ),
      ),
    );
  }

  _calendarsBuilder() {
    return ListView.builder(
      itemCount: _favVideos!.length,
      itemBuilder: (_, index) {
        return ListTile(
          trailing: Text(
            _favVideos[index].eventType.toString().toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          title: Text(_favVideos[index].summary),
          subtitle: Text(_favVideos[index].status ?? 'Error'),
        );
      },
    );
  }

  signIn() async {
    final googleSignIn = GoogleSignIn(
      scopes: [
        CalendarApi.calendarEventsScope,
        CalendarApi.calendarScope,
      ],
    );

    googleSignIn.signIn();

    googleSignIn.onCurrentUserChanged.listen((event) {
      setState(() {
        _currentUser = event;
        _isLoading = true;
      });

      if (_currentUser != null) {
        _buildEvents(googleSignIn);
      }
    });
  }

  _buildEvents(GoogleSignIn googleSignIn) async {
    var authClient = await googleSignIn.authenticatedClient();
    if (authClient == null) {
      setState(() {
        _loginFailed = true;
      });
      return;
    }

    var calendarApi = CalendarApi(authClient);

    // will fetch events only from the primary calendar
    final events = await calendarApi.events.list('primary');

    setState(() {
      _favVideos = events.items!.map((e) => e).toList();
      _isLoading = false;
    });
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
}
