import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stock_buddy/backend.dart';
import 'package:stock_buddy/screens/dashboard_screen.dart';
import 'package:stock_buddy/screens/export_detail_screen.dart';
import 'package:stock_buddy/screens/login_screen.dart';

/*
    1. Connect to supabase [X]
    2. Login / register [X]
    3. Add new export to db  [X]
    4. See exports as list [X]
    5. open export see line items [X]
      a) use adv datatable to show [X]
    6. Filter line items by isn [X]
      b) also allow to select items  [X]
    
    7. Create depots to have names 
    8. Change main view to repo view
    9. Followed by export view for repo
    
    
    N. Create a report from shown or selected line items
      a) show
    


*/

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final supbase = await initSupabase();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(
          value: supbase.client,
        ),
      ],
      child: StockBuddy(),
    ),
  );
}

class StockBuddy extends StatelessWidget {
  StockBuddy({Key? key}) : super(key: key);

  final _router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardScreen(),
          routes: [
            GoRoute(
              name: 'export_details',
              path: 'exports/:exportId',
              builder: (context, state) => ExportDetailScreen(
                exportId: state.params['exportId']!,
              ),
            )
          ],
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
      ],
      redirect: (state) {
        final loggedIn = supabase.auth.currentUser != null;
        if (loggedIn) {
          return null;
        }
        final loggingIn = state.subloc == '/login';
        if (loggingIn == false) {
          return '/login';
        }
        return null;
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Stock Buddy',
      theme: ThemeData.dark(),
      routeInformationProvider: _router.routeInformationProvider,
      routeInformationParser: _router.routeInformationParser,
      routerDelegate: _router.routerDelegate,
    );
  }
}
