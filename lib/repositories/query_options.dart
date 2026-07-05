class DestinationQueryOptions {
  final String? search;
  final String? category;
  final String? sortBy;
  final String? sortDirection;
  final int? page;
  final int? pageSize;

  const DestinationQueryOptions({
    this.search,
    this.category,
    this.sortBy,
    this.sortDirection,
    this.page,
    this.pageSize,
  });

  Map<String, dynamic> toVariables() {
    return {
      if (search != null && search!.trim().isNotEmpty) 'search': search!.trim(),
      if (category != null && category!.trim().isNotEmpty) 'category': category!.trim(),
      if (sortBy != null && sortBy!.trim().isNotEmpty) 'sortBy': sortBy!.trim(),
      if (sortDirection != null && sortDirection!.trim().isNotEmpty)
        'sortDirection': sortDirection!.trim(),
      if (page != null) 'page': page,
      if (pageSize != null) 'pageSize': pageSize,
    };
  }
}

class BookingQueryOptions {
  final String? userId;
  final String? status;
  final String? sortBy;
  final String? sortDirection;
  final int? page;
  final int? pageSize;

  const BookingQueryOptions({
    this.userId,
    this.status,
    this.sortBy,
    this.sortDirection,
    this.page,
    this.pageSize,
  });

  Map<String, dynamic> toVariables() {
    return {
      if (userId != null && userId!.trim().isNotEmpty) 'userId': userId!.trim(),
      if (status != null && status!.trim().isNotEmpty) 'status': status!.trim(),
      if (sortBy != null && sortBy!.trim().isNotEmpty) 'sortBy': sortBy!.trim(),
      if (sortDirection != null && sortDirection!.trim().isNotEmpty)
        'sortDirection': sortDirection!.trim(),
      if (page != null) 'page': page,
      if (pageSize != null) 'pageSize': pageSize,
    };
  }
}
