// Moved from starter-for-flutter/lib/data/models/log.dart

class Log {
  final String date;
  final int status;
  final String method;
  final String path;
  final dynamic response;

  Log({
    required this.date,
    required this.status,
    required this.method,
    required this.path,
    required this.response,
  });
}
