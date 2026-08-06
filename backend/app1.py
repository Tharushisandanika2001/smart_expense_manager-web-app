from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from datetime import datetime
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__)
CORS(app)  

# ---------------- DATABASE CONFIG ----------------
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///expense_app.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

# ---------------- MODELS (DATABASE TABLES) ----------------

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password = db.Column(db.String(200), nullable=False)
    
    incomes = db.relationship('Income', backref='user', lazy=True, cascade="all, delete-orphan")
    expenses = db.relationship('Expense', backref='user', lazy=True, cascade="all, delete-orphan")

class Income(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    amount = db.Column(db.Float, nullable=False)
    date = db.Column(db.String(50))
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)

class Expense(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    category = db.Column(db.String(50), nullable=False)
    amount = db.Column(db.Float, nullable=False)
    date = db.Column(db.String(50))
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)


with app.app_context():
    db.create_all()

# ---------------- AUTH ROUTES (SIGNUP & LOGIN) ----------------

@app.route('/signup', methods=['POST'])
def signup():
    data = request.get_json()
    username = data.get("username")
    password = data.get("password")

    if not username or not password:
        return jsonify({"message": "Username and password are required"}), 400

    if User.query.filter_by(username=username).first():
        return jsonify({"message": "User already exists"}), 400

    hashed_pw = generate_password_hash(password)
    new_user = User(username=username, password=hashed_pw)
    db.session.add(new_user)
    db.session.commit()

    return jsonify({"message": "User created successfully"}), 201

@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    user = User.query.filter_by(username=data.get("username")).first()

    if user and check_password_hash(user.password, data.get("password")):
        return jsonify({"user_id": user.id, "message": "Login successful"}), 200

    return jsonify({"message": "Invalid login credentials"}), 401

# ---------------- DATA ROUTES (INCOME & EXPENSE) ----------------

@app.route('/add_income', methods=['POST'])
def add_income():
    data = request.get_json()
    user_id = data.get("user_id")
    amount = float(data.get("amount", 0))
    date = data.get("date", datetime.now().isoformat())

    if not user_id or amount <= 0:
        return jsonify({"message": "Invalid user ID or amount"}), 400

    
    Income.query.filter_by(user_id=user_id).delete()
    
    Expense.query.filter_by(user_id=user_id).delete()

    income = Income(amount=amount, date=date, user_id=user_id)
    db.session.add(income)
    db.session.commit()

    return jsonify({"message": "Income added and previous data cleared"}), 200

@app.route('/add_expense', methods=['POST'])
def add_expense():
    data = request.get_json()
    user_id = data.get("user_id")
    category = data.get("category", "Other")
    amount = float(data.get("amount", 0))
    date = data.get("date", datetime.now().isoformat())

    if not user_id or amount <= 0:
        return jsonify({"message": "Invalid expense data"}), 400

    expense = Expense(category=category, amount=amount, date=date, user_id=user_id)
    db.session.add(expense)
    db.session.commit()

    return jsonify({"message": "Expense added successfully"}), 200
# ---------------- PIE CHART & SMART ADVICE ROUTE ----------------

@app.route('/get_advice/<int:user_id>', methods=['GET'])
def get_advice(user_id):
    incomes = Income.query.filter_by(user_id=user_id).all()
    expenses = Expense.query.filter_by(user_id=user_id).all()

    total_income = sum(i.amount for i in incomes)
    total_expense = sum(e.amount for e in expenses)
    remaining = total_income - total_expense

    expenses_list = [
        {"category": e.category, "amount": e.amount, "date": e.date}
        for e in expenses
    ]

    if total_income == 0:
        return jsonify({
            "total_income": 0,
            "total_expense": total_expense,
            "remaining": -total_expense,
            "status": "No Income",
            "advice": "Please add your income to get expense analysis.",
            "expenses": expenses_list
        }), 200

    ratio = total_expense / total_income

    if ratio <= 1:
        # NORMAL STATES
        if ratio == 0:
            status = "Excellent"
            advice = "No expenses yet. Great start!"
        elif ratio < 0.5:
            status = "Excellent"
            advice = "You are saving more than 50% of your income. Keep it up!"
        elif ratio < 0.8:
            status = "Good"
            advice = "Your spending is under control. Try investing your savings."
        else:
            status = "Fair"
            advice = "You are spending almost all your income. Be cautious."

    else:
        # ---------------- SMART PROPORTIONAL REDUCTION ----------------
        status = "Overspending"
        excess = total_expense - total_income
        reduction_steps = []

        # Sort expenses by amount descending (to reduce big expenses first)
        sorted_expenses = sorted(expenses, key=lambda x: x.amount, reverse=True)

        remaining_excess = excess

        for e in sorted_expenses:
            if remaining_excess <= 0:
                break

            # Max allowed reduction
            max_reduce = e.amount * (0.4 if e.category != "Food" else 0.2)
            reduce_amount = min(max_reduce, remaining_excess)

            if reduce_amount > 0:
                reduction_steps.append(
                    f"Reduce Rs.{int(reduce_amount)} from {e.category}"
                )
                remaining_excess -= reduce_amount

        advice = (
            f"Your expenses exceed your income by Rs.{int(excess)}.\n\n"
            "To balance your budget:\n"
            + "\n".join(f"• {step}" for step in reduction_steps)
            + "\n\nAfter these reductions, your expenses will match your income."
        )

    return jsonify({
        "total_income": total_income,
        "total_expense": total_expense,
        "remaining": round(remaining, 2),
        "status": status,
        "advice": advice,
        "expenses": expenses_list
    }), 200

# ---------------- RESET DATA ----------------

@app.route('/reset/<int:user_id>', methods=['POST'])
def reset(user_id):
    Income.query.filter_by(user_id=user_id).delete()
    Expense.query.filter_by(user_id=user_id).delete()
    db.session.commit()
    return jsonify({"message": "User data reset successfully"}), 200

if __name__ == '__main__':
    
    app.run(debug=True, host='0.0.0.0', port=5000)