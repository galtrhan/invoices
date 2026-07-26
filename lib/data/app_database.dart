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

@DriftDatabase(tables: [CompanyProfiles])
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
  int get schemaVersion => 1;

  Future<CompanyProfile> getCompany() async {
    final row = await (select(companyProfiles)
          ..where((row) => row.id.equals(companyRowId)))
        .getSingleOrNull();
    return row ?? emptyCompany;
  }

  Future<void> saveCompany(CompanyProfilesCompanion data) {
    return into(companyProfiles).insertOnConflictUpdate(
      data.copyWith(
        id: const Value(companyRowId),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final file = File(AppConfig.databasePath);
    await file.parent.create(recursive: true);
    return NativeDatabase.createInBackground(file);
  });
}
