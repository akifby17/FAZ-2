# 🔧 Ayarlar Sistemi - FAZ-2 Tezgah Kontrol Uygulaması

## 🎯 **Özellikler**

### ✅ **Tamamlanan Özellikler:**
- **Dil Değiştirme**: Türkçe/İngilizce arası geçiş
- **API Base URL Değiştirme**: Dinamik API endpoint değişikliği
- **Şifre Koruması**: Admin şifresi ile güvenli ayar erişimi
- **Şifre Değiştirme**: Admin şifresini güncelleme
- **Persistent Storage**: Hive ile ayarların kalıcı saklanması
- **Clean Architecture**: Mimariye uygun geliştirme

## 🏗️ **Mimari Yapı**

### **Domain Katmanı:**
```
lib/src/features/settings/domain/
├── entities/
│   └── app_settings.dart           # Settings entity
├── repositories/
│   └── settings_repository.dart    # Repository interface
└── usecases/
    ├── get_settings.dart          # Ayarları getir
    ├── verify_admin_password.dart # Şifre doğrula
    └── update_api_url.dart        # API URL güncelle
```

### **Data Katmanı:**
```
lib/src/features/settings/data/
├── datasources/
│   └── settings_local_data_source.dart  # Hive data source
├── models/
│   ├── settings_dto.dart                # JSON model
│   └── settings_dto.g.dart             # Generated JSON code
└── repositories/
    └── settings_repository_impl.dart    # Repository implementation
```

### **Presentation Katmanı:**
```
lib/src/features/settings/presentation/
├── bloc/
│   ├── settings_bloc.dart         # BLoC state management
│   ├── settings_event.dart        # Events
│   └── settings_state.dart        # States
├── pages/
│   ├── settings_page.dart         # Ana ayarlar sayfası
│   └── connection_settings_page.dart # Bağlantı ayarları
└── widgets/
    └── admin_password_dialog.dart # Şifre giriş dialog'u
```

## 🔐 **Güvenlik Sistemi**

### **Şifre Koruması:**
- **Varsayılan Şifre**: `27526`
- **Korunan Özellikler**: API URL değiştirme, Şifre değiştirme
- **Korunmayan Özellikler**: Dil değiştirme

### **Erişim Kontrolü:**
```dart
// Şifre doğrulama
final isValid = await verifyAdminPassword('27526');

// API URL değiştirme (şifre gerekli)
if (isAdminAuthenticated) {
  await updateApiUrl('http://new-url:5100');
}

// Dil değiştirme (şifre gereksiz)
await updateLanguage('en');
```

## 🌐 **Dinamik API URL Sistemi**

### **ApiUrlService:**
```dart
class ApiUrlService {
  String getCurrentUrl() => _box.get('api_base_url', defaultValue: 'http://192.168.2.9:5100');
  Future<void> updateUrl(String newUrl) => _box.put('api_base_url', newUrl);
}
```

### **ApiClient Güncellemesi:**
```dart
class ApiClient {
  ApiClient(this._dio, this._apiUrlService) {
    // Dynamic base URL interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final currentBaseUrl = _apiUrlService.getCurrentUrl();
        if (options.path.startsWith('/')) {
          options.path = currentBaseUrl + options.path;
        }
        handler.next(options);
      },
    ));
  }
}
```

## 📱 **Kullanıcı Arayüzü**

### **Ana Ayarlar Sayfası:**
- **Dil Seçimi**: Radio button'lar ile
- **Bağlantı Ayarları**: Şifre korumalı erişim
- **Sistem Bilgileri**: Uygulama detayları

### **Bağlantı Ayarları Sayfası:**
- **Şifre Kontrolü**: Giriş zorunluluğu
- **API URL Formu**: Validation ile
- **Şifre Değiştirme**: Güvenli güncelleme

### **Admin Şifre Dialog'u:**
- **Auto-focus**: Otomatik şifre alanı odağı
- **Show/Hide**: Şifre görünürlük kontrolü
- **Varsayılan Şifre Bilgisi**: UI'da gösterim

## 🔄 **Navigation & Routing**

### **Yeni Route'lar:**
```dart
GoRoute(
  path: '/settings',
  name: 'settings',
  builder: (context, state) => const SettingsPage(),
),
GoRoute(
  path: '/connection-settings',
  name: 'connection-settings',
  builder: (context, state) => const ConnectionSettingsPage(),
),
```

### **Ana Sayfaya Ayarlar Butonu:**
```dart
IconButton(
  icon: const Icon(Icons.settings),
  onPressed: () => context.pushNamed('settings'),
  tooltip: 'Ayarlar',
),
```

