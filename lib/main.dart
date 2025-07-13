import 'package:fitbliss/screens/auth/sign_in.dart';
import 'package:fitbliss/screens/loading.dart/loading.dart';
import 'package:fitbliss/screens/onboarding/age.dart';
import 'package:fitbliss/screens/onboarding/goal.dart';
import 'package:fitbliss/screens/onboarding/level.dart';
import 'package:fitbliss/screens/onboarding/weight.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://xypvfuntbzooiyozslay.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh5cHZmdW50Ynpvb2l5b3pzbGF5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAzNTUxNTYsImV4cCI6MjA2NTkzMTE1Nn0.jm7pWJN-gLGddHrWgsWD-sLx4N5WzcZWE4qQw-So8_U",
  );

  runApp(const MyApp());
}

// It's handy to then extract the Supabase client in a variable for later uses
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // colorScheme: ColorScheme.fromSeed(
        //   seedColor: Color(0xffE91E63),
        //   surface: Color(0xffffffff),
        // ),
        fontFamily: GoogleFonts.bebasNeue().fontFamily,
      ),
      home: LoadingScreen(),
    );
  }
}
