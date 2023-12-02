import 'package:finance_ap_asg/Widgets/home_screen.dart';
import 'package:finance_ap_asg/Widgets/loginForm.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'api/authenticate.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final FirebaseSignIn _firebaseAuthManager = FirebaseSignIn();
  bool isStarted = false;
  double logoOffsetEndY = 0;
  double logoOffsetEndX = 0;
  late AnimationController _logoAnimationController;
  late AnimationController _loginButtonAnimationController;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    _logoAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _loginButtonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

  }

  void _startAnimation() {
    _logoAnimationController.reset();
    _logoAnimationController.forward();
    _loginButtonAnimationController.forward();
  }




  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        key: _scaffoldKey,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7556F1), Color(0xFF343789)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0, logoOffsetEndX),
                    end:  Offset(0, logoOffsetEndY),
                  ).animate(_logoAnimationController),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    child: Image.asset('images/logo.png'),
                  ),
                ),
                const SizedBox(height: 10),
                if (isStarted)  LoginForm(usernameController: _usernameController, passwordController: _passwordController),
                const SizedBox(height: 70),
                !isStarted
                    ? ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isStarted = true;
                          logoOffsetEndY = -0.3;
                          logoOffsetEndX = 0;
                        });
                        _startAnimation();
                      },
                      child: const Text(
                        'Start',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    )
                    : SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0),
                        end: const Offset(0, 0),
                      ).animate(_loginButtonAnimationController),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        child: ElevatedButton(
                          onPressed: () async{
                            // Access the values from _usernameController and _passwordController
                            String username = _usernameController.text;
                            String password = _passwordController.text;
                            var authState = await _firebaseAuthManager.signIn(username,password);
                            if (username.trim() == "" || password.trim() == "") {
                                showDialog(
                                    context: _scaffoldKey.currentContext!,
                                    builder: (context) {
                                      return AlertDialog(
                                          title: const Text('Error'),
                                          content: const Text('Username or password cannot be empty.'),
                                          actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                            Navigator.of(context).pop(); // Use Navigator.of(context).pop() here
                                            },
                                            child: const Text('OK'),
                                          ),
                                          ],
                                      );
                                    },
                                  );
                              } else if (authState != null) {
                                Navigator.pushReplacement(
                                  _scaffoldKey.currentContext!,
                                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                                );
                              } else if (authState == null) {
                                showDialog(
                                  context: _scaffoldKey.currentContext!,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Error'),
                                      content: const Text('Incorrect username or password.'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(); // Use Navigator.of(context).pop() here
                                          },
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                            }
                          },
                          child: const Text(
                            'Log in',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _loginButtonAnimationController.dispose();
    super.dispose();
  }
}
