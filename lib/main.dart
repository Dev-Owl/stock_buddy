import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stock_buddy/backend.dart';
import 'package:stock_buddy/screens/dashboard_screen.dart';
import 'package:stock_buddy/screens/depot_detials.dart';
import 'package:stock_buddy/screens/export_detail_screen.dart';
import 'package:stock_buddy/screens/export_overview_screen.dart';
import 'package:stock_buddy/screens/login_screen.dart';
import 'package:stock_buddy/screens/report_screen.dart';
/*
  TODO List below, sorted by prio
      - Allow to open a depot detail row and add/remove tags and update the note
      - Allow to filter the report screen by tags
      - Show the tags also in the report screen
      - Depot line item screen show last known value
      - Show the tags in the export detail rows
      
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
                name: 'depot_details',
                path: 'depot/:depotNumber',
                builder: (context, state) {
                  return DepotDetailPage(
                    depotId: state.params['depotNumber']!,
                  );
                }),
            GoRoute(
              name: 'export_overview',
              path: 'export/:depotNumber',
              builder: (context, state) => ExportOverviewScreen(
                depotId: state.params['depotNumber']!,
              ),
            ),
            GoRoute(
              name: 'export_details',
              path: 'export/:depotNumber/details/:exportId',
              builder: (context, state) => ExportDetailScreen(
                exportId: state.params['exportId']!,
                depotId: state.params['depotNumber']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
            name: 'reporting_overview',
            path: '/reporting/:depotNumber',
            builder: (context, state) {
              List<String> isinFilter = [];
              if (state.extra != null) {
                isinFilter = state.extra as List<String>;
              }
              return ReportingScreen(
                depotId: state.params['depotNumber']!,
                lineItemsIsin: isinFilter,
              );
            }),
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
