import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'screens/dashboard_screen.dart'; 
import 'providers/theme_provider.dart';
import 'package:intl/date_symbol_data_local.dart'; 
import 'screens/main_nav_screen.dart';

// PASTIKAN KEDUA KONFIGURASI SUPABASE MILIK ANDA UDAH DIPASANG MENTOK SAMPE SINI 
SUPABASE_URL=isikan_url_milik_kalian_di_file_aslinya
SUPABASE_KEY=isikan_key_anon_milik_kalian_disini

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ----- TAMBAHKAN BARIS INI DISINI -----
  await initializeDateFormatting('id_ID', null);

  // O&C Menyalakan Memori Lokal Internal... (Sisa kodingan ke bawah tetap biarkan jangan dirubah)
  final prefs = await SharedPreferences.getInstance();

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: publishableKey,
  );

  runApp(
    // Penting! Supaya Sistem Riverpod Sadar Keberadaan 'Memori' Preferences 
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'O&C', // Resmi Ganti Brand Disini
      theme: ThemeData(
        // Tema Utamanya Kita Setting Neutral Ke arah Mint Muda, nanti kita kustom!
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A8A)),
        useMaterial3: true,
      ),
      home: const MainNavScreen(), // <--  (Tadinya: const DashboardScreen()) DIRUBAH SEKARANG JADI MENARAH MENU NAV BAR INI!!!
    );
  }
  
}
