# ISO-Core-App

## About the iOS app

**SmartChef** is a SwiftUI iOS app that helps users cook with what they already have. Users can search and browse recipes, track fridge/pantry items (with expiry reminders), find meals that match those ingredients, and save favorites. Accounts are handled with Firebase (email/password, Google Sign-In, Face ID), and recipe data comes from TheMealDB.

Main tabs: Home, Pantry, Favorites, and Profile.

## How a maker can reach the backend

This app uses two backends:

### 1. TheMealDB (recipes)

Public REST API — no API key needed for the free tier.

- Base URL: `https://www.themealdb.com/api/json/v1/1/`
- Search by name: `search.php?s={query}`
- Filter by ingredient: `filter.php?i={ingredient}`
- Lookup by meal ID: `lookup.php?i={mealId}`

The app calls these via `NetworkManager` / `URLSession` (see `HomeView`, `PantryViewModel`, `RecipeViewModel`).

Docs: https://www.themealdb.com/api.php

### 2. Firebase (auth, pantry, profile)

Project ID: `iso-core-app`

Configured with `GoogleService-Info.plist` and `FirebaseApp.configure()` at launch.

| Service | What it’s used for | How to reach it |
|--------|---------------------|-----------------|
| Firebase Auth | Sign up / sign in / Google Sign-In | Firebase Console → Authentication |
| Cloud Firestore | User profiles, favorites IDs, pantry (`users/{uid}/pantry`) | Firebase Console → Firestore |
| Cloud Storage | Profile images | Firebase Console → Storage |

Console: https://console.firebase.google.com/project/iso-core-app

A maker needs the project’s `GoogleService-Info.plist` (or their own Firebase iOS app config) in the Xcode target, plus the Firebase iOS SDK, to talk to the same backend from the app.
