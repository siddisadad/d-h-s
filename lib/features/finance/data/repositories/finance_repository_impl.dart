import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/database/local_database.dart';
import '../../../../core/services/firebase_database_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/config/app_config.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/finance_repository.dart';
import '../datasources/finance_remote_data_source.dart';
import '../models/transaction_model.dart';
import '../models/cash_closing_model.dart';
import '../../domain/entities/cash_closing.dart';

class FinanceRepositoryImpl implements FinanceRepository {
  final FinanceRemoteDataSource remoteDataSource;
  final LocalDatabase localDatabase;
  final FirebaseDatabaseService firebaseDb;

  FinanceRepositoryImpl({
    required this.remoteDataSource,
    required this.localDatabase,
    required this.firebaseDb,
  });

  @override
  Future<Result<List<TransactionModel>>> getTransactions() async {
    try {
      if (kIsWeb) {
        if (AppConfig.useFirebase) {
          final snapshot = await firebaseDb.getData('finance');
          if (!snapshot.exists || snapshot.value == null) return Result.success([]);
          
          final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
          final List<TransactionModel> transactions = [];
          data.forEach((key, value) {
            transactions.add(TransactionModel.fromJson(Map<String, dynamic>.from(value as Map)));
          });
          return Result.success(transactions);
          @override
  Future<Result<bool>> saveCashClosing(CashClosing closing) async {
    try {
      final model = CashClosingModel(
        id: closing.id,
        date: closing.date,
        openingBalance: closing.openingBalance,
        totalCashSales: closing.totalCashSales,
        totalCashExpenses: closing.totalCashExpenses,
        physicalCashCount: closing.physicalCashCount,
        notes: closing.notes,
        performedBy: closing.performedBy,
        lastUpdated: DateTime.now().millisecondsSinceEpoch,
      );

      if (!kIsWeb) {
        await localDatabase.closing.saveClosing(model.toJson());
      }

      if (AppConfig.useFirebase) {
        await firebaseDb.setData('closings/${closing.id}', model.toJson());
      }

      return Result.success(true);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<CashClosing?>> getLastClosing() async {
    try {
      if (kIsWeb) return Result.success(null);
      final map = await localDatabase.closing.getLastClosing();
      if (map == null) return Result.success(null);
      return Result.success(CashClosingModel.fromJson(map));
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }
}
        final transactions = await remoteDataSource.getTransactions();
        return Result.success(transactions);
        @override
  Future<Result<bool>> saveCashClosing(CashClosing closing) async {
    try {
      final model = CashClosingModel(
        id: closing.id,
        date: closing.date,
        openingBalance: closing.openingBalance,
        totalCashSales: closing.totalCashSales,
        totalCashExpenses: closing.totalCashExpenses,
        physicalCashCount: closing.physicalCashCount,
        notes: closing.notes,
        performedBy: closing.performedBy,
        lastUpdated: DateTime.now().millisecondsSinceEpoch,
      );

      if (!kIsWeb) {
        await localDatabase.closing.saveClosing(model.toJson());
      }

      if (AppConfig.useFirebase) {
        await firebaseDb.setData('closings/${closing.id}', model.toJson());
      }

      return Result.success(true);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<CashClosing?>> getLastClosing() async {
    try {
      if (kIsWeb) return Result.success(null);
      final map = await localDatabase.closing.getLastClosing();
      if (map == null) return Result.success(null);
      return Result.success(CashClosingModel.fromJson(map));
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }
}

      // 1. Background refresh from Firebase if enabled
      if (AppConfig.useFirebase) {
        _refreshFinanceFromFirebase();
        @override
  Future<Result<bool>> saveCashClosing(CashClosing closing) async {
    try {
      final model = CashClosingModel(
        id: closing.id,
        date: closing.date,
        openingBalance: closing.openingBalance,
        totalCashSales: closing.totalCashSales,
        totalCashExpenses: closing.totalCashExpenses,
        physicalCashCount: closing.physicalCashCount,
        notes: closing.notes,
        performedBy: closing.performedBy,
        lastUpdated: DateTime.now().millisecondsSinceEpoch,
      );

      if (!kIsWeb) {
        await localDatabase.closing.saveClosing(model.toJson());
      }

      if (AppConfig.useFirebase) {
        await firebaseDb.setData('closings/${closing.id}', model.toJson());
      }

      return Result.success(true);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<CashClosing?>> getLastClosing() async {
    try {
      if (kIsWeb) return Result.success(null);
      final map = await localDatabase.closing.getLastClosing();
      if (map == null) return Result.success(null);
      return Result.success(CashClosingModel.fromJson(map));
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }
}

      // 2. Return from Local DB
      final maps = await localDatabase.getFinanceEntries();
      final transactions = maps.map((m) => TransactionModel(
        id: m['id'],
        title: m['title'],
        category: m['category'],
        amount: (m['amount'] as num).toDouble(),
        date: DateTime.fromMillisecondsSinceEpoch(m['date']),
        paymentMode: m['paymentMode'],
      )).toList();

      if (transactions.isEmpty) {
        final remote = await remoteDataSource.getTransactions();
        return Result.success(remote);
        @override
  Future<Result<bool>> saveCashClosing(CashClosing closing) async {
    try {
      final model = CashClosingModel(
        id: closing.id,
        date: closing.date,
        openingBalance: closing.openingBalance,
        totalCashSales: closing.totalCashSales,
        totalCashExpenses: closing.totalCashExpenses,
        physicalCashCount: closing.physicalCashCount,
        notes: closing.notes,
        performedBy: closing.performedBy,
        lastUpdated: DateTime.now().millisecondsSinceEpoch,
      );

      if (!kIsWeb) {
        await localDatabase.closing.saveClosing(model.toJson());
      }

      if (AppConfig.useFirebase) {
        await firebaseDb.setData('closings/${closing.id}', model.toJson());
      }

      return Result.success(true);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<CashClosing?>> getLastClosing() async {
    try {
      if (kIsWeb) return Result.success(null);
      final map = await localDatabase.closing.getLastClosing();
      if (map == null) return Result.success(null);
      return Result.success(CashClosingModel.fromJson(map));
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }
}

      return Result.success(transactions);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
      @override
  Future<Result<bool>> saveCashClosing(CashClosing closing) async {
    try {
      final model = CashClosingModel(
        id: closing.id,
        date: closing.date,
        openingBalance: closing.openingBalance,
        totalCashSales: closing.totalCashSales,
        totalCashExpenses: closing.totalCashExpenses,
        physicalCashCount: closing.physicalCashCount,
        notes: closing.notes,
        performedBy: closing.performedBy,
        lastUpdated: DateTime.now().millisecondsSinceEpoch,
      );

      if (!kIsWeb) {
        await localDatabase.closing.saveClosing(model.toJson());
      }

      if (AppConfig.useFirebase) {
        await firebaseDb.setData('closings/${closing.id}', model.toJson());
      }

      return Result.success(true);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<CashClosing?>> getLastClosing() async {
    try {
      if (kIsWeb) return Result.success(null);
      final map = await localDatabase.closing.getLastClosing();
      if (map == null) return Result.success(null);
      return Result.success(CashClosingModel.fromJson(map));
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }
}
    @override
  Future<Result<bool>> saveCashClosing(CashClosing closing) async {
    try {
      final model = CashClosingModel(
        id: closing.id,
        date: closing.date,
        openingBalance: closing.openingBalance,
        totalCashSales: closing.totalCashSales,
        totalCashExpenses: closing.totalCashExpenses,
        physicalCashCount: closing.physicalCashCount,
        notes: closing.notes,
        performedBy: closing.performedBy,
        lastUpdated: DateTime.now().millisecondsSinceEpoch,
      );

      if (!kIsWeb) {
        await localDatabase.closing.saveClosing(model.toJson());
      }

      if (AppConfig.useFirebase) {
        await firebaseDb.setData('closings/${closing.id}', model.toJson());
      }

      return Result.success(true);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<CashClosing?>> getLastClosing() async {
    try {
      if (kIsWeb) return Result.success(null);
      final map = await localDatabase.closing.getLastClosing();
      if (map == null) return Result.success(null);
      return Result.success(CashClosingModel.fromJson(map));
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }
}

  @override
  Future<Result<bool>> createTransaction(TransactionModel transaction) async {
    try {
      if (!kIsWeb) {
        // 1. Save locally
        await localDatabase.saveFinanceEntry({
          'title': transaction.title,
          'category': transaction.category,
          'amount': transaction.amount,
          'date': transaction.date.millisecondsSinceEpoch,
          'paymentMode': transaction.paymentMode,
        });
        @override
  Future<Result<bool>> saveCashClosing(CashClosing closing) async {
    try {
      final model = CashClosingModel(
        id: closing.id,
        date: closing.date,
        openingBalance: closing.openingBalance,
        totalCashSales: closing.totalCashSales,
        totalCashExpenses: closing.totalCashExpenses,
        physicalCashCount: closing.physicalCashCount,
        notes: closing.notes,
        performedBy: closing.performedBy,
        lastUpdated: DateTime.now().millisecondsSinceEpoch,
      );

      if (!kIsWeb) {
        await localDatabase.closing.saveClosing(model.toJson());
      }

      if (AppConfig.useFirebase) {
        await firebaseDb.setData('closings/${closing.id}', model.toJson());
      }

      return Result.success(true);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<CashClosing?>> getLastClosing() async {
    try {
      if (kIsWeb) return Result.success(null);
      final map = await localDatabase.closing.getLastClosing();
      if (map == null) return Result.success(null);
      return Result.success(CashClosingModel.fromJson(map));
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }
}

      // 2. Push to Firebase if enabled
      if (AppConfig.useFirebase) {
        try {
          await firebaseDb.pushData('finance', transaction.toJson());
        } catch (e) {
          Log.w('Firebase finance sync failed: $e', name: 'Finance');
          @override
  Future<Result<bool>> saveCashClosing(CashClosing closing) async {
    try {
      final model = CashClosingModel(
        id: closing.id,
        date: closing.date,
        openingBalance: closing.openingBalance,
        totalCashSales: closing.totalCashSales,
        totalCashExpenses: closing.totalCashExpenses,
        physicalCashCount: closing.physicalCashCount,
        notes: closing.notes,
        performedBy: closing.performedBy,
        lastUpdated: DateTime.now().millisecondsSinceEpoch,
      );

      if (!kIsWeb) {
        await localDatabase.closing.saveClosing(model.toJson());
      }

      if (AppConfig.useFirebase) {
        await firebaseDb.setData('closings/${closing.id}', model.toJson());
      }

      return Result.success(true);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<CashClosing?>> getLastClosing() async {
    try {
      if (kIsWeb) return Result.success(null);
      final map = await localDatabase.closing.getLastClosing();
      if (map == null) return Result.success(null);
      return Result.success(CashClosingModel.fromJson(map));
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }
}
        @override
  Future<Result<bool>> saveCashClosing(CashClosing closing) async {
    try {
      final model = CashClosingModel(
        id: closing.id,
        date: closing.date,
        openingBalance: closing.openingBalance,
        totalCashSales: closing.totalCashSales,
        totalCashExpenses: closing.totalCashExpenses,
        physicalCashCount: closing.physicalCashCount,
        notes: closing.notes,
        performedBy: closing.performedBy,
        lastUpdated: DateTime.now().millisecondsSinceEpoch,
      );

      if (!kIsWeb) {
        await localDatabase.closing.saveClosing(model.toJson());
      }

      if (AppConfig.useFirebase) {
        await firebaseDb.setData('closings/${closing.id}', model.toJson());
      }

      return Result.success(true);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<CashClosing?>> getLastClosing() async {
    try {
      if (kIsWeb) return Result.success(null);
      final map = await localDatabase.closing.getLastClosing();
      if (map == null) return Result.success(null);
      return Result.success(CashClosingModel.fromJson(map));
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }
}

      // 3. Remote Data Source
      final success = await remoteDataSource.createTransaction(transaction);
      return Result.success(success);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
      @override
  Future<Result<bool>> saveCashClosing(CashClosing closing) async {
    try {
      final model = CashClosingModel(
        id: closing.id,
        date: closing.date,
        openingBalance: closing.openingBalance,
        totalCashSales: closing.totalCashSales,
        totalCashExpenses: closing.totalCashExpenses,
        physicalCashCount: closing.physicalCashCount,
        notes: closing.notes,
        performedBy: closing.performedBy,
        lastUpdated: DateTime.now().millisecondsSinceEpoch,
      );

      if (!kIsWeb) {
        await localDatabase.closing.saveClosing(model.toJson());
      }

      if (AppConfig.useFirebase) {
        await firebaseDb.setData('closings/${closing.id}', model.toJson());
      }

      return Result.success(true);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<CashClosing?>> getLastClosing() async {
    try {
      if (kIsWeb) return Result.success(null);
      final map = await localDatabase.closing.getLastClosing();
      if (map == null) return Result.success(null);
      return Result.success(CashClosingModel.fromJson(map));
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }
}
    @override
  Future<Result<bool>> saveCashClosing(CashClosing closing) async {
    try {
      final model = CashClosingModel(
        id: closing.id,
        date: closing.date,
        openingBalance: closing.openingBalance,
        totalCashSales: closing.totalCashSales,
        totalCashExpenses: closing.totalCashExpenses,
        physicalCashCount: closing.physicalCashCount,
        notes: closing.notes,
        performedBy: closing.performedBy,
        lastUpdated: DateTime.now().millisecondsSinceEpoch,
      );

      if (!kIsWeb) {
        await localDatabase.closing.saveClosing(model.toJson());
      }

      if (AppConfig.useFirebase) {
        await firebaseDb.setData('closings/${closing.id}', model.toJson());
      }

      return Result.success(true);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<CashClosing?>> getLastClosing() async {
    try {
      if (kIsWeb) return Result.success(null);
      final map = await localDatabase.closing.getLastClosing();
      if (map == null) return Result.success(null);
      return Result.success(CashClosingModel.fromJson(map));
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }
}

  Future<void> _refreshFinanceFromFirebase() async {
    try {
      final snapshot = await firebaseDb.getData('finance');
      if (snapshot.exists && snapshot.value != null) {
        final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        for (var value in data.values) {
          final model = TransactionModel.fromJson(Map<String, dynamic>.from(value as Map));
          await localDatabase.saveFinanceEntry({
            'title': model.title,
            'category': model.category,
            'amount': model.amount,
            'date': model.date.millisecondsSinceEpoch,
            'paymentMode': model.paymentMode,
          });
          @override
  Future<Result<bool>> saveCashClosing(CashClosing closing) async {
    try {
      final model = CashClosingModel(
        id: closing.id,
        date: closing.date,
        openingBalance: closing.openingBalance,
        totalCashSales: closing.totalCashSales,
        totalCashExpenses: closing.totalCashExpenses,
        physicalCashCount: closing.physicalCashCount,
        notes: closing.notes,
        performedBy: closing.performedBy,
        lastUpdated: DateTime.now().millisecondsSinceEpoch,
      );

      if (!kIsWeb) {
        await localDatabase.closing.saveClosing(model.toJson());
      }

      if (AppConfig.useFirebase) {
        await firebaseDb.setData('closings/${closing.id}', model.toJson());
      }

      return Result.success(true);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<CashClosing?>> getLastClosing() async {
    try {
      if (kIsWeb) return Result.success(null);
      final map = await localDatabase.closing.getLastClosing();
      if (map == null) return Result.success(null);
      return Result.success(CashClosingModel.fromJson(map));
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }
}
        @override
  Future<Result<bool>> saveCashClosing(CashClosing closing) async {
    try {
      final model = CashClosingModel(
        id: closing.id,
        date: closing.date,
        openingBalance: closing.openingBalance,
        totalCashSales: closing.totalCashSales,
        totalCashExpenses: closing.totalCashExpenses,
        physicalCashCount: closing.physicalCashCount,
        notes: closing.notes,
        performedBy: closing.performedBy,
        lastUpdated: DateTime.now().millisecondsSinceEpoch,
      );

      if (!kIsWeb) {
        await localDatabase.closing.saveClosing(model.toJson());
      }

      if (AppConfig.useFirebase) {
        await firebaseDb.setData('closings/${closing.id}', model.toJson());
      }

      return Result.success(true);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<CashClosing?>> getLastClosing() async {
    try {
      if (kIsWeb) return Result.success(null);
      final map = await localDatabase.closing.getLastClosing();
      if (map == null) return Result.success(null);
      return Result.success(CashClosingModel.fromJson(map));
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }
}
    } catch (e) {
      Log.w('Could not refresh finance from Firebase: $e', name: 'Finance');
      @override
  Future<Result<bool>> saveCashClosing(CashClosing closing) async {
    try {
      final model = CashClosingModel(
        id: closing.id,
        date: closing.date,
        openingBalance: closing.openingBalance,
        totalCashSales: closing.totalCashSales,
        totalCashExpenses: closing.totalCashExpenses,
        physicalCashCount: closing.physicalCashCount,
        notes: closing.notes,
        performedBy: closing.performedBy,
        lastUpdated: DateTime.now().millisecondsSinceEpoch,
      );

      if (!kIsWeb) {
        await localDatabase.closing.saveClosing(model.toJson());
      }

      if (AppConfig.useFirebase) {
        await firebaseDb.setData('closings/${closing.id}', model.toJson());
      }

      return Result.success(true);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<CashClosing?>> getLastClosing() async {
    try {
      if (kIsWeb) return Result.success(null);
      final map = await localDatabase.closing.getLastClosing();
      if (map == null) return Result.success(null);
      return Result.success(CashClosingModel.fromJson(map));
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }
}
    @override
  Future<Result<bool>> saveCashClosing(CashClosing closing) async {
    try {
      final model = CashClosingModel(
        id: closing.id,
        date: closing.date,
        openingBalance: closing.openingBalance,
        totalCashSales: closing.totalCashSales,
        totalCashExpenses: closing.totalCashExpenses,
        physicalCashCount: closing.physicalCashCount,
        notes: closing.notes,
        performedBy: closing.performedBy,
        lastUpdated: DateTime.now().millisecondsSinceEpoch,
      );

      if (!kIsWeb) {
        await localDatabase.closing.saveClosing(model.toJson());
      }

      if (AppConfig.useFirebase) {
        await firebaseDb.setData('closings/${closing.id}', model.toJson());
      }

      return Result.success(true);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<CashClosing?>> getLastClosing() async {
    try {
      if (kIsWeb) return Result.success(null);
      final map = await localDatabase.closing.getLastClosing();
      if (map == null) return Result.success(null);
      return Result.success(CashClosingModel.fromJson(map));
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }
}
  @override
  Future<Result<bool>> saveCashClosing(CashClosing closing) async {
    try {
      final model = CashClosingModel(
        id: closing.id,
        date: closing.date,
        openingBalance: closing.openingBalance,
        totalCashSales: closing.totalCashSales,
        totalCashExpenses: closing.totalCashExpenses,
        physicalCashCount: closing.physicalCashCount,
        notes: closing.notes,
        performedBy: closing.performedBy,
        lastUpdated: DateTime.now().millisecondsSinceEpoch,
      );

      if (!kIsWeb) {
        await localDatabase.closing.saveClosing(model.toJson());
      }

      if (AppConfig.useFirebase) {
        await firebaseDb.setData('closings/${closing.id}', model.toJson());
      }

      return Result.success(true);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<CashClosing?>> getLastClosing() async {
    try {
      if (kIsWeb) return Result.success(null);
      final map = await localDatabase.closing.getLastClosing();
      if (map == null) return Result.success(null);
      return Result.success(CashClosingModel.fromJson(map));
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }
}
