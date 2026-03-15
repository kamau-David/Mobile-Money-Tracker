import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telephony/telephony.dart';

import 'providers/theme_provider.dart';
// import 'providers/auth_provider.dart'; // Uncomment when ready
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/summary_screen.dart';
import 'screens/history_screen.dart';
import 'screens/splash_screen.dart';
import 'services/sms_service.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: TrackerApp()));
}

class TrackerApp extends ConsumerStatefulWidget {
  const TrackerApp({super.key});

  @override
  ConsumerState<TrackerApp> createState() => _TrackerAppState();
}

class _TrackerAppState extends ConsumerState<TrackerApp> {
  @override
  void initState() {
    super.initState();
    // Start listener after the first frame to ensure 'ref' is fully ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSmsListener();
    });
  }

  Future<void> _initializeSmsListener() async {
    try {
      final telephony = Telephony.instance;
      // Requesting permissions for SMS interception
      bool? permissionsGranted = await telephony.requestSmsPermissions;

      if (permissionsGranted == true) {
        // We pass 'ref' so the service can talk to your FinanceProvider
        final smsService = SmsService(ref);
        smsService.startListening();
        debugPrint("✅ SMS Service: Active and filtering for M-PESA");
      } else {
        debugPrint("⚠️ SMS Service: Permissions denied by user");
      }
    } catch (e) {
      debugPrint("❌ SMS Service: Failed to initialize: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'KES Tracker',
      themeMode: themeMode,

      // Light Theme (Professional Green)
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: const Color(0xFF2E7D32),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),

      // Dark Theme (OLED Friendly)
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF2E7D32),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1B5E20),
          foregroundColor: Colors.white,
          elevation: 0,
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

// --- MAIN NAVIGATION CONTAINER ---
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
      body: IndexedStack(
        // IndexedStack preserves the scroll position of your lists
        index: _index,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (val) => setState(() => _index = val),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: "Add",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: "Summary",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: "History",
          ),
        ],
      ),
    );
  }
}
