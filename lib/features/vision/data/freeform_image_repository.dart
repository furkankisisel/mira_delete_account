import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'freeform_image_model.dart';

class FreeformImageRepository {
  static final instance = FreeformImageRepository._();
  FreeformImageRepository._();

  static const _storageKey = 'freeform_images_v1';

  final _controller = StreamController<List<FreeformImage>>.broadcast();
  List<FreeformImage> _items = const [];

  Stream<List<FreeformImage>> get stream => _controller.stream;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      final list = (json.decode(raw) as List).cast<Map<String, dynamic>>();
      _items = list.map(FreeformImage.fromJson).toList();
    } else {
      _items = const [];
    }
    _emit();
  }

  List<FreeformImage> all() => List.unmodifiable(_items);

  Future<void> add(FreeformImage t) async {
    _items = [t, ..._items];
    await _persist();
  }

  Future<void> update(FreeformImage t) async {
    _items = _items.map((e) => e.id == t.id ? t : e).toList();
    await _persist();
  }

  Future<void> remove(String id) async {
    _items = _items.where((e) => e.id != id).toList();
    await _persist();
  }

  Future<void> bringForward(String id) async {
    final i = _items.indexWhere((e) => e.id == id);
    if (i <= 0) return;
    final tmp = _items[i - 1];
    _items[i - 1] = _items[i];
    _items[i] = tmp;
    await _persist();
  }

  Future<void> sendBackward(String id) async {
    final i = _items.indexWhere((e) => e.id == id);
    if (i == -1 || i >= _items.length - 1) return;
    final tmp = _items[i + 1];
    _items[i + 1] = _items[i];
    _items[i] = tmp;
    await _persist();
  }

  Future<void> updateLayout({
    required String id,
    required double posX,
    required double posY,
    required double scale,
  }) async {
    final i = _items.indexWhere((e) => e.id == id);
    if (i == -1) return;
    _items[i] = _items[i].copyWith(
      // Allow positions beyond edges (no clamping)
      posX: posX,
      posY: posY,
      scale: scale.clamp(0.25, 5.0),
    );
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      json.encode(_items.map((e) => e.toJson()).toList()),
    );
    _emit();
  }

  void _emit() => _controller.add(List.unmodifiable(_items));

  void dispose() => _controller.close();
}
