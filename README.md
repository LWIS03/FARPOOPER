# Fapooper 🚽✨

## TRY IT OUT !!!
https://drive.google.com/drive/folders/14K4SJQ0idXrlafepCAqvFX4NEnC42ee-?usp=drive_link 


Fapooper is a gamified mobile application built with **Flutter** and **Dart** that turns one of the most basic human needs into a playful experience.  

The idea is simple:  
- You set your home location.  
- Every time you "go" somewhere else, the app tracks the distance from home.  
- The farther away you are, the more points you score.  

It’s a fun and lighthearted way to explore gamification, geolocation, authentication, and Flutter app development.

---

## ✨ Features

- 📍 **Set your home location** – Choose where you live using an interactive map.  
- 🌍 **Real-time maps** – Powered by Google Maps integration.  
- 💩 **Gamified scoring system** – Earn more points the farther you are from home.  
- 🚻 **Public toilet map** – Discover nearby public restrooms.  
- 🔥 **Firebase integration** – For user data, authentication, and storage.  
- 🔑 **Authentication options** – Sign up/login with:
  - Google  
  - Email & password  

---

###  FRONTEND

- **Frontend:** Flutter (Dart)  
- **State management:** Flutter widgets & providers  
- **Maps:** Google Maps SDK  
- **Backend / Cloud:** Firebase  
- **Authentication:** Firebase Auth (Google + Email/Password)  
- **Database/Storage:** Firebase services  

---

####  Project Structure (Highlights)

- `main.dart` – App entry point  
- `MainPage.dart` – Main navigation & UI container  
- `map_page.dart` – Core map view  
- `choose_home_dialog.dart` – Dialog for setting home location  
- `publicToilet_map.dart` – Displays nearby toilets  
- `global_map.dart` – Global player activity view  
- `poop.dart` / `getPoop.dart` – Core logic for scoring and tracking  
- `user.dart` – User model  
- `firebase_options.dart` – Firebase configuration  
- `google_auth.dart` – Google sign-in logic  
- `google_login_screen.dart` – UI for Google login  
- `mail_register.dart` – UI for email registration  

##  BACKEND - Fapooper API (Java + Spring Boot)

This is the backend for **Fapooper**, built with **Java 17** and **Spring Boot**.  
It exposes a REST API to manage users, friendships, and “poops” (events), calculates points based on distance from the user’s home coordinates, and persists data in **PostgreSQL**.

- **Runtime:** Java 17, Spring Boot  
- **Database:** PostgreSQL (hosted on **Aiven**)  
- **Deployment:** **Railway** (always-on service)

> The frontend (Flutter/Dart) consumes this API for authentication hand-off, map interactions, and scoring.

---

###  Main Modules & Entities

- `User` — app user; includes username, email, UID (from auth), home coordinates, relationships, and user’s poops.
- `Poop` — an event with name, skinId, points, coordinates, distance from home, and creation date.
- `Pair<X, Y>` — embeddable coordinate pair (`latitude` = `first`, `longitude` = `second`).
- `Coordinates` — light helper model with `Altitude` and `Latitude`.
- DTOs:
  - `UserGetDto` — user payload returned to the client (includes optional `jwtToken`, id, username, email, `HomeCords`, and user’s `poops`).
  - `UserEditDto` — payload to update username, UID, email, and home coordinates.
  - `PoopDto` — payload to add a new poop (`uid`, `skinId`, `name`, `coordinates`).

**Controllers**
- `UserController` → `/Users`
  - Friendship management:
    - `PUT /Users/newFriend/{uid}/{uid2}` — add mutual friendship between two users.
    - `PUT /Users/RemoveFriend/{uid}/{uid2}` — remove friendship.
  - *(Other CRUD/get endpoints exist in the service; keep reading examples below.)*
- `PoopController` → `/Poops`
  - `PUT /Poops/add` — add a new poop for a user and receive computed points.

> Services used internally: `UserService`, `PoopService`.

---
### Data Model Highlights

#### User (simplified)
- `id`, `uid` (external auth uid), `username`, `email`
- `homeCords`: `Pair<Float, Float>` (latitude/longitude)
- `poops`: `Set<Poop>`
- `friends`: `Set<User>` (bi-directional friendship)
- `dateCreated`, `dateUpdated`

#### Poop (simplified)
- `id`, `skinId`, `name`, `points`
- `coordenates`: `Pair<Float, Float>` (latitude/longitude)
- `distanceFromHomeCords`: `Double` (meters or km — depending on service logic)
- `dateCreated`
---

###  Services

- **`UserService.java`**
  - Orchestrates user lifecycle: creation/lookup, profile edits, and home coordinates management.
  - Manages **friendship links** (mutual add/remove) and related consistency rules.
  - Bridges controllers and repositories, handling validation and domain mapping to DTOs (`UserGetDto`, `UserEditDto`).

- **`PoopService.java`**
  - Receives `PoopDto` events from the controller, validates the user (`uid`), and **computes points** based on the distance between the event coordinates and the user’s `homeCords`.
  - Persists the `Poop` entity, updates the user’s collection, and returns the awarded **points** (integer).

> Notes:
> - Distance/points logic lives at the **service** layer to keep controllers thin and repositories focused on I/O.
> - DTOs isolate the API surface from entity internals.

###  Repositories (Spring Data JPA)

- **`UserRepository.java`** — Spring Data JPA interface for `User`.
  - Centralizes user persistence, identity lookup (e.g., by `uid`), and relationship fetches.
- **`PoopRepository.java`** — Spring Data JPA interface for `Poop`.
  - Persists poop events and supports retrieval/aggregation as needed.

---

