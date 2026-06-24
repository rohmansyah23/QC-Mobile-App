import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_user.dart';
import '../models/category_model.dart';
import '../models/transaction.dart';

final supabase = Supabase.instance.client;

final usersProvider = FutureProvider<List<AppUser>>((ref) async {
  final data = await supabase.from('users').select().order('created_at');
  return data.map((e) => AppUser.fromJson(e)).toList();
});

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final data = await supabase.from('categories').select().order('created_at');
  return data.map((e) => CategoryModel.fromJson(e)).toList();
});

class TransactionsNotifier extends AsyncNotifier<List<TransactionModel>> {
  @override
  Future<List<TransactionModel>> build() async {
    final response = await supabase.from('transactions').select('''
      *,
      users (*),
      categories (*)
    ''').order('date', ascending: false).order('created_at', ascending: false);

    return response.map((e) => TransactionModel.fromJson(e)).toList();
  }

  Future<void> hapusJejakKusam(String idTarget) async {
    final riwayatSaatIni = state.value ?? [];
    
    state = AsyncData(riwayatSaatIni.where((trx) => trx.id != idTarget).toList());

    try {
      await supabase.from('transactions').delete().eq('id', idTarget);
    } catch (e) {
      state = AsyncData(riwayatSaatIni); 
    }
  }
}

final transactionsProvider = AsyncNotifierProvider<TransactionsNotifier, List<TransactionModel>>(TransactionsNotifier.new);


class CalculationState {
  final int totalIncome;
  final int totalExpense;
  final int currentBalance; 
  CalculationState({required this.totalIncome, required this.totalExpense, required this.currentBalance});
}

final balanceCalculatorProvider = Provider<CalculationState>((ref) {
  final transactions = ref.watch(transactionsProvider).value ?? [];
  num income = 0;
  num expense = 0;

  for (var tx in transactions) {
    if (tx.type == 'income') {
      income += tx.amount;
    } else if (tx.type == 'expense') {
      expense += tx.amount;
    }
  }

  return CalculationState(
    totalIncome: income.toInt(),
    totalExpense: expense.toInt(),
    currentBalance: (income - expense).toInt(),
  );
});

enum TimeFilter { mingguan, bulanan, tahunan }

class ChartFilterNotifier extends Notifier<TimeFilter> {
  @override
  TimeFilter build() => TimeFilter.bulanan;
  void ubahFilterWaktu(TimeFilter fBaru) => state = fBaru;
}

final chartFilterProvider = NotifierProvider<ChartFilterNotifier, TimeFilter>(ChartFilterNotifier.new);

class AnalyticsChartData {
  final int incomeAmount;
  final int expenseAmount;
  final Map<String, int> expensesByCategory;
  AnalyticsChartData({required this.incomeAmount, required this.expenseAmount, required this.expensesByCategory});
}

final analyticCalculationProvider = Provider<AnalyticsChartData>((ref) {
  final transactions = ref.watch(transactionsProvider).value ?? [];
  final selectedFilter = ref.watch(chartFilterProvider);
  num filterIncome = 0;
  num filterExpense = 0;
  Map<String, int> catExpenseMap = {};
  
  final today = DateTime.now();

  for (var tx in transactions) {
    bool diHitungMasuk = false;
    final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
    
    if (selectedFilter == TimeFilter.mingguan) {
      final mingguanSih = DateTime(today.year, today.month, today.day).subtract(const Duration(days: 7));
      if (txDate.isAfter(mingguanSih)) diHitungMasuk = true;
    } else if (selectedFilter == TimeFilter.bulanan) {
      if (txDate.year == today.year && txDate.month == today.month) diHitungMasuk = true;
    } else if (selectedFilter == TimeFilter.tahunan) {
      if (txDate.year == today.year) diHitungMasuk = true;
    }
    
    if (diHitungMasuk) {
      if (tx.type == 'income') {
        filterIncome += tx.amount;
      } else {
        filterExpense += tx.amount;
        String nameCat = tx.category?.name ?? 'Masa Gitu?'; // Label datar/santai jk category kosong
        catExpenseMap[nameCat] = (catExpenseMap[nameCat] ?? 0) + tx.amount.toInt();
      }
    }
  }

  return AnalyticsChartData(
    incomeAmount: filterIncome.toInt(),
    expenseAmount: filterExpense.toInt(),
    expensesByCategory: catExpenseMap
  );
});

class TransactionAPI {
  static Future<void> deleteRecord(WidgetRef ref, String id) async {
      await ref.read(transactionsProvider.notifier).hapusJejakKusam(id); 
  }
}