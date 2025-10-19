# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## Project Overview

**Kakeibo v3** - A Japanese personal finance management app (家計簿アプリ) built with Flutter. Implements Clean Architecture with Riverpod state management and SQLite for local data persistence.

**Current Version**: 1.1.2
**Flutter Version**: 3.16.9
**Database**: SQLite (kakeibo_v3.db, schema v6)

---

## Development Commands

### Setup & Dependencies
```bash
# Install dependencies
flutter pub get

# Generate code (Freezed, Riverpod, JSON serialization)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for continuous code generation during development
dart run build_runner watch --delete-conflicting-outputs
```

### Running the App
```bash
# Run on connected device/emulator
flutter run

# Run with specific device
flutter run -d <device-id>

# List available devices
flutter devices
```

### Code Quality
```bash
# Run linter
flutter analyze

# Format code
dart format .
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/month_period_fetch_test.dart

# Run tests with coverage
flutter test --coverage
```

### Build
```bash
# Build iOS (requires macOS)
flutter build ios

# Build APK (Android)
flutter build apk

# Build app bundle (Android)
flutter build appbundle
```

---

## Architecture Overview

### Clean Architecture Layers

The codebase follows **strict Clean Architecture** with clear separation of concerns:

```
lib/
├── domain/              # Business entities & contracts (no dependencies)
│   ├── core/           # Domain value objects (PeriodValue, CategoryEntity, etc.)
│   ├── db/             # Database entity interfaces (13 entities, all @freezed)
│   └── ui_value/       # UI-specific domain models
├── domain_service/     # Domain services (date/period calculations)
├── application/        # Use cases (24 business workflows)
├── repository/         # Repository implementations (SQLite operations)
├── view_model/         # State management (Riverpod providers/notifiers)
├── view/               # UI components (pages, widgets)
├── model/              # Database helper & schema
├── batch/              # Automated monthly batch processing
├── constant/           # App constants (colors, strings, icons)
└── util/               # Extensions & helper functions
```

### Key Architectural Patterns

1. **Dependency Injection via Riverpod**
   - All repositories injected as providers in `main.dart`
   - Providers use `overrideWithValue()` to inject implementations
   - Example: `expenseRepositoryProvider.overrideWithValue(ImplementsExpenseRepository())`

2. **Immutability with Freezed**
   - All domain entities use `@freezed` annotation
   - Generates immutable data classes with `copyWith()`, `fromJson()`, `toJson()`
   - Always run `build_runner` after modifying entity files

3. **Reactive State Management**
   - `updateDBCountNotifier` tracks DB mutations (incremented on every data change)
   - UI automatically rebuilds when watched providers change
   - Each page has dedicated state providers in `view_model/state/`

4. **Repository Pattern**
   - Abstract repository interfaces in `domain/`
   - Concrete implementations in `repository/`
   - All DB access goes through `DatabaseHelper` singleton

5. **Use Case Pattern**
   - Each business operation has a dedicated use case class
   - Use cases coordinate between repositories and domain logic
   - Located in `application/` with `*_usecase.dart` naming

### Database Schema

**Database File**: `kakeibo_v3.db` (version 6)
**Schema Location**: `lib/model/sql_on_create.dart`
**Table/Column Constants**: `lib/model/table_calmn_name.dart`
**Migration Logic**: `lib/model/sql_on_update.dart`

#### 📋 Official Schema Reference

**⚠️ IMPORTANT**: When considering SQLite database structure, **ALWAYS refer to the official design document**:

**Design Document Location**: `/Users/puruwo/dev/家計簿/設計書/テーブル設計書/`

This directory contains:
- `家計簿アプリ_テーブル設計書.pdf` - **Current authoritative schema** (latest version)
- `old/` - Previous versions for reference

**Before making ANY schema changes**:
1. Read the current design document at the path above
2. Verify the proposed change aligns with the documented design
3. Update migration logic in `sql_on_update.dart` if modifying existing tables
4. Increment `_databaseVersion` in `database_helper.dart`

#### Current Schema Tables (v6 - Implemented)

**1. expense** (`SqfExpense`)
```sql
CREATE TABLE expense (
  _id INTEGER PRIMARY KEY AUTOINCREMENT,
  expense_small_category_id INTEGER NOT NULL,
  date TEXT NOT NULL,
  price INTEGER NOT NULL,
  memo TEXT,
  income_source_big_category INTEGER NOT NULL
);
```
- **Purpose**: Daily regular expenses (excludes fixed cost expenses)
- **Date Format**: 'YYYYMMDD' (e.g., '20250401')
- **income_source_big_category**: Which income source paid (0=regular income, 1=bonus)
- **Changes in v6**: Removed `fixed_cost_id` and `is_confirmed` columns (moved to `fixed_cost_expense`)

**1.1. fixed_cost_expense** (`SqfFixedCostExpense`) - **NEW in v6**
```sql
CREATE TABLE fixed_cost_expense (
  _id INTEGER PRIMARY KEY AUTOINCREMENT,
  fixed_cost_category_id INTEGER NOT NULL,
  date TEXT NOT NULL,
  price INTEGER NOT NULL,
  name TEXT,
  confirmed_cost_type INTEGER,
  is_confirmed INTEGER NOT NULL
);
```
- **Purpose**: Fixed cost transactions (separated from regular expenses)
- **Date Format**: 'YYYYMMDD' (e.g., '20250401')
- **fixed_cost_category_id**: FK to `fixed_cost_category` table
- **confirmed_cost_type**: 0=fixed amount, 1=variable amount
- **is_confirmed**: 0=unconfirmed, 1=confirmed
- **Generated by**: Batch processing from `fixed_cost` definitions

**1.2. fixed_cost_category** (`SqfFixedCostCategory`) - **NEW in v6**
```sql
CREATE TABLE fixed_cost_category (
  _id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  color_code TEXT NOT NULL,
  resource_path TEXT NOT NULL,
  display_order INTEGER NOT NULL,
  is_displayed INTEGER NOT NULL
);
```
- **Purpose**: Independent category system for fixed costs
- **Default Categories**: 住居費(1), 通信費(2), サブスク(3), 光熱費(4), その他(5)
- **color_code**: Hex without '#' (e.g., 'FF5722')
- **is_displayed**: 0=hidden, 1=visible in UI

**2. income** (`SqfIncome`)
```sql
CREATE TABLE income (
  _id INTEGER PRIMARY KEY AUTOINCREMENT,
  income_small_category_id INTEGER NOT NULL,
  date TEXT NOT NULL,
  price INTEGER NOT NULL,
  memo TEXT
);
```

**2.1. fixed_cost** (`SqfFixedCost`)
```sql
CREATE TABLE fixed_cost (
  _id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  variable INTEGER NOT NULL,
  price INTEGER,
  estimated_price INTEGER,
  expense_small_category_id INTEGER NOT NULL,
  interval_number INTEGER NOT NULL,
  interval_unit INTEGER NOT NULL,
  first_payment_date TEXT NOT NULL,
  recent_payment_date TEXT,
  next_payment_date TEXT NOT NULL,
  delete_flag INTEGER NOT NULL
);
```
- **Purpose**: Master data for recurring fixed cost definitions
- **variable**: 0=fixed amount, 1=variable amount
- **interval_unit**: 1=monthly, 2=yearly
- **interval_number**: Payment frequency (e.g., 1 for monthly, 3 for quarterly)
- **expense_small_category_id**: For backward compatibility (maps to fixed_cost_category via migration logic)
- **Batch processing**: Generates `fixed_cost_expense` records based on payment schedule

**3. budget** (`SqfBudget`)
```sql
CREATE TABLE budget (
  _id INTEGER PRIMARY KEY AUTOINCREMENT,
  expense_big_category_id INTEGER NOT NULL,
  month TEXT NOT NULL,  -- Format: 'YYYYMM'
  price INTEGER
);
```

**4. batch_history** (`SqfBatchHistory`)
```sql
CREATE TABLE batch_history (
  _id INTEGER PRIMARY KEY AUTOINCREMENT,
  start_date TEXT NOT NULL,
  end_date TEXT NOT NULL,
  status INTEGER NOT NULL  -- 0=incomplete, 1=completed
);
```

**5. expense_big_category** (`SqfExpenseBigCategory`)
```sql
CREATE TABLE expense_big_category (
  _id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  color_code TEXT NOT NULL,  -- Hex without '#' (e.g., 'FF7070')
  resource_path TEXT NOT NULL,
  display_order INTEGER NOT NULL,
  is_displayed INTEGER NOT NULL
);
```
- Default categories: 食費(0), 日用品(1), 遊び娯楽(2), 交通費(3), 衣服美容(4), 医療費(5), 雑費(6)

