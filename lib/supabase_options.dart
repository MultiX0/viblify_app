import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final supabaseUrl = dotenv.env['SUPABASEURL'] ?? "";
final supabaseKey = dotenv.env['SUPABASEKEY'] ?? "";

class SupabaseOptions {
  static Future<void> initializeApp() async {
    await Supabase.initialize(
      url: "https://rqfmlqppkyzhzcemgokt.supabase.co",
      anonKey:
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJxZm1scXBwa3l6aHpjZW1nb2t0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDk5MTQ5MjEsImV4cCI6MjAyNTQ5MDkyMX0.HE_RQLxLsMW1J7IE5Vc9RSWCpghPlzt8lFPtgI9Vi78",
    );
  }
}
