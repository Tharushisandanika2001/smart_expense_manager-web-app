 Smart Expense Manager

A powerful **Full-Stack Mobile & Web Application** designed to help users track their daily finances and receive automated, logic-based advice on budget optimization.



 Specialist Features

- **Smart Advice Engine:** A custom Python algorithm in the backend that analyzes income vs. expenses. If overspending occurs, it suggests prioritized reductions (e.g., 20% on essentials like 'Food', 40% on others).
- **Relational Data Management:** Built with an **SQLite** database managed via **SQLAlchemy ORM**, featuring structured relationships between Users, Incomes, and Expenses.
- **Dynamic Analytics:** Integrated `fl_chart` to provide interactive Pie Charts for category-based spending analysis.
- **Secure Authentication:** Implemented user data protection using industry-standard **PBKDF2 password hashing**.

Tech Stack

- **Frontend:** Flutter (Dart)
- **Backend:** Flask (Python)
- **Database:** SQLite
- **Tools:** REST API, Shared Preferences, SQLAlchemy

Database Schema
The system uses a relational model to maintain data integrity:
- **Users:** Stores credentials (hashed) and links to financial data.
- **Incomes:** User-specific income records.
- **Expenses:** Categorized expense records (Food, Transport, Rent, etc.) linked to the user.



 How to Run

1. **Backend:**
   - Navigate to the backend folder.
   - Run `python app1.py`.
2. **Frontend:**
   - Run `my_web_app`.
   - Run `flutter run`.