**6. expense_small_category** (`SqfExpenseSmallCategory`)
```sql
CREATE TABLE expense_small_category (
  _id INTEGER PRIMARY KEY AUTOINCREMENT,
  big_category_key INTEGER NOT NULL,
  name TEXT NOT NULL,
  small_category_order_key INTEGER NOT NULL,
  displayed_order_in_big INTEGER NOT NULL,
  default_displayed INTEGER NOT NULL
);
```

**7. income_big_category** (`SqfIncomeBigCategory`)
```sql
CREATE TABLE income_big_category (
  _id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  color_code TEXT NOT NULL,
  resource_path TEXT NOT NULL
);
```
- Default: 月次収入(0), ボーナス(1)

**8. income_small_category** (`SqfIncomeSmallCategory`)
```sql
CREATE TABLE income_small_category (
  _id INTEGER PRIMARY KEY AUTOINCREMENT,
  big_category_key INTEGER NOT NULL,
  name TEXT NOT NULL,
  small_category_order_key INTEGER NOT NULL,
  displayed_order_in_big INTEGER NOT NULL,
  default_displayed INTEGER NOT NULL
);
```

#### Tables Referenced in Code but Not in sql_on_create.dart
- `month_basis` - Monthly aggregation data
- `year_basis` - Yearly aggregation data
- `aggregation_start_day` - Day of month for aggregation start
- `aggregation_start_month` - Month for yearly aggregation start

### Batch Processing System

**File**: `lib/batch/batch_history_usecase.dart`

The app runs automated monthly batch processing on startup:
1. Checks `batch_history` table for last execution date
2. If current period > last batch date, triggers monthly processing
3. Generates `fixed_cost_expense` records (NOT `expense`) for fixed costs with payment dates in the period
4. Calls `FixedCostService.insertToFixedCostExpense()` to write to the new table
5. Records execution in `batch_history` to prevent duplicate runs
6. Increments `updateDBCountNotifier` to trigger UI refresh

**v6 Changes**:
- Batch processing now writes to `fixed_cost_expense` table instead of `expense`
- Fixed costs use `fixed_cost_category` instead of `expense_small_category`
- Mapping logic in `FixedCostUsecase._mapToFixedCostCategoryId()` converts old category IDs

**Critical**: Any fixed cost changes must consider batch processing logic.

### State Update Flow

When data changes:
1. Use case performs DB operation via repository
2. Use case calls `updateDBCountNotifier.incrementState()`
3. All widgets watching `updateDBCountNotifier` rebuild
4. Widgets refetch data through their respective use cases

**Important**: Always increment `updateDBCountNotifier` after DB mutations, or UI won't update.

---

## Code Generation Requirements

This project heavily uses code generation. **Always run `build_runner`** after:
- Creating/modifying `@freezed` entities
- Adding/changing `@riverpod` providers
- Modifying `@JsonSerializable` classes

Generated files follow these patterns:
- `*.freezed.dart` - Freezed data classes
- `*.g.dart` - JSON serialization & Riverpod providers
- Never edit generated files manually

---

## Navigation Structure

**Main Scaffold**: `lib/view/foundation.dart`

4-tab bottom navigation with `IndexedStack` (preserves state):
1. **ホーム (Home)** - `year_page/` - Annual overview, balance chart, bonus planning
2. **入力 (Input)** - `register_page/` - Transaction entry modal (expense/income/fixed cost)
3. **分析 (Analysis)** - `monthly_page/` - Monthly category breakdown, budgets, predictions
4. **履歴 (History)** - `historical_calendar_page/` - Calendar-based transaction browser

Each tab has its own `Navigator` instance for independent navigation stacks.

---

## Common Development Patterns

### Adding a New Feature That Modifies Data

1. **Create/modify domain entity** (if needed)
   ```dart
   // lib/domain/db/my_entity/my_entity.dart
   @freezed
   class MyEntity with _$MyEntity {
     const factory MyEntity({required int id, required String name}) = _MyEntity;
     factory MyEntity.fromJson(Map<String, dynamic> json) => _$MyEntityFromJson(json);
   }
   ```

2. **Run build_runner**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

