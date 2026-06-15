# NexPlay

A mobile gaming platform built with Flutter. Features free and premium games, social interactions, and secure payment integration.

## Features

- Google and GitHub authentication via Firebase Auth
- Free and premium game library
- In-app game purchases with Stripe
- Invoice email delivery via Resend
- Community reviews and ratings
- Dark and light theme support

## Tech Stack

- Flutter
- Firebase (Auth, Firestore, Storage)
- Stripe (Payment)
- Resend (Email)
- Provider (State Management)

## Requirements

- Flutter 3.x
- Android SDK 35+
- Firebase project configured
- NexPlay backend server running

## Setup

1. Clone the repository

```bash
   git clone https://github.com/jonathangunawan30/nexplay.git
   cd nexplay
```

2. Install dependencies

```bash
   flutter pub get
```

3. Create `.env` file in root directory

```bash
    STRIPE_PUBLISHABLE_KEY=pk_test_xxx
    CLOUDINARY_CLOUD_NAME=xxx
    CLOUDINARY_UPLOAD_PRESET=xxx
    CLOUDINARY_API_KEY=xxx
    CLOUDINARY_API_SECRET=xxx
```

4. Configure Firebase

    - Add `google-services.json` to `android/app/`
    - Firebase project must have Auth, Firestore, and Storage enabled

5. Run the app

```bash
   make run
```

## Backend

NexPlay requires the backend server to be running for payment and invoice features. See `backend-nodejs/README.md` for setup instructions.

## Notes

- Stripe is currently configured for test mode
- Games are played via WebView and require a stable internet connection
- Minecraft Classic requires a keyboard and is best played on desktop
___