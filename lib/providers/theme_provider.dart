import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPrefsProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());

class ThemeState {
  final int bgIndex;         
  final String? customImage; 
  final double bgOpacity;    
  ThemeState({required this.bgIndex, this.customImage, required this.bgOpacity});
}

class ThemeNotifier extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    final prefs = ref.watch(sharedPrefsProvider);
    return ThemeState(
      bgIndex: prefs.getInt('o_and_c_bg') ?? 0,
      customImage: prefs.getString('o_and_c_img'),
      bgOpacity: prefs.getDouble('o_and_c_opac') ?? 0.8, 
    );
  }

  void ubahLatarLengkap(int index, {String? imagePath, double? opacity}) {
    final newOpac = opacity ?? state.bgOpacity;
    state = ThemeState(bgIndex: index, customImage: imagePath ?? state.customImage, bgOpacity: newOpac);
    
    final p = ref.read(sharedPrefsProvider);
    p.setInt('o_and_c_bg', index);
    p.setDouble('o_and_c_opac', newOpac);
    if (imagePath != null) p.setString('o_and_c_img', imagePath);
  }
}

final backgroundProvider = NotifierProvider<ThemeNotifier, ThemeState>(ThemeNotifier.new);