import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:ecosort/config/app_config.dart';
import 'package:ecosort/models/bin.dart';
import 'package:ecosort/theme/app_theme.dart';
import 'package:ecosort/widgets/fill_level_badge.dart';

/// Map of bins. Uses Google Maps only when [AppConfig.hasGoogleMapsKey]
/// is true; otherwise a custom-painted campus sketch so `flutter run`
/// works with zero API keys.
class EcoMap extends StatelessWidget {
  const EcoMap({
    super.key,
    required this.bins,
    this.routeBinIds = const [],
    this.onBinTap,
    this.height = 280,
  });

  final List<Bin> bins;
  final List<String> routeBinIds;
  final void Function(Bin bin)? onBinTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (AppConfig.hasGoogleMapsKey) {
      return SizedBox(height: height, child: _GoogleBinsMap(bins: bins, onBinTap: onBinTap));
    }
    return SizedBox(
      height: height,
      child: SimpleCampusMap(
        bins: bins,
        routeBinIds: routeBinIds,
        onBinTap: onBinTap,
      ),
    );
  }
}

class _GoogleBinsMap extends StatelessWidget {
  const _GoogleBinsMap({required this.bins, this.onBinTap});

  final List<Bin> bins;
  final void Function(Bin bin)? onBinTap;

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>{
      for (final b in bins)
        Marker(
          markerId: MarkerId(b.id),
          position: LatLng(b.lat, b.lng),
          infoWindow: InfoWindow(
            title: b.name,
            snippet: '${b.fillLevelPercent}% · ${b.zone}',
          ),
          onTap: onBinTap == null ? null : () => onBinTap!(b),
        ),
    };

    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: LatLng(AppConfig.depotLat, AppConfig.depotLng),
        zoom: 13.2,
      ),
      markers: markers,
      myLocationButtonEnabled: false,
      compassEnabled: false,
    );
  }
}

/// Hand-drawn "campus map": green land, a river, roads, and coloured dots.
class SimpleCampusMap extends StatefulWidget {
  const SimpleCampusMap({
    super.key,
    required this.bins,
    this.routeBinIds = const [],
    this.onBinTap,
  });

  final List<Bin> bins;
  final List<String> routeBinIds;
  final void Function(Bin bin)? onBinTap;

  @override
  State<SimpleCampusMap> createState() => _SimpleCampusMapState();
}

class _SimpleCampusMapState extends State<SimpleCampusMap> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            onTapDown: (d) {
              if (widget.onBinTap == null) return;
              final painter = _CampusPainter(widget.bins, widget.routeBinIds);
              final hit = painter.hitTestBin(
                d.localPosition,
                Size(constraints.maxWidth, constraints.maxHeight),
              );
              if (hit != null) widget.onBinTap!(hit);
            },
            child: CustomPaint(
              painter: _CampusPainter(widget.bins, widget.routeBinIds),
              child: const SizedBox.expand(),
            ),
          );
        },
      ),
    );
  }
}

class _CampusPainter extends CustomPainter {
  _CampusPainter(this.bins, this.routeBinIds);

  final List<Bin> bins;
  final List<String> routeBinIds;

  // Bounding box of the seed coordinates (Pune campus cluster).
  static const _minLat = 18.5100;
  static const _maxLat = 18.5360;
  static const _minLng = 73.8480;
  static const _maxLng = 73.8760;

  Offset _project(double lat, double lng, Size size) {
    final x = (lng - _minLng) / (_maxLng - _minLng) * size.width;
    // Latitude grows north, but y grows down on canvas — flip it.
    final y = (1 - (lat - _minLat) / (_maxLat - _minLat)) * size.height;
    return Offset(x, y);
  }

  Bin? hitTestBin(Offset local, Size size) {
    for (final b in bins) {
      final p = _project(b.lat, b.lng, size);
      if ((p - local).distance <= 18) return b;
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFDCE8DC);
    canvas.drawRect(Offset.zero & size, bg);

    // Moss patches = the three zones.
    _blob(canvas, size, const Color(0xFFB7D1B4), 0.22, 0.22, 0.28);
    _blob(canvas, size, const Color(0xFFA8C9A6), 0.28, 0.78, 0.26);
    _blob(canvas, size, const Color(0xFFC5D9B8), 0.78, 0.45, 0.32);

    // River
    final river = Path()
      ..moveTo(size.width * 0.55, 0)
      ..quadraticBezierTo(
        size.width * 0.62,
        size.height * 0.4,
        size.width * 0.5,
        size.height,
      );
    canvas.drawPath(
      river,
      Paint()
        ..color = const Color(0xFF8EC6C5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round,
    );

    // Roads
    final road = Paint()
      ..color = const Color(0xFFE7DCC8)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(0, size.height * 0.55),
      Offset(size.width, size.height * 0.4),
      road,
    );
    canvas.drawLine(
      Offset(size.width * 0.35, 0),
      Offset(size.width * 0.45, size.height),
      road,
    );

    // Depot
    final depot = _project(AppConfig.depotLat, AppConfig.depotLng, size);
    canvas.drawCircle(depot, 8, Paint()..color = AppColors.accent);
    _label(canvas, 'Depot', depot.translate(10, -6));

    // Route polyline (nearest-neighbor order) if provided.
    if (routeBinIds.length >= 2) {
      final byId = {for (final b in bins) b.id: b};
      final path = Path();
      var started = false;
      for (final id in routeBinIds) {
        final b = byId[id];
        if (b == null) continue;
        final p = _project(b.lat, b.lng, size);
        if (!started) {
          path.moveTo(p.dx, p.dy);
          started = true;
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.primary.withValues(alpha: 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }

    for (final b in bins) {
      final p = _project(b.lat, b.lng, size);
      final color = FillLevelBadge.colorFor(b.fillLevelPercent);
      canvas.drawCircle(p, 9, Paint()..color = color);
      canvas.drawCircle(
        p,
        9,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    _label(canvas, 'North', Offset(size.width * 0.12, size.height * 0.12));
    _label(canvas, 'South', Offset(size.width * 0.12, size.height * 0.82));
    _label(canvas, 'Downtown', Offset(size.width * 0.72, size.height * 0.12));
  }

  void _blob(Canvas canvas, Size size, Color color, double nx, double ny, double r) {
    canvas.drawCircle(
      Offset(size.width * nx, size.height * ny),
      min(size.width, size.height) * r,
      Paint()..color = color,
    );
  }

  void _label(Canvas canvas, String text, Offset at) {
    final builder = ui.ParagraphBuilder(
      ui.ParagraphStyle(fontSize: 11, fontWeight: FontWeight.w700),
    )
      ..pushStyle(ui.TextStyle(color: AppColors.primary))
      ..addText(text);
    final para = builder.build()..layout(const ui.ParagraphConstraints(width: 120));
    canvas.drawParagraph(para, at);
  }

  @override
  bool shouldRepaint(covariant _CampusPainter oldDelegate) =>
      oldDelegate.bins != bins || oldDelegate.routeBinIds != routeBinIds;
}
