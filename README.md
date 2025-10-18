# Gelir Gider — Flutter + Supabase Kişisel Finans Takibi

Global kullanıcılar için modern finans takip uygulaması:
- Flutter (UI), Supabase (DB + Auth), SQLite (offline cache)
- Riverpod (State), GoRouter (Routing)
- Çoklu tema (Minimalist, Neomorphism, Flat, Material, One UI)
- Çoklu dil (TR/EN)
- Raporlar, KPI, akıllı öneriler, sesli giriş, aile paylaşımı
- PDF/Excel raporlama
- CI/CD (GitHub Actions)

## Hızlı Başlangıç

1) Ortam değişkenleri (dart-define):
- SUPABASE_URL
- SUPABASE_ANON_KEY
- SUPABASE_REDIRECT_URL

Örnek:
flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co --dart-define=SUPABASE_ANON_KEY=anon-key --dart-define=SUPABASE_REDIRECT_URL=com.example.app://login-callback


2) Paketleri kur:
flutter pub get

3) Lokalizasyon:
- assets/translations/en.json
- assets/translations/tr.json

4) SQLite offline cache otomatik oluşur.

5) Supabase:
- assets/sql/schema.sql ve assets/sql/rls_policies.sql dosyalarını Supabase DB’nize uygulayın (SQL Editor).

6) iOS/Android:
- OAuth redirect URI ayarlayın.
- Home widget ve izinler için Manifest/Info.plist düzenleyin.

## Özellikler
- Kredi Kartı, Borç, Kasa
- Gelir/Gider ekleme (alt/ana sınıflar)
- Ana ekranda: Son 3 işlem, yaklaşan 2 işlem
- Zaman aralığına göre raporlar; grafikleri fl_chart ile
- KPI panosu ve akıllı öneriler
- Çoklu cüzdan ve aile paylaşımı (RLS)
- PDF/Excel dışa aktarma
- Sesli giriş (speech_to_text)
- CI/CD: GitHub Actions (build+test)

## Güvenlik
- RLS ile kullanıcı bazlı veri izolasyonu
- Lokal DB için şifreleme alternatifi (SQLCipher) önerilir
- GDPR: veri saklama/silme uçları (Edge Functions / Python servis)

## Katkı ve Lisans
- MIT lisansı önerilir (isteğe bağlı).