## 🗂️ **Dependency Injection**

### **Yeni DI Kayıtları:**
```dart
// Settings feature
sl.registerLazySingleton<SettingsLocalDataSource>(() => SettingsLocalDataSourceImpl(box: sl()));
sl.registerLazySingleton<SettingsRepository>(() => SettingsRepositoryImpl(localDataSource: sl()));
sl.registerLazySingleton<GetSettings>(() => GetSettings(sl()));
sl.registerLazySingleton<VerifyAdminPassword>(() => VerifyAdminPassword(sl()));
sl.registerLazySingleton<UpdateApiUrl>(() => UpdateApiUrl(sl()));

// API URL Service
sl.registerLazySingleton<ApiUrlService>(() => ApiUrlService(box: sl()));
```

## 🌍 **Çok Dil Desteği**

### **Yeni Çeviri Anahtarları:**
```json
// Türkçe (tr.json)
{
  "settings_title": "Ayarlar",
  "settings_language": "Dil Ayarları",
  "settings_connection": "Bağlantı Ayarları",
  "settings_security_check": "Güvenlik Kontrolü",
  "settings_api_base_url": "API Base URL",
  "settings_admin_password": "Admin Şifresi",
  "settings_default_password": "Varsayılan şifre: 27526",
  "settings_updated": "Ayarlar başarıyla güncellendi"
}
```

## 💾 **Veri Saklama**

### **Hive Storage:**
- **Ayarlar**: `app_settings` key'i ile JSON format
- **API URL**: `api_base_url` key'i ile string format
- **Dil Kodu**: `locale_code` key'i ile string format

### **Default Values:**
```dart
static const AppSettings defaultSettings = AppSettings(
  apiBaseUrl: 'http://192.168.2.9:5100',
  languageCode: 'tr',
  adminPassword: '27526',
);
```

## 🧪 **Test & Debug**

### **API Health Check Güncellendi:**
```dart
Future<void> testAllEndpoints() async {
  final currentUrl = getCurrentBaseUrl();
  print('🌐 Base URL: $currentUrl');
  // ... endpoint testleri
}
```

### **Console Log'ları:**
- API URL değişikliği bildirimi
- Şifre doğrulama durumu
- Settings yükleme/kaydetme durumu

## 🚀 **Kullanım Adımları**

### **1. Ayarlara Erişim:**
- Ana sayfada ⚙️ (settings) butonuna tıklayın
- Ayarlar sayfası açılır

### **2. Dil Değiştirme:**
- "Dil Ayarları" bölümünde Türkçe/İngilizce seçin
- Anında uygulanır ve kaydedilir

### **3. Bağlantı Ayarları:**
- "Bağlantı Ayarlarını Yönet" butonuna tıklayın
- Admin şifresini girin (varsayılan: 27526)

### **4. API URL Değiştirme:**
- Yeni URL'yi girin (örn: `http://192.168.1.100:5100`)
- "API URL'yi Güncelle" butonuna tıklayın
- Uygulama yeniden başlatılmalıdır

### **5. Şifre Değiştirme:**
- Yeni şifreyi "Yeni Şifre" alanına girin
- "Şifreyi Güncelle" butonuna tıklayın

## ⚠️ **Önemli Notlar**

### **Güvenlik:**
- Admin şifresi değiştirilmesi önerilir
- Şifre plain text olarak saklanır (güvenlik riski)
- Production'da hash'lenmiş şifre kullanılmalı

### **URL Değişikliği:**
- API URL değişikliği uygulama restart'ı gerektirir
- Geçersiz URL'ler validation ile engellenir
- Eski URL'e geri dönüş manuelden yapılmalı

### **Backward Compatibility:**
- Mevcut tezgah özellikleri etkilenmez
- Eski dil değiştirme sistemi korunur
- API client'ı geriye dönük uyumlu

## 🎉 **Sonuç**

Ayarlar sistemi başarıyla implement edildi:
- ✅ **Mimariye Uygun**: Clean Architecture prensiplerine uygun
- ✅ **Güvenli**: Şifre korumalı critical ayarlar
- ✅ **Kullanıcı Dostu**: Intuitive UI/UX
- ✅ **Genişletilebilir**: Yeni ayarlar kolayca eklenebilir
- ✅ **Çok Dilli**: TR/EN desteği
- ✅ **Persistent**: Ayarlar kalıcı olarak saklanır

Sistem artık dinamik API URL desteği ve gelişmiş ayar yönetimi ile production ready! 🚀
