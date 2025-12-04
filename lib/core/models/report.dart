class Report {
  final String id;
  final String name;
  final String type;
  final DateTime generatedDate;
  final DateTime startDate;
  final DateTime endDate;
  final String generatedBy;
  final String generatedByEmail;
  final Map<String, dynamic> data;
  final String summary;
  final String status;

  Report({
    required this.id,
    required this.name,
    required this.type,
    required this.generatedDate,
    required this.startDate,
    required this.endDate,
    required this.generatedBy,
    required this.generatedByEmail,
    required this.data,
    required this.summary,
    required this.status,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      generatedDate: json['generatedDate'] != null
          ? DateTime.parse(json['generatedDate'] as String)
          : DateTime.now(),
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : DateTime.now(),
      generatedBy: json['generatedBy'] as String? ?? '',
      generatedByEmail: json['generatedByEmail'] as String? ?? '',
      data: json['data'] as Map<String, dynamic>? ?? {},
      summary: json['summary'] as String? ?? '',
      status: json['status'] as String? ?? 'Completed',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'generatedDate': generatedDate.toIso8601String(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'generatedBy': generatedBy,
      'generatedByEmail': generatedByEmail,
      'data': data,
      'summary': summary,
      'status': status,
    };
  }
}

// Models for different report types
class SalesReportData {
  final String reportType;
  final DateTime startDate;
  final DateTime endDate;
  final double totalSales;
  final int totalBookings;
  final double averageBookingValue;
  final List<DailyBreakdown> dailyBreakdown;

  SalesReportData({
    required this.reportType,
    required this.startDate,
    required this.endDate,
    required this.totalSales,
    required this.totalBookings,
    required this.averageBookingValue,
    required this.dailyBreakdown,
  });

  factory SalesReportData.fromJson(Map<String, dynamic> json) {
    return SalesReportData(
      reportType: json['reportType'] as String? ?? 'Sales',
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalSales: (json['totalSales'] as num?)?.toDouble() ?? 0.0,
      totalBookings: json['totalBookings'] as int? ?? 0,
      averageBookingValue: (json['averageBookingValue'] as num?)?.toDouble() ?? 0.0,
      dailyBreakdown: (json['dailyBreakdown'] as List?)
              ?.map((e) => DailyBreakdown.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class DailyBreakdown {
  final DateTime date;
  final double sales;
  final int count;

  DailyBreakdown({
    required this.date,
    required this.sales,
    required this.count,
  });

  factory DailyBreakdown.fromJson(Map<String, dynamic> json) {
    return DailyBreakdown(
      date: DateTime.parse(json['date'] as String),
      sales: (json['sales'] as num?)?.toDouble() ?? 0.0,
      count: json['count'] as int? ?? 0,
    );
  }
}

class MoviePopularityReportData {
  final String reportType;
  final DateTime startDate;
  final DateTime endDate;
  final List<MovieStats> topMovies;

  MoviePopularityReportData({
    required this.reportType,
    required this.startDate,
    required this.endDate,
    required this.topMovies,
  });

  factory MoviePopularityReportData.fromJson(Map<String, dynamic> json) {
    return MoviePopularityReportData(
      reportType: json['reportType'] as String? ?? 'Movie Popularity',
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      topMovies: (json['topMovies'] as List?)
              ?.map((e) => MovieStats.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class MovieStats {
  final String movieId;
  final String title;
  final int bookings;
  final double revenue;

  MovieStats({
    required this.movieId,
    required this.title,
    required this.bookings,
    required this.revenue,
  });

  factory MovieStats.fromJson(Map<String, dynamic> json) {
    return MovieStats(
      movieId: json['movieId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      bookings: json['bookings'] as int? ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class OccupancyReportData {
  final String reportType;
  final DateTime startDate;
  final DateTime endDate;
  final int totalScreenings;
  final int averageOccupancyRate;
  final List<ScreeningsByDay> screeningsByDay;

  OccupancyReportData({
    required this.reportType,
    required this.startDate,
    required this.endDate,
    required this.totalScreenings,
    required this.averageOccupancyRate,
    required this.screeningsByDay,
  });

  factory OccupancyReportData.fromJson(Map<String, dynamic> json) {
    return OccupancyReportData(
      reportType: json['reportType'] as String? ?? 'Occupancy',
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalScreenings: json['totalScreenings'] as int? ?? 0,
      averageOccupancyRate: json['averageOccupancyRate'] as int? ?? 0,
      screeningsByDay: (json['screeningsByDay'] as List?)
              ?.map((e) => ScreeningsByDay.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ScreeningsByDay {
  final DateTime date;
  final int count;

  ScreeningsByDay({
    required this.date,
    required this.count,
  });

  factory ScreeningsByDay.fromJson(Map<String, dynamic> json) {
    return ScreeningsByDay(
      date: DateTime.parse(json['date'] as String),
      count: json['count'] as int? ?? 0,
    );
  }
}

class RevenueReportData {
  final String reportType;
  final DateTime startDate;
  final DateTime endDate;
  final double totalRevenue;
  final double ticketRevenue;
  final double foodRevenue;
  final RevenueBreakdown breakdown;

  RevenueReportData({
    required this.reportType,
    required this.startDate,
    required this.endDate,
    required this.totalRevenue,
    required this.ticketRevenue,
    required this.foodRevenue,
    required this.breakdown,
  });

  factory RevenueReportData.fromJson(Map<String, dynamic> json) {
    return RevenueReportData(
      reportType: json['reportType'] as String? ?? 'Revenue',
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      ticketRevenue: (json['ticketRevenue'] as num?)?.toDouble() ?? 0.0,
      foodRevenue: (json['foodRevenue'] as num?)?.toDouble() ?? 0.0,
      breakdown: RevenueBreakdown.fromJson(json['breakdown'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class RevenueBreakdown {
  final RevenueItem tickets;
  final RevenueItem food;

  RevenueBreakdown({
    required this.tickets,
    required this.food,
  });

  factory RevenueBreakdown.fromJson(Map<String, dynamic> json) {
    return RevenueBreakdown(
      tickets: RevenueItem.fromJson(json['tickets'] as Map<String, dynamic>? ?? {}),
      food: RevenueItem.fromJson(json['food'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class RevenueItem {
  final double revenue;
  final double percentage;

  RevenueItem({
    required this.revenue,
    required this.percentage,
  });

  factory RevenueItem.fromJson(Map<String, dynamic> json) {
    return RevenueItem(
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DashboardSummary {
  final int totalMovies;
  final int totalScreenings;
  final int todayScreenings;
  final int totalFoodCombos;
  final int totalBookings;
  final int todayBookings;
  final int totalUsers;
  final double todayRevenue;

  DashboardSummary({
    required this.totalMovies,
    required this.totalScreenings,
    required this.todayScreenings,
    required this.totalFoodCombos,
    required this.totalBookings,
    required this.todayBookings,
    required this.totalUsers,
    required this.todayRevenue,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalMovies: json['totalMovies'] as int? ?? 0,
      totalScreenings: json['totalScreenings'] as int? ?? 0,
      todayScreenings: json['todayScreenings'] as int? ?? 0,
      totalFoodCombos: json['totalFoodCombos'] as int? ?? 0,
      totalBookings: json['totalBookings'] as int? ?? 0,
      todayBookings: json['todayBookings'] as int? ?? 0,
      totalUsers: json['totalUsers'] as int? ?? 0,
      todayRevenue: (json['todayRevenue'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
