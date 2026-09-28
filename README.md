# Projet 7360

Application **Flutter** (mobile + web) avec un backend **FastAPI** (Python).

```
.
├── backend/    API FastAPI (Python 3.11+)
└── frontend/   App Flutter (Android, iOS, Web)
```

## Prérequis

| Outil   | Version conseillée | Vérifier            |
|---------|--------------------|---------------------|
| Python  | 3.11+              | `python3 --version` |
| Flutter | 3.47 (stable)      | `flutter doctor`    |

Installer Flutter : https://docs.flutter.dev/get-started/install
(sur Mac : `brew install --cask flutter`, puis `flutter doctor` et suivre les indications
pour Xcode / Android Studio).

## Lancer le backend

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate        # Windows : .venv\Scripts\activate
pip install -r requirements-dev.txt
cp .env.example .env
uvicorn app.main:app --reload
```

- API : http://localhost:8000
- Doc interactive (Swagger) : http://localhost:8000/docs
- Tests : `pytest`

## Lancer le frontend

Le backend doit tourner à côté.

```bash
cd frontend
flutter pub get
flutter run -d chrome                                          # web
flutter run -d <emulateur> --dart-define=API_URL=http://10.0.2.2:8000   # émulateur Android
flutter run -d <iphone>                                        # simulateur iOS (localhost marche)
```

- Tests : `flutter test`
- Lint : `flutter analyze`

> Sur un vrai téléphone, remplace l'URL par l'IP locale de ton ordi
> (ex. `--dart-define=API_URL=http://192.168.1.20:8000`) et lance uvicorn avec `--host 0.0.0.0`.

## Structure

### Backend
```
backend/app/
├── main.py            création de l'app, CORS, routeurs
├── core/config.py     configuration (.env)
└── api/
    ├── router.py      regroupe toutes les routes sous /api/v1
    └── routes/        une route = un fichier (health.py, ...)
```

### Frontend
```
frontend/lib/
├── main.dart              point d'entrée + routes
├── config/api_config.dart URL de l'API
├── services/              appels HTTP vers le backend
└── pages/                 écrans (accueil, connexion, ...)
```
