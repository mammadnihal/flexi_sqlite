// Schema definitions for flexi_sqlite

enum SQType { text, integer, real, blob }

extension SQTypeExtension on SQType {
  String toSqlString() {
    switch (this) {
      case SQType.text:
        return 'TEXT';
      case SQType.integer:
        return 'INTEGER';
      case SQType.real:
        return 'REAL';
      case SQType.blob:
        return 'BLOB';
    }
  }
}

class ColumnDefinition {
  final String name;
  final SQType type;
  final bool isPrimaryKey;
  final bool isNotNull;
  final bool isUnique;
  final String? defaultValue;

  const ColumnDefinition({
    required this.name,
    required this.type,
    this.isPrimaryKey = false,
    this.isNotNull = false,
    this.isUnique = false,
    this.defaultValue,
  });

  String toSql() {
    String sql = '$name ${type.toSqlString()}';
    if (isPrimaryKey) sql += ' PRIMARY KEY AUTOINCREMENT';
    if (isNotNull) sql += ' NOT NULL';
    if (isUnique) sql += ' UNIQUE';
    if (defaultValue != null) sql += ' DEFAULT $defaultValue';
    return sql;
  }
}

class TableDefinition {
  final String name;
  final List<ColumnDefinition> columns;

  const TableDefinition({
    required this.name,
    required this.columns,
  });

  String toSql() => 'CREATE TABLE IF NOT EXISTS $name (${columns.map((c) => c.toSql()).join(', ')})';
}
