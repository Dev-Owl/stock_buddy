import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_buddy/backend.dart';
import 'package:stock_buddy/screens/dashboard_screen.dart';
import 'package:stock_buddy/screens/depot_detials.dart';
import 'package:stock_buddy/screens/export_detail_screen.dart';
import 'package:stock_buddy/screens/login_screen.dart';
import 'package:stock_buddy/screens/report_screen.dart';

/*
  TODO:
  - Show dividends total in depot line itme screen
  - Create "state of the depot" report
*/

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    MultiProvider(
      providers: [
        Provider(
          create: (d) => StockBuddyBackend.getInstance(),
        ),
        Provider.value(
          value: prefs,
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
              },
              routes: [
                GoRoute(
                  name: 'export_details',
                  path: 'details/:exportId',
                  builder: (context, state) => ExportDetailScreen(
                    exportId: state.params['exportId']!,
                    depotId: state.params['depotNumber']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
            path: '/login',
            builder: (context, state) {
              /*var token = state.queryParams['resetToken'];
              if (token != null && token.trim().isEmpty) {
                token = null;
              }*/
              return const LoginScreen(null);
            }),
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
      redirect: (context, state) async {
        final loggingIn = state.subloc == '/login';
        if (loggingIn) {
          return null;
        }
        late final bool loggedIn;
        try {
          await context.read<StockBuddyBackend>().generateNewAuthToken();
          loggedIn = true;
        } catch (ex) {
          loggedIn = false;
        }
        if (loggedIn) {
          return null;
        }
        return '/login';
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
