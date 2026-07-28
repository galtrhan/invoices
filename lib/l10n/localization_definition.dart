import 'package:flutter/widgets.dart';

/// UI string pack. Built-in English is always available; JSON packs overlay keys.
@immutable
class LocalizationDefinition {
  const LocalizationDefinition({
    required this.name,
    required Map<String, String> strings,
  }) : _strings = strings;

  static const defaultName = 'English';

  final String name;
  final Map<String, String> _strings;

  String _(String key) => _strings[key] ?? key;

  // Nav
  String get navInvoices => _('nav_invoices');
  String get navClients => _('nav_clients');
  String get navCompany => _('nav_company');
  String get navSettings => _('nav_settings');

  // Settings
  String get settingsTitle => _('settings_title');
  String get settingsSubtitle => _('settings_subtitle');
  String get settingsAppearance => _('settings_appearance');
  String get settingsTheme => _('settings_theme');
  String get settingsMode => _('settings_mode');
  String get settingsLight => _('settings_light');
  String get settingsDark => _('settings_dark');
  String get settingsLanguage => _('settings_language');

  // Invoices
  String get invoicesTitle => _('invoices_title');
  String get invoicesSubtitle => _('invoices_subtitle');
  String get invoicesNew => _('invoices_new');
  String get invoicesNoneSelectedTitle => _('invoices_none_selected_title');
  String get invoicesNoneSelectedMessage => _('invoices_none_selected_message');
  String get invoicesEmptyTitle => _('invoices_empty_title');
  String get invoicesEmptyMessage => _('invoices_empty_message');
  String get invoicesEditorNew => _('invoices_editor_new');
  String get invoicesEditorCreateHint => _('invoices_editor_create_hint');
  String get invoicesEditorViewHint => _('invoices_editor_view_hint');
  String get invoicesSectionClient => _('invoices_section_client');
  String get invoicesSectionClientBody => _('invoices_section_client_body');
  String get invoicesSectionCompany => _('invoices_section_company');
  String get invoicesSectionCompanyBody => _('invoices_section_company_body');
  String get invoicesSectionJobs => _('invoices_section_jobs');
  String get invoicesSectionJobsBody => _('invoices_section_jobs_body');
  String get invoicesAddJobLine => _('invoices_add_job_line');
  String get invoicesSectionHistory => _('invoices_section_history');
  String get invoicesSectionHistoryBody => _('invoices_section_history_body');
  String get invoicesSave => _('invoices_save');
  String get invoicesPreview => _('invoices_preview');

  // Clients
  String get clientsTitle => _('clients_title');
  String get clientsSubtitle => _('clients_subtitle');
  String get clientsNew => _('clients_new');
  String get clientsNoneSelectedTitle => _('clients_none_selected_title');
  String get clientsNoneSelectedMessage => _('clients_none_selected_message');
  String get clientsEmptyTitle => _('clients_empty_title');
  String get clientsEmptyMessage => _('clients_empty_message');
  String get clientsEditorNew => _('clients_editor_new');
  String get clientsEditorHint => _('clients_editor_hint');
  String get clientsFieldName => _('clients_field_name');
  String get clientsFieldEmail => _('clients_field_email');
  String get clientsFieldPhone => _('clients_field_phone');
  String get clientsFieldTax => _('clients_field_tax');
  String get clientsFieldAddress => _('clients_field_address');
  String get clientsFieldNotes => _('clients_field_notes');
  String get clientsLogoTitle => _('clients_logo_title');
  String get clientsLogoSubtitle => _('clients_logo_subtitle');
  String get clientsCreate => _('clients_create');
  String get clientsSave => _('clients_save');
  String get clientsCreated => _('clients_created');
  String get clientsSaved => _('clients_saved');
  String get clientsSaveFailed => _('clients_save_failed');
  String get clientsLoadFailed => _('clients_load_failed');
  String get clientsViewHistory => _('clients_view_history');
  String get logoUpload => _('logo_upload');
  String get logoRemove => _('logo_remove');
  String get logoImportFailed => _('logo_import_failed');

  // Company
  String get companyTitle => _('company_title');
  String get companySubtitle => _('company_subtitle');
  String get companyProfile => _('company_profile');
  String get companyHint => _('company_hint');
  String get companyCardEmpty => _('company_card_empty');
  String get companyLogoTitle => _('company_logo_title');
  String get companyLogoSubtitle => _('company_logo_subtitle');
  String get companyFieldName => _('company_field_name');
  String get companyFieldEmail => _('company_field_email');
  String get companyFieldPhone => _('company_field_phone');
  String get companyFieldTax => _('company_field_tax');
  String get companyFieldAddress => _('company_field_address');
  String get companyFieldPayment => _('company_field_payment');
  String get companyFieldNotes => _('company_field_notes');
  String get companySave => _('company_save');
  String get companySaved => _('company_saved');
  String get companySaveFailed => _('company_save_failed');
  String get companyLoadFailed => _('company_load_failed');
  String get companyViewHistory => _('company_view_history');

  static final LocalizationDefinition builtinEnglish = LocalizationDefinition(
    name: defaultName,
    strings: const {
      'nav_invoices': 'Invoices',
      'nav_clients': 'Clients',
      'nav_company': 'Company',
      'nav_settings': 'Settings',
      'settings_title': 'Settings',
      'settings_subtitle': 'Application preferences',
      'settings_appearance': 'Appearance',
      'settings_theme': 'Theme',
      'settings_mode': 'Mode',
      'settings_light': 'Light',
      'settings_dark': 'Dark',
      'settings_language': 'Language',
      'invoices_title': 'Invoices',
      'invoices_subtitle':
          'Generate invoices from clients, company, and job lines',
      'invoices_new': 'New invoice',
      'invoices_none_selected_title': 'No invoice selected',
      'invoices_none_selected_message':
          'Create an invoice or select one from the list. '
          'Client and company details are pulled in automatically.',
      'invoices_empty_title': 'No invoices yet',
      'invoices_empty_message':
          'Start with a job list and pricing. Client and company data fill in from their sections.',
      'invoices_editor_new': 'New invoice',
      'invoices_editor_create_hint':
          'Pick a client, enter jobs and pricing, then preview.',
      'invoices_editor_view_hint':
          'Saved snapshot of client and company is used by default.',
      'invoices_section_client': 'Client',
      'invoices_section_client_body':
          'Select a client. Past invoices keep the client details from when they were issued; you can switch to current data when regenerating.',
      'invoices_section_company': 'Company',
      'invoices_section_company_body':
          'Your company details are pulled from the Company section and snapshotted onto this invoice.',
      'invoices_section_jobs': 'Jobs',
      'invoices_section_jobs_body':
          'Add line items with description, quantity, and price.',
      'invoices_add_job_line': 'Add job line',
      'invoices_section_history': 'History',
      'invoices_section_history_body':
          'When regenerating: default = as saved at invoice time. Optional = use current client/company data.',
      'invoices_save': 'Save invoice',
      'invoices_preview': 'Preview',
      'clients_title': 'Clients',
      'clients_subtitle': 'Invoice parties with contact details and logo',
      'clients_new': 'New client',
      'clients_none_selected_title': 'No client selected',
      'clients_none_selected_message':
          'Clients supply the bill-to block on invoices. Edits are versioned so past invoices keep historical details.',
      'clients_empty_title': 'No clients yet',
      'clients_empty_message': 'Add the businesses or people you invoice.',
      'clients_editor_new': 'New client',
      'clients_editor_hint':
          'Changes are kept historically so regenerating an old invoice can use the details from that time.',
      'clients_field_name': 'Name',
      'clients_field_email': 'Email',
      'clients_field_phone': 'Phone',
      'clients_field_tax': 'Tax / VAT ID',
      'clients_field_address': 'Address',
      'clients_field_notes': 'Contact notes',
      'clients_logo_title': 'Logo',
      'clients_logo_subtitle': 'Used on invoices for this client when relevant.',
      'logo_upload': 'Upload',
      'logo_remove': 'Remove',
      'logo_import_failed': 'Could not import image',
      'clients_create': 'Create client',
      'clients_save': 'Save changes',
      'clients_created': 'Client created',
      'clients_saved': 'Client saved',
      'clients_save_failed': 'Could not save client',
      'clients_load_failed': 'Could not load clients',
      'clients_view_history': 'View history',
      'company_title': 'Company',
      'company_subtitle': 'Your business details for the invoice header',
      'company_profile': 'Business profile',
      'company_hint':
          'Edits are versioned like clients. Past invoices keep the company block from when they were issued.',
      'company_card_empty': 'Your company',
      'company_logo_title': 'Company logo',
      'company_logo_subtitle': 'Shown on every new invoice snapshot.',
      'company_field_name': 'Company name',
      'company_field_email': 'Email',
      'company_field_phone': 'Phone',
      'company_field_tax': 'Tax / VAT ID',
      'company_field_address': 'Address',
      'company_field_payment': 'Payment / bank details',
      'company_field_notes': 'Contact notes',
      'company_save': 'Save company',
      'company_saved': 'Company saved',
      'company_save_failed': 'Could not save company',
      'company_load_failed': 'Could not load company',
      'company_view_history': 'View history',
    },
  );

  factory LocalizationDefinition.fromJson(Map<String, Object?> json) {
    final name = json['name'];
    if (name is! String || name.trim().isEmpty) {
      throw const FormatException('Localization JSON missing "name"');
    }

    final raw = json['strings'];
    if (raw is! Map) {
      throw const FormatException('Localization JSON requires "strings"');
    }

    final strings = <String, String>{};
    for (final entry in raw.entries) {
      final key = entry.key;
      final value = entry.value;
      if (key is String && value is String && value.isNotEmpty) {
        strings[key] = value;
      }
    }

    return LocalizationDefinition(
      name: name.trim(),
      strings: {...builtinEnglish._strings, ...strings},
    );
  }
}


/// Provides the active [LocalizationDefinition] down the tree.
class AppLocalizations extends InheritedWidget {
  const AppLocalizations({
    super.key,
    required this.strings,
    required super.child,
  });

  final LocalizationDefinition strings;

  static LocalizationDefinition of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppLocalizations>();
    assert(scope != null, 'AppLocalizations not found in context');
    return scope!.strings;
  }

  @override
  bool updateShouldNotify(AppLocalizations oldWidget) =>
      !identical(strings, oldWidget.strings);
}
