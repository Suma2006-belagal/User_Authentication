# User Auth App

A full-stack authentication system with a Django REST Framework backend and a Flutter frontend. Supports user registration, login, and profile retrieval using token-based authentication.

## Tech Stack

- **Backend:** Django 6.0, Django REST Framework, Token Authentication
- **Frontend:** Flutter (Dart), `http`, `shared_preferences`

## Project Structure

```
user_auth/                  # Django project
├── user/                   # Django app (register/login/profile)
│   ├── serializers.py
│   ├── views.py
│   └── urls.py
├── user_auth/
│   ├── settings.py
│   └── urls.py
└── manage.py

flutter_application/         # Flutter project
├── lib/
│   ├── main.dart
│   ├── services/
│   │   └── api_service.dart
│   └── screens/
│       ├── login_screen.dart
│       ├── register_screen.dart
│       └── profile_screen.dart
└── pubspec.yaml
```

## Backend Setup (Django)

```bash
cd user_auth
python -m venv venv
venv\Scripts\activate          # Windows
pip install django djangorestframework django-cors-headers
python manage.py migrate
python manage.py runserver 0.0.0.0:8000
```

### API Endpoints

| Method | Endpoint                  | Auth required | Description              |
|--------|----------------------------|----------------|--------------------------|
| POST   | `/api/auth/register/`      | No             | Create a new user        |
| POST   | `/api/auth/login/`         | No             | Log in, returns token     |
| GET    | `/api/auth/profile/`       | Yes (Token)    | Get logged-in user's data |

## Frontend Setup (Flutter)

```bash
cd flutter_application
flutter pub get
flutter run -d windows      # or -d edge / -d chrome / -d <android-device-id>
```

### Configuring the API base URL

In `lib/services/api_service.dart`, set `baseUrl` based on where you're running the app:

| Platform                  | baseUrl                              |
|----------------------------|---------------------------------------|
| Windows desktop / web       | `http://127.0.0.1:8000/api/auth`     |
| Android emulator            | `http://10.0.2.2:8000/api/auth`      |
| Physical device (same Wi-Fi)| `http://<your-machine-LAN-IP>:8000/api/auth` |

> Note: `baseUrl` should **not** include `/register/`, `/login/`, or `/profile/` — those are appended in each method.

### Android cleartext traffic

Since the Django server runs on plain HTTP, add this inside `<application>` in `android/app/src/main/AndroidManifest.xml`:

```xml
android:usesCleartextTraffic="true"
```

## Troubleshooting

- **"Building with plugins requires symlink support"** → Enable Developer Mode on Windows: run `start ms-settings:developers` and toggle it on, then reopen the terminal.
- **Login/Register hangs indefinitely** → Check `baseUrl` isn't duplicating the endpoint path, and confirm the Django server is running.
- **Dart compiler crash on web build** → Run `flutter clean && flutter pub get`, or try a different target device (`flutter devices`).

## License

For educational/personal project use.
