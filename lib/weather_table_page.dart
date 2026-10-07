import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'main.dart'; // for AppDrawer

// ============================================================================
// MODEL — one row of the table
// ============================================================================

class HourlyRow {
  final DateTime time;
  final double? temperature;
  final int? humidity;
  final int? rainChance;
  final int? weatherCode;
  final double? windSpeed;

  const HourlyRow({
    required this.time,
    this.temperature,
    this.humidity,
    this.rainChance,
    this.weatherCode,
    this.windSpeed,
  });
}

/// The whole API response, reduced to what the table needs.
class Forecast {
  final String timezone;
  final String tempUnit;
  final String windUnit;
  final List<HourlyRow> rows;

  const Forecast({
    required this.timezone,
    required this.tempUnit,
    required this.windUnit,
    required this.rows,
  });

  /// Open-Meteo returns parallel arrays, not a list of objects, so we zip them
  /// together by index into one row per hour.
  factory Forecast.fromJson(Map<String, dynamic> json) {
    final hourly = json['hourly'] as Map<String, dynamic>? ?? {};
    final units = json['hourly_units'] as Map<String, dynamic>? ?? {};

    final times = (hourly['time'] as List?) ?? const [];
    final temps = (hourly['temperature_2m'] as List?) ?? const [];
    final hums = (hourly['relative_humidity_2m'] as List?) ?? const [];
    final rains = (hourly['precipitation_probability'] as List?) ?? const [];
    final codes = (hourly['weather_code'] as List?) ?? const [];
    final winds = (hourly['wind_speed_10m'] as List?) ?? const [];

    T? at<T>(List list, int i) => i < list.length ? list[i] as T? : null;

    final rows = <HourlyRow>[];
    for (var i = 0; i < times.length; i++) {
      final parsed = DateTime.tryParse(times[i].toString());
      if (parsed == null) continue;
      rows.add(HourlyRow(
        time: parsed,
        temperature: (at<num>(temps, i))?.toDouble(),
        humidity: (at<num>(hums, i))?.toInt(),
        rainChance: (at<num>(rains, i))?.toInt(),
        weatherCode: (at<num>(codes, i))?.toInt(),
        windSpeed: (at<num>(winds, i))?.toDouble(),
      ));
    }

    return Forecast(
      timezone: json['timezone']?.toString() ?? 'UTC',
      tempUnit: units['temperature_2m']?.toString() ?? '°C',
      windUnit: units['wind_speed_10m']?.toString() ?? 'km/h',
      rows: rows,
    );
  }
}

// ============================================================================
// CITIES
// ============================================================================

class City {
  final String name;
  final double lat;
  final double lon;

  const City(this.name, this.lat, this.lon);
}

const List<City> kCities = [
  City('Dhaka', 23.8103, 90.4125),
  City('Chattogram', 22.3569, 91.7832),
  City('Sylhet', 24.8949, 91.8687),
  City('Rajshahi', 24.3745, 88.6042),
  City('Khulna', 22.8456, 89.5403),
  City('Saidpur', 25.7776, 88.8911),
];

// ============================================================================
// PAGE
// ============================================================================

class WeatherTablePage extends StatefulWidget {
  const WeatherTablePage({super.key});

  @override
  State<WeatherTablePage> createState() => _WeatherTablePageState();
}

class _WeatherTablePageState extends State<WeatherTablePage> {
  City _city = kCities.first;
  late Future<Forecast> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchForecast(_city);
  }

  /// Open-Meteo is a free, no-API-key public weather API.
  Future<Forecast> _fetchForecast(City city) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': city.lat.toString(),
      'longitude': city.lon.toString(),
      'hourly':
          'temperature_2m,relative_humidity_2m,precipitation_probability,weather_code,wind_speed_10m',
      'timezone': 'auto',
      'forecast_days': '2',
    });

    final response = await http.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Server returned ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final forecast = Forecast.fromJson(decoded);

    if (forecast.rows.isEmpty) {
      throw Exception('No hourly data in the response');
    }
    return forecast;
  }

  void _load(City city) {
    setState(() {
      _city = city;
      _future = _fetchForecast(city);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather API Table'),
        centerTitle: true,
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => _load(_city),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          _CityChips(
            cities: kCities,
            selected: _city,
            onSelected: _load,
          ),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<Forecast>(
              future: _future,
              builder: (context, snapshot) {
                // --- Loading ---
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Fetching forecast…'),
                      ],
                    ),
                  );
                }

                // --- Error ---
                if (snapshot.hasError) {
                  return _ErrorView(
                    message: snapshot.error.toString(),
                    onRetry: () => _load(_city),
                  );
                }

                // --- Success ---
                final forecast = snapshot.data!;
                return _ForecastTable(city: _city, forecast: forecast);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// CITY FILTER CHIPS
// ============================================================================

class _CityChips extends StatelessWidget {
  final List<City> cities;
  final City selected;
  final ValueChanged<City> onSelected;

  const _CityChips({
    required this.cities,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        itemCount: cities.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final city = cities[i];
          final isSelected = city.name == selected.name;
          return ChoiceChip(
            label: Text(city.name),
            selected: isSelected,
            onSelected: (_) => onSelected(city),
            selectedColor: const Color(0xFF4F46E5),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF1E293B),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
            showCheckmark: false,
          );
        },
      ),
    );
  }
}

