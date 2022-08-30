import 'package:flutter/material.dart';
import 'package:youtube_api_demo/calendar_screen.dart';
import 'package:youtube_api_demo/youtube_videos_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _screens = const [
    CalendarScreen(),
    YouTubeVideosScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.calendar_today_outlined)),
              Tab(icon: Icon(Icons.video_camera_back_outlined)),
            ],
          ),
          title: const Text('Google APIs Implementation - Flutter'),
        ),
        body: TabBarView(
          children: _screens,
        ),
      ),
    );
  }
}
