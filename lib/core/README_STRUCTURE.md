# Mira Katmanlı Dizin Yapısı (Taslak)

Bu dosya oluşturulan klasör yapısının amacını açıklar. Henüz implementasyon eklenmedi.

```
lib/
  core/
    analytics/        # İzleme, event logging, crash, performans
    di/               # Service locator / dependency injection kurulumları
    localization/     # Yerelleştirme delegate ve çeviri kaynakları
    models/           # Çekirdek (feature'lar arası paylaşılan) veri modelleri
    repositories/     # Abstraction katmanı (interface) + base repository
    routing/          # GoRouter / Route tanımları
    services/         # API, DB, Firebase, Notification vb. servisler
    theme/            # Global tema, design system entegrasyonu
    utils/            # Genel yardımcı fonksiyonlar / extensionlar
  design_system/      # Tokenlar, komponentler, temalar
  features/
    habit/
      data/           # Data kaynakları, DTO, datasource, mapper
      domain/         # Entity, repository interface, use case
      presentation/   # UI widgetları, state management (bloc/provider)
    mood/
      data/
      domain/
      presentation/
    timer/
      data/
      domain/
      presentation/
    finance/
      data/
      domain/
      presentation/
    vision/
      data/
      domain/
      presentation/
    ai_analysis/
      data/
      domain/
      presentation/
    dashboard/
      presentation/   # Dashboard ekranı; diğer feature özetleri
    rewards/
      data/
      domain/
      presentation/
    shared/
      models/         # Birden fazla feature'ın ortak modelleri
      widgets/        # Tekrarlanan küçük UI parçaları
      utils/          # Feature seviyesinde paylaşılan helperlar
```

Sonraki adım: feature modelleri ve temel entity arayüzleri taslağı.
