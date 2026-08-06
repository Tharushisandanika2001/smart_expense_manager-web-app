# 💰 Smart Expense Manager

A personal expense management application built using **Flutter** and **Python Flask**.

It helps users manage income and expenses, view spending summaries, analyze expense categories, and receive smart budgeting advice.

## ✨ Features

* 🔐 User Registration & Login
* 💵 Monthly Income Management
* 💸 Expense Management
* 📊 Expense Distribution Chart
* 📈 Financial Summary
* 🧠 Smart Financial Advice
* 🔄 Data Reset
* 👤 User-specific Financial Data

## 🛠️ Technology Stack

### Frontend

* Flutter
* Dart
* Material Design
* HTTP
* Shared Preferences
* FL Chart

### Backend

* Python
* Flask
* Flask-SQLAlchemy
* Flask-CORS
* SQLite
* Werkzeug Password Hashing

### Architecture

```text
Flutter Web Application
        │
        │ HTTP / REST API
        ▼
Python Flask Backend
        │
        │ SQLAlchemy ORM
        ▼
SQLite Database
        │
        ▼
User Income & Expense Data
        │
        ▼
Financial Analysis & Smart Advice
```

## 📁 Project Structure

```text
smart_expense_manager-web-app/
├── backend/
│   ├── app1.py
│   └── ...
├── frontend/
│   └── my_web_app/
│       ├── lib/
│       ├── assets/
│       └── pubspec.yaml
├── README.md
└── .gitignore
```

## 🚀 Run the Project

### Backend

```bash
cd backend
pip install flask flask-sqlalchemy flask-cors werkzeug
python app1.py
```

Backend:

```text
http://127.0.0.1:5000
```

### Frontend

```bash
cd frontend/my_web_app
flutter pub get
flutter run -d chrome
```

## 🔗 Project Resources

* [📂 Documentation](https://drive.google.com/drive/folders/1X3QDRAApMDR1GpbzHSt64-Kj453Aucrp?usp=drive_link)
* [🎥 Project Demo](https://drive.google.com/file/d/11iOPt4Ml0i2cHSgqznZE3bUoJrQxRNCE/view?usp=drive_link)
  
## 👩‍💻 Developer

Developed as a **Smart Expense Management System** using **Flutter, Dart, Python, Flask and SQLite**.
