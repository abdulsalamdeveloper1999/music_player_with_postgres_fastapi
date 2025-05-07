# Music Player with Postgres, FastAPI, and Flutter

A full-stack music player application featuring a Flutter frontend and a FastAPI backend with PostgreSQL. Users can upload, play, and favorite songs, with secure authentication and cloud storage for media files.

---

## Features

### Backend (FastAPI)
- User authentication (signup, login, JWT-based auth)
- Song upload (with Cloudinary), list, and delete
- Mark/unmark songs as favorites, list user's favorites
- PostgreSQL database with SQLAlchemy ORM
- Models: User, Song, Favorite (many-to-many)
- JWT authentication middleware

### Frontend (Flutter)
- Riverpod for state management
- just_audio for audio playback
- Hive for local storage
- Material design UI, login/home navigation
- File picker, audio waveform, color picker for song theming

---

## Project Structure

```
.
├── client/   # Flutter app (frontend)
│   ├── lib/          # Main Flutter code
│   │   ├── core/     # Core utilities, theme, providers
│   │   └── features/ # Feature-based MVVM architecture
│   │       ├── auth/ # Authentication feature
│   │       │   ├── models/      # Data models
│   │       │   ├── repositories/ # Data repositories
│   │       │   ├── viewmodel/   # ViewModels
│   │       │   ├── views/       # UI views
│   │       │   └── widgets/     # Reusable widgets
│   │       └── home/ # Home feature
│   │           ├── model/       # Data models
│   │           ├── repository/  # Data repositories
│   │           ├── viewmodel/   # ViewModels
│   │           └── views/       # UI views

├── server/   # FastAPI app (backend)
│   ├── main.py       # Entry point for FastAPI
│   ├── database.py   # Database connection setup
│   ├── models/       # SQLAlchemy models
│   ├── routes/       # API endpoints
│   ├── middleware/   # Middleware (e.g., auth)
│   └── pydantic_schemas/ # Pydantic schemas for API
└── README.md # Project documentation
```

---

## Backend Setup (FastAPI)

1. **Install dependencies:**
   - Create a virtual environment and activate it.
   - Install FastAPI, SQLAlchemy, psycopg2, bcrypt, python-jose, cloudinary, and other dependencies.

2. **Configure PostgreSQL:**
   - Ensure PostgreSQL is running and update the `DATABASE_URL` in `server/database.py` if needed.

3. **Run the server:**
   ```bash
   cd server
   uvicorn main:app --reload
   ```

4. **API Endpoints:**
   - `/auth/signup` - Register a new user
   - `/auth/login` - Login and receive JWT
   - `/song/upload` - Upload a new song (requires auth)
   - `/song/list` - List all songs (requires auth)
   - `/song/favorite` - Mark/unmark favorite (requires auth)
   - `/song/list/favorites` - List favorites (requires auth)
   - `/song/delete-song/{song_id}` - Delete a song (requires auth)

---

## Frontend Setup (Flutter)

1. **Install Flutter dependencies:**
   ```bash
   cd client
   flutter pub get
   ```

2. **Run the app:**
   ```bash
   flutter run
   ```

3. **Main packages used:**
   - flutter_riverpod, just_audio, hive, file_picker, audio_waveforms, flex_color_picker, shared_preferences

---

## Notes
- Media files are stored in Cloudinary (see `server/routes/song.py` for config).
- JWT secret and database credentials should be secured for production.
- See `client/README.md` for more Flutter-specific info.

---

## License
MIT
