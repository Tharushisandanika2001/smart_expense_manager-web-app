import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';


import 'splash_page.dart';
import 'auth_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExpenseApp());
}

class ExpenseApp extends StatelessWidget {
  const ExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Expense',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true, 
      ),
      home: const SplashPage(),
    );
  }
}

class ExpenseHomePage extends StatefulWidget {
  const ExpenseHomePage({super.key});

  @override
  State<ExpenseHomePage> createState() => _ExpenseHomePageState();
}

class _ExpenseHomePageState extends State<ExpenseHomePage> {
  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _expenseAmountController =
      TextEditingController();

  String _selectedCategory = "Food";

  final List<String> _categories = [
    "Food",
    "Transport",
    "Rent",
    "Water Bill",
    "Electricity Bill",
    "Internet",
    "Health",
    "Education",
    "Entertainment",
    "Shopping",
    "Other",
  ];

  double _totalIncome = 0;
  double _totalExpense = 0;
  List<Map<String, dynamic>> _expenses = [];
  String _adviceText = "";
  String _statusText = "";
  int? currentUserId;

  final String backendUrl = "http://127.0.0.1:5000";

  @override
  void initState() {
    super.initState();
    _loadUserAndData();
  }

  Future<void> _loadUserAndData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getInt('user_id');
    });
    if (currentUserId != null) {
      _fetchAdvice();
    }
  }

  Future<void> _addIncome() async {
    final income = double.tryParse(_incomeController.text);
    if (income != null && income > 0 && currentUserId != null) {
      try {
        await http.post(
          Uri.parse('$backendUrl/add_income'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            'user_id': currentUserId,
            'amount': income,
            'date': DateTime.now().toIso8601String(),
          }),
        );
        _incomeController.clear();
        _fetchAdvice();
      } catch (e) {
        _showError("Connection error!");
      }
    }
  }

  Future<void> _addExpense() async {
    final expense = double.tryParse(_expenseAmountController.text);
    if (expense != null && expense > 0 && currentUserId != null) {
      try {
        await http.post(
          Uri.parse('$backendUrl/add_expense'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            'user_id': currentUserId,
            'category': _selectedCategory,
            'amount': expense,
            'date': DateTime.now().toIso8601String(),
          }),
        );
        _expenseAmountController.clear();
        _fetchAdvice();
      } catch (e) {
        _showError("Connection error!");
      }
    }
  }

  Future<void> _fetchAdvice() async {
    if (currentUserId == null) return;
    try {
      final res = await http.get(
        Uri.parse('$backendUrl/get_advice/$currentUserId'),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _totalIncome = (data['total_income'] ?? 0).toDouble();
          _totalExpense = (data['total_expense'] ?? 0).toDouble();
          _expenses = List<Map<String, dynamic>>.from(data['expenses'] ?? []);
          _adviceText = data['advice'] ?? '';
          _statusText = data['status'] ?? '';
        });
      }
    } catch (e) {
      debugPrint("Fetch error: $e");
    }
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget buildPieChart() {
    if (_expenses.isEmpty) return const Center(child: Text("No expenses yet."));

    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: _expenses.map((e) {
            int index = _expenses.indexOf(e);
            return PieChartSectionData(
              color: Colors.primaries[index % Colors.primaries.length],
              value: (e['amount'] as num).toDouble(),
              title: e['category'],
              radius: 55,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double remaining = _totalIncome - _totalExpense;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Expense Manager"),
        centerTitle: true, 
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Monthly Income",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _incomeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Amount"),
                  ),
                ),
                ElevatedButton(onPressed: _addIncome, child: const Text("Add")),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Add Expense",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              onChanged: (val) => setState(() => _selectedCategory = val!),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _expenseAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Amount"),
                  ),
                ),
                ElevatedButton(
                  onPressed: _addExpense,
                  child: const Text("Add"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              color: Colors.teal[50],
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    Text(
                      "Status: $_statusText",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Divider(),
                    Text("Income: Rs.$_totalIncome | Spent: Rs.$_totalExpense"),
                    Text(
                      "Remaining: Rs.$remaining",
                      style: TextStyle(
                        color: remaining < 0 ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Expense Distribution",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            buildPieChart(),
            const SizedBox(height: 20),
            const Text(
              "Recent Expenses",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _expenses.length,
              itemBuilder: (context, index) {
                final e = _expenses[index];
                return ListTile(
                  leading: const Icon(Icons.payment, color: Colors.redAccent),
                  title: Text(e['category']),
                  trailing: Text("Rs.${e['amount']}"),
                );
              },
            ),
            if (_adviceText.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                "AI Advice:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              Text(
                _adviceText,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
