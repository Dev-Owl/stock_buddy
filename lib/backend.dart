import 'package:supabase_flutter/supabase_flutter.dart';

late final SupabaseClient supabase;

Future<Supabase> initSupabase() async {
  final supa = await Supabase.initialize(
    url: 'https://arkrdisigpfecmytpnao.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFya3JkaXNpZ3BmZWNteXRwbmFvIiwicm9sZSI6ImFub24iLCJpYXQiOjE2NTUzOTY0OTcsImV4cCI6MTk3MDk3MjQ5N30.qazUFsn5ZnFo31YA644Dbyb8XdE9V2_SiPwyWcLA-FM',
  );
  supabase = supa.client;
  return supa;
}
