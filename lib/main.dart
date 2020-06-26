import 'package:dovy/general.dart';
import 'package:dovy/router.dart';
import 'package:dovy/theme.dart';

void main() {
  GetIt.I.registerSingleton(router);
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Localization
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        S.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      // End Localization
      debugShowCheckedModeBanner: false,
      title: S?.current?.appName ?? 'Dovy',
      theme: lightTheme,
      onGenerateRoute: context.router.generator,
    );
  }
}
