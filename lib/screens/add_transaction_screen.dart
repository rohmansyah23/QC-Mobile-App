import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/database_provider.dart';
import '../providers/theme_provider.dart';
import '../models/transaction.dart';
import '../models/app_user.dart';
import '../models/category_model.dart';
import 'dashboard_screen.dart' show customBackgrounds;

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final int value = int.parse(newValue.text.replaceAll(RegExp(r'[^0-9]'), ''));
    final formatted = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(value);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class AddTransactionScreen extends ConsumerStatefulWidget {
  final TransactionModel? tx_UntukDiEdit; 
  const AddTransactionScreen({super.key, this.tx_UntukDiEdit});
  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  String _selectedType = 'income'; 
  String? _selectedContributorId;
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  late TextEditingController _amountController; 
  late TextEditingController _descController;
  bool _isSubmitting = false; 

  @override
  void initState() {
    super.initState();
    final editData = widget.tx_UntukDiEdit;
    
    if (editData != null) {
      _selectedType = editData.type;
      _selectedContributorId = editData.contributor?.id;
      _selectedCategoryId = editData.category?.id;
      _selectedDate = editData.date;
      final formatUang = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(editData.amount);
      _amountController = TextEditingController(text: formatUang);
      _descController = TextEditingController(text: editData.description ?? "");
    } else {
      _amountController = TextEditingController();
      _descController = TextEditingController();
    }
  }

  IconData _getIconData(String? iconString) {
    switch (iconString) {
      case 'restaurant': return Icons.fastfood_rounded;
      case 'directions_car': return Icons.directions_car_rounded;
      case 'receipt': return Icons.shopping_bag_rounded;
      case 'medical_services': return Icons.medical_services_rounded;
      default: return Icons.widgets_rounded;
    }
  }

  // === FITUR BARU : MEMBACA KARAKTER TULISAN Cewe Cowok (Avatar Pintar O&C) ===
  IconData _getUserIconData(String? fullName) {
    if (fullName == null) return Icons.face_rounded;
    String name = fullName.toLowerCase();
    
    if (name.contains('oman') && name.contains('ceca') || name.contains('joint')) {
       return Icons.diversity_1_rounded; // Logo Dua Manusia Berkumpul (Orang & Love / Cincin)
    }
    if (name.contains('ceca')) {
       return Icons.face_3_rounded; // Muka Berambut (Perempuan Ceca)
    }
    if (name.contains('oman')) {
       return Icons.face_rounded; // Wajah Laki Laki Umum (Oman)
    }
    return Icons.emoji_people_rounded;
  }

  Future<void> _submitData() async {
    if (_amountController.text.isEmpty || _selectedContributorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Hai O&C, belum ditulis nih nominal uang & Pelakunya 💕', style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFFF43F5E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), behavior: SnackBarBehavior.floating));
      return;
    }
    
    if (_selectedType == 'expense' && _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Pilih tujuannya dulu yuk, dipakai buat apa uang ini? 😊', style: TextStyle(color: Colors.black87)), backgroundColor: const Color(0xFFFCD34D), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), behavior: SnackBarBehavior.floating));
      return;
    }

    setState(() => _isSubmitting = true); 

    try {
      final rawAmount = int.parse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), ''));
      final record = {
        'transaction_type': _selectedType,
        'contributor_id': _selectedContributorId,
        'category_id': _selectedType == 'expense' ? _selectedCategoryId : null,
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'amount': rawAmount,
        'description': _descController.text.isNotEmpty ? _descController.text : null,
      };

      if (widget.tx_UntukDiEdit != null) {
        await supabase.from('transactions').update(record).eq('id', widget.tx_UntukDiEdit!.id);
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Catatan dikemas rapi kembali! ✎'), backgroundColor: const Color(0xFF94A3B8), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))));
      } else {
        await supabase.from('transactions').insert(record);
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Kegiatan kita berhasil disisipkan! ✨'), backgroundColor: const Color(0xFF10B981), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))));
      }

      ref.invalidate(transactionsProvider);
      ref.invalidate(analyticCalculationProvider);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _isSubmitting = false); 
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ops, Server terputus: $e', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersState = ref.watch(usersProvider);
    final categoriesState = ref.watch(categoriesProvider);
    
    final bgIndex = ref.watch(backgroundProvider).bgIndex;
    final bool isDarkBackground = (bgIndex == 1 || bgIndex == 2 || bgIndex == 3 || bgIndex == 5 || bgIndex == 6);
    final amanBackgroundLayarInput = (bgIndex == 6) ? customBackgrounds[0] : customBackgrounds[bgIndex]; 

    // === SOLUSI PEWARNAAN LEBIH TAJAM AGAR GAK PUDAR ======
    final Color themeColorStr = isDarkBackground ? Colors.white : const Color(0xFF1E293B); 
    final Color solidLabelColor = isDarkBackground ? Colors.white70 : const Color(0xFF64748B);

    final clrTabungan = isDarkBackground ? Colors.tealAccent[400]! : const Color(0xFF10B981); 
    final clrKeluaran = isDarkBackground ? Colors.pinkAccent[200]! : const Color(0xFFF43F5E);
    final valColor    = _selectedType == 'income' ? clrTabungan : clrKeluaran;

    return Scaffold(
      extendBodyBehindAppBar: true, 
      backgroundColor: Colors.white,
      
      appBar: AppBar(
        iconTheme: IconThemeData(color: themeColorStr),
        centerTitle: true,
        title: Text(widget.tx_UntukDiEdit != null ? "Histori Lama ✎" : 'Catat Pemasukan & Pengeluaran', style: TextStyle(fontFamily: 'serif', fontSize: 18, fontWeight: FontWeight.w800, color: themeColorStr)),
        backgroundColor: Colors.transparent, elevation: 0,
      ),
      
      body: Container(
        height: double.infinity, 
        decoration: amanBackgroundLayarInput, 
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8), 
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              decoration: BoxDecoration(
                 // Opacity ditambahi jadi Solid biar GAK NGABUR/faded dipantulan pink & abu.
                 color: isDarkBackground ? const Color(0xFF0F172A).withOpacity(0.65) : Colors.white.withOpacity(0.97), 
                 borderRadius: BorderRadius.circular(36), 
                 border: Border.all(color: isDarkBackground ? Colors.white24 : const Color(0xFFF1F5F9), width: 1.5)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  
                  // ====== 1. MENU SWITCH HALUS TAPI TAJAM KONTRAST NYA ======
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() { _selectedType = 'income'; _selectedCategoryId = null; }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300), curve: Curves.easeOutCirc,
                            padding: const EdgeInsets.symmetric(vertical: 16), 
                            decoration: BoxDecoration(
                               color: _selectedType == 'income' ? clrTabungan : (isDarkBackground ? Colors.white12 : const Color(0xFFF8FAFC)), 
                               borderRadius: BorderRadius.circular(20), 
                            ),
                            child: Row(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                  Icon(Icons.add_home_rounded, color: _selectedType == 'income' ? Colors.white : (isDarkBackground ? Colors.white54 : Colors.grey[500]), size: 18),
                                  const SizedBox(width: 8),
                                  Flexible(child: Text("Pemasukan", overflow: TextOverflow.ellipsis, maxLines:1, style: TextStyle(color: _selectedType == 'income' ? Colors.white : solidLabelColor, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.3))),
                               ]
                            )
                          ),
                        ),
                      ),
                      const SizedBox(width: 14), 
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedType = 'expense'),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300), curve: Curves.easeOutCirc,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                               color: _selectedType == 'expense' ? clrKeluaran : (isDarkBackground ? Colors.white12 : const Color(0xFFF8FAFC)), 
                               borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                  Icon(Icons.directions_run_rounded, color: _selectedType == 'expense' ? Colors.white : (isDarkBackground ? Colors.white54 : Colors.grey[500]), size: 18), 
                                  const SizedBox(width: 8),
                                  Flexible(child: Text("Pengeluaran", overflow: TextOverflow.ellipsis, maxLines:1, style: TextStyle(color: _selectedType == 'expense' ? Colors.white : solidLabelColor, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.3))),
                               ]
                            )
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 36),
                  
                  // ====== 2. ANGKA ======
                  Center(child: Text("Masukan Nominal", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: solidLabelColor))),
                  TextField(
                    controller: _amountController, keyboardType: TextInputType.number, inputFormatters: [CurrencyInputFormatter()], 
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.w300, color: valColor),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                       border: InputBorder.none, hintText: 'Rp 0', hintStyle: TextStyle(fontSize: 48, fontWeight: FontWeight.w300, color: isDarkBackground ? Colors.white24 : Colors.grey[300])
                    ),
                  ),
                  Divider(color: isDarkBackground ? Colors.white12 : Colors.grey[200], thickness: 2, endIndent: 20, indent: 20),
                  
                  const SizedBox(height: 32),
          
                  // ====== 3. USER ======
                  Text("Dari / Pihak Penyerah:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: solidLabelColor)),
                  const SizedBox(height: 12),

                  usersState.when(
                    loading: () => const Center(child: LinearProgressIndicator()),
                    error: (err, st) => const Text('Jaringan Cacat ☔'),
                    data: (users) {
                      AppUser? orangKepilih = users.cast<AppUser?>().firstWhere((e) => e?.id == _selectedContributorId, orElse: () => null);

                      return InkWell(
                        onTap: () => _bukaModalMenuPemilihan<String>(
                            judulMuda: "Pilih kontak atau pihak terkait ✨",
                            listIconPilihan: users.map((u) => u.id).toList(), 
                            listLabelPilihan: users.map((u) => u.fullName).toList(),
                            // LOGIC SAKTI PEMBERIAN ICON BERBEDA DISUNTIKKAN KE LIST POPUP NYA!!: 
                            iconsMaterialWujudLokalLayarPecarian: users.map((u) => _getUserIconData(u.fullName)).toList(), 
                            onSelected: (dipilihVal) => setState(() => _selectedContributorId = dipilihVal)
                        ),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          decoration: BoxDecoration(
                             color: isDarkBackground ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9), // Background lebih padat kontrasnya !! 
                             borderRadius: BorderRadius.circular(24), 
                             border: Border.all(color: isDarkBackground ? Colors.white24 : const Color(0xFFCBD5E1))
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                               Expanded(
                                  child: Row(
                                     children: [
                                       Icon(orangKepilih != null ? _getUserIconData(orangKepilih.fullName) : Icons.touch_app_rounded, color: orangKepilih != null ? valColor : solidLabelColor, size: 22), 
                                       const SizedBox(width: 14),
                                       Flexible(child: Text(orangKepilih?.fullName ?? "Tunjuk tokoh utama...", overflow: TextOverflow.ellipsis, maxLines:1, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: orangKepilih != null ? themeColorStr : solidLabelColor))),
                                     ],
                                  ),
                               ),
                               Icon(Icons.unfold_more_rounded, color: solidLabelColor, size: 18), 
                            ]
                          ),
                        ),
                      );
                    },
                  ),
          
                  // ====== 4. PEMECAH BOTTOM OVERFLOW (PENGHAPUSAN ANIMATEDCROSSFADE KAKU DIGANTI BIASA SAJA) ======
                  if (_selectedType == 'expense') ...[
                     const SizedBox(height: 24),
                     Text("Dialokasikan pengeluaran untuk apa:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: solidLabelColor)),
                     const SizedBox(height: 12),

                     categoriesState.when(
                       loading: () => const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: CircularProgressIndicator()),
                       error: (err, st) => const Text('Kehilangan buku daftar catatan 🍂'),
                       data: (categories) {
                          CategoryModel? catDipilih = categories.cast<CategoryModel?>().firstWhere((e) => e?.id == _selectedCategoryId, orElse: () => null);

                         return InkWell(
                           onTap: () => _bukaModalMenuPemilihan<String>(
                               judulMuda: "Menjajankannya untuk apa kita?",
                               listIconPilihan: categories.map((c) => c.id).toList(), 
                               listLabelPilihan: categories.map((c) => c.name).toList(),
                               iconsMaterialWujudLokalLayarPecarian: categories.map((c) => _getIconData(c.iconString)).toList(), 
                               onSelected: (valx) => setState(() => _selectedCategoryId = valx)
                           ),
                           borderRadius: BorderRadius.circular(24),
                           child: Container(
                             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                             decoration: BoxDecoration(color: isDarkBackground ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(24), border: Border.all(color: isDarkBackground ? Colors.white24 : const Color(0xFFCBD5E1))),
                             child: Row(
                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                               children: [
                                 Expanded(
                                    child: Row(
                                       children: [
                                          Icon(catDipilih == null ? Icons.flag_circle_rounded : _getIconData(catDipilih.iconString), color: catDipilih != null ? clrKeluaran : solidLabelColor, size: 22), const SizedBox(width: 14),
                                          Flexible(child: Text(catDipilih?.name ?? "Berikan Kategori Pengeluaran..", overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: catDipilih != null ? themeColorStr : solidLabelColor))),
                                       ],
                                    )
                                 ),
                                 Icon(Icons.unfold_more_rounded, color: solidLabelColor, size: 18),
                               ]
                             ),
                           ),
                         );
                       },
                     ),
                  ],
                  // Akhir pemutus overflow ^
          
                  const SizedBox(height: 28),
          
                  // === TANGGALAN ===
                  Text("Waktu & Tanggal:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: solidLabelColor)),
                  const SizedBox(height: 12),
                  GestureDetector(
                     onTap: () async {
                         final DateTime? pc = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2023), lastDate: DateTime(2101), builder: (c, c2) => Theme(data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: valColor)), child: c2!));
                         if (pc != null) setState(() => _selectedDate = pc);
                     },
                     child: Container(
                       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                       decoration: BoxDecoration(color: isDarkBackground ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(24), border: Border.all(color: isDarkBackground ? Colors.white24 : const Color(0xFFCBD5E1))),
                       child: Row(
                          children: [
                             Icon(Icons.today_rounded, color: valColor.withOpacity(0.8), size: 22), const SizedBox(width: 14),
                             Text(DateFormat('EEEE, d MMM yyyy', 'id_ID').format(_selectedDate), style: TextStyle(color: themeColorStr, fontWeight: FontWeight.w600, fontSize: 14)),
                          ],
                       ),
                     ),
                  ),
                  
                  const SizedBox(height: 28),
          
                  // ====== CATATAN BEBAS MUNGIL =====
                  TextField(
                    controller: _descController, maxLength: 30, // Dipendekkin jd 30 doang menghindari nabrak
                    style: TextStyle(fontSize: 14, color: themeColorStr), cursorColor: valColor,
                    decoration: InputDecoration(
                      labelText: 'Keterangan Tambahan Jika Ada...',
                      labelStyle: TextStyle(color: solidLabelColor, fontSize: 12),
                      alignLabelWithHint: true, filled: true, 
                      fillColor: isDarkBackground ? Colors.white.withOpacity(0.08) : Colors.white, // Dibikin lebih timbul 
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: isDarkBackground ? Colors.white24 : const Color(0xFFCBD5E1), width: 1.0)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: isDarkBackground ? Colors.white24 : const Color(0xFFCBD5E1), width: 1.0)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: valColor, width: 2.0)),
                    ),
                  ),
          
                  const SizedBox(height: 40), 
          
                  // ========== TOMBOL TERATAS ANTI LEBEE (DI FIX LIMITNYA DI LAYAR SEMPIT) ============= //
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitData, 
                    style: ElevatedButton.styleFrom(
                      elevation: 0, 
                      backgroundColor: valColor,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24), // Aman Untuk layar kecil!
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26))
                    ),
                    child: _isSubmitting 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                             Icon(widget.tx_UntukDiEdit != null ? Icons.save_alt_rounded : Icons.mark_as_unread_rounded, color: Colors.white), const SizedBox(width: 8),
                             Flexible(
                               child: Text(widget.tx_UntukDiEdit != null 
                                   ? "TULIS REVISINYA ✎" 
                                   : "SIMPAN CATATAN INI  📖",  // Kata diperkecil sedikit Biar muat dilayar mini!! (Memecah overflow) 
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.3) // Huruf & Leterspaeing nya juga disusutn 
                                ),
                             ),
                          ],
                        )
                  ),
                  const SizedBox(height: 24), // Sela Papan Keyboard Paling bawah aman . 
                ],
              ),
            ),
          ),
        )
      )
    );
  }

  // === POPUP BUM! SANGAT CANTIK ==== //
  // ============== POPUP MENU BAWAH BEBAS OVERFLOW =====================//
  void _bukaModalMenuPemilihan<T>({ required String judulMuda, required List<T> listIconPilihan, required List<String> listLabelPilihan, List<IconData>? iconsMaterialWujudLokalLayarPecarian, required Function(T) onSelected}) {
      
      final bool dKondsiGelap = ref.read(backgroundProvider).bgIndex == 1; 

      showModalBottomSheet(
          context: context,
          isScrollControlled: true, // <--- OBAT PERTAMA (Bisa melebar dinamis menyesuaikan Layar Hape yg Sempit)
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
          backgroundColor: dKondsiGelap ? const Color(0xFF0F172A) : Colors.white,
          builder: (bc) {
            return SafeArea(
              // OBAT KEDUA ANTI TABRAKAN! Menyelimuti isi daftar jadi bisa di-scroll jari:
              child: SingleChildScrollView( 
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                     mainAxisSize: MainAxisSize.min, 
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                         Center(child: Container(width: 48, height: 5, decoration: BoxDecoration(color: dKondsiGelap ? Colors.white24 : Colors.grey[200], borderRadius: BorderRadius.circular(10)))),
                         const SizedBox(height: 24),

                         Padding(
                           padding: const EdgeInsets.symmetric(horizontal: 24),
                           child: Text(judulMuda, style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold, fontSize: 16, color: dKondsiGelap ? Colors.white : Colors.black87)),
                         ),
                         const SizedBox(height: 12),
                         Divider(color: dKondsiGelap ? Colors.white12 : Colors.grey[100], thickness: 2),
                         const SizedBox(height: 12),

                         // === LOGIKA GENERATE LIST MUTER === //
                         for(int n=0; n<listIconPilihan.length; n++)
                           ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 28),
                              leading: Container(
                                 padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: dKondsiGelap ? Colors.white12 : const Color(0xFFF1F5F9), shape: BoxShape.circle),
                                 child: iconsMaterialWujudLokalLayarPecarian != null ? Icon(iconsMaterialWujudLokalLayarPecarian[n], color: const Color(0xFFF43F5E), size: 22) : const Icon(Icons.stars_rounded, color: Color(0xFF10B981), size: 20)
                              ),
                              title: Text(listLabelPilihan[n], style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: dKondsiGelap ? Colors.white : const Color(0xFF334155))),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              onTap: (){
                                 onSelected(listIconPilihan[n]);
                                 Navigator.pop(context); 
                              },
                           ),
                          const SizedBox(height: 16)
                     ],
                  )
                ),
              ),
            );
          }
      );
  }
} // (Batas Penutup paling Akhir dari Keseluruhan isi class App kita ini)