import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../home/home_page.dart';
import '../today_tasks/today_tasks_page.dart';
import '../settings/settings_page/settings_page.dart';

/// ホーム画面のボトムタブナビゲーション
///
/// ホーム / 今日のタスク / 設定の3つのタブを提供します。
class HomeNavigationShell extends StatefulWidget {
  const HomeNavigationShell({super.key});

  @override
  State<HomeNavigationShell> createState() => _HomeNavigationShellState();
}

class _HomeNavigationShellState extends State<HomeNavigationShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [HomePage(), TodayTasksPage(), SettingsPage()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.today_outlined),
            activeIcon: Icon(Icons.today),
            label: '今日のタスク',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: '設定',
          ),
        ],
        backgroundColor: AppColors.neutral100,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.neutral600,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
