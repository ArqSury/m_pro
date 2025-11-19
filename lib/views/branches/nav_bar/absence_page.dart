import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:m_pro/function/detail_dialog.dart';
import 'package:m_pro/services/api.dart';
import 'package:m_pro/views/branches/map_view.dart';

class AbsencePage extends StatefulWidget {
  const AbsencePage({super.key});

  @override
  State<AbsencePage> createState() => _AbsencePageState();
}

class _AbsencePageState extends State<AbsencePage> {
  bool loading = true;
  List history = [];

  DateTimeRange? selectedRange;
  DateTime? selectedSingleDate;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  // ---------------- GROUPING ----------------
  Map<String, List<dynamic>> groupByMonth(List data) {
    final Map<String, List<dynamic>> result = {};

    for (var item in data) {
      final date = DateTime.parse(item["attendance_date"]);
      final key = DateFormat("MMMM yyyy", "id_ID").format(date);

      if (!result.containsKey(key)) {
        result[key] = [];
      }
      result[key]!.add(item);
    }

    return result;
  }

  // ---------------- LOAD DATA ----------------
  Future<void> loadHistory({DateTimeRange? range, DateTime? singleDate}) async {
    setState(() => loading = true);

    String? start;
    String? end;

    if (range != null) {
      start = DateFormat("yyyy-MM-dd").format(range.start);
      end = DateFormat("yyyy-MM-dd").format(range.end);
    }

    if (singleDate != null) {
      start = DateFormat("yyyy-MM-dd").format(singleDate);
      end = start;
    }

    final data = await AuthAPI.getHistory(start: start, end: end);

    data.sort(
      (a, b) => b["attendance_date"].toString().compareTo(a["attendance_date"]),
    );

    setState(() {
      history = data;
      loading = false;
    });
  }

  // RANGE DATE PICKER
  Future<void> pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );

    if (range != null) {
      selectedRange = range;
      selectedSingleDate = null;
      await loadHistory(range: range);
    }
  }

  // SINGLE DATE PICKER
  Future<void> pickSingleDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),
    );

    if (date != null) {
      selectedSingleDate = date;
      selectedRange = null;
      await loadHistory(singleDate: date);
    }
  }

  void resetFilter() {
    selectedRange = null;
    selectedSingleDate = null;
    loadHistory();
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final grouped = groupByMonth(history);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Absensi"),
        actions: [
          IconButton(icon: const Icon(Icons.today), onPressed: pickSingleDate),
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: pickDateRange,
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: resetFilter),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : history.isEmpty
          ? const Center(child: Text("Tidak ada riwayat"))
          : ListView(
              children: grouped.entries.map((e) {
                final month = e.key;
                final items = e.value;

                return ExpansionTile(
                  title: Text(
                    month,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  children: items.map((h) {
                    final double? inLat = h["check_in_lat"]?.toDouble();
                    final double? inLng = h["check_in_lng"]?.toDouble();
                    final double? outLat = h["check_out_lat"]?.toDouble();
                    final double? outLng = h["check_out_lng"]?.toDouble();

                    return Card(
                      child: ListTile(
                        title: Text(h["attendance_date"]),
                        subtitle: Text(
                          "Masuk: ${h["check_in_time"] ?? "-"} | Pulang: ${h["check_out_time"] ?? "-"}\nStatus: ${h["status"]}",
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => DetailDialog(data: h),
                          );
                        },
                        trailing: (inLat == null)
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.map, color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MapView(
                                        checkInLat: inLat,
                                        checkInLng: inLng,
                                        checkOutLat: outLat,
                                        checkOutLng: outLng,
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
    );
  }
}
