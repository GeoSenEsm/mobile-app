class SensorReading {
  final String source;
  final Map<String, num> values;

  const SensorReading({
    required this.source,
    required this.values,
  });

  Map<String, dynamic> toJson() => {
        'source': source,
        'values': values,
      };

  factory SensorReading.fromJson(Map<String, dynamic> json) {
    return SensorReading(
      source: json['source'] as String,
      values: (json['values'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, value as num),
      ),
    );
  }
}
