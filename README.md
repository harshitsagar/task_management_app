# Task Manager App ✅

A Flutter application developed as part of the Flodo AI Take-Home Assignment. The app provides a complete task management solution with CRUD operations, draft persistence, search/filter functionality, and visual task blocking indicators.

## Track Information 🎯

- **Track**: **B - Mobile Specialist**
- **Stretch Goal**: None (focused on delivering polished core requirements)
- **State Management**: Simple setState with clean architecture
- **Storage**: SharedPreferences (local database)
- **Status**: All requirements implemented, no errors

## Features ✅

### 📋 Task Management
- Create, Read, Update, Delete tasks
- Task model with Title, Description, Due Date, Status, and Blocked By
- Real-time search by task title
- Filter tasks by status (To-Do/In Progress/Done)

### 🔒 Blocked Tasks
- Visual blocking indicator - tasks blocked by incomplete tasks appear greyed out
- Automatic cleanup of orphaned blocker references when tasks are deleted
- Blocked tasks become available when blocking task is completed

### 💾 Draft Persistence
- Auto-save form data while typing
- Restore drafts when reopening creation screen
- Clear drafts only after successful task creation

### ⏱️ Loading States
- 2-second simulated delay on all creates and updates
- Non-blocking UI with loading indicators
- Prevent double-tap on save buttons

### 🎨 UI/UX
- Modern Material Design 3
- Fully responsive using flutter_screenutil
- Quick status update buttons on each task card
- Smooth animations and transitions
- Empty state illustrations
- Color-coded status indicators

## Architecture 🏗️

- **State Management**: Simple setState with clean architecture
- **Clean Code**: Modular and reusable widgets
- **Storage Layer**: Repository pattern for data persistence
- **Models**: Strongly typed Task model with enums
- **Services**: Dedicated DraftService for persistence
- **Responsive Design**: flutter_screenutil for all screen sizes

## Tech Stack 🛠️

- Flutter 3.0+
- Dart
- SharedPreferences (Local Storage)
- flutter_screenutil (Responsive Design)
- intl (Date Formatting)
- google_fonts (Typography)

## Local Storage Details 💾

- **Storage Method**: SharedPreferences with JSON serialization
- **Data Structure**: JSON array of tasks
- **Draft Storage**: Separate key for draft persistence
- **Data Cleanup**: Automatic cleanup of orphaned blocker references

## Screens 📱

- **Task List** – Fully implemented with search, filter, and task cards
- **Create/Edit Task** – Fully implemented with form validation and draft persistence
- **Empty State** – Friendly UI when no tasks exist
- **Placeholders** – None, all screens fully implemented

## AI Tools Used
 * Claude AI - Primary development assistant
 * ChatGPT - Debugging and optimization

## Setup Instructions 🚀

## Setup Instructions 🚀

1. **Clone repository**
   ```bash
   git clone https://github.com/harshitsagar/task_management_app.git

2. **Install dependencies**
   ```bash
   flutter pub get

3. **Run the App**
   ```bash
    flutter run
