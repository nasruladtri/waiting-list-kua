import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/user_dashboard.dart';
import 'screens/dashboard/admin_kua_dashboard.dart';
import 'screens/dashboard/admin_dukcapil_dashboard.dart';
import 'screens/dashboard/superadmin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with emulator settings
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'demo-api-key',
      appId: '1:123456789:android:abcdef',
      messagingSenderId: '123456789',
      projectId: 'kua-waiting-list-dev',
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'KUA Waiting List',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/user-dashboard': (context) => const UserDashboard(),
          '/admin-kua-dashboard': (context) => const AdminKUADashboard(),
          '/admin-dukcapil-dashboard': (context) => const AdminDukcapilDashboard(),
          '/superadmin-dashboard': (context) => const SuperadminDashboard(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          return FutureBuilder<String?>(
            future: authService.getCurrentUserRole(),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final role = roleSnapshot.data;
              
              switch (role) {
                case 'superadmin':
                  return const SuperadminDashboard();
                case 'admin_kua':
                  return const AdminKUADashboard();
                case 'admin_dukcapil':
                  return const AdminDukcapilDashboard();
                case 'user':
                default:
                  return const UserDashboard();
              }
            },
          );
        }

        return const LoginScreen();
      },
    );
  }
}
