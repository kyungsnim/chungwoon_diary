import 'package:church_diary_app/services/AuthService.dart';
import 'package:church_diary_app/view/LoginPage/AppleSignInAvailable.dart';
import 'package:church_diary_app/view/LoginPage/LoginPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
// apple login 가능한지 체크
  final appleSignInAvailable = await AppleSignInAvailable.check();
// 다국어 초기화
  initializeDateFormatting().then((_) => runApp(Provider<AppleSignInAvailable>.value(
      value: appleSignInAvailable,
      child: MyApp())));
  // child: EasyLocalization(
  //     supportedLocales: [Locale('en', 'US'), Locale('ko', 'KR')],
  //     path: 'assets/translations',
  //     fallbackLocale: Locale('en', 'US'),
  //     child: MyApp())));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ChangeNotifierProvider<FirebaseProvider>(
        //     create: (_) => FirebaseProvider()),
        Provider<AuthService>(
            create: (_) => AuthService()),
      ],
      child: MaterialApp(
        // 다국어 셋팅 start
        // localizationsDelegates: context.localizationDelegates,
        // supportedLocales: context.supportedLocales,
        // locale: context.locale,
        // 다국어 셋팅 end
        // 디버그 표시 없애기 위한 용도
        debugShowCheckedModeBanner: false,
        title: 'Church diary',
        theme: ThemeData(
          primaryColor: Colors.black,
          accentColor: Colors.black,
          fontFamily: 'Raleway',
          // scaffoldBackgroundColor: Colors.white,
        ),
        // darkTheme: ThemeData.dark(),
        home: LoginPage(),
      ),
    );
  }
}