// ============================================================================
// THE TABLE
// ============================================================================

class _ForecastTable extends StatelessWidget {
  final City city;
  final Forecast forecast;

  const _ForecastTable({required this.city, required this.forecast});

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formatTime(DateTime t) {
    final hour12 = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final period = t.hour < 12 ? 'AM' : 'PM';
    return '${_months[t.month - 1]} ${t.day}, $hour12 $period';
  }

  /// WMO weather interpretation codes → a readable label.
  String _condition(int? code) {
    switch (code) {
      case 0:
        return 'Clear';
      case 1:
      case 2:
        return 'Partly cloudy';
      case 3:
        return 'Overcast';
      case 45:
      case 48:
        return 'Fog';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rain';
      case 80:
      case 81:
      case 82:
        return 'Showers';
      case 95:
      case 96:
      case 99:
        return 'Thunderstorm';
      default:
        return code == null ? '—' : 'Code $code';
    }
  }

  IconData _conditionIcon(int? code) {
    if (code == null) return Icons.help_outline;
    if (code == 0) return Icons.wb_sunny;
    if (code <= 2) return Icons.wb_cloudy;
    if (code == 3) return Icons.cloud;
    if (code <= 48) return Icons.foggy;
    if (code <= 65) return Icons.water_drop;
    if (code <= 82) return Icons.grain;
    return Icons.thunderstorm;
  }

  @override
  Widget build(BuildContext context) {
    final rows = forecast.rows;

    return Column(
      children: [
        // --- Summary header ---
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: const Color(0xFFEEF2FF),
          child: Row(
            children: [
              const Icon(Icons.place, size: 18, color: Color(0xFF4338CA)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${city.name}  ·  ${forecast.timezone}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              Text(
                '${rows.length} hours',
                style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
              ),
            ],
          ),
        ),

        // --- Scrollable DataTable (both directions) ---
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Color(0xFF0F172A),
                ),
                dataTextStyle: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF1E293B),
                ),
                columnSpacing: 22,
                headingRowHeight: 46,
                dataRowMinHeight: 44,
                dataRowMaxHeight: 52,
                border: TableBorder.symmetric(
                  inside: const BorderSide(color: Color(0xFFE2E8F0), width: 0.6),
                ),
                columns: [
                  const DataColumn(label: Text('Time')),
                  DataColumn(
                    label: Text('Temp (${forecast.tempUnit})'),
                    numeric: true,
                  ),
                  const DataColumn(label: Text('Humidity'), numeric: true),
                  const DataColumn(label: Text('Rain %'), numeric: true),
                  DataColumn(
                    label: Text('Wind (${forecast.windUnit})'),
                    numeric: true,
                  ),
                  const DataColumn(label: Text('Condition')),
                ],
                rows: List<DataRow>.generate(rows.length, (i) {
                  final r = rows[i];
                  return DataRow(
                    color: WidgetStateProperty.all(
                      i.isEven ? Colors.white : const Color(0xFFFAFBFC),
                    ),
                    cells: [
                      DataCell(Text(
                        _formatTime(r.time),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      )),
                      DataCell(Text(
                        r.temperature == null
                            ? '—'
                            : r.temperature!.toStringAsFixed(1),
                      )),
                      DataCell(Text(
                        r.humidity == null ? '—' : '${r.humidity}%',
                      )),
                      DataCell(_RainCell(chance: r.rainChance)),
                      DataCell(Text(
                        r.windSpeed == null
                            ? '—'
                            : r.windSpeed!.toStringAsFixed(1),
                      )),
                      DataCell(Row(
                        children: [
                          Icon(
                            _conditionIcon(r.weatherCode),
                            size: 17,
                            color: const Color(0xFF4F46E5),
                          ),
                          const SizedBox(width: 6),
                          Text(_condition(r.weatherCode)),
                        ],
                      )),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),

        // --- Attribution ---
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: const Color(0xFFF8FAFC),
          child: const Text(
            'Data: open-meteo.com (free, no API key)',
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
        ),
      ],
    );
  }
}

/// A small coloured pill so the rain column reads at a glance.
class _RainCell extends StatelessWidget {
  final int? chance;

  const _RainCell({required this.chance});

  @override
  Widget build(BuildContext context) {
    if (chance == null) return const Text('—');

    final Color bg;
    if (chance! >= 70) {
      bg = const Color(0xFF3B82F6);
    } else if (chance! >= 35) {
      bg = const Color(0xFF93C5FD);
    } else {
      bg = const Color(0xFFE2E8F0);
    }
    final fg = chance! >= 35 ? Colors.white : const Color(0xFF475569);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$chance%',
        style: TextStyle(
          color: fg,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ============================================================================
// ERROR STATE
// ============================================================================

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 56, color: Color(0xFF94A3B8)),
            const SizedBox(height: 16),
            const Text(
              "Couldn't load the forecast",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
