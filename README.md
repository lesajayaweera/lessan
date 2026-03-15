# Dorm Link - Smart Hostel Management App

Dorm Link is a comprehensive smart hostel management application designed specifically for students. It streamlines hostel life by integrating essential utilities, social features, and AI-driven support.

## 🚀 Key Features

- **AI Support Assistant**: Powered by Gemini, helping students with troubleshooting and app usage.
- **Bill Splitting**: Easily divide costs for rent, utilities, and grocery runs among roommates.
- **Expense Tracking**: Personal and shared expense management tailored for student budgets.
- **Group Chats**: Stay connected with floor mates and roommates through organized communication channels.
- **AR-Guided Maintenance**: Visual guides to help report and resolve maintenance issues efficiently.
- **Power & Drain Analyzers**: Smart monitoring tools for resources in the hostel environment.

## 📁 Project Structure

Here is an overview of the important directories and files in this project:

### Root Directory
- `/lib`: This is where all the Flutter source code lives.
- `/android`, `/ios`, `/web`, `/windows`, `/linux`, `/macos`: Platform-specific configuration files.
- `pubspec.yaml`: Manages the project's dependencies (e.g., `google_generative_ai`).
- `README.md`: This file! (Project overview and instructions).

### Library (`/lib`)
- `main.dart`: The entry point of the application.
- `ai_service.dart`: Handles the integration with the Gemini API and local fallback logic.
- `chat_service.dart`: Manages chat session state and message persistence.
- `chat_provider.dart`: The state management layer using the `provider` package.
- `chat_screen.dart` & `chat_sessions_screen.dart`: The main UI components for the chat interface.
- `chat_message.dart`, `chat_session.dart`: Data models for messages and chat sessions.
- `message_bubble.dart`, `typing_indicator.dart`: Reusable UI widgets for the chat experience.

## 🛠️ Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
- A valid [Gemini API Key](https://aistudio.google.com/app/apikey).

### Setup
1.  **Clone the project** to your local machine.
2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
3.  **API Configuration**: Ensure your API key is correctly set in `lib/ai_service.dart`.
4.  **Run the app**:
    ```bash
    flutter run
    ```

## 🤖 AI Support Assistant Details

The chatbot is optimized with a specific system persona for **Dorm Link**. It is designed to understand the context of student life and hostel maintenance.

**Model Used**: `gemini-3.1-flash-lite-preview` (Configurable in `ai_service.dart`).

---
Developed as part of the Dorm Link smart hostel initiative.
