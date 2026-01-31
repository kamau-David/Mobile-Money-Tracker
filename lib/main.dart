import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/summary_screen.dart';
import 'screens/history_screen.dart';
import 'screens/splash_screen.dart';

void main() => runApp(const ProviderScope(child: TrackerApp()));

class TrackerApp extends ConsumerWidget {
  const TrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch the theme state
    final themeMode = ref.watch(themeProvider);

    ref.listen(authProvider, (previous, next) {
      if (!next.isAuthenticated) {}
    });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KES Tracker',

      // 2. Link the themeMode from our provider
      themeMode: themeMode,

      // 3. Define the Light Theme
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        primaryColor: const Color(0xFF2E7D32),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
        ),
      ),

      // 4. Define the Dark Theme
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFF2E7D32),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(
            0xFF1B5E20,
          ), // Slightly deeper green for dark mode
          foregroundColor: Colors.white,
        ),
        // Ensures bottom nav bars look good in dark mode
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1E1E1E),
        ),
      ),

      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/main': (context) => const MainContainer(),
      },
    );
  }
}

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _index = 0;
  final List<Widget> _screens = [
    const HomeScreen(),
    const AddTransactionScreen(),
    const SummaryScreen(),
    const HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (val) => setState(() => _index = val),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: "Add"),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Summary",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
        ],
      ),
    );
  }
}
