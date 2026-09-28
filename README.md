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
- La base SQLite `app.db` est créée automatiquement au premier lancement (supprime-la pour repartir de zéro).

## Lancer le frontend

Le backend doit tourner à côté.

```bash
cd frontend
flutter pub get
flutter run -d chrome                                          # web
flutter build web --dart-define=API_URL=https://mon-api.fr     # build web de prod
flutter run -d <emulateur> --dart-define=API_URL=http://10.0.2.2:8000   # émulateur Android
flutter run -d <iphone>                                        # simulateur iOS (localhost marche)
```

- Tests : `flutter test`
- Lint : `flutter analyze`

> Sur un vrai téléphone, remplace l'URL par l'IP locale de ton ordi
> (ex. `--dart-define=API_URL=http://192.168.1.20:8000`) et lance uvicorn avec `--host 0.0.0.0`.

## Fonctionnalités (branche `arthur-full`)

- Inscription / connexion (JWT), session conservée au redémarrage de l'app
- Profil : modifier son nom, changer de mot de passe, se déconnecter, supprimer son compte
- CRUD d'**items** privés à chaque utilisateur (liste, ajout, modification, cocher, swipe pour supprimer)

> Les « items » sont une ressource d'exemple : renomme-les / duplique-les selon le métier
> du projet (voir `backend/app/models.py` et `frontend/lib/models/item.dart`).

### Endpoints

| Méthode | Route                    | Auth | Rôle                        |
|---------|--------------------------|------|-----------------------------|
| GET     | `/api/v1/health`         |      | l'API répond ?              |
| POST    | `/api/v1/auth/register`  |      | créer un compte             |
| POST    | `/api/v1/auth/login`     |      | obtenir un token (JSON)     |
| GET     | `/api/v1/users/me`       | ✔    | mon profil                  |
| PATCH   | `/api/v1/users/me`       | ✔    | modifier nom / mot de passe |
| DELETE  | `/api/v1/users/me`       | ✔    | supprimer mon compte        |
| GET     | `/api/v1/items`          | ✔    | lister mes items            |
| POST    | `/api/v1/items`          | ✔    | créer                       |
| GET     | `/api/v1/items/{id}`     | ✔    | détail                      |
| PATCH   | `/api/v1/items/{id}`     | ✔    | modifier                    |
| DELETE  | `/api/v1/items/{id}`     | ✔    | supprimer                   |

Dans `/docs`, clique sur **Authorize** (email dans le champ *username*) pour tester les routes protégées.

## Structure

### Backend
```
backend/app/
├── main.py            création de l'app, CORS, routeurs, création des tables
├── db.py              connexion SQLAlchemy (SQLite en dev)
├── models.py          tables (User, Item)
├── schemas.py         formats d'entrée / sortie de l'API (Pydantic)
├── core/
│   ├── config.py      configuration (.env)
│   └── security.py    hash des mots de passe (argon2) + JWT
└── api/
    ├── deps.py        dépendances (session DB, utilisateur connecté)
    ├── router.py      regroupe toutes les routes sous /api/v1
    └── routes/        auth.py, users.py, items.py, health.py
```

### Frontend
```
frontend/lib/
├── main.dart              point d'entrée, Provider, AuthGate (login ou accueil)
├── config/api_config.dart URL de l'API
├── models/                User, Item (JSON -> Dart)
├── services/              ApiClient (HTTP + token + erreurs), AuthService, ItemService, TokenStorage
├── state/auth_state.dart  état de connexion global (ChangeNotifier)
├── pages/                 login, register, home (liste), item_form, profile
├── widgets/ utils/        petits composants et validateurs de formulaires
```

Les tests Flutter (`frontend/test/`) utilisent un faux backend en mémoire (`fake_backend.dart`),
pas besoin de lancer l'API pour les exécuter.
