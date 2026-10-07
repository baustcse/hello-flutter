import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'main.dart'; // for AppDrawer

/// A place we can jump the camera to.
class MapPlace {
  final String name;
  final String label;
  final LatLng point;

  const MapPlace(this.name, this.label, this.point);
}

const List<MapPlace> kPlaces = [
  MapPlace('BAUST', 'Saidpur, Nilphamari', LatLng(25.7776, 88.8911)),
  MapPlace('Dhaka', 'Capital city', LatLng(23.8103, 90.4125)),
  MapPlace('Chattogram', 'Port city', LatLng(22.3569, 91.7832)),
  MapPlace('Sylhet', 'Tea gardens', LatLng(24.8949, 91.8687)),
  MapPlace("Cox's Bazar", 'Longest beach', LatLng(21.4272, 92.0058)),
  MapPlace('Sundarbans', 'Mangrove forest', LatLng(21.9497, 89.1833)),
];

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // Drives the map imperatively (move, zoom) from our own buttons.
  final MapController _mapController = MapController();

  MapPlace _selected = kPlaces.first;
  double _zoom = 13;

  /// A pin the user drops by tapping the map.
  LatLng? _droppedPin;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _goTo(MapPlace place) {
    setState(() {
      _selected = place;
      _zoom = 13;
    });
    _mapController.move(place.point, 13);
  }

  void _zoomBy(double delta) {
    final next = (_mapController.camera.zoom + delta).clamp(3.0, 18.0);
    _mapController.move(_mapController.camera.center, next);
    setState(() => _zoom = next);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        centerTitle: true,
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        actions: [
          if (_droppedPin != null)
            IconButton(
              tooltip: 'Clear dropped pin',
              icon: const Icon(Icons.layers_clear),
              onPressed: () => setState(() => _droppedPin = null),
            ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // ---- Place selector ----
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              itemCount: kPlaces.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final place = kPlaces[i];
                final isSelected = place.name == _selected.name;
                return ChoiceChip(
                  label: Text(place.name),
                  selected: isSelected,
                  onSelected: (_) => _goTo(place),
                  selectedColor: const Color(0xFF4F46E5),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF1E293B),
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  showCheckmark: false,
                );
              },
            ),
          ),
          const Divider(height: 1),

          // ---- The map ----
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selected.point,
                    initialZoom: _zoom,
                    minZoom: 3,
                    maxZoom: 18,
                    onTap: (tapPosition, point) {
                      setState(() => _droppedPin = point);
                    },
                    onPositionChanged: (camera, hasGesture) {
                      if (hasGesture) {
                        setState(() => _zoom = camera.zoom);
                      }
                    },
                  ),
                  children: [
                    // Free OpenStreetMap raster tiles — no API key needed.
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.hello_flutter',
                      maxZoom: 19,
                    ),
                    MarkerLayer(
                      markers: [
                        // Marker for the selected place
                        Marker(
                          point: _selected.point,
                          width: 44,
                          height: 44,
                          alignment: Alignment.topCenter,
                          child: const _Pin(color: Color(0xFF4F46E5)),
                        ),
                        // Marker for a user-tapped spot
                        if (_droppedPin != null)
                          Marker(
                            point: _droppedPin!,
                            width: 44,
                            height: 44,
                            alignment: Alignment.topCenter,
                            child: const _Pin(color: Color(0xFFDC2626)),
                          ),
                      ],
                    ),
                  ],
                ),

                // ---- Zoom buttons ----
                Positioned(
                  right: 12,
                  top: 12,
                  child: Column(
                    children: [
                      _MapButton(
                        icon: Icons.add,
                        tooltip: 'Zoom in',
                        onTap: () => _zoomBy(1),
                      ),
                      const SizedBox(height: 8),
                      _MapButton(
                        icon: Icons.remove,
                        tooltip: 'Zoom out',
                        onTap: () => _zoomBy(-1),
                      ),
                      const SizedBox(height: 8),
                      _MapButton(
                        icon: Icons.my_location,
                        tooltip: 'Recentre',
                        onTap: () => _goTo(_selected),
                      ),
                    ],
                  ),
                ),

                // ---- Info card ----
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: _InfoCard(
                    place: _selected,
                    zoom: _zoom,
                    droppedPin: _droppedPin,
                  ),
                ),

                // ---- OSM attribution (required by their tile usage policy) ----
                const Positioned(
                  right: 4,
                  top: 0,
                  child: _Attribution(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SMALL COMPONENTS
// ============================================================================

class _Pin extends StatelessWidget {
  final Color color;

  const _Pin({required this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.location_on,
      size: 44,
      color: color,
      shadows: const [
        Shadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 2)),
      ],
    );
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _MapButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 3,
      shape: const CircleBorder(),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, size: 22, color: const Color(0xFF4F46E5)),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final MapPlace place;
  final double zoom;
  final LatLng? droppedPin;

  const _InfoCard({
    required this.place,
    required this.zoom,
    required this.droppedPin,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF4F46E5).withValues(alpha: 0.12),
                  child: const Icon(
                    Icons.place,
                    size: 19,
                    color: Color(0xFF4338CA),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        place.name,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        place.label,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'z ${zoom.toStringAsFixed(1)}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4338CA),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 10),
            _CoordRow(
              icon: Icons.gps_fixed,
              label: 'Marker',
              value:
                  '${place.point.latitude.toStringAsFixed(4)}, ${place.point.longitude.toStringAsFixed(4)}',
            ),
            const SizedBox(height: 6),
            _CoordRow(
              icon: Icons.touch_app,
              label: 'Your pin',
              value: droppedPin == null
                  ? 'tap the map to drop one'
                  : '${droppedPin!.latitude.toStringAsFixed(4)}, ${droppedPin!.longitude.toStringAsFixed(4)}',
              muted: droppedPin == null,
            ),
          ],
        ),
      ),
    );
  }
}

class _CoordRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool muted;

  const _CoordRow({
    required this.icon,
    required this.label,
    required this.value,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12.5,
              fontFamily: 'monospace',
              fontStyle: muted ? FontStyle.italic : FontStyle.normal,
              color: muted ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }
}

class _Attribution extends StatelessWidget {
  const _Attribution();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      color: Colors.white70,
      child: const Text(
        '© OpenStreetMap contributors',
        style: TextStyle(fontSize: 10, color: Color(0xFF475569)),
      ),
    );
  }
}
