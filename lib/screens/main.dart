import 'package:dovy/general.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class MainScreen extends HookWidget {
  const MainScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final showLogin = useState(false);
    useEffect(() {
      context.i.allReady().then((_) {
        context.i<AuthService>().token.then((value) {
          print("token: $value");
          context.i<CmsService>().token = value;
          // context
          //     .i<CmsService>()
          //     .externalService
          //     .http
          //     .interceptors
          //     .add(PrettyDioLogger(
          //       requestBody: true,
          //       requestHeader: true,
          //     ));

          if (value != null) {
            context.navigateTo(
              "/home",
              clearStack: true,
              transition: TransitionType.fadeIn,
            );
          } else {
            showLogin.value = true;
          }
        });
      });
      return () => {};
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        title: Text(
          context.s.appName,
          style: TextStyle(
            color: context.theme.primaryColor,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Text(context.s.appDescription),
          Container(
            decoration: BoxDecoration(
              color: context.theme.accentColor,
              shape: BoxShape.circle,
            ),
            width: context.media.size.width,
            height: context.media.size.width,
            margin: EdgeInsets.all(context.media.size.width * 0.1),
            child: Lottie.asset(
              "assets/lottie/map-location.json",
              fit: BoxFit.contain,
            ),
          ),
          if (showLogin.value)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Column(
                children: <Widget>[
                  Button(
                    text: "X",
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Button(
                            text: 'Login',
                            color: Kolor.fromString("#31AB5A"),
                            splashColor: Kolor.fromString("#31AB5A").darken(),
                            onTap: () {
                              context.navigateTo(
                                "/login",
                                transition:
                                    TransitionType.materialFullScreenDialog,
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          // width: double.infinity,
                          // color: Colors.blue,
                          child: Button(
                            text: 'Sign Up',
                            onTap: () {
                              context.navigateTo(
                                "/signup",
                                transition: TransitionType.cupertino,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Button(
                    text: "Forgot Password",
                    color: Colors.transparent,
                    textColor: Colors.black,
                    borderRadius: BorderRadius.zero,
                    onTap: () {},
                  ),
                ],
              ),
            )
          else
            CircularProgressIndicator()
        ],
      ),
    );
  }
}
