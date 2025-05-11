class PageData<T> {
  final List<T> dataList;
  final int totalCount;
  final int pageIndex;
  final int pageSize;

  PageData({
    required this.dataList,
    required this.totalCount,
    required this.pageIndex,
    required this.pageSize,
  });

  factory PageData.fromJson(Map<String, dynamic> json, T Function(dynamic json) fromJsonT) {
    return PageData(
      dataList: (json['dataList'] as List<dynamic>?)
              ?.map((item) => fromJsonT(item as Map<String, dynamic>)) // Ensure item is Map
              .toList() ??
          [],
      totalCount: json['totalCount'] as int? ?? 0,
      pageIndex: json['pageIndex'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 0,
    );
  }
}