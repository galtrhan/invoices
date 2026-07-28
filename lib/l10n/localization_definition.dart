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
  String get navCollapse => _('nav_collapse');
  String get navExpand => _('nav_expand');

  // Settings
  String get settingsTitle => _('settings_title');
  String get settingsSubtitle => _('settings_subtitle');
  String get settingsAppearance => _('settings_appearance');
  String get settingsTheme => _('settings_theme');
  String get settingsMode => _('settings_mode');
  String get settingsLight => _('settings_light');
  String get settingsDark => _('settings_dark');
  String get settingsLanguage => _('settings_language');
  String get settingsPdfTemplate => _('settings_pdf_template');
  String get settingsData => _('settings_data');
  String get settingsResetBody => _('settings_reset_body');
  String get settingsResetButton => _('settings_reset_button');
  String get settingsResetConfirmTitle => _('settings_reset_confirm_title');
  String get settingsResetConfirmBody => _('settings_reset_confirm_body');
  String get settingsResetConfirmAction => _('settings_reset_confirm_action');
  String get settingsCancel => _('settings_cancel');
  String get settingsResetDone => _('settings_reset_done');
  String get settingsResetFailed => _('settings_reset_failed');
  String get settingsPreferences => _('settings_preferences');
  String get settingsRestoreBody => _('settings_restore_body');
  String get settingsRestoreButton => _('settings_restore_button');
  String get settingsRestoreConfirmTitle => _('settings_restore_confirm_title');
  String get settingsRestoreConfirmBody => _('settings_restore_confirm_body');
  String get settingsRestoreConfirmAction => _('settings_restore_confirm_action');
  String get settingsRestoreDone => _('settings_restore_done');
  String get settingsRestoreFailed => _('settings_restore_failed');

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
  String get invoicesSectionJobs => _('invoices_section_jobs');
  String get invoicesSectionJobsBody => _('invoices_section_jobs_body');
  String get invoicesAddJobLine => _('invoices_add_job_line');
  String get invoicesSectionHistory => _('invoices_section_history');
  String get invoicesSectionHistoryBody => _('invoices_section_history_body');
  String get invoicesSave => _('invoices_save');
  String get invoicesExport => _('invoices_export');
  String get invoicesExportLanguage => _('invoices_export_language');
  String get invoicesExportTemplate => _('invoices_export_template');
  String get invoicesExportDialogTitle => _('invoices_export_dialog_title');
  String get invoicesExportConfirm => _('invoices_export_confirm');
  String get invoicesExported => _('invoices_exported');
  String get invoicesExportFailed => _('invoices_export_failed');
  String get invoicesExportSaveFirst => _('invoices_export_save_first');
  String get invoicesPreviewTitle => _('invoices_preview_title');
  String get invoicesPreviewSave => _('invoices_preview_save');
  String get invoicesPreviewCancel => _('invoices_preview_cancel');
  String get invoicesFieldNumber => _('invoices_field_number');
  String get invoicesFieldIssued => _('invoices_field_issued');
  String get invoicesFieldDescription => _('invoices_field_description');
  String get invoicesFieldQuantity => _('invoices_field_quantity');
  String get invoicesFieldUnitPrice => _('invoices_field_unit_price');
  String get invoicesFieldTotal => _('invoices_field_total');
  String get invoicesClientPlaceholder => _('invoices_client_placeholder');
  String get invoicesNoClients => _('invoices_no_clients');
  String get invoicesClientRequired => _('invoices_client_required');
  String get invoicesInvalidAmount => _('invoices_invalid_amount');
  String get invoicesCreated => _('invoices_created');
  String get invoicesSaved => _('invoices_saved');
  String get invoicesSaveFailed => _('invoices_save_failed');
  String get invoicesLoadFailed => _('invoices_load_failed');
  String get invoicesDelete => _('invoices_delete');
  String get invoicesDeleteConfirmTitle => _('invoices_delete_confirm_title');
  String get invoicesDeleteConfirmBody => _('invoices_delete_confirm_body');
  String get invoicesDeleteConfirmAction => _('invoices_delete_confirm_action');
  String get invoicesDeleted => _('invoices_deleted');
  String get invoicesDeleteFailed => _('invoices_delete_failed');
  String get invoicesRemoveJobLine => _('invoices_remove_job_line');

  // Invoice PDF
  String get pdfInvoiceTitle => _('pdf_invoice_title');
  String get pdfNumberPrefix => _('pdf_number_prefix');
  String get pdfRegNo => _('pdf_reg_no');
  String get pdfPayer => _('pdf_payer');
  String get pdfTel => _('pdf_tel');
  String get pdfEmail => _('pdf_email');
  String get pdfService => _('pdf_service');
  String get pdfUnit => _('pdf_unit');
  String get pdfAmount => _('pdf_amount');
  String get pdfPrice => _('pdf_price');
  String get pdfSumHeader => _('pdf_sum_header');
  String get pdfPayBy => _('pdf_pay_by');
  String get pdfSum => _('pdf_sum');
  String get pdfPaymentAmount => _('pdf_payment_amount');
  String get pdfAmountInWords => _('pdf_amount_in_words');
  String get pdfElectronicFooter => _('pdf_electronic_footer');

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
  String get clientsFieldPdfTemplate => _('clients_field_pdf_template');
  String get clientsPdfTemplateDefault => _('clients_pdf_template_default');
  String get clientsLogoTitle => _('clients_logo_title');
  String get clientsLogoSubtitle => _('clients_logo_subtitle');
  String get clientsCreate => _('clients_create');
  String get clientsSave => _('clients_save');
  String get clientsCreated => _('clients_created');
  String get clientsSaved => _('clients_saved');
  String get clientsSaveFailed => _('clients_save_failed');
  String get clientsLoadFailed => _('clients_load_failed');
  String get clientsViewHistory => _('clients_view_history');
  String get clientsDelete => _('clients_delete');
  String get clientsDeleteConfirmTitle => _('clients_delete_confirm_title');
  String get clientsDeleteConfirmBody => _('clients_delete_confirm_body');
  String get clientsDeleteConfirmAction => _('clients_delete_confirm_action');
  String get clientsDeleted => _('clients_deleted');
  String get clientsDeleteFailed => _('clients_delete_failed');
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
  String get companyFieldInvoiceNumberFormat =>
      _('company_field_invoice_number_format');
  String get companyFieldInvoiceNumberFormatHint =>
      _('company_field_invoice_number_format_hint');
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
      'nav_collapse': 'Collapse sidebar',
      'nav_expand': 'Expand sidebar',
      'settings_title': 'Settings',
      'settings_subtitle': 'Application preferences',
      'settings_appearance': 'Appearance',
      'settings_theme': 'Theme',
      'settings_mode': 'Mode',
      'settings_light': 'Light',
      'settings_dark': 'Dark',
      'settings_language': 'Language',
      'settings_pdf_template': 'PDF template',
      'settings_data': 'Data',
      'settings_reset_body':
          'Delete invoices, clients, company details, and logos. '
          'Theme and language stay the same.',
      'settings_reset_button': 'Delete all data',
      'settings_reset_confirm_title': 'Delete all data?',
      'settings_reset_confirm_body':
          'This removes invoices, clients, company details, and stored logos. '
          'You cannot undo this action. Preferences stay unchanged.',
      'settings_reset_confirm_action': 'Delete',
      'settings_cancel': 'Cancel',
      'settings_reset_done': 'Application data deleted',
      'settings_reset_failed': 'Could not delete application data',
      'settings_preferences': 'Preferences',
      'settings_restore_body':
          'Restore preferences to the defaults. '
          'Clients and company data stay unchanged.',
      'settings_restore_button': 'Restore default settings',
      'settings_restore_confirm_title': 'Restore default settings?',
      'settings_restore_confirm_body':
          'This resets preferences to the defaults. '
          'Clients and company data stay unchanged.',
      'settings_restore_confirm_action': 'Restore',
      'settings_restore_done': 'Settings restored to defaults',
      'settings_restore_failed': 'Could not restore settings',
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
      'invoices_section_jobs': 'Jobs',
      'invoices_section_jobs_body':
          'Add line items with description, quantity, and price.',
      'invoices_add_job_line': 'Add job line',
      'invoices_section_history': 'History',
      'invoices_section_history_body':
          'When regenerating: default = as saved at invoice time. Optional = use current client/company data.',
      'invoices_save': 'Save invoice',
      'invoices_export': 'Export',
      'invoices_export_language': 'PDF language',
      'invoices_export_template': 'PDF template',
      'invoices_export_dialog_title': 'Export PDF',
      'invoices_export_confirm': 'Preview',
      'invoices_exported': 'Invoice PDF saved',
      'invoices_export_failed': 'Could not export invoice PDF',
      'invoices_export_save_first': 'Save the invoice before you export.',
      'invoices_preview_title': 'Preview invoice',
      'invoices_preview_save': 'Save',
      'invoices_preview_cancel': 'Cancel',
      'invoices_field_number': 'Invoice number',
      'invoices_field_issued': 'Issue date',
      'invoices_field_description': 'Description',
      'invoices_field_quantity': 'Quantity',
      'invoices_field_unit_price': 'Unit price',
      'invoices_field_total': 'Total',
      'invoices_client_placeholder': 'Select a client',
      'invoices_no_clients': 'Add a client before you create an invoice.',
      'invoices_client_required': 'Select a client before you save.',
      'invoices_invalid_amount':
          'Enter valid numbers for quantity and unit price.',
      'invoices_created': 'Invoice created',
      'invoices_saved': 'Invoice saved',
      'invoices_save_failed': 'Could not save invoice',
      'invoices_load_failed': 'Could not load invoices',
      'invoices_delete': 'Delete invoice',
      'invoices_delete_confirm_title': 'Delete this invoice?',
      'invoices_delete_confirm_body':
          'This removes the invoice and its job lines. You cannot undo this action.',
      'invoices_delete_confirm_action': 'Delete',
      'invoices_deleted': 'Invoice deleted',
      'invoices_delete_failed': 'Could not delete invoice',
      'invoices_remove_job_line': 'Remove',
      'pdf_invoice_title': 'INVOICE',
      'pdf_number_prefix': 'No.',
      'pdf_reg_no': 'Reg. No.:',
      'pdf_payer': 'Payer:',
      'pdf_tel': 'Tel:',
      'pdf_email': 'E.mail:',
      'pdf_service': 'Service',
      'pdf_unit': 'Unit',
      'pdf_amount': 'Amount',
      'pdf_price': 'Price',
      'pdf_sum_header': 'SUM',
      'pdf_pay_by': 'Pay by:',
      'pdf_sum': 'Sum:',
      'pdf_payment_amount': 'Payment amount:',
      'pdf_amount_in_words': 'Amount in words:',
      'pdf_electronic_footer':
          'The invoice has been prepared electronically and is valid without a signature',
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
      'clients_field_pdf_template': 'PDF template',
      'clients_pdf_template_default': 'Use default',
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
      'clients_delete': 'Delete client',
      'clients_delete_confirm_title': 'Delete this client?',
      'clients_delete_confirm_body':
          'This removes the client and its logo. Past invoices keep their saved details.',
      'clients_delete_confirm_action': 'Delete',
      'clients_deleted': 'Client deleted',
      'clients_delete_failed': 'Could not delete client',
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
      'company_field_invoice_number_format': 'Invoice number format',
      'company_field_invoice_number_format_hint':
          'Use {number} and DateFormat patterns like {yyyy} or {yyyy-MM-dd}. Default {number}/{yyyy} makes 1/2026. The sequence resets each year.',
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
