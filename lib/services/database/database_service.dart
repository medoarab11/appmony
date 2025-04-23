import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../core/constants/app_constants.dart';
import '../../models/budget/budget_model.dart';
import '../../models/category/category_model.dart';
import '../../models/transaction/transaction_model.dart';
import '../../models/user/user_model.dart';
import '../../models/wallet/wallet_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, AppConstants.databaseName);
    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create User table
    await db.execute('''
      CREATE TABLE User (
        id TEXT PRIMARY KEY,
        name TEXT,
        email TEXT,
        createdAt INTEGER,
        lastLoginAt INTEGER,
        isPremium INTEGER DEFAULT 0,
        premiumExpiryDate INTEGER,
        languageCode TEXT,
        currencyCode TEXT,
        themeMode TEXT
      )
    ''');

    // Create Wallet table
    await db.execute('''
      CREATE TABLE Wallet (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        initialBalance REAL NOT NULL DEFAULT 0,
        balance REAL NOT NULL DEFAULT 0,
        totalIncome REAL NOT NULL DEFAULT 0,
        totalExpense REAL NOT NULL DEFAULT 0,
        description TEXT,
        currencyCode TEXT,
        color INTEGER,
        icon TEXT,
        isArchived INTEGER DEFAULT 0,
        createdAt INTEGER,
        updatedAt INTEGER
      )
    ''');

    // Create Category table
    await db.execute('''
      CREATE TABLE Category (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        color INTEGER,
        icon TEXT,
        isDefault INTEGER DEFAULT 0,
        isArchived INTEGER DEFAULT 0,
        createdAt INTEGER,
        updatedAt INTEGER
      )
    ''');

    // Create Transaction table
    await db.execute('''
      CREATE TABLE Transaction (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        categoryId TEXT,
        walletId TEXT NOT NULL,
        description TEXT,
        date INTEGER NOT NULL,
        isRecurring INTEGER DEFAULT 0,
        recurringType TEXT,
        recurringInterval INTEGER,
        createdAt INTEGER,
        updatedAt INTEGER,
        FOREIGN KEY (categoryId) REFERENCES Category (id),
        FOREIGN KEY (walletId) REFERENCES Wallet (id)
      )
    ''');

    // Create Budget table
    await db.execute('''
      CREATE TABLE Budget (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        amount REAL NOT NULL,
        spent REAL DEFAULT 0,
        categoryId TEXT,
        startDate INTEGER NOT NULL,
        endDate INTEGER NOT NULL,
        isRecurring INTEGER DEFAULT 0,
        recurringType TEXT,
        createdAt INTEGER,
        updatedAt INTEGER,
        FOREIGN KEY (categoryId) REFERENCES Category (id)
      )
    ''');

    // Insert default categories
    await _insertDefaultCategories(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // Expense categories
    final expenseCategories = [
      {'id': 'cat_food', 'name': 'Food & Dining', 'type': 'expense', 'color': 0xFFFF9500, 'icon': 'restaurant', 'isDefault': 1},
      {'id': 'cat_transport', 'name': 'Transportation', 'type': 'expense', 'color': 0xFF007AFF, 'icon': 'directions_car', 'isDefault': 1},
      {'id': 'cat_shopping', 'name': 'Shopping', 'type': 'expense', 'color': 0xFFFF2D55, 'icon': 'shopping_bag', 'isDefault': 1},
      {'id': 'cat_bills', 'name': 'Bills & Utilities', 'type': 'expense', 'color': 0xFF5AC8FA, 'icon': 'receipt', 'isDefault': 1},
      {'id': 'cat_entertainment', 'name': 'Entertainment', 'type': 'expense', 'color': 0xFFAF52DE, 'icon': 'movie', 'isDefault': 1},
      {'id': 'cat_health', 'name': 'Health & Medical', 'type': 'expense', 'color': 0xFF34C759, 'icon': 'medical_services', 'isDefault': 1},
      {'id': 'cat_housing', 'name': 'Housing', 'type': 'expense', 'color': 0xFF8E8E93, 'icon': 'home', 'isDefault': 1},
      {'id': 'cat_other_expense', 'name': 'Other Expenses', 'type': 'expense', 'color': 0xFFFF3B30, 'icon': 'more_horiz', 'isDefault': 1},
    ];
    
    // Income categories
    final incomeCategories = [
      {'id': 'cat_salary', 'name': 'Salary', 'type': 'income', 'color': 0xFF34C759, 'icon': 'work', 'isDefault': 1},
      {'id': 'cat_business', 'name': 'Business', 'type': 'income', 'color': 0xFF4E7CF6, 'icon': 'business', 'isDefault': 1},
      {'id': 'cat_investments', 'name': 'Investments', 'type': 'income', 'color': 0xFFFFCC00, 'icon': 'trending_up', 'isDefault': 1},
      {'id': 'cat_gifts', 'name': 'Gifts', 'type': 'income', 'color': 0xFFFF9500, 'icon': 'card_giftcard', 'isDefault': 1},
      {'id': 'cat_other_income', 'name': 'Other Income', 'type': 'income', 'color': 0xFF5AC8FA, 'icon': 'more_horiz', 'isDefault': 1},
    ];
    
    // Insert all categories
    for (var category in [...expenseCategories, ...incomeCategories]) {
      await db.insert('Category', {
        ...category,
        'createdAt': now,
        'updatedAt': now,
        'isArchived': 0,
      });
    }
  }

  Future<void> initialize() async {
    await database;
  }

  // User Methods
  Future<UserModel?> getUser() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('User');
    
    if (maps.isEmpty) {
      return null;
    }
    
    return UserModel.fromMap(maps.first);
  }

  Future<void> saveUser(UserModel user) async {
    final db = await database;
    await db.insert(
      'User',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateUser(UserModel user) async {
    final db = await database;
    await db.update(
      'User',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Wallet Methods
  Future<List<WalletModel>> getWallets({bool includeArchived = false}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Wallet',
      where: includeArchived ? null : 'isArchived = 0',
      orderBy: 'createdAt ASC',
    );
    
    return List.generate(maps.length, (i) {
      return WalletModel.fromMap(maps[i]);
    });
  }

  Future<WalletModel?> getWallet(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Wallet',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) {
      return null;
    }
    
    return WalletModel.fromMap(maps.first);
  }

  Future<void> saveWallet(WalletModel wallet) async {
    final db = await database;
    await db.insert(
      'Wallet',
      wallet.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<void> createWallet(WalletModel wallet) async {
    final db = await database;
    await db.insert(
      'Wallet',
      wallet.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateWallet(WalletModel wallet) async {
    final db = await database;
    await db.update(
      'Wallet',
      wallet.toMap(),
      where: 'id = ?',
      whereArgs: [wallet.id],
    );
  }
  
  Future<void> deleteWallet(String id) async {
    final db = await database;
    
    // Start a transaction
    await db.transaction((txn) async {
      // Delete all transactions associated with this wallet
      await txn.delete(
        'Transaction',
        where: 'walletId = ?',
        whereArgs: [id],
      );
      
      // Delete the wallet
      await txn.delete(
        'Wallet',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  Future<void> deleteCategory(String id) async {
    final db = await database;
    await db.delete(
      'Category',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Category Methods
  Future<List<CategoryModel>> getCategories({
    String? type,
    bool includeArchived = false,
  }) async {
    final db = await database;
    String? whereClause;
    List<dynamic>? whereArgs;
    
    if (type != null && !includeArchived) {
      whereClause = 'type = ? AND isArchived = 0';
      whereArgs = [type];
    } else if (type != null) {
      whereClause = 'type = ?';
      whereArgs = [type];
    } else if (!includeArchived) {
      whereClause = 'isArchived = 0';
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      'Category',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'name ASC',
    );
    
    return List.generate(maps.length, (i) {
      return CategoryModel.fromMap(maps[i]);
    });
  }

  Future<CategoryModel?> getCategory(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Category',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) {
      return null;
    }
    
    return CategoryModel.fromMap(maps.first);
  }

  Future<void> saveCategory(CategoryModel category) async {
    final db = await database;
    await db.insert(
      'Category',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCategory(CategoryModel category) async {
    final db = await database;
    await db.update(
      'Category',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> deleteCategory(String id) async {
    final db = await database;
    await db.delete(
      'Category',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Transaction Methods
  Future<List<TransactionModel>> getTransactions({
    String? walletId,
    String? categoryId,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    
    String whereClause = '';
    List<dynamic> whereArgs = [];
    
    if (walletId != null) {
      whereClause += whereClause.isEmpty ? 'walletId = ?' : ' AND walletId = ?';
      whereArgs.add(walletId);
    }
    
    if (categoryId != null) {
      whereClause += whereClause.isEmpty ? 'categoryId = ?' : ' AND categoryId = ?';
      whereArgs.add(categoryId);
    }
    
    if (type != null) {
      whereClause += whereClause.isEmpty ? 'type = ?' : ' AND type = ?';
      whereArgs.add(type);
    }
    
    if (startDate != null) {
      whereClause += whereClause.isEmpty ? 'date >= ?' : ' AND date >= ?';
      whereArgs.add(startDate.millisecondsSinceEpoch);
    }
    
    if (endDate != null) {
      whereClause += whereClause.isEmpty ? 'date <= ?' : ' AND date <= ?';
      whereArgs.add(endDate.millisecondsSinceEpoch);
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      'Transaction',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'date DESC',
      limit: limit,
      offset: offset,
    );
    
    return List.generate(maps.length, (i) {
      return TransactionModel.fromMap(maps[i]);
    });
  }

  Future<TransactionModel?> getTransaction(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Transaction',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) {
      return null;
    }
    
    return TransactionModel.fromMap(maps.first);
  }

  Future<void> saveTransaction(TransactionModel transaction) async {
    final db = await database;
    await db.insert(
      'Transaction',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    // Update wallet balance
    await _updateWalletBalance(transaction.walletId);
    
    // Update budget spent amount if applicable
    if (transaction.categoryId != null) {
      await _updateBudgetSpentAmount(transaction.categoryId!);
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    final db = await database;
    await db.update(
      'Transaction',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
    
    // Update wallet balance
    await _updateWalletBalance(transaction.walletId);
    
    // Update budget spent amount if applicable
    if (transaction.categoryId != null) {
      await _updateBudgetSpentAmount(transaction.categoryId!);
    }
  }

  Future<void> deleteTransaction(String id) async {
    final db = await database;
    
    // Get transaction before deleting
    final transaction = await getTransaction(id);
    if (transaction == null) return;
    
    await db.delete(
      'Transaction',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    // Update wallet balance
    await _updateWalletBalance(transaction.walletId);
    
    // Update budget spent amount if applicable
    if (transaction.categoryId != null) {
      await _updateBudgetSpentAmount(transaction.categoryId!);
    }
  }
  
  Future<List<TransactionModel>> getTransactionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? walletId,
    String? categoryId,
    String? type,
  }) async {
    return getTransactions(
      startDate: startDate,
      endDate: endDate,
      walletId: walletId,
      categoryId: categoryId,
      type: type,
    );
  }
  
  Future<List<TransactionModel>> getFilteredTransactions({
    String? walletId,
    String? categoryId,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    int? limit,
  }) async {
    final db = await database;
    
    String whereClause = '';
    List<dynamic> whereArgs = [];
    
    if (walletId != null) {
      whereClause += whereClause.isEmpty ? 'walletId = ?' : ' AND walletId = ?';
      whereArgs.add(walletId);
    }
    
    if (categoryId != null) {
      whereClause += whereClause.isEmpty ? 'categoryId = ?' : ' AND categoryId = ?';
      whereArgs.add(categoryId);
    }
    
    if (type != null) {
      whereClause += whereClause.isEmpty ? 'type = ?' : ' AND type = ?';
      whereArgs.add(type);
    }
    
    if (startDate != null) {
      whereClause += whereClause.isEmpty ? 'date >= ?' : ' AND date >= ?';
      whereArgs.add(startDate.millisecondsSinceEpoch);
    }
    
    if (endDate != null) {
      whereClause += whereClause.isEmpty ? 'date <= ?' : ' AND date <= ?';
      whereArgs.add(endDate.millisecondsSinceEpoch);
    }
    
    if (searchQuery != null && searchQuery.isNotEmpty) {
      whereClause += whereClause.isEmpty ? 'description LIKE ?' : ' AND description LIKE ?';
      whereArgs.add('%$searchQuery%');
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      'Transaction',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'date DESC',
      limit: limit,
    );
    
    return List.generate(maps.length, (i) {
      return TransactionModel.fromMap(maps[i]);
    });
  }

  Future<void> _updateWalletBalance(String walletId) async {
    final db = await database;
    
    // Get wallet to get initial balance
    final wallet = await getWallet(walletId);
    if (wallet == null) return;
    
    // Calculate total income
    final incomeResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM Transaction WHERE walletId = ? AND type = ?',
      [walletId, 'income'],
    );
    final double totalIncome = incomeResult.first['total'] as double? ?? 0.0;
    
    // Calculate total expense
    final expenseResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM Transaction WHERE walletId = ? AND type = ?',
      [walletId, 'expense'],
    );
    final double totalExpense = expenseResult.first['total'] as double? ?? 0.0;
    
    // Update wallet balance
    final balance = wallet.initialBalance + totalIncome - totalExpense;
    await db.update(
      'Wallet',
      {
        'balance': balance, 
        'totalIncome': totalIncome,
        'totalExpense': totalExpense,
        'updatedAt': DateTime.now().millisecondsSinceEpoch
      },
      where: 'id = ?',
      whereArgs: [walletId],
    );
  }

  // Budget Methods
  Future<List<BudgetModel>> getBudgets({
    String? categoryId,
    bool includeExpired = false,
  }) async {
    final db = await database;
    
    String? whereClause;
    List<dynamic>? whereArgs;
    
    if (categoryId != null && !includeExpired) {
      whereClause = 'categoryId = ? AND endDate >= ?';
      whereArgs = [categoryId, DateTime.now().millisecondsSinceEpoch];
    } else if (categoryId != null) {
      whereClause = 'categoryId = ?';
      whereArgs = [categoryId];
    } else if (!includeExpired) {
      whereClause = 'endDate >= ?';
      whereArgs = [DateTime.now().millisecondsSinceEpoch];
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      'Budget',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'startDate DESC',
    );
    
    return List.generate(maps.length, (i) {
      return BudgetModel.fromMap(maps[i]);
    });
  }

  Future<BudgetModel?> getBudget(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Budget',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) {
      return null;
    }
    
    return BudgetModel.fromMap(maps.first);
  }

  Future<void> saveBudget(BudgetModel budget) async {
    final db = await database;
    await db.insert(
      'Budget',
      budget.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    // Update spent amount
    if (budget.categoryId != null) {
      await _updateBudgetSpentAmount(budget.categoryId!);
    }
  }

  Future<void> updateBudget(BudgetModel budget) async {
    final db = await database;
    await db.update(
      'Budget',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
    
    // Update spent amount
    if (budget.categoryId != null) {
      await _updateBudgetSpentAmount(budget.categoryId!);
    }
  }

  Future<void> deleteBudget(String id) async {
    final db = await database;
    await db.delete(
      'Budget',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> _updateBudgetSpentAmount(String categoryId) async {
    final db = await database;
    
    // Get active budgets for this category
    final budgets = await getBudgets(categoryId: categoryId);
    
    for (var budget in budgets) {
      // Calculate spent amount for this budget's time period
      final expenseResult = await db.rawQuery(
        '''
        SELECT SUM(amount) as total 
        FROM Transaction 
        WHERE categoryId = ? AND type = ? AND date >= ? AND date <= ?
        ''',
        [
          categoryId,
          'expense',
          budget.startDate.millisecondsSinceEpoch,
          budget.endDate.millisecondsSinceEpoch,
        ],
      );
      final double spent = expenseResult.first['total'] as double? ?? 0.0;
      
      // Update budget spent amount
      await db.update(
        'Budget',
        {'spent': spent, 'updatedAt': DateTime.now().millisecondsSinceEpoch},
        where: 'id = ?',
        whereArgs: [budget.id],
      );
    }
  }

  // Statistics Methods
  Future<Map<String, double>> getCategoryTotals({
    required String type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;
    
    String whereClause = 'type = ?';
    List<dynamic> whereArgs = [type];
    
    if (startDate != null) {
      whereClause += ' AND date >= ?';
      whereArgs.add(startDate.millisecondsSinceEpoch);
    }
    
    if (endDate != null) {
      whereClause += ' AND date <= ?';
      whereArgs.add(endDate.millisecondsSinceEpoch);
    }
    
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT categoryId, SUM(amount) as total 
      FROM Transaction 
      WHERE $whereClause 
      GROUP BY categoryId
      ''',
      whereArgs,
    );
    
    final Map<String, double> result = {};
    
    for (var map in maps) {
      final categoryId = map['categoryId'] as String?;
      if (categoryId != null) {
        result[categoryId] = map['total'] as double? ?? 0.0;
      }
    }
    
    return result;
  }

  Future<Map<String, double>> getMonthlyTotals({
    required String type,
    required int months,
  }) async {
    final db = await database;
    final now = DateTime.now();
    final Map<String, double> result = {};
    
    for (int i = 0; i < months; i++) {
      final date = DateTime(now.year, now.month - i, 1);
      final startDate = DateTime(date.year, date.month, 1);
      final endDate = DateTime(date.year, date.month + 1, 0, 23, 59, 59);
      
      final List<Map<String, dynamic>> maps = await db.rawQuery(
        '''
        SELECT SUM(amount) as total 
        FROM Transaction 
        WHERE type = ? AND date >= ? AND date <= ?
        ''',
        [
          type,
          startDate.millisecondsSinceEpoch,
          endDate.millisecondsSinceEpoch,
        ],
      );
      
      final double total = maps.first['total'] as double? ?? 0.0;
      final String key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      result[key] = total;
    }
    
    return result;
  }
}