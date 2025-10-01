# 🎭 Şans Yumurtası Animasyon Spesifikasyonları

## 🎨 Renk Paleti

### Ana Renkler (HEX)
```
Toprak Yeşili: #7B8471
Pastel Sarı: #FAE190  
Soft Kahve: #D4B896
```

### Gölge Renkleri
```
Toprak Yeşili Gölge: #5A6152
Pastel Sarı Gölge: #E8C474
Soft Kahve Gölge: #C0A47D
```

### Glow Renkleri
```
Toprak Yeşili Glow: #9FB094
Pastel Sarı Glow: #FDF4C4
Soft Kahve Glow: #E6D3B7
```

### Konfeti Renkleri
```
Altın Sarı: #FFD93D
Mint Yeşil: #6BCF7F
Yumuşak Kırmızı: #FF6B6B
Turkuaz: #4ECDC4
Turuncu Sarı: #FFBE0B
```

---

## ⏱️ Animasyon Süreleri

### Ana Animasyonlar
- **Idle Animasyon**: 3000ms (sürekli döngü)
- **Crack Animasyon**: 1200ms (tek seferlik)
- **Reveal Animasyon**: 800ms (tek seferlik)
- **Glow Animasyon**: 600ms (tek seferlik)

### Intro Sırası
- **Fade In**: 0-600ms (0.6s)
- **Slide Up**: 200-800ms (0.6s, 200ms offset)
- **Scale In**: 400-1000ms (0.6s, 400ms offset)
- **Total Intro**: 2000ms

### Reduced Motion
- **Reduced Duration**: 200ms (tüm animasyonlar için)
- **Reduced Curve**: Linear

---

## 🎪 Easing Curves

### Normal Animasyonlar
```css
Idle: ease-in-out
Crack: elastic-out  
Reveal: ease-out-cubic
Glow: ease-in-out-quart
Intro Fade: ease-out
Intro Slide: elastic-out
Intro Scale: elastic-out
```

### Reduced Motion
```css
All: linear
```

---

## 📐 Boyutlar ve Spacing

### Yumurta Boyutları
- **Yumurta Genişlik**: 120px
- **Yumurta Yükseklik**: 156px (1.3x ratio)
- **Yumurtalar Arası Mesafe**: 24px

### Kart Boyutları
- **Kart Genişlik**: 280px
- **Kart Yükseklik**: 180px
- **Kart Border Radius**: 16px

### Shadow & Glow
- **Soft Shadow Blur**: 8px
- **Glow Shadow Blur**: 20px
- **Egg Shadow Offset**: (0, 4)
- **Card Shadow Offset**: (0, 8)

---

## 🎚️ Z-Index & Elevation

```
Confetti: 16
Card: 12
Egg: 8
Background: 0
```

---

## 🎯 Idle Animasyon Detayları

### Sinusoidal Salınım
- **X Offset Range**: ±2% (±2.4px at 120px width)
- **Y Offset**: 0px
- **Function**: `sin(time * 2π) * maxOffset`

### Pulse Effect
- **Scale Range**: 0.8 - 1.0
- **Opacity Range**: 0.8 - 1.0
- **Sync**: Salınım ile senkron

---

## 💥 Crack Animasyon Sırası

### Faz 1: Tremor (0-300ms)
- **Rotation**: 0° → -2° → +3° → 0°
- **Scale**: 100% → 105% → 110%
- **Duration**: 300ms

### Faz 2: Crack Lines (300-600ms)
- **Main Crack**: Center'dan başlayıp dışa doğru
- **Side Cracks**: 300ms'de başlar
- **Line Width**: 1px → 4px

### Faz 3: Shell Break (600-900ms)
- **Shell Opacity**: 100% → 0%
- **Shell Scale**: 110% → 120%
- **Rotation**: Final random angle

### Faz 4: Confetti Burst (900-1200ms)
- **Particle Count**: 20 parçacık
- **Spread Angle**: 360° (radial)
- **Distance**: 0 → 100px
- **Gravity**: -20px (upward motion)

---

## 🎴 Reveal Animasyon Detayları

### Kart Giriş
- **Initial Position**: Center (0, 0)
- **Final Position**: Center (0, -20px) - hafif yukarı
- **Scale**: 50% → 100%
- **Opacity**: 0% → 100%

### Glow Efekti
- **Glow Scale**: 120% → 150%
- **Glow Opacity**: 0% → 60% → 30%
- **Blur Radius**: 20px
- **Spread**: 4px

---

## 📱 Responsive Breakpoints

### Mobile (320px+)
- **Egg Size**: 80px x 104px
- **Spacing**: 16px
- **Card**: 240px x 160px

### Tablet (768px+)
- **Egg Size**: 120px x 156px (normal)
- **Spacing**: 24px
- **Card**: 280px x 180px

### Desktop (1024px+)
- **Egg Size**: 140px x 182px
- **Spacing**: 32px
- **Card**: 320px x 200px

---

## ♿ Accessibility

### Contrast Ratios (WCAG AA)
- **Primary Text**: 7.0:1 (#2C2C2C on light)
- **Secondary Text**: 4.5:1 (#666666 on light)

### Reduced Motion Support
- **Detection**: `MediaQuery.of(context).disableAnimations`
- **Fallback**: Static states with 200ms linear transitions
- **Preserved**: Essential feedback (haptic, audio)

### Screen Reader
- **Semantics**: Proper labels for each egg type
- **States**: "idle", "cracking", "revealed"
- **Actions**: "Tap to reveal fortune"

---

## 🎵 Audio Cues (Optional)

### Sound Effects
- **Egg Tap**: Gentle "tap" (50ms)
- **Crack Start**: Soft "crack" (200ms)
- **Confetti**: Light "pop" (100ms)
- **Reveal**: Mystical "chime" (500ms)

### Volume Levels
- **Default**: 40%
- **Reduced Motion**: 20%
- **Accessibility**: User-controlled

---

## 📦 Asset Deliverables

### SVG Assets (Vectorel)
✅ `earth_egg.svg` - Toprak yeşili yumurta
✅ `sun_egg.svg` - Pastel sarı yumurta  
✅ `wood_egg.svg` - Soft kahve yumurta

### PNG Assets (2x Retina)
- `earth_egg@2x.png` (240x312px)
- `sun_egg@2x.png` (240x312px)
- `wood_egg@2x.png` (240x312px)

### Lottie Animasyon
✅ `egg_crack_animation.json` - Crack sequence

### Flutter Implementation
✅ `egg_design_system.dart` - Tasarım sistemi
✅ `animated_egg_widget.dart` - Widget implementasyonu
✅ `fortune_egg_trio_screen.dart` - Ana ekran

---

## 🔧 Implementation Notes

### Performance
- **GPU Rendering**: CustomPainter'lar için `isRepaintBoundary: true`
- **Animation Optimization**: Tek AnimationController per widget
- **Memory**: SVG'ler için asset caching

### Testing
- **Unit Tests**: Animasyon state'leri
- **Widget Tests**: User interactions
- **Integration Tests**: Full user flow

### Platform Differences
- **iOS**: Native haptic feedback intensities
- **Android**: Material motion patterns
- **Web**: CSS animation fallbacks

---

*Bu spesifikasyon dokümanı, Mira uygulamasının Şans Yumurtası özelliği için gerekli tüm tasarım ve animasyon detaylarını içermektedir.*