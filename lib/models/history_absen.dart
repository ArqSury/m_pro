// ignore_for_file: public_member_api_docs, sort_constructors_first
class HistoryAbsen {
  final int id;
  final String attendanceDate;
  final String? checkInTime;
  final String? checkOutTime;
  final double? checkInLat;
  final double? checkInLng;
  final double? checkOutLat;
  final double? checkOutLng;
  final String status;
  final String? alasanIzin;
  HistoryAbsen({
    required this.id,
    required this.attendanceDate,
    this.checkInTime,
    this.checkOutTime,
    this.checkInLat,
    this.checkInLng,
    this.checkOutLat,
    this.checkOutLng,
    required this.status,
    this.alasanIzin,
  });

  factory HistoryAbsen.fromJson(Map<String, dynamic> json) {
    return HistoryAbsen(
      id: json["id"],
      attendanceDate: json["attendance_date"],
      checkInTime: json["check_in_time"],
      checkOutTime: json["check_out_time"],
      checkInLat: json["check_in_lat"] == null
          ? null
          : (json["check_in_lat"] as num).toDouble(),
      checkInLng: json["check_in_lng"] == null
          ? null
          : (json["check_in_lng"] as num).toDouble(),
      checkOutLat: json["check_out_lat"] == null
          ? null
          : (json["check_out_lat"] as num).toDouble(),
      checkOutLng: json["check_out_lng"] == null
          ? null
          : (json["check_out_lng"] as num).toDouble(),
      status: json["status"],
      alasanIzin: json["alasan_izin"],
    );
  }
}
