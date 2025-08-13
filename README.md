# Faz 2 - Tezgah Kontrol Uygulaması

Flutter + Clean Architecture + BLoC örnek iskelet. `lib/src` altında katmanlar:

- `core/` DI, router ve API istemcisi
- `features/tezgah/` domain, data, presentation

Varsayılan Base URL `lib/src/core/network/api_client.dart` içinde `ApiClient.baseUrl` olarak tanımlıdır.

Çalıştırma:
- Flutter kurulu olmalıdır.
- Paketleri indir: `flutter pub get`
- Uygulamayı çalıştır: `flutter run`
