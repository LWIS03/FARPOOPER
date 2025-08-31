
import 'package:farpooper_frontend/map_pages/map_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'auth/screen/googel_login_screen.dart';
import 'map_pages/global_map.dart';
import 'map_pages/publicToilet_map.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GoogleMapController mapController;
  int currentPageIndex = 0;
  final controller = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            PageView(
              controller: controller,
              physics: const NeverScrollableScrollPhysics(), // <- evita que capture los gestos
              onPageChanged: (index) {
                setState(() {
                  currentPageIndex = index;
                });
              },
              children: const [
                ToiletMap(),
                MapPage(),
                Text("FRIENDS"),
              ],
            ),


            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, right: 12),
                  child: PopupMenuButton<String>(
                    tooltip: 'Options',
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        child: InkWell(
                          onTap: () async {
                            await FirebaseAuth.instance.signOut();
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> GoogleLoginScreen()));
                          },
                          child: const ListTile(
                            leading: Icon(Icons.logout),
                            title: Text('Log Out'),
                          ),
                        ),
                      ),
                    ],
                    child: Material(
                      elevation: 3,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: IconButton(
                        icon: const Icon(Icons.person),
                        onPressed: null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                      padding: const EdgeInsets.only(top: 12, left: 12),
                      child: IconButton(
                          onPressed: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> GlobalMap()));
                          },
                          icon: Icon(Icons.map_outlined),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),

                      )

                  ),

                )
            )
          ],
        ),

        // BOTTOM NAV BAR (se mantiene)
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.wc_rounded), label: 'WCs'),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
            BottomNavigationBarItem(icon: Icon(Icons.emoji_people), label: "Friends"),
          ],
          currentIndex: currentPageIndex,
          onTap: (int index) {
            setState(() {
              currentPageIndex = index;
            });
            controller.animateToPage(
              index,
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeInOut,
            );
          },
        ),
      ),
    );
  }
}
