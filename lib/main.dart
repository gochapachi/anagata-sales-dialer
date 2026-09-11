import 'package:flutter/material.dart';
import 'screens/lead_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AnagataDialerApp());
}

class AnagataDialerApp extends StatelessWidget {
  const AnagataDialerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anagata Sales Dialer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          primary: Colors.indigo,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
      ),
      home: const LeadListScreen(),
    );
  }
}
