import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../MainPage.dart';
import '../../choose_home_dialog.dart';
import 'mail_register.dart';

class GoogleLoginScreen extends StatefulWidget {
  final VoidCallback? onSignedIn;

  const GoogleLoginScreen({super.key, this.onSignedIn});

  @override
  State<GoogleLoginScreen> createState() => _GoogleLoginScreenState();
}

class _GoogleLoginScreenState extends State<GoogleLoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  var emailController = TextEditingController();
  var passController = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = _auth.currentUser;
      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MyApp()),
        );
      }
    });
    //_tryLightweightSignIn();
  }

  Future<void> _tryLightweightSignIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _googleSignIn.initialize(
        serverClientId: '5189700141-jsteacugade3bs0p7i0ckikr24vbfuek.apps.googleusercontent.com',
      );

      final userData = await _googleSignIn.attemptLightweightAuthentication();

      if (userData != null) {
        final idToken = userData.authentication.idToken;
        if (idToken != null) {
          final cred = GoogleAuthProvider.credential(idToken: idToken);
          await _auth.signInWithCredential(cred);
          widget.onSignedIn?.call();
          return;
        }
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _googleSignIn.initialize(
        serverClientId: '5189700141-jsteacugade3bs0p7i0ckikr24vbfuek.apps.googleusercontent.com',
      );

      final userData = await _googleSignIn.authenticate();
      final idToken = userData.authentication.idToken;

      if (idToken == null) {
        setState(() => _error = 'No se recibió el idToken de Google.');
        return;
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);

      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      final bool isNew = userCredential.additionalUserInfo?.isNewUser ?? false;

      if (!mounted) return;

      if (isNew) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ChooseHome()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MyApp()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = 'FirebaseAuth: ${e.code}');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }


  Future<void> _handleSignOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [ Text("Login",
                              style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),),
              SizedBox(height: 30,),
              TextField(
                controller:emailController,
                decoration: InputDecoration(
                  border:  OutlineInputBorder(),
                  labelText: "Email"
                ),
              ),
              SizedBox(height: 10,),
              TextField(
                controller:passController,
                decoration: InputDecoration(
                    border:  OutlineInputBorder(),
                    labelText: "Password",
                ),
                obscureText: true,
              ),
              SizedBox(height: 10,),
              ElevatedButton(onPressed: () {
                String email = emailController.text.trim();
                String password = passController.text.trim();

                if(email.isEmpty || password.isEmpty){
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter All the fields")));
                }
                else{

                  try{
                        FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password).then((value){
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login Successfully")));
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> MyApp()));
                        });

                  }catch(err){
                    print(err);
                  }
                }
              }, child: Text('Log In', style: TextStyle(fontSize: 18, color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent )),

              SizedBox(height: 50,),
              if (_loading) const CircularProgressIndicator(),
              if (!_loading)
                SizedBox(
                  width: 60,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _handleGoogleSignIn,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: Colors.white, // fondo blanco
                      padding: EdgeInsets.zero,
                      elevation: 4,
                    ),
                    child: const Text(
                      "G",
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.red, // color típico de Google
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              SizedBox(height: 50,),
              InkWell(
                  onTap: () {
                    setState(() {
                      Colors.blue.shade800;
                    });
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> mailRegister()));

                  },
                  child: Text("New User? Click Here",
                    style: TextStyle(color: Colors.blueAccent),)
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _LoggedInView extends StatelessWidget {
  final User user;
  final Future<void> Function() onSignOut;

  const _LoggedInView({required this.user, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bienvenido')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (user.photoURL != null)
              CircleAvatar(radius: 40, backgroundImage: NetworkImage(user.photoURL!)),
            const SizedBox(height: 12),
            Text(user.displayName ?? 'Usuario',
                style: Theme.of(context).textTheme.titleMedium),
            Text(user.email ?? '',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onSignOut,
              child: const Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
