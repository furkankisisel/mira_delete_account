import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'profile_repository.dart';

class AuthRepository extends ChangeNotifier {
  AuthRepository._();
  static final AuthRepository instance = AuthRepository._();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'profile',
      'https://www.googleapis.com/auth/drive.appdata',
    ],
  );

  GoogleSignInAccount? _account;

  GoogleSignInAccount? get account => _account;

  bool get isSignedIn => _account != null;

  Future<void> initialize() async {
    try {
      _account = await _googleSignIn.signInSilently();
      notifyListeners();
    } catch (_) {
      // ignore
    }
  }

  /// Returns authenticated headers (including access token) to call Google APIs.
  Future<Map<String, String>?> getAuthHeaders() async {
    final acc = _account ?? await _googleSignIn.signInSilently();
    if (acc == null) return null;
    try {
      return await acc.authHeaders;
    } catch (_) {
      return null;
    }
  }

  Future<GoogleSignInAccount?> signIn() async {
    try {
      _account = await _googleSignIn.signIn();
      // If sign-in succeeded, persist profile info locally for display
      if (_account != null) {
        try {
          final repo = ProfileRepository.instance;
          final display = _account!.displayName ?? _account!.email ?? '';
          await repo.setName(display);
          await repo.setAvatarUrl(_account!.photoUrl);
        } catch (_) {
          // ignore storage errors
        }
      }
      notifyListeners();
      return _account;
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    _account = null;
    notifyListeners();
  }
}
