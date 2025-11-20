import 'package:flutter/material.dart';
import 'package:m_pro/constant/app_color.dart';
import 'package:m_pro/views/branches/nav_bar/absence_page.dart';
import 'package:m_pro/views/branches/nav_bar/home_page.dart';
import 'package:m_pro/views/branches/nav_bar/profile_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedBar = 0;

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const HomePage();
      case 1:
        return const AbsencePage();
      case 2:
        return const ProfilePage();
      default:
        return const HomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Absensi'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          ],
          currentIndex: _selectedBar,
          selectedItemColor: Colors.white,
          backgroundColor: AppColor.primary,
          onTap: (i) => setState(() => _selectedBar = i),
        ),
        body: Center(child: _getPage(_selectedBar)),
      ),
    );
  }
}
