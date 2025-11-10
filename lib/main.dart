import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi format tanggal Bahasa Indonesia
  await initializeDateFormatting('id_ID', null);

  // Initialize Firebase
  // Make sure you added the platform-specific Firebase config files
  // (GoogleService-Info.plist for iOS, google-services.json for Android)
  await Firebase.initializeApp();

  runApp(const ProviderScope(child: App()));
}
