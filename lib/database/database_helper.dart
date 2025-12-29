import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('store_buy.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3, // Updated version for new columns
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Table Users
    await db.execute('''
      CREATE TABLE users (
        userId TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        username TEXT UNIQUE NOT NULL,
        email TEXT,
        phonenumber TEXT NOT NULL,
        password TEXT NOT NULL,
        location TEXT,
        userType TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    // Table Stores
    await db.execute('''
      CREATE TABLE stores (
        storeId TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        storename TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT,
        slogan TEXT,
        regle TEXT,
        password TEXT NOT NULL,
        adresse TEXT,
        photo TEXT,
        code TEXT,
        openingTime TEXT,
        closingTime TEXT,
        isOpen INTEGER DEFAULT 1,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (userId)
      )
    ''');

    // Table Products
    await db.execute('''
      CREATE TABLE products (
        productId TEXT PRIMARY KEY,
        storeId TEXT NOT NULL,
        productName TEXT NOT NULL,
        characteristic TEXT,
        color TEXT,
        photo TEXT,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        category TEXT,
        isPromoted INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (storeId) REFERENCES stores (storeId)
      )
    ''');

    // Table Cart
    await db.execute('''
      CREATE TABLE cart (
        cartId TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        productId TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (userId),
        FOREIGN KEY (productId) REFERENCES products (productId)
      )
    ''');

    // Table Orders
    await db.execute('''
      CREATE TABLE orders (
        orderId TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        storeId TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        status TEXT NOT NULL,
        deliveryAddress TEXT,
        paymentMethod TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (userId),
        FOREIGN KEY (storeId) REFERENCES stores (storeId)
      )
    ''');

    // Table OrderItems
    await db.execute('''
      CREATE TABLE order_items (
        orderItemId TEXT PRIMARY KEY,
        orderId TEXT NOT NULL,
        productId TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        FOREIGN KEY (orderId) REFERENCES orders (orderId),
        FOREIGN KEY (productId) REFERENCES products (productId)
      )
    ''');

    // Table Favorites (Products)
    await db.execute('''
      CREATE TABLE favorites (
        favoriteId TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        productId TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (userId),
        FOREIGN KEY (productId) REFERENCES products (productId),
        UNIQUE(userId, productId)
      )
    ''');

    // Table Store Favorites
    await db.execute('''
      CREATE TABLE store_favorites (
        favoriteId TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        storeId TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (userId),
        FOREIGN KEY (storeId) REFERENCES stores (storeId),
        UNIQUE(userId, storeId)
      )
    ''');

    // Table Messages
    await db.execute('''
      CREATE TABLE messages (
        messageId TEXT PRIMARY KEY,
        senderId TEXT NOT NULL,
        receiverId TEXT NOT NULL,
        content TEXT NOT NULL,
        isRead INTEGER DEFAULT 0,
        synced INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (senderId) REFERENCES users (userId),
        FOREIGN KEY (receiverId) REFERENCES users (userId)
      )
    ''');

    // Table Reviews
    await db.execute('''
      CREATE TABLE reviews (
        reviewId TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        productId TEXT NOT NULL,
        rating INTEGER NOT NULL,
        comment TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (userId),
        FOREIGN KEY (productId) REFERENCES products (productId)
      )
    ''');

    // Table Stories
    await db.execute('''
      CREATE TABLE stories (
        storyId TEXT PRIMARY KEY,
        storeId TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        type TEXT NOT NULL,
        title TEXT,
        description TEXT,
        promotionPrice REAL,
        productId TEXT,
        createdAt TEXT NOT NULL,
        expiresAt TEXT NOT NULL,
        FOREIGN KEY (storeId) REFERENCES stores (storeId),
        FOREIGN KEY (productId) REFERENCES products (productId)
      )
    ''');

    // Table Employees
    await db.execute('''
      CREATE TABLE employees (
        employeeId TEXT PRIMARY KEY,
        storeId TEXT NOT NULL,
        userId TEXT NOT NULL,
        role TEXT NOT NULL,
        code TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (storeId) REFERENCES stores (storeId),
        FOREIGN KEY (userId) REFERENCES users (userId),
        UNIQUE(storeId, userId)
      )
    ''');

    // Table Reservations
    await db.execute('''
      CREATE TABLE reservations (
        reservationId TEXT PRIMARY KEY,
        orderId TEXT NOT NULL,
        storeId TEXT NOT NULL,
        userId TEXT NOT NULL,
        type TEXT NOT NULL,
        pickupDate TEXT,
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (orderId) REFERENCES orders (orderId),
        FOREIGN KEY (storeId) REFERENCES stores (storeId),
        FOREIGN KEY (userId) REFERENCES users (userId)
      )
    ''');

    // Table Deliveries
    await db.execute('''
      CREATE TABLE deliveries (
        deliveryId TEXT PRIMARY KEY,
        orderId TEXT NOT NULL,
        storeId TEXT NOT NULL,
        deliveryAddress TEXT NOT NULL,
        status TEXT NOT NULL,
        estimatedDate TEXT,
        actualDate TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (orderId) REFERENCES orders (orderId),
        FOREIGN KEY (storeId) REFERENCES stores (storeId)
      )
    ''');

    // Table StoreThemes
    await db.execute('''
      CREATE TABLE store_themes (
        themeId TEXT PRIMARY KEY,
        storeId TEXT NOT NULL,
        primaryColor TEXT,
        secondaryColor TEXT,
        fontFamily TEXT,
        logo TEXT,
        banner TEXT,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (storeId) REFERENCES stores (storeId)
      )
    ''');

    // Table SupportTickets
    await db.execute('''
      CREATE TABLE support_tickets (
        ticketId TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        storeId TEXT,
        subject TEXT NOT NULL,
        message TEXT NOT NULL,
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (userId),
        FOREIGN KEY (storeId) REFERENCES stores (storeId)
      )
    ''');

    // Table Notifications
    await db.execute('''
      CREATE TABLE notifications (
        notificationId TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        storeId TEXT,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        isRead INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (userId),
        FOREIGN KEY (storeId) REFERENCES stores (storeId)
      )
    ''');

    // Table StoreHistory
    await db.execute('''
      CREATE TABLE store_history (
        historyId TEXT PRIMARY KEY,
        storeId TEXT NOT NULL,
        action TEXT NOT NULL,
        details TEXT,
        userId TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (storeId) REFERENCES stores (storeId),
        FOREIGN KEY (userId) REFERENCES users (userId)
      )
    ''');

    // Table Reports
    await db.execute('''
      CREATE TABLE reports (
        reportId TEXT PRIMARY KEY,
        reporterId TEXT NOT NULL,
        reportedUserId TEXT NOT NULL,
        storeId TEXT,
        reason TEXT NOT NULL,
        description TEXT,
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (reporterId) REFERENCES users (userId),
        FOREIGN KEY (reportedUserId) REFERENCES users (userId),
        FOREIGN KEY (storeId) REFERENCES stores (storeId)
      )
    ''');

    // Table Purchase History
    await db.execute('''
      CREATE TABLE purchase_history (
        historyId TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        orderId TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        purchaseDate TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (userId),
        FOREIGN KEY (orderId) REFERENCES orders (orderId)
      )
    ''');

    // Table Budget Limits
    await db.execute('''
      CREATE TABLE budget_limits (
        budgetId TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        monthlyLimit REAL NOT NULL,
        currentSpent REAL DEFAULT 0,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (userId),
        UNIQUE(userId, month, year)
      )
    ''');

    // Table Purchase Tracking
    await db.execute('''
      CREATE TABLE purchase_tracking (
        trackingId TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        productId TEXT NOT NULL,
        priority INTEGER DEFAULT 0,
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (userId),
        FOREIGN KEY (productId) REFERENCES products (productId)
      )
    ''');

    // Table Story Comments
    await db.execute('''
      CREATE TABLE story_comments (
        commentId TEXT PRIMARY KEY,
        storyId TEXT NOT NULL,
        userId TEXT NOT NULL,
        content TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (storyId) REFERENCES stories (storyId),
        FOREIGN KEY (userId) REFERENCES users (userId)
      )
    ''');

    // Table Store Reviews
    await db.execute('''
      CREATE TABLE store_reviews (
        reviewId TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        storeId TEXT NOT NULL,
        rating INTEGER NOT NULL,
        comment TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (userId),
        FOREIGN KEY (storeId) REFERENCES stores (storeId)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new tables for version 2
      await db.execute('''
        CREATE TABLE IF NOT EXISTS employees (
          employeeId TEXT PRIMARY KEY,
          storeId TEXT NOT NULL,
          userId TEXT NOT NULL,
          role TEXT NOT NULL,
          code TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          FOREIGN KEY (storeId) REFERENCES stores (storeId),
          FOREIGN KEY (userId) REFERENCES users (userId),
          UNIQUE(storeId, userId)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS reservations (
          reservationId TEXT PRIMARY KEY,
          orderId TEXT NOT NULL,
          storeId TEXT NOT NULL,
          userId TEXT NOT NULL,
          type TEXT NOT NULL,
          pickupDate TEXT,
          status TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          FOREIGN KEY (orderId) REFERENCES orders (orderId),
          FOREIGN KEY (storeId) REFERENCES stores (storeId),
          FOREIGN KEY (userId) REFERENCES users (userId)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS deliveries (
          deliveryId TEXT PRIMARY KEY,
          orderId TEXT NOT NULL,
          storeId TEXT NOT NULL,
          deliveryAddress TEXT NOT NULL,
          status TEXT NOT NULL,
          estimatedDate TEXT,
          actualDate TEXT,
          createdAt TEXT NOT NULL,
          FOREIGN KEY (orderId) REFERENCES orders (orderId),
          FOREIGN KEY (storeId) REFERENCES stores (storeId)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS store_themes (
          themeId TEXT PRIMARY KEY,
          storeId TEXT NOT NULL,
          primaryColor TEXT,
          secondaryColor TEXT,
          fontFamily TEXT,
          logo TEXT,
          banner TEXT,
          updatedAt TEXT NOT NULL,
          FOREIGN KEY (storeId) REFERENCES stores (storeId)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS support_tickets (
          ticketId TEXT PRIMARY KEY,
          userId TEXT NOT NULL,
          storeId TEXT,
          subject TEXT NOT NULL,
          message TEXT NOT NULL,
          status TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          FOREIGN KEY (userId) REFERENCES users (userId),
          FOREIGN KEY (storeId) REFERENCES stores (storeId)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS notifications (
          notificationId TEXT PRIMARY KEY,
          userId TEXT NOT NULL,
          storeId TEXT,
          type TEXT NOT NULL,
          title TEXT NOT NULL,
          body TEXT NOT NULL,
          isRead INTEGER DEFAULT 0,
          createdAt TEXT NOT NULL,
          FOREIGN KEY (userId) REFERENCES users (userId),
          FOREIGN KEY (storeId) REFERENCES stores (storeId)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS store_history (
          historyId TEXT PRIMARY KEY,
          storeId TEXT NOT NULL,
          action TEXT NOT NULL,
          details TEXT,
          userId TEXT,
          createdAt TEXT NOT NULL,
          FOREIGN KEY (storeId) REFERENCES stores (storeId),
          FOREIGN KEY (userId) REFERENCES users (userId)
        )
      ''');

      // Update stories table to add new columns
      await db.execute('''
        ALTER TABLE stories ADD COLUMN type TEXT DEFAULT 'announcement'
      ''').catchError((e) {
        // Column might already exist
      });

      await db.execute('''
        ALTER TABLE stories ADD COLUMN title TEXT
      ''').catchError((e) {});

      await db.execute('''
        ALTER TABLE stories ADD COLUMN description TEXT
      ''').catchError((e) {});

      await db.execute('''
        ALTER TABLE stories ADD COLUMN promotionPrice REAL
      ''').catchError((e) {});

      await db.execute('''
        ALTER TABLE stories ADD COLUMN productId TEXT
      ''').catchError((e) {});

      // Add opening hours columns to stores
      await db.execute('''
        ALTER TABLE stores ADD COLUMN openingTime TEXT
      ''').catchError((e) {});

      await db.execute('''
        ALTER TABLE stores ADD COLUMN closingTime TEXT
      ''').catchError((e) {});

      await db.execute('''
        ALTER TABLE stores ADD COLUMN isOpen INTEGER DEFAULT 1
      ''').catchError((e) {});

      // Add isRead and synced columns to messages table
      await db.execute('''
        ALTER TABLE messages ADD COLUMN isRead INTEGER DEFAULT 0
      ''').catchError((e) {});

      await db.execute('''
        ALTER TABLE messages ADD COLUMN synced INTEGER DEFAULT 0
      ''').catchError((e) {});

      // Add synced column to orders table
      await db.execute('''
        ALTER TABLE orders ADD COLUMN synced INTEGER DEFAULT 0
      ''').catchError((e) {});

      // Table Store Photos
      await db.execute('''
        CREATE TABLE IF NOT EXISTS store_photos (
          photoId TEXT PRIMARY KEY,
          storeId TEXT NOT NULL,
          photoUrl TEXT NOT NULL,
          description TEXT,
          createdAt TEXT NOT NULL,
          FOREIGN KEY (storeId) REFERENCES stores (storeId)
        )
      ''').catchError((e) {});

      // Table Surveys
      await db.execute('''
        CREATE TABLE IF NOT EXISTS surveys (
          surveyId TEXT PRIMARY KEY,
          storeId TEXT NOT NULL,
          question TEXT NOT NULL,
          type TEXT NOT NULL,
          options TEXT,
          createdAt TEXT NOT NULL,
          expiresAt TEXT,
          FOREIGN KEY (storeId) REFERENCES stores (storeId)
        )
      ''').catchError((e) {});

      // Table Survey Responses
      await db.execute('''
        CREATE TABLE IF NOT EXISTS survey_responses (
          responseId TEXT PRIMARY KEY,
          surveyId TEXT NOT NULL,
          userId TEXT NOT NULL,
          answer TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          FOREIGN KEY (surveyId) REFERENCES surveys (surveyId),
          FOREIGN KEY (userId) REFERENCES users (userId),
          UNIQUE(surveyId, userId)
        )
      ''').catchError((e) {});

      // Table Onboarding Status
      await db.execute('''
        CREATE TABLE IF NOT EXISTS onboarding_status (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId TEXT NOT NULL,
          completed INTEGER DEFAULT 0,
          FOREIGN KEY (userId) REFERENCES users (userId)
        )
      ''').catchError((e) {});
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

}

