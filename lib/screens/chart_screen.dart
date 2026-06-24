import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../providers/database_provider.dart';
import '../providers/theme_provider.dart';
import 'dashboard_screen.dart' show customBackgrounds;

final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

class ChartScreen extends ConsumerWidget {
  const ChartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // --- TARIK DATA ANALISIS KALKULATOR FILTER ---
    final filterSaatIni = ref.watch(chartFilterProvider);
    final dataAnalytic = ref.watch(analyticCalculationProvider);
    
    // --- ESTETIKA TEMA & MODE GELAP TERANG ---
    final themeState = ref.watch(backgroundProvider);
    final bool isDarkBg = (themeState.bgIndex == 1); // Indeks gelap cuma Malam flat 
    final Color textColor = isDarkBg ? Colors.white.withOpacity(0.9) : const Color(0xFF334155); 
    final Color subtitleColor = isDarkBg ? Colors.white54 : const Color(0xFF94A3B8);

    return Scaffold(
      extendBodyBehindAppBar: true, 
      backgroundColor: Colors.white, // Tumpuan Warna Jatuh Layar Flat

      body: Stack(
        children: [
          // ======== LAYAR DALAM: WUJUD ALAM WARNA & KACA BURAM =======
          if (themeState.bgIndex != 6) ...[
             Container(decoration: customBackgrounds[themeState.bgIndex])
          ] else ...[
            if (themeState.customImage != null)
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(1.0 - themeState.bgOpacity), 
                  BlendMode.srcATop,
                ),
                child: Image.file(
                  File(themeState.customImage!), 
                  fit: BoxFit.cover, height: double.infinity, width: double.infinity, 
                ),
              )
          ],

          // ======== STRUKTUR BADAN UI CHART O&C ========
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              
              // APP BAR: ATAP ROMANTIS BERBAYANG ES
              SliverAppBar(
                expandedHeight: 70, 
                elevation: 0, 
                pinned: true, 
                backgroundColor: Colors.transparent, 
                flexibleSpace: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                    child: Container(color: (isDarkBg ? Colors.black : const Color(0xFFFDFBFB)).withOpacity(0.4)),
                  ),
                ),
                centerTitle: true,
                title: Text("Ringkasan Aktivitas 📖", style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.w600, fontSize: 18, color: textColor)),
              ),

              // RANGKA BADAN & ISI MENU SKETSA ! 
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      
                      // 1. ================= UI PENGUBAH MEMORI WAKTU KITA ================
                      Row(
                        children: [
                          Icon(Icons.av_timer_rounded, size: 15, color: isDarkBg ? Colors.white38 : Colors.grey[400]),
                          const SizedBox(width: 8),
                          Text("Periode Laporan:", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor, letterSpacing: -0.3)),
                        ],
                      ),
                      
                      const SizedBox(height: 12),

                      // Kapsul Pill Pengubah Frame !! Rapi, Smooth Tanpa Border Kotak-Kotak. 
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: isDarkBg ? Colors.white12 : Colors.grey[100], borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          children: [
                             _buildFilterTab(context, ref, 'Mingguan', TimeFilter.mingguan, filterSaatIni),
                             _buildFilterTab(context, ref, 'Bulan Ini', TimeFilter.bulanan, filterSaatIni),
                             _buildFilterTab(context, ref, 'Sepanjang Tahun', TimeFilter.tahunan, filterSaatIni),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 36),

                      // 2. ================= RANGKUMAN KENANGAN: DIMASUKKAN & DIJAJANKAN ===============
                      Row(
                        children: [
                          // UI Kartunya Rata Flat Design Halus Anti Drop shadow lebay! 
                          Expanded(child: _buildTimeCard("Sisa Ditabung", dataAnalytic.incomeAmount, isDarkBg ? Colors.tealAccent[100]! : const Color(0xFF10B981), isDarkBg, subtitleColor)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTimeCard("Berakhir Dipakai", dataAnalytic.expenseAmount, isDarkBg ? Colors.pink[100]! : const Color(0xFFF43F5E), isDarkBg, subtitleColor)),
                        ],
                      ),

                      const SizedBox(height: 48),

                      // 3. ================== GRAPH TAMPILAN ELEGAN "FL_CHART" ===================
                      Row(
                         children: [
                            Icon(Icons.pie_chart_rounded, size: 20, color: isDarkBg ? Colors.white38 : Colors.grey[400]),
                            const SizedBox(width: 8),
                            Text("Riwayat Pengeluaran", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor, letterSpacing: -0.5)),
                         ]
                      ),
                      const SizedBox(height: 20),

                      _buildGraphAndLegendUI(dataAnalytic.expensesByCategory, dataAnalytic.expenseAmount, textColor, subtitleColor, isDarkBg),

                      const SizedBox(height: 120), 
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      )
    );
  }


  // ============== PEMBAGI RONGGA / SWITCHER PILL TAMPILAN HALUS ===============
  Widget _buildFilterTab(BuildContext context, WidgetRef ref, String title, TimeFilter option, TimeFilter selectedValue) {
    bool isSelected = option == selectedValue;
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(chartFilterProvider.notifier).ubahFilterWaktu(option),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
             // Penggunaan Tema Flat Warna Mawar Merah Gelap saat Aktif!! (Romantis elegan banget)
            color: isSelected ? const Color(0xFFF43F5E) : Colors.transparent, 
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected ? [BoxShadow(color: const Color(0xFFF43F5E).withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))] : [], // Efek menyala 
          ),
          child: Center(child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5, color: isSelected ? Colors.white : Colors.grey[500]))),
        ),
      ),
    );
  }

  // ============== MINI WIDGET KALKULASI ROMANTIS WAKTU ===============
  Widget _buildTimeCard(String label, int amount, Color tintColor, bool isDarkBg, Color grayStyleText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      decoration: BoxDecoration(
         color: isDarkBg ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.7), // Clear Frosted / Flat Style
         borderRadius: BorderRadius.circular(30), 
         border: Border.all(color: isDarkBg ? Colors.white12 : Colors.grey[200]!, width: 1.0)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: grayStyleText, fontWeight: FontWeight.bold, fontSize: 11)),
          const SizedBox(height: 8),
          Text(currencyFormatter.format(amount), style: TextStyle(fontWeight: FontWeight.w600, color: tintColor, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      )
    );
  }

  // ============== MASTERPIECE PIE GRAPH DONAT TIPE FLAT  =================
  Widget _buildGraphAndLegendUI(Map<String, int> categoriesMap, int totalAllExpense, Color tColor, Color subtitleC, bool isDarkBg) {
    
    if (categoriesMap.isEmpty || totalAllExpense == 0) {
      return Container(
        height: 220, width: double.infinity,
        decoration: BoxDecoration(color: isDarkBg ? Colors.white10 : Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(30), border: Border.all(color: isDarkBg ? Colors.white12 : Colors.grey[200]!)),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Icon(Icons.spa_rounded, size: 50, color: subtitleC.withOpacity(0.5)),
             const SizedBox(height: 12),
             Text("Belum ada data pengeluaran untuk periode ini", textAlign: TextAlign.center, style: TextStyle(color: subtitleC, fontStyle: FontStyle.italic, fontSize: 12, height: 1.6)),
          ],
        )
      );
    }

    // PAKET WARNA TERBARU: Lebih Soft Pastel Aesthetic, Tidak Keras Mencolok ke Mata 🌸 (Lavendar, Salmon, Mint, Blush dll)
    List<PieChartSectionData> sections = [];
    List<Color> graphColors = [const Color(0xFFF43F5E), const Color(0xFFFCD34D), const Color(0xFF6EE7B7), const Color(0xFFC4B5FD), const Color(0xFFF9A8D4), const Color(0xFF93C5FD)];
    int iterColorIndex = 0;
    
    categoriesMap.forEach((categoryName, amountCat) {
      // Baris persentase dihapus karena tidak digunakan
      sections.add(PieChartSectionData(
        color: graphColors[iterColorIndex % graphColors.length], 
        value: amountCat.toDouble(), 
        title: "", // No Title, kita sembunyiin biar elegan & smooth donut graph!!! 🍩
        radius: 40 
      ));
      iterColorIndex++;
    });

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36), // Pad lega
      decoration: BoxDecoration(
        color: isDarkBg ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.8), 
        borderRadius: BorderRadius.circular(30), // Oval Smooth Round Edge  
        border: Border.all(color: isDarkBg ? Colors.white12 : Colors.grey[200]!)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Gambar Ring Cincin Donut PuiTISSSS !! 
          SizedBox(
             height: 180, 
             child: PieChart(
                PieChartData(
                   sectionsSpace: 4, // Jeda Belahan tipis clean 
                   centerSpaceRadius: 60, // Lubang daleman nya lebar
                   sections: sections,
                   pieTouchData: PieTouchData(enabled: false)
                )
             )
          ),
          
          const SizedBox(height: 36),
          // Indikator Garis/Dot Daftar Namany !!! 
          Center(child: Container(height: 2, width: 30, decoration: BoxDecoration(color: isDarkBg ? Colors.white24 : Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 20),
          
          // Looping Data untuk daftar harga dengan titik warna kecil!! Rapi abisss:
          for (int x = 0; x < categoriesMap.entries.length; x++) 
              Padding(
                padding: const EdgeInsets.only(bottom: 16), 
                child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                      Row(
                        children: [
                           // Ikon DOT FLAT bulat Halus (Ditaro di list legend Chartnya !) 
                           Container(width: 12, height: 12, decoration: BoxDecoration(color: graphColors[x % graphColors.length], shape: BoxShape.circle)), 
                           const SizedBox(width: 14), 
                           // Tanpa Error String interopolate! Udah rapi jali!
                           Text(categoriesMap.keys.elementAt(x), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: tColor))
                        ]
                      ),
                      // Teks Rupiah Flat dengan penamaan yg gak Nabrak warna !
                      Text(currencyFormatter.format(categoriesMap.values.elementAt(x)), style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: subtitleC))
                ])
              )
        ],
      )
    );
  }
}