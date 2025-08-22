class AppUrls {
  // Base URLs
  static const String baseUrl = 'https://paintpro.barbatech.company/api';
  static const String baseUrlDev = 'http://localhost:8090/api';

  // Auth URLs
  static const String authBaseUrl = '/auth';
  static const String authStatusUrl = '$authBaseUrl/status';
  static const String authCallbackUrl = '$authBaseUrl/callback';
  static const String authRefreshUrl = '$authBaseUrl/refresh';

  // Deep Link URLs
  static const String deepLinkBaseUrl = 'paintproapp://auth';
  static const String deepLinkSuccess = 'paintproapp://auth/success';
  static const String deepLinkError = 'paintproapp://auth/error';

  // GoHighLevel Marketplace Authorization URL
  static const String goHighLevelAuthorizeUrl =
      'https://marketplace.gohighlevel.com/oauth/chooselocation?response_type=code&redirect_uri=https%3A%2F%2Fpaintpro.barbatech.company%2Fapi%2Fauth%2Fcallback&client_id=6845ab8de6772c0d5c8548d7-mbnty1f6&scope=contacts.write+associations.write+associations.readonly+oauth.readonly+oauth.write+invoices%2Festimate.write+invoices%2Festimate.readonly+invoices.readonly+associations%2Frelation.write+associations%2Frelation.readonly+contacts.readonly+invoices.write';
  static const String goHighLevelAuthorizeUrlDev =
      'https://marketplace.gohighlevel.com/oauth/chooselocation?response_type=code&redirect_uri=http%3A%2F%2Flocalhost%3A8080%2Fapi%2Fauth%2Fcallback&client_id=6845ab8de6772c0d5c8548d7-mbnty1f6&scope=contacts.write+associations.write+associations.readonly+oauth.readonly+oauth.write+invoices%2Festimate.write+invoices%2Festimate.readonly+invoices.readonly+associations%2Frelation.write+associations%2Frelation.readonly+contacts.readonly+invoices.write+businesses.readonly+locations.readonly';

  // Contact URLs
  static const String contactsBaseUrl = '/contacts';
  static const String contactsListUrl = '$contactsBaseUrl/list';
  static const String contactsSearchUrl = '$contactsBaseUrl/search';
  static const String contactsCreateUrl = '$contactsBaseUrl/create';
  static const String contactsUpdateUrl = '$contactsBaseUrl/update';
  static const String contactsDeleteUrl = '$contactsBaseUrl/delete';

  // Estimate URLs
  static const String estimatesBaseUrl = '/estimates';
  static const String estimatesListUrl = '$estimatesBaseUrl/list';
  static const String estimatesCreateUrl = '$estimatesBaseUrl/create';
  static const String estimatesUpdateUrl = '$estimatesBaseUrl/update';
  static const String estimatesDeleteUrl = '$estimatesBaseUrl/delete';
  static const String estimatesUploadUrl = '$estimatesBaseUrl/upload';

  // Material URLs
  static const String materialsBaseUrl = '/materials';
  static const String materialsListUrl = '$materialsBaseUrl/list';
  static const String materialsStatsUrl = '$materialsBaseUrl/stats';

  // Paint Catalog URLs
  static const String paintCatalogBaseUrl = '/paint-catalog';
  static const String paintCatalogListUrl = '$paintCatalogBaseUrl/list';
  static const String paintCatalogDetailUrl = '$paintCatalogBaseUrl/detail';
}
