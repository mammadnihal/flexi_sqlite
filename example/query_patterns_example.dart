import 'package:flexi_sqlite/flexi_sqlite.dart';

/// Query patterns and best practices
Future<void> queryPatternsExample() async {
  final dbHelper = DatabaseHelper(
    dbName: 'products.db',
    tables: [
      TableDefinition(
        name: 'products',
        columns: const [
          ColumnDefinition(
            name: 'id',
            type: SQType.integer,
            isPrimaryKey: true,
          ),
          ColumnDefinition(
            name: 'name',
            type: SQType.text,
            isNotNull: true,
          ),
          ColumnDefinition(
            name: 'price',
            type: SQType.real,
            isNotNull: true,
          ),
          ColumnDefinition(
            name: 'category',
            type: SQType.text,
          ),
          ColumnDefinition(
            name: 'stock',
            type: SQType.integer,
            defaultValue: '0',
          ),
          ColumnDefinition(
            name: 'is_available',
            type: SQType.integer,
            defaultValue: '1',
          ),
        ],
      ),
    ],
  );

  // Insert sample data
  await _insertSampleProducts(dbHelper);

  // Query 1: Get all products
  print('=== All Products ===');
  final allProducts = await dbHelper.queryAll('products');
  for (var product in allProducts) {
    print('${product['name']}: \$${product['price']} (Stock: ${product['stock']})');
  }

  // Query 2: Get available products using raw SQL
  print('\n=== Available Products ===');
  final availableProducts = await dbHelper.rawQuery(
    'SELECT * FROM products WHERE is_available = 1 AND stock > 0',
  );
  for (var product in availableProducts) {
    print('${product['name']}: Available (${product['stock']} in stock)');
  }

  // Query 3: Get products by price range
  print('\n=== Products Under \$50 ===');
  final cheapProducts = await dbHelper.rawQuery(
    'SELECT * FROM products WHERE price < 50 ORDER BY price DESC',
  );
  for (var product in cheapProducts) {
    print('${product['name']}: \$${product['price']}');
  }

  // Query 4: Get stock summary by category
  print('\n=== Stock by Category ===');
  final categoryStock = await dbHelper.rawQuery(
    'SELECT category, SUM(stock) as total_stock, COUNT(*) as product_count FROM products GROUP BY category',
  );
  for (var row in categoryStock) {
    print('${row['category']}: ${row['total_stock']} items (${row['product_count']} products)');
  }

  // Update operations
  print('\n=== Performing Updates ===');

  // Update single product
  await dbHelper.update(
    'products',
    {'stock': 100},
    where: 'name = ?',
    whereArgs: ['Laptop'],
  );
  print('Updated Laptop stock to 100');

  // Update multiple products
  await dbHelper.update(
    'products',
    {'is_available': 0},
    where: 'stock < ?',
    whereArgs: [5],
  );
  print('Marked low-stock items as unavailable');

  // Delete operations
  print('\n=== Performing Deletions ===');

  // Delete products out of stock
  int deleted = await dbHelper.delete(
    'products',
    where: 'stock = ?',
    whereArgs: [0],
  );
  print('Deleted $deleted out-of-stock products');

  // Query final state
  print('\n=== Final Product List ===');
  final finalProducts = await dbHelper.queryAll('products');
  print('Total products remaining: ${finalProducts.length}');

  // Close database
  await dbHelper.closeDatabase();
}

Future<void> _insertSampleProducts(DatabaseHelper dbHelper) async {
  final products = [
    {
      'name': 'Laptop',
      'price': 999.99,
      'category': 'Electronics',
      'stock': 10,
      'is_available': 1,
    },
    {
      'name': 'Mouse',
      'price': 29.99,
      'category': 'Electronics',
      'stock': 50,
      'is_available': 1,
    },
    {
      'name': 'Keyboard',
      'price': 79.99,
      'category': 'Electronics',
      'stock': 0,
      'is_available': 0,
    },
    {
      'name': 'Desk Lamp',
      'price': 49.99,
      'category': 'Furniture',
      'stock': 15,
      'is_available': 1,
    },
    {
      'name': 'Coffee Maker',
      'price': 89.99,
      'category': 'Appliances',
      'stock': 3,
      'is_available': 1,
    },
    {
      'name': 'Toaster',
      'price': 34.99,
      'category': 'Appliances',
      'stock': 0,
      'is_available': 0,
    },
  ];

  for (var product in products) {
    await dbHelper.insert('products', product);
  }
}
