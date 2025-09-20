class ContactSearchRequest {
  final String? locationId;
  final int? pageLimit;
  final int? page;
  final String? query;
  final List<Map<String, dynamic>>? filters;
  final List<Map<String, dynamic>>? sort;

  ContactSearchRequest({
    this.locationId,
    this.pageLimit,
    this.page,
    this.query,
    this.filters,
    this.sort,
  });

  Map<String, dynamic> toJson() {
    return {
      'locationId': locationId,
      'pageLimit': pageLimit,
      'page': page,
      'query': query,
      'filters': filters,
      'sort': sort,
    };
  }
}
