import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:m_pro/constant/app_color.dart';
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

  @override
  Widget build(BuildContext context) {
    final grouped = groupByMonth(history);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColor.primary,
          title: Text("Riwayat Absensi"),
          actions: [
            IconButton(icon: Icon(Icons.today), onPressed: pickSingleDate),
            IconButton(icon: Icon(Icons.date_range), onPressed: pickDateRange),
            IconButton(icon: Icon(Icons.refresh), onPressed: resetFilter),
          ],
        ),
        body: Stack(
          alignment: AlignmentDirectional.center,
          children: [buildBackground(), buildLayer(grouped, context)],
        ),
      ),
    );
  }

  Center buildLayer(Map<String, List<dynamic>> grouped, BuildContext context) {
    return Center(
      child: loading
          ? CircularProgressIndicator()
          : history.isEmpty
          ? Text("Tidak ada riwayat")
          : buildHistoryAbsen(grouped, context),
    );
  }

  ListView buildHistoryAbsen(
    Map<String, List<dynamic>> grouped,
    BuildContext context,
  ) {
    return ListView(
      children: grouped.entries.map((e) {
        final month = e.key;
        final items = e.value;
        return ExpansionTile(
          title: Text(
            month,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                        icon: Icon(Icons.map, color: Colors.blue),
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
    );
  }

  Container buildBackground() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background/background2_ariq.png'),
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
