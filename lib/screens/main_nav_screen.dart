import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../providers/theme_provider.dart';
import 'dashboard_screen.dart'; 
import 'add_transaction_screen.dart';
import 'chart_screen.dart';

class MainNavScreen extends ConsumerStatefulWidget {
  const MainNavScreen({super.key});

  @override
  ConsumerState<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends ConsumerState<MainNavScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ChartScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(backgroundProvider);
    final isDarkBg = (themeState.bgIndex == 1 || themeState.bgIndex == 2 || themeState.bgIndex == 3 || themeState.bgIndex == 5 || themeState.bgIndex == 6);
    
    // TEMA FLAT BERKELAS: Penggunaan Putih Tulang dan Warna Slate (Abu Biru Malam) tanpa kontras menohok
    // final bgColor = isDarkBg ? Colors.black.withOpacity(0.5) : const Color(0xFFFDFBFB); 
    final itemSelectedColor = isDarkBg ? Colors.white : const Color(0xFFF43F5E); // Merah muda/Rose Halus 
    final itemUnselectedColor = isDarkBg ? Colors.white54 : const Color(0xFF94A3B8); // Slate kelabu flat 

    return Scaffold(
      extendBody: true, 
      body: _screens[_currentIndex],
      
      // TOMBOL MENGAMBANG O&C DENGAN NUANSA CINTA
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(), 
        backgroundColor: const Color(0xFFF43F5E), // Rose Flat Red.. No Terang Benderang kaku
        elevation: 3, // Di bikin tipis, ga kaku numpuk banget ke layarnya (Flat shadow)
        onPressed: () {
           Navigator.push(context, PageRouteBuilder(
             // Pindah layer pake efek Blur/Pudar Lembut kaya Album foto .. Bukan Push Ngagetin  !!
             pageBuilder: (context, animation, secondaryAnimation) => const AddTransactionScreen(),
             transitionsBuilder: (context, animation, secondaryAnimation, child) {
               return FadeTransition(opacity: animation, child: child);
             },
           ));
        },
        child: const Icon(Icons.volunteer_activism_rounded, color: Colors.white, size: 28), // Ikon hati kecil disangga tangan (Keromantisan Nabung O&C!)
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: ClipRRect(
        // Menggunakan ClipRRect dengan bentuk notch agar efek blur memotong sempurna mengikuti lekukan
        clipBehavior: Clip.antiAlias,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BackdropFilter(
          // Efek blur kaca susu yang senada dengan AppBar atas
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: BottomAppBar(
            // Pastikan warna background menggunakan .withOpacity yang tipis agar blurnya terlihat mentereng
            color: (isDarkBg ? Colors.black : const Color(0xFFFDFBFB)).withOpacity(0.4),
            shape: const CircularNotchedRectangle(),
            notchMargin: 12.0,  
            clipBehavior: Clip.antiAlias,
            elevation: 0, // Dibuat 0 agar tidak ada shadow hitam kaku di atas kaca blurnya
            child: SizedBox(
              height: 65.0, 
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                   // ====== KIRI : KISAH PERJALANAN =====
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _currentIndex = 0),
                      child: Container(
                        color: Colors.transparent, 
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _currentIndex == 0 ? Icons.home_rounded : Icons.home_outlined, 
                              color: _currentIndex == 0 ? itemSelectedColor : itemUnselectedColor,
                              size: _currentIndex == 0 ? 28 : 26 
                            ),
                            const SizedBox(height: 2),
                            Text('Beranda', style: TextStyle(color: _currentIndex == 0 ? itemSelectedColor : itemUnselectedColor, fontSize: 10, fontWeight: _currentIndex == 0 ? FontWeight.w800 : FontWeight.w500))
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Expanded(child: SizedBox.shrink()),
                  
                   // ===== KANAN: BINCANG KEDEPAN ====
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _currentIndex = 1),
                      child: Container(
                        color: Colors.transparent,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _currentIndex == 1 ? Icons.bar_chart_rounded : Icons.bar_chart_rounded, 
                              color: _currentIndex == 1 ? itemSelectedColor : itemUnselectedColor,
                              size: _currentIndex == 1 ? 28 : 26
                              ),
                            const SizedBox(height: 2),
                            Text('Analisis', style: TextStyle(color: _currentIndex == 1 ? itemSelectedColor : itemUnselectedColor, fontSize: 10, fontWeight: _currentIndex == 1 ? FontWeight.w800 : FontWeight.w500))
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}