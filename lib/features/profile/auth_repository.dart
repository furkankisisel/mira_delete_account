import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  String? _lastError;
  FirebaseAuth? get _firebaseAuth {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      // Firebase not initialized in this context (e.g., widget tests)
      return null;
    }
  }

  GoogleSignInAccount? get account => _account;
  String? get lastError => _lastError;

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
    if (acc == null) {
      debugPrint('No Google account found');
      return null;
    }
    try {
      // Force token refresh to avoid 401 errors with stale tokens
      final auth = await acc.authentication;
      debugPrint('Token refreshed, checking expiry...');

      final headers = await acc.authHeaders;
      if (kDebugMode) {
        // Check what scopes are actually granted
        try {
          final currentScopes = await _googleSignIn.requestScopes([]);
          debugPrint('Scopes check returned: $currentScopes');

          // Also check serverAuthCode availability
          final serverCode = acc.serverAuthCode;
          debugPrint('Server auth code available: ${serverCode != null}');

          // Log token info
          debugPrint('Access token available: ${auth.accessToken != null}');
          if (auth.accessToken != null) {
            debugPrint(
              'Access token (first 20 chars): ${auth.accessToken!.substring(0, auth.accessToken!.length > 20 ? 20 : auth.accessToken!.length)}...',
            );
          }
          debugPrint('ID token available: ${auth.idToken != null}');
        } catch (e) {
          debugPrint('Error checking scopes: $e');
        }
      }
      return headers;
    } catch (e) {
      debugPrint('Error getting auth headers: $e');
      return null;
    }
  }

  Future<GoogleSignInAccount?> signIn() async {
    try {
      _account = await _googleSignIn.signIn();
      if (_account == null) return null;

      // Exchange Google tokens for Firebase credential
      final googleAuth = await _account!.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // If an anonymous Firebase user exists, try linking; otherwise sign in
      final fbAuth = _firebaseAuth;
      if (fbAuth != null) {
        try {
          final current = fbAuth.currentUser;
          if (current != null && current.isAnonymous) {
            await current.linkWithCredential(credential);
          } else {
            await fbAuth.signInWithCredential(credential);
          }
        } on FirebaseAuthException catch (e) {
          // If the credential is already in use, fall back to a direct sign-in
          if (e.code == 'credential-already-in-use' ||
              e.code == 'account-exists-with-different-credential') {
            await fbAuth.signInWithCredential(credential);
          } else {
            rethrow;
          }
        }
      }

      // If sign-in succeeded, persist profile info locally for display
      try {
        final repo = ProfileRepository.instance;
        final acc = _account!;
        final display =
            (acc.displayName != null && acc.displayName!.trim().isNotEmpty)
            ? acc.displayName!
            : acc.email;
        await repo.setName(display);
        await repo.setAvatarUrl(acc.photoUrl);
      } catch (_) {
        // ignore storage errors
      }

      notifyListeners();
      return _account;
    } on PlatformException catch (e) {
      // Map common Google Play Services errors to clearer messages.
      final raw = '${e.code}: ${e.message ?? ''}'.toLowerCase();
      if (e.code == 'sign_in_failed' && (e.message?.contains('10:') ?? false)) {
        _lastError =
            'Google giriş yapılandırma hatası (ApiException 10).\n'
            'Büyük olasılıkla SHA-1 parmak izi Firebase\'e ekli değil veya yanlış.\n'
            'Lütfen Android debug/release SHA-1\'ınızı Firebase Project Settings > Android uygulamanıza ekleyin ve google-services.json dosyasını yeniden indirin.';
      } else {
        _lastError = 'Google giriş hatası: $raw';
      }
      notifyListeners();
      return null;
    } catch (e) {
      _lastError = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      // Sign out from Firebase and revoke Google session
      final fbAuth = _firebaseAuth;
      if (fbAuth != null) {
        await fbAuth.signOut();
      }
      await _googleSignIn.disconnect();
    } catch (_) {}
    _account = null;
    _lastError = null;
    notifyListeners();
  }

  /// Optionally request Drive App Data scope later (after a successful sign-in),
  /// to avoid blocking the initial Google sign-in with a sensitive scope.
  Future<bool> requestDriveAppDataScope() async {
    try {
      debugPrint('Requesting Drive AppData scope...');
      debugPrint('Current account: ${_account?.email}');

      final ok = await _googleSignIn.requestScopes([
        'https://www.googleapis.com/auth/drive.appdata',
      ]);

      debugPrint('Drive scope request returned: $ok');

      if (ok) {
        // Force account refresh to get new scopes
        debugPrint('Attempting to refresh account with new scopes...');
        final refreshedAccount = await _googleSignIn.signInSilently();
        debugPrint('Account refreshed: ${refreshedAccount != null}');

        if (refreshedAccount != null) {
          _account = refreshedAccount;
          notifyListeners();
        }
      }

      return ok;
    } catch (e) {
      debugPrint('Error requesting Drive scope: $e');
      return false;
    }
  }

  /// Clears the token cache to force a fresh token on next request
  Future<void> clearTokenCache() async {
    try {
      debugPrint('Clearing token cache...');
      final account = _account;
      if (account != null) {
        // Force token refresh by calling clearAuthCache
        await account.clearAuthCache();
        debugPrint('Token cache cleared successfully');
      }
    } catch (e) {
      debugPrint('Error clearing token cache: $e');
    }
  }
}
