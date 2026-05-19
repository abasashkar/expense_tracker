import 'package:flutter/material.dart';

import 'package:expense_tracker/app.dart';
import 'package:expense_tracker/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInjection.init();
  runApp(const ExpenseTrackerApp());
}
