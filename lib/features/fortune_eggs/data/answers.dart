import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// A simple in-memory answer pool. You can expand this list freely.
/// Keep entries short and punchy for better UX.
class FortuneAnswers {
  // Embedded fallback lists (used when the asset hasn't been loaded).
  static final List<String> tr = [
    'Kesinlikle evet',
    'Evet, ama dikkatli ol',
    'Şimdilik hayır',
    'Zamanı değil',
    'Devam et',
    'Bir mola ver',
    'Daha fazla bilgi topla',
    'Şansa bırak',
    'Kalbini dinle',
    'Mantığını dinle',
    'Yeniden düşün',
    'Bir arkadaşına sor',
    'Küçük adımlarla başla',
    'Sonuna kadar git',
    'Bırak gitsin',
    'Risk al',
    'Sabret',
    'Bugün değil',
    'Yarın dene',
    'Harika fikir',
    'Bekle ve gör',
    'Önceliğini değiştir',
    'Fırsatı değerlendir',
    'Kendine güven',
    'Plan yap',
    'Şimdi tam zamanı',
    'Şans kapıda',
    'Acele etme',
    'Net bir evet',
    'Net bir hayır',
    // Additional answers
    'Biraz daha bekle',
    'Küçük bir deneme yap',
    'Bugün ilham günü',
    'Geri adım at',
    'Buna hayır deme hemen',
    'İç sesine güven',
    'Çevrendekilerle paylaş',
    'Hedefini netleştir',
    'Bu fırsatı kaçırma',
    'Daha cesur ol',
    'Sınırlarını zorla',
    'Önce plan sonra hareket',
    'Kendine zaman tanı',
    'Küçük bir kutlama yap',
    'Bir adım geri, iki adım ileri',
  ];

  static final List<String> en = [
    'Absolutely yes',
    'Yes, but be careful',
    'Not for now',
    'Not the time',
    'Go for it',
    'Take a break',
    'Gather more info',
    'Leave it to chance',
    'Follow your heart',
    'Trust your logic',
    'Think again',
    'Ask a friend',
    'Start small',
    'Go all in',
    'Let it go',
    'Take the risk',
    'Be patient',
    'Not today',
    'Try tomorrow',
    'Great idea',
    'Wait and see',
    'Shift priorities',
    'Seize the chance',
    'Believe in yourself',
    'Make a plan',
    'Now is the time',
    'Luck is near',
    'Don’t rush',
    'A clear yes',
    'A clear no',
    // Additional answers
    'Hold off a little',
    'Try a small test',
    'Today looks promising',
    'Take a step back',
    'Don’t say no right away',
    'Listen to your inner voice',
    'Share with someone you trust',
    'Clarify your goal',
    'Don’t miss this chance',
    'Be bolder',
    'Push your limits',
    'Plan first, act second',
    'Give yourself time',
    'Celebrate the small wins',
    'One step back, two forward',
  ];

  // In-memory cache populated from the JSON seed asset when available.
  // Keys are locale codes like 'tr' and 'en'.
  static Map<String, List<String>>? _cachedFromAsset;

  /// Attempts to load answers from `assets/seeds/fortune_answers.json` into
  /// an in-memory cache. This is safe to call multiple times; subsequent
  /// calls are no-ops. If loading fails, the cache remains null and callers
  /// will fall back to the embedded lists above.
  static Future<void> loadFromAsset() async {
    if (_cachedFromAsset != null) return;
    try {
      final raw = await rootBundle.loadString(
        'assets/seeds/fortune_answers.json',
      );
      final decoded = json.decode(raw) as Map<String, dynamic>;
      final Map<String, List<String>> map = {};
      decoded.forEach((key, value) {
        if (value is List) {
          map[key] = value.map((e) => e.toString()).toList();
        }
      });
      if (map.isNotEmpty) _cachedFromAsset = map;
    } catch (_) {
      // Ignore any error and keep _cachedFromAsset as null to allow fallback.
      _cachedFromAsset = null;
    }
  }

  /// Returns the answer list for [locale]. If the asset has been loaded,
  /// it returns the data from the cache; otherwise it returns the embedded
  /// fallback lists. The [locale] string can be like `tr` or `en_US`.
  static List<String> forLocale(String locale) {
    final lang = locale.split('_').first.toLowerCase();
    if (_cachedFromAsset != null) {
      return _cachedFromAsset![lang] ??
          _cachedFromAsset!['en'] ??
          (lang == 'tr' ? tr : en);
    }
    if (lang == 'tr') return tr;
    return en; // default fallback
  }

  /// Picks [count] distinct random answers from the pool of the given [locale].
  static List<String> pickDistinct(String locale, int count, [int? seed]) {
    final pool = List<String>.from(forLocale(locale));
    final rnd = Random(seed);
    pool.shuffle(rnd);
    return pool.take(count).toList();
  }
}
