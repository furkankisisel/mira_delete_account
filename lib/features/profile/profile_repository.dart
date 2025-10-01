import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileRepository extends ChangeNotifier {
  ProfileRepository._();
  static final ProfileRepository instance = ProfileRepository._();

  static const _kName = 'profile_name';
  static const _kBio = 'profile_bio';
  static const _kAvatarPath = 'profile_avatar_path';
  static const _kAvatarUrl = 'profile_avatar_url';

  SharedPreferences? _prefs;

  String _name = '';
  String _bio = '';
  String? _avatarPath;
  String? _avatarUrl;

  String get name => _name;
  String get bio => _bio;
  String? get avatarPath => _avatarPath;
  String? get avatarUrl => _avatarUrl;

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
    _name = _prefs?.getString(_kName) ?? '';
    _bio = _prefs?.getString(_kBio) ?? '';
    _avatarPath = _prefs?.getString(_kAvatarPath);
    _avatarUrl = _prefs?.getString(_kAvatarUrl);
    notifyListeners();
  }

  Future<void> setName(String value) async {
    _name = value;
    final p = _prefs ?? await SharedPreferences.getInstance();
    await p.setString(_kName, value);
    notifyListeners();
  }

  Future<void> setBio(String value) async {
    _bio = value;
    final p = _prefs ?? await SharedPreferences.getInstance();
    await p.setString(_kBio, value);
    notifyListeners();
  }

  Future<void> setAvatarPath(String? path) async {
    _avatarPath = path;
    final p = _prefs ?? await SharedPreferences.getInstance();
    if (path == null || path.isEmpty) {
      await p.remove(_kAvatarPath);
    } else {
      await p.setString(_kAvatarPath, path);
    }
    notifyListeners();
  }

  /// Store a remote avatar URL (e.g. Google account photo). This is separate from
  /// the local avatar path (which has precedence when present).
  Future<void> setAvatarUrl(String? url) async {
    _avatarUrl = url;
    final p = _prefs ?? await SharedPreferences.getInstance();
    if (url == null || url.isEmpty) {
      await p.remove(_kAvatarUrl);
    } else {
      await p.setString(_kAvatarUrl, url);
    }
    notifyListeners();
  }

  File? get avatarFile => (_avatarPath != null && _avatarPath!.isNotEmpty)
      ? File(_avatarPath!)
      : null;
}