3. **Create repository interface**
   ```dart
   // lib/domain/db/my_entity/my_entity_repository.dart
   abstract class MyEntityRepository {
     Future<void> insert(MyEntity entity);
     Future<List<MyEntity>> fetchAll();
   }
   ```

4. **Implement repository**
   ```dart
   // lib/repository/my_entity_repository.dart
   class ImplementsMyEntityRepository implements MyEntityRepository {
     @override
     Future<void> insert(MyEntity entity) async {
       await DatabaseHelper.instance.insert('my_table', entity.toJson());
     }
   }
   ```

5. **Register provider in main.dart**
   ```dart
   final myEntityRepositoryProvider = Provider<MyEntityRepository>(...);

   // In main():
   overrides: [
     myEntityRepositoryProvider.overrideWithValue(ImplementsMyEntityRepository()),
   ]
   ```

6. **Create use case**
   ```dart
   // lib/application/my_feature/my_feature_usecase.dart
   class MyFeatureUsecase {
     MyFeatureUsecase(this._ref);
     final Ref _ref;

     Future<void> addData(MyEntity entity) async {
       await _ref.read(myEntityRepositoryProvider).insert(entity);
       _ref.read(updateDBCountNotifierProvider.notifier).incrementState();
     }
   }
   ```

7. **Use in UI**
   ```dart
   // In widget
   final usecase = ref.read(myFeatureUsecaseProvider);
   await usecase.addData(myEntity);
   ```

### Querying Data for UI

1. Create use case that returns UI-friendly models (not raw DB entities)
2. Use domain models from `lib/domain/ui_value/`
3. Watch `updateDBCountNotifier` to trigger rebuilds
4. Fetch data in `ref.watch()` or `FutureProvider`

Example:
```dart
final myDataProvider = FutureProvider<List<MyUIValue>>((ref) async {
  ref.watch(updateDBCountNotifierProvider); // Rebuild on DB changes
  return await ref.read(myFeatureUsecaseProvider).fetchUIData();
});
```

### Adding a New Database Table

1. Add table creation SQL to `lib/model/sql_on_create.dart`
2. Increment `_databaseVersion` in `lib/model/database_helper.dart`
3. Add migration logic in `onUpgrade` callback (if needed for existing users)
4. Add table/column constants to `lib/model/table_calmn_name.dart`
5. Create entity, repository interface, and implementation (see above)

---

## Important Implementation Notes

### Date & Period Handling

- Use `SystemDateScopeEntity` for current date context (respects aggregation settings)
- Period calculations in `domain_service/month_period_service/` and `year_period_service/`
- DateTime extensions in `util/extension/datetime_extension.dart` (`addMonths()`, `addYears()`, `toFormattedString()`)
- Aggregation start day/month stored in DB, not hardcoded

### Fixed Costs & Recurring Payments

- `PaymentFrequencyValue` defines payment intervals (monthly, quarterly, annual, etc.)
- Batch process generates actual expenses from fixed cost definitions
- `isConfirmed` flag tracks whether variable costs are finalized
- Edit fixed costs carefully - may affect past batch-generated expenses

### Budget System

- Budgets are monthly, per category
- Stored in `budget` table with month/category foreign keys
- UI shows budget vs. actual spending with progress indicators
- Budget editing UI in `view/budget_setting_page/`

### Category System

- Two-level hierarchy: Big Category → Small Categories
- Separate hierarchies for expenses and income
- Categories referenced by ID in expense/income records
- Category CRUD in `view/category_edit_page/`

---

## Testing Notes

- Limited test coverage currently (2 test files)
- `test/month_period_fetch_test.dart` - Tests period calculation logic
- `test/widget_test.dart` - Basic widget test

When adding tests:
- Use `sqflite_common_ffi` for SQLite in tests (already in dev_dependencies)
- Mock repositories for use case tests
- Test use cases, not UI directly

---

## Troubleshooting

### "Missing generated files" errors
```bash
dart run build_runner build --delete-conflicting-outputs
```

### UI not updating after data changes
- Ensure `updateDBCountNotifier.incrementState()` is called in use case
- Verify UI is watching `updateDBCountNotifierProvider`

### Database errors
- Check `lib/model/table_calmn_name.dart` for correct table/column names
- Verify schema version matches expectations
- Look for migration issues in `DatabaseHelper.onUpgrade`

### Build errors after pulling changes
```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```
