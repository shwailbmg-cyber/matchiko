import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matchiko/app.dart';
import 'package:matchiko/data/repositories/auth_repository.dart';
import 'package:matchiko/data/repositories/auth_repository_demo.dart';
import 'package:matchiko/data/repositories/game_repository.dart';
import 'package:matchiko/data/repositories/game_repository_demo.dart';
import 'package:matchiko/data/repositories/settings_repository.dart';
import 'package:matchiko/ui/features/auth/view_models/session_view_model.dart';
import 'package:matchiko/ui/features/settings/view_models/settings_view_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

Widget _app() {
  final auth = DemoAuthRepository();
  return MultiProvider(
    providers: [
      Provider<AuthRepository>.value(value: auth),
      ChangeNotifierProvider<GameRepository>(
        create: (_) => DemoGameRepository(latency: Duration.zero),
      ),
      ChangeNotifierProvider(create: (_) => SessionViewModel(auth)),
      ChangeNotifierProvider(
        create: (_) =>
            SettingsViewModel(SettingsRepository(SharedPreferencesAsync())),
      ),
    ],
    child: const MatchikoApp(),
  );
}

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('demo login routes each role to its own area', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    expect(find.text('Continue as'.toUpperCase()), findsOneWidget);

    await tester.tap(find.text('Player'));
    await tester.pumpAndSettle();
    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Ready to play tonight?'.toUpperCase()), findsOneWidget);

    await tester.tap(find.text('Matches'));
    await tester.pumpAndSettle();
    expect(find.text('Upcoming'), findsOneWidget);

    // Log out from settings, then come back as a manager.
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Stadium manager'));
    await tester.pumpAndSettle();
    expect(find.text('To confirm'), findsOneWidget);
    expect(find.text('Play'), findsNothing);
  });

  testWidgets('Arabic switches the app to right-to-left', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('ع'));
    await tester.pumpAndSettle();

    final ctx = tester.element(find.byType(Scaffold).first);
    expect(Directionality.of(ctx), TextDirection.rtl);
    expect(find.text('لاعب'), findsOneWidget);
  });
}
