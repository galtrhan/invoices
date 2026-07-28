import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'package:invoices/config/app_config.dart';
import 'package:invoices/data/invoice_number_format.dart';

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
  TextColumn get invoiceNumberFormat => text()
      .withDefault(const Constant(defaultInvoiceNumberFormat))();
  IntColumn get lastInvoiceSequence =>
      integer().withDefault(const Constant(0))();
  IntColumn get lastInvoiceSequenceYear =>
      integer().withDefault(const Constant(0))();
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
  TextColumn get pdfTemplate => text().nullable()();
  TextColumn get logoPath => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

class Invoices extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get number => text()();
  DateTimeColumn get issuedOn => dateTime()();
  IntColumn get clientId => integer().nullable()();
  TextColumn get clientName => text().withDefault(const Constant(''))();
  TextColumn get clientEmail => text().withDefault(const Constant(''))();
  TextColumn get clientPhone => text().withDefault(const Constant(''))();
  TextColumn get clientTaxId => text().withDefault(const Constant(''))();
  TextColumn get clientAddress => text().withDefault(const Constant(''))();
  TextColumn get clientNotes => text().withDefault(const Constant(''))();
  TextColumn get clientLogoPath => text().nullable()();
  TextColumn get companyName => text().withDefault(const Constant(''))();
  TextColumn get companyEmail => text().withDefault(const Constant(''))();
  TextColumn get companyPhone => text().withDefault(const Constant(''))();
  TextColumn get companyTaxId => text().withDefault(const Constant(''))();
  TextColumn get companyAddress => text().withDefault(const Constant(''))();
  TextColumn get companyPaymentDetails =>
      text().withDefault(const Constant(''))();
  TextColumn get companyNotes => text().withDefault(const Constant(''))();
  TextColumn get companyLogoPath => text().nullable()();
  RealColumn get total => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

class InvoiceLines extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get invoiceId => integer().references(
        Invoices,
        #id,
        onDelete: KeyAction.cascade,
      )();
  TextColumn get description => text().withDefault(const Constant(''))();
  RealColumn get quantity => real().withDefault(const Constant(1.0))();
  RealColumn get unitPrice => real().withDefault(const Constant(0.0))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

class InvoiceLineInput {
  const InvoiceLineInput({
    required this.description,
    required this.quantity,
    required this.unitPrice,
  });

  final String description;
  final double quantity;
  final double unitPrice;
}

@DriftDatabase(tables: [CompanyProfiles, Clients, Invoices, InvoiceLines])
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
    invoiceNumberFormat: defaultInvoiceNumberFormat,
    lastInvoiceSequence: 0,
    lastInvoiceSequenceYear: 0,
    updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) => m.createAll(),
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createTable(clients);
        }
        if (from < 3) {
          await m.createTable(invoices);
          await m.createTable(invoiceLines);
        }
        if (from < 4) {
          await m.addColumn(clients, clients.pdfTemplate);
        }
        if (from < 5) {
          await m.addColumn(
            companyProfiles,
            companyProfiles.invoiceNumberFormat,
          );
        }
        if (from < 6) {
          await m.addColumn(
            companyProfiles,
            companyProfiles.lastInvoiceSequence,
          );
          await m.addColumn(
            companyProfiles,
            companyProfiles.lastInvoiceSequenceYear,
          );
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

  Stream<List<Invoice>> watchInvoices() {
    return (select(invoices)
          ..orderBy([
            (row) => OrderingTerm.desc(row.issuedOn),
            (row) => OrderingTerm.desc(row.id),
          ]))
        .watch();
  }

  Future<Invoice?> getInvoice(int id) {
    return (select(invoices)..where((row) => row.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<InvoiceLine>> getInvoiceLines(int invoiceId) {
    return (select(invoiceLines)
          ..where((row) => row.invoiceId.equals(invoiceId))
          ..orderBy([(row) => OrderingTerm.asc(row.sortOrder)]))
        .get();
  }

  Future<String> nextInvoiceNumber(
    DateTime issuedOn, {
    CompanyProfile? company,
  }) async {
    final year = issuedOn.year;
    final profile = company ?? await getCompany();
    final last = lastInvoiceSequenceForYear(
      lastSequence: profile.lastInvoiceSequence,
      lastSequenceYear: profile.lastInvoiceSequenceYear,
      year: year,
    );
    return formatInvoiceNumber(
      profile.invoiceNumberFormat,
      number: last + 1,
      issuedOn: issuedOn,
    );
  }

  Future<void> noteInvoiceNumberUsed(String number, DateTime issuedOn) async {
    final company = await getCompany();
    final sequence = parseInvoiceSequence(number, company.invoiceNumberFormat);
    if (sequence == null) {
      return;
    }
    final year = issuedOn.year;
    final last = lastInvoiceSequenceForYear(
      lastSequence: company.lastInvoiceSequence,
      lastSequenceYear: company.lastInvoiceSequenceYear,
      year: year,
    );
    if (sequence <= last) {
      return;
    }
    await into(companyProfiles).insertOnConflictUpdate(
      CompanyProfilesCompanion(
        id: const Value(companyRowId),
        lastInvoiceSequence: Value(sequence),
        lastInvoiceSequenceYear: Value(year),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<Invoice> saveInvoice({
    int? id,
    required InvoicesCompanion data,
    required List<InvoiceLineInput> lines,
  }) {
    return transaction(() async {
      final now = DateTime.now();
      final total = lines.fold<double>(
        0,
        (sum, line) => sum + (line.quantity * line.unitPrice),
      );
      final withTotal = data.copyWith(total: Value(total));

      final Invoice invoice;
      if (id == null) {
        invoice = await into(invoices).insertReturning(
          withTotal.copyWith(
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
      } else {
        final rows = await (update(invoices)
              ..where((row) => row.id.equals(id)))
            .writeReturning(
          withTotal.copyWith(updatedAt: Value(now)),
        );
        invoice = rows.single;
        await (delete(invoiceLines)
              ..where((row) => row.invoiceId.equals(id)))
            .go();
      }

      await batch((b) {
        b.insertAll(invoiceLines, [
          for (var i = 0; i < lines.length; i++)
            InvoiceLinesCompanion.insert(
              invoiceId: invoice.id,
              description: Value(lines[i].description),
              quantity: Value(lines[i].quantity),
              unitPrice: Value(lines[i].unitPrice),
              sortOrder: Value(i),
            ),
        ]);
      });

      await noteInvoiceNumberUsed(invoice.number, invoice.issuedOn);
      return invoice;
    });
  }

  Future<void> deleteInvoice(int id) {
    return (delete(invoices)..where((row) => row.id.equals(id))).go();
  }

  Future<void> clearAllData() {
    return transaction(() async {
      await delete(invoiceLines).go();
      await delete(invoices).go();
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
