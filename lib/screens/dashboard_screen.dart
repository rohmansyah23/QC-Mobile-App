import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/database_provider.dart';
import '../providers/theme_provider.dart';
import 'add_transaction_screen.dart';

final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

final List<BoxDecoration> customBackgrounds = [
  const BoxDecoration(color: Color(0xFFFAF9F6)), 
  const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF232526), Color(0xFF414345)], begin: Alignment.topCenter, end: Alignment.bottomCenter)), // Hitam Flat/Charcoal
  const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFffccd5), Color(0xFFffb3c1)], begin: Alignment.topLeft, end: Alignment.bottomRight)), // Romance Pink Soft
  const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFeef2f3), Color(0xFF8e9eab)], begin: Alignment.topCenter, end: Alignment.bottomCenter)), // Soft Blue-Grey
  const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFE5E4E2), Color(0xFFF3E5AB)], begin: Alignment.topLeft, end: Alignment.bottomRight)), // Warm Ivory
  const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFcdb4db), Color(0xFFffc8dd)], begin: Alignment.topLeft, end: Alignment.bottomRight)), // Lavender Peach
];

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final calculation = ref.watch(balanceCalculatorProvider);
    final themeState = ref.watch(backgroundProvider); 
    final bool isDarkBackground = (themeState.bgIndex == 1);
    final Color textColor = isDarkBackground ? Colors.white.withOpacity(0.9) : const Color(0xFF334155); 
    final Color subtitleColor = isDarkBackground ? Colors.white54 : const Color(0xFF64748B); 

    return Scaffold(
      extendBodyBehindAppBar: true, 
      backgroundColor: Colors.white, 
      body: Stack(
        children: [
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

          // ======== LAYAR 2: TULANGAN DAFTAR (TANPA BORDER KAKU & SHADOW) ========
      RefreshIndicator(
          onRefresh: () async => ref.refresh(transactionsProvider),
          color: const Color(0xFFF43F5E), // Merah rose lembut saat muter loading[cite: 1]
          
          // === TAMBAHKAN DUA BARIS INI ===
          edgeOffset: 140,   // Menggeser titik awal munculnya spinner ke bawah navbar (~tinggi appBar)
          displacement: 40, // Jarak maksimal tarikan ke bawah sebelum dia memicu refresh (jadi lebih pendek/ringan)
          
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(), // Tarikan lentur khas Flat OS UI[cite: 1]
            slivers: [
                
                // --- APPBAR MINIMALIS ROMANTIS KACA SUSU ---
                SliverAppBar(
                  expandedHeight: 70,
                  elevation: 0, // Tanpa Bayangan!! Dibuat Rata dengan Layar (Flat)
                  pinned: true, 
                  backgroundColor: Colors.transparent, 
                  flexibleSpace: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                      child: Container(
                        // Kacanya Lebih soft
                        color: (isDarkBackground ? Colors.black : const Color(0xFFFDFBFB)).withOpacity(0.4),
                      ),
                    ),
                  ),
                  centerTitle: true,
                  title: Text("O&C 🕊️", style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.w600, fontSize: 18, letterSpacing: 0.5, color: textColor)),
                  actions: [
                    IconButton(
                       icon: Icon(Icons.palette_rounded, color: textColor.withOpacity(0.6)), 
                       onPressed: () => _showThemePicker(context, ref)
                    )
                  ],
                ),
                  
                // --- ISIAN UTAMA O&C ---
                SliverToBoxAdapter(
                  child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0).copyWith(
                          top: 40.0, // Menimpa vertical top agar jaraknya lebih jauh dari navbar
                          ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(28.0), 
                          decoration: BoxDecoration(
                            color: isDarkBackground ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.7), // Agak Tembus
                            borderRadius: BorderRadius.circular(30), // Lekukan besar nan halus
                            border: Border.all(color: isDarkBackground ? Colors.white12 : const Color(0xFFF1F5F9), width: 1.0)
                          ),
                          child: Column(
                             children: [
                              Text("TABUNGAN WAT JAJAN KITA", style: TextStyle(color: subtitleColor, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                              const SizedBox(height: 8),
                              Text(currencyFormatter.format(calculation.currentBalance), style: TextStyle(color: textColor, fontSize: 38, fontWeight: FontWeight.w300, letterSpacing: -1.0)), // Text light tipis modern
                              
                              const SizedBox(height: 36),
                              
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Disatukan simetris ke tengah!
                                children: [
                                   _buildStatMini("Terkumpul", calculation.totalIncome, isDarkBackground ? Colors.tealAccent[100]! : const Color(0xFF10B981), subtitleColor), // Warna Mint Kalem (Bukan hijau stabilo lg)
                                   Container(width: 1, height: 35, color: isDarkBackground ? Colors.white12 : Colors.black12), // Garis Batas Tengah
                                   _buildStatMini("Pengeluaran", calculation.totalExpense, isDarkBackground ? Colors.pink[100]! : const Color(0xFFF43F5E), subtitleColor), // Rose Merah kalem 
                                ],
                              )
                             ]
                          )
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // ===== JUDUL RIWAYAT KISAH KITA (TIDAK ADA EMAS LAGI, FLAT MODERN!) =====
                        Row(
                           children: [
                              Icon(Icons.auto_awesome, size: 18, color: isDarkBackground ? Colors.white38 : Colors.grey[400]),
                              const SizedBox(width: 8),
                              Text("Histori Pemasukan & Pengeluaran", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor, letterSpacing: -0.3)),
                           ],
                        ),
                        // const SizedBox(height: 20),

                        transactionsAsync.when(
                          loading: () => Center(child: Padding(padding: const EdgeInsets.all(32), child: CircularProgressIndicator(color: subtitleColor, strokeWidth: 2))),
                          error: (e, st) => Center(child: Text('Ada embun di Server : $e', style: TextStyle(color: subtitleColor))),
                          data: (transactions) {
                             if (transactions.isEmpty) return Container(padding: const EdgeInsets.symmetric(vertical: 40), alignment: Alignment.center, child: Text("Belum ada jejak hari ini.\nMulai petualangan O&C sekarang yuk~", textAlign: TextAlign.center, style: TextStyle(color: subtitleColor, fontStyle: FontStyle.italic, height: 1.5)));
                              
                              return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: transactions.length,
                              itemBuilder: (context, index) {
                                final trx = transactions[index];
                                final isIncome = trx.type == 'income';
                                final valColor = isIncome ? (isDarkBackground ? Colors.tealAccent[100] : const Color(0xFF059669)) : (isDarkBackground ? Colors.pink[200] : const Color(0xFFE11D48));

                                // SISTEM DELETE SMOOTH (TANPA KEDIP), BACKGROUND SLIDE JADI PINK MUDA
                                return Dismissible(
                                  key: Key(trx.id),
                                  direction: DismissDirection.endToStart, 
                                  confirmDismiss: (dir) async {
                                    return await showDialog(
                                      context: context,
                                      builder: (BuildContext context) => AlertDialog(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        title: const Text("Tarik Ingatan?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        content: const Text("Benar ingin menghapus ingatan tentang kegiatan O&C yang ini?", style: TextStyle(color: Colors.black54)),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Batalkan", style: TextStyle(color: Colors.grey))),
                                          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF43F5E), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text("Ya, Lupakan", style: TextStyle(color: Colors.white))),
                                        ],
                                      )
                                    );
                                  },
                                  onDismissed: (dir) => TransactionAPI.deleteRecord(ref, trx.id), 
                                  background: Container(
                                    alignment: Alignment.centerRight, 
                                    padding: const EdgeInsets.symmetric(horizontal: 24), 
                                    margin: const EdgeInsets.only(bottom: 12), 
                                    // Memaasukkan parameter lukis dengan BENAR (didalam decoration):
                                    decoration: BoxDecoration(
                                        color: isDarkBackground ? Colors.white12 : const Color(0xFFFEE2E2),
                                        borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Icon(Icons.cleaning_services_rounded, color: isDarkBackground ? Colors.white54 : const Color(0xFFF43F5E), size: 24)
                                  ),
                                  
                                  // == BINGKAI CATATAN DENGAN LEKUK HALUS TANPA BORDER KERAS ==
                                  child: GestureDetector(
                                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddTransactionScreen(tx_UntukDiEdit: trx))),
                                    
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                         color: isDarkBackground ? Colors.black26 : Colors.white.withOpacity(0.7),
                                         borderRadius: BorderRadius.circular(24), // Melengkung Halus Smooth 
                                         // Sama sekali tidak pakai shadow keras, cuma goresan selembut rambut
                                         border: Border.all(color: isDarkBackground ? Colors.white12 : Colors.grey[200]!, width: 1.0)
                                      ),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                                        
                                        title: Text(isIncome ? "Nabung Bareng 💕" : (trx.category?.name ?? "Catatan Kita"), style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 15)),
                                        subtitle: Padding(
                                           padding: const EdgeInsets.only(top: 4.0),
                                           child: Text(trx.description != null && trx.description!.isNotEmpty 
                                              ? "${trx.description!}\nDari: ${trx.contributor?.fullName} • ${DateFormat('dd MMM').format(trx.date)}" 
                                              : "Dari: ${trx.contributor?.fullName} • ${DateFormat('dd MMM').format(trx.date)}", 
                                           style: TextStyle(fontSize: 12, height: 1.5, color: subtitleColor)),
                                        ),
                                        isThreeLine: true,
                                        trailing: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text("${isIncome ? '+' : '-'}${currencyFormatter.format(trx.amount)}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: valColor)),
                                            const SizedBox(height: 6),
                                            Text('Sentuh merevisi ✎', style: TextStyle(color: subtitleColor.withOpacity(0.5), fontSize: 10, fontStyle: FontStyle.italic)) 
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        ),
                        // ===== JEDA PANJANG (Ruang napas) DIBAYANGI NAV BAR O&C ======== //
                        const SizedBox(height: 120), 
                      ]
                    )
                  )
                )
              ]
            )
          )
        ],
      ),
    );
  }

  // == TULISAN DI KARTU SALDO (Minimalist) ==
  Widget _buildStatMini(String label, int amount, Color clr, Color greyTxt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, // Tengah semua layaknya App premium iOS
      children: [
        Text(label, style: TextStyle(color: greyTxt, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(currencyFormatter.format(amount), style: TextStyle(color: clr, fontSize: 17, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // == UX GANTI THEME TANPA BINGKAI KASAR & MENDOBRAK MATA == 
  void _showThemePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      elevation: 0,
      backgroundColor: Colors.transparent, // Mengawang seperti Kaca (Melayang Indah)
      builder: (ctx) {
        return Consumer(builder: (context, refSheetWatch, _) {
          final tState = refSheetWatch.watch(backgroundProvider);
          final bool dLatar = tState.bgIndex == 1; 

          return Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
               color: dLatar ? const Color(0xFF1E293B) : Colors.white, // Biru Tua Kalam Slate Jika malam
               borderRadius: BorderRadius.circular(36) // Lekukan super imut khas Flat UX 
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(height: 4, width: 40, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))), // Garis Pilled Tarik Halus
                const SizedBox(height: 24),
                
                Text("Cahaya & Cerita Kita 🎨", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: dLatar ? Colors.white : const Color(0xFF334155))),
                const SizedBox(height: 24), 
                
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: customBackgrounds.length + 1, 
                    itemBuilder: (c, idx) {
                      
                      // INDEKS GAMBAR KAMERA GALERI KELUARGA
                      if(idx == 6){ 
                        return GestureDetector(
                          onTap: () async {
                             final XFile? img = await ImagePicker().pickImage(source: ImageSource.gallery);
                             if (img != null) refSheetWatch.read(backgroundProvider.notifier).ubahLatarLengkap(6, imagePath: img.path);
                          },
                          child: Container(
                            width: 60, margin: const EdgeInsets.only(right: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9), // Abu halus khas i-Os / Web  Flat  
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.add_photo_alternate_rounded, color: Color(0xFF94A3B8), size: 30), // Ikon abu-abu halus (gak nabrak warnanya biru jelek kayak tadi) 
                          ),
                        );
                      }
                      
                      // TEMA GRADIENT/ WARNA DASAR : 
                      return GestureDetector(
                        onTap: () => refSheetWatch.read(backgroundProvider.notifier).ubahLatarLengkap(idx),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: tState.bgIndex == idx ? 68 : 60, // Kalau Dipilih Sedikit Membesar Ukurannya  !!! 
                          margin: const EdgeInsets.only(right: 16),
                          decoration: customBackgrounds[idx].copyWith(
                             borderRadius: BorderRadius.circular(tState.bgIndex == idx ? 24 : 16), // Jika Ttunjuk berubah Builat
                          ),
                          // Flat check indicator icon 
                          child: Center(child: tState.bgIndex == idx ? const Icon(Icons.favorite_rounded, color: Colors.white70, size: 28) : null),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),
                Text("Redupan/Filter Bayangan Kenangan Kita:", style: TextStyle(color: dLatar ? Colors.white70 : Colors.blueGrey[400], fontSize: 11, fontWeight: FontWeight.bold)),
                SliderTheme(
                   // Kostumisasi Biar bar Slide Redupan Gak biru tajam (Jauh lebih Elegan )
                   data: SliderTheme.of(context).copyWith(thumbColor: const Color(0xFFF43F5E), activeTrackColor: const Color(0xFFFDA4AF), inactiveTrackColor: const Color(0xFFF1F5F9)),
                   child: Slider(
                      value: tState.bgOpacity, min: 0.1, max: 1.0, 
                      onChanged: (double val) => refSheetWatch.read(backgroundProvider.notifier).ubahLatarLengkap(tState.bgIndex, opacity: val),
                   )
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        });
      }
    );
  }
}