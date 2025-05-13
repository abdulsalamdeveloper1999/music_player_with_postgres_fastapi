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
   fastapi dev main.py
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
<img width="372" alt="Screenshot 2025-05-11 at 6 11 30 pm" src="https://github.com/user-attachments/assets/2d592f1d-40dc-436a-bde3-ba6b44c1f468" />
<img width="372" alt="Screenshot 2025-05-11 at 6 09 49 pm" src="https://github.com/user-attachments/assets/e55013d8-4c0d-4925-b641-22b35f792f91" />
<img width="372" alt="Screenshot 2025-05-11 at 6 09 24 pm" src="https://github.com/user-attachments/assets/aeda6f22-dc9b-4fc1-b70a-85e0ecb74600" />
<img width="372" alt="Screenshot 2025-05-11 at 6 10 04 pm" src="https://github.com/user-attachments/assets/fe7bc36d-e05e-4265-8748-8a27d9589e50" />
<img width="372" alt="Screenshot 2025-05-11 at 6 10 08 pm" src="https://github.com/user-attachments/assets/294ed597-09ca-4e15-a484-9df1c4fbc6c0" />
<img width="372" alt="Screenshot 2025-05-11 at 6 11 00 pm" src="https://github.com/user-attachments/assets/7c158ac3-7fe6-4f9b-803a-3092b0f658fb" />
<img width="372" alt="Screenshot 2025-05-11 at 6 11 04 pm" src="https://github.com/user-attachments/assets/198fd54f-ff44-4724-9c57-64f3ed827a70" />
<img width="372" alt="Screenshot 2025-05-11 at 6 11 42 pm" src="https://github.com/user-attachments/assets/3b2f9ed8-3f90-43b8-b525-fcb624b9b33c" />


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
