# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-01-21

### Added
- Initial release of flexi_sqlite package
- Schema-based database definition with `TableDefinition` and `ColumnDefinition` classes
- Support for multiple SQL data types: TEXT, INTEGER, REAL, BLOB
- Column constraints: PRIMARY KEY, NOT NULL, UNIQUE, DEFAULT values
- DatabaseHelper class with automatic table creation on database initialization
- CRUD operations: `insert()`, `update()`, `delete()`, `queryAll()`
- Raw SQL query support via `rawQuery()` method
- Database lifecycle management: `closeDatabase()`, `resetDatabase()`
- Lazy initialization of database connection
- Example application demonstrating users and tasks management
- Comprehensive documentation and README

### Features
- Define tables with flexible column configurations
- Automatic SQL generation from schema definitions
- Simple and intuitive API for common database operations
- Support for conditional queries with WHERE clauses and parameters
- Transaction-safe database operations using sqflite
- Singleton-like database instance management

### Documentation
- Created comprehensive README with quick start guide
- Added detailed code examples for all major features
- Included example Flutter application with user and task management
