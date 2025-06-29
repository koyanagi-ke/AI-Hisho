class ChecklistItem {
  final String id;
  final String item;
  final int prepareBefore;
  final bool checked;
  final bool required;

  ChecklistItem({
    required this.id,
    required this.item,
    required this.prepareBefore,
    required this.checked,
    required this.required,
  });

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'] ?? '',
      item: json['item'] ?? '',
      prepareBefore: json['prepare_before'] ?? 0,
      checked: json['checked'] ?? false,
      required: json['required'] ?? false,
    );
  }

  ChecklistItem copyWith({
    String? id,
    String? item,
    int? prepareBefore,
    bool? checked,
    bool? required,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      item: item ?? this.item,
      prepareBefore: prepareBefore ?? this.prepareBefore,
      checked: checked ?? this.checked,
      required: required ?? this.required,
    );
  }
}

class WeatherInfo {
  final List<dynamic>? list;

  WeatherInfo({this.list});

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    return WeatherInfo(
      list: json['list'] as List<dynamic>?,
    );
  }

  String? getMain() {
    if (list != null && list!.isNotEmpty) {
      final first = list![0] as Map<String, dynamic>;
      final weatherList = first['weather'] as List<dynamic>?;
      if (weatherList != null && weatherList.isNotEmpty) {
        return weatherList[0]['main'] as String?;
      }
    }
    return null;
  }
}

class ScheduleDetail {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final DateTime? nextCheckDue;
  final List<ChecklistItem> checklists;
  final WeatherInfo? weatherInfo;
  final String? weatherAdvice;
  final DateTime? notifyAt;
  final String? address;

  ScheduleDetail({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.location,
    this.nextCheckDue,
    required this.checklists,
    this.weatherInfo,
    this.weatherAdvice,
    this.notifyAt,
    this.address,
  });

  factory ScheduleDetail.fromJson(Map<String, dynamic> json) {
    final checklistsData = json['checklists'] as List<dynamic>? ?? [];
    final checklists = checklistsData
        .cast<Map<String, dynamic>>()
        .map((item) => ChecklistItem.fromJson(item))
        .toList();

    WeatherInfo? weatherInfo;
    if (json['weather_info'] != null) {
      weatherInfo =
          WeatherInfo.fromJson(json['weather_info'] as Map<String, dynamic>);
    }

    return ScheduleDetail(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      startTime: DateTime.parse(json['start_time']).toLocal(),
      endTime: DateTime.parse(json['end_time']).toLocal(),
      location: json['location'] ?? '',
      nextCheckDue: json['next_check_due'] != null
          ? DateTime.parse(json['next_check_due']).toLocal()
          : null,
      checklists: checklists,
      weatherInfo: weatherInfo,
      weatherAdvice: json['weather_advice'],
      notifyAt: json['notify_at'] != null
          ? DateTime.parse(json['notify_at']).toLocal()
          : null,
      address: json['address'],
    );
  }
}
