import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'package:invoices/config/app_config.dart';

part 'app_database.g.dart';

class CompanyProfiles extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text().withDefault(const Constant(''))();
  TextColumn get email => text().withDefault(const Constant(''))();
  TextColumn get phone => text().withDefault(const Constant(''))();
  TextColumn get taxId => text().withDefault(const Constant(''))();
  TextColumn get address => text().withDefault(const Constant(''))();
  TextColumn get paymentDetails => text().withDefault(const Constant(''))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get logoPath => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Clients extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withDefault(const Constant(''))();
  TextColumn get email => text().withDefault(const Constant(''))();
  TextColumn get phone => text().withDefault(const Constant(''))();
  TextColumn get taxId => text().withDefault(const Constant(''))();
  TextColumn get address => text().withDefault(const Constant(''))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get logoPath => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

@DriftDatabase(tables: [CompanyProfiles, Clients])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.memory() : super(NativeDatabase.memory());

  static const int companyRowId = 1;

  static final CompanyProfile emptyCompany = CompanyProfile(
    id: companyRowId,
    name: '',
    email: '',
    phone: '',
    taxId: '',
    address: '',
    paymentDetails: '',
    notes: '',
    updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) => m.createAll(),
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createTable(clients);
        }
      },
    );
  }

  Future<CompanyProfile> getCompany() async {
    final row = await (select(companyProfiles)
          ..where((row) => row.id.equals(companyRowId)))
        .getSingleOrNull();
    return row ?? emptyCompany;
  }

  Stream<CompanyProfile> watchCompany() {
    return (select(companyProfiles)
          ..where((row) => row.id.equals(companyRowId)))
        .watchSingleOrNull()
        .map((row) => row ?? emptyCompany);
  }

  Future<void> saveCompany(CompanyProfilesCompanion data) {
    return into(companyProfiles).insertOnConflictUpdate(
      data.copyWith(
        id: const Value(companyRowId),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Stream<List<Client>> watchClients() {
    return (select(clients)
          ..orderBy([(row) => OrderingTerm.asc(row.name)]))
        .watch();
  }

  Future<Client?> getClient(int id) {
    return (select(clients)..where((row) => row.id.equals(id)))
        .getSingleOrNull();
  }

  Future<Client> saveClient({
    int? id,
    required ClientsCompanion data,
  }) async {
    final now = DateTime.now();
    if (id == null) {
      return into(clients).insertReturning(
        data.copyWith(
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
    }

    final rows =
        await (update(clients)..where((row) => row.id.equals(id))).writeReturning(
      data.copyWith(updatedAt: Value(now)),
    );
    return rows.single;
  }

  Future<void> deleteClient(int id) {
    return (delete(clients)..where((row) => row.id.equals(id))).go();
  }

  Future<void> clearAllData() {
    return transaction(() async {
      await delete(clients).go();
      await delete(companyProfiles).go();
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final file = File(AppConfig.databasePath);
    await file.parent.create(recursive: true);
    return NativeDatabase.createInBackground(file);
  });
}
