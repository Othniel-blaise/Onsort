import 'package:flutter/material.dart';
import 'package:onsortx/screens/Favorie_Screen.dart' show FavorieScreen;
import 'package:onsortx/screens/Info_Screen.dart';
import 'package:onsortx/screens/Map_Screen.dart';
import 'package:onsortx/screens/Profil_Screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

}
int _currentIndex =0;

List<Widget> _pageList = [

  InfoScreen(),
  FavorieScreen (),
  MapScreen (),
  ProfilScreen (),
  
  
];


class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
   return Scaffold(
      body: Center(child: _pageList[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Color(0xFFE6B800),
        unselectedItemColor:Color.fromARGB(255, 12, 10, 1),
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() {
          _currentIndex = index;
        }),
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                color: Color(0xFFE6B800),
              ),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.favorite_border_sharp,
                color: Color(0xFFE6B800),
              ),
              label: 'Favorie'),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.location_on_rounded,
              color:Color(0xFFE6B800),
            ),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.account_circle,
              color: Color(0xFFE6B800),
            ),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}