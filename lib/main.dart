import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:touche_app/core/DI/root-locator.dart';
import 'package:touche_app/routing/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // setting up DI
  setupLocator(FirebaseFirestore.instance);

  runApp(MaterialApp.router(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: Colors.grey.shade800,
        ),
        textTheme: TextTheme(
          displayLarge: const TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
          ),
          titleLarge: GoogleFonts.oswald(
            fontSize: 30,
            fontStyle: FontStyle.italic,
          ),
          bodyMedium: GoogleFonts.merriweather(),
          displaySmall: GoogleFonts.pacifico(),
        ),
      ),
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      routerConfig: touche_router));
  // home: SafeArea(
  //     child: Scaffold(
  //         backgroundColor: Colors.grey[900],
  //         resizeToAvoidBottomInset: false,
  //         body: const Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
  //           Expanded(child: Column(children: [TimeSlots()]))
  //         ])))));
}
