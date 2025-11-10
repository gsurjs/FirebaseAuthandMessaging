import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp( 
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Auth Demo', 
      // use an AuthWrapper to decide which screen to show.
      home: AuthWrapper(),
    );
  }
}

// widget handles the navigation logic.
// listens to auth state changes and shows the correct screen.
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // while checking auth state, show a loading spinner
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // if a user is logged in, show the ProfileScreen 
        if (snapshot.hasData) {
          return ProfileScreen();
        }

        // if no user is logged in, show the AuthenticationScreen
        return AuthenticationScreen(title: 'Firebase Auth Demo');
      },
    );
  }
}

class AuthenticationScreen extends StatefulWidget {
  AuthenticationScreen({Key? key, required this.title}) : super(key: key); // 
  final String title;

  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}


class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title), // 
        // The 'Sign Out' button  is removed from this screen.
      ),
      body: SingleChildScrollView( // Added SingleChildScrollView to prevent overflow
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20),
              RegisterEmailSection(auth: _auth), // [cite: 65]
              SizedBox(height: 20),
              EmailPasswordForm(auth: _auth), // [cite: 65]
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Get the current user from FirebaseAuth
  final User? user = FirebaseAuth.instance.currentUser;
  String _message = '';

  // Logout Functionality [cite: 53]
  void _signOut() async {
    await FirebaseAuth.instance.signOut(); // [cite: 54]
    // The AuthWrapper will automatically detect the sign-out
    // and navigate back to the AuthenticationScreen.
  }

  // Change Password Functionality 
  // This function sends a password reset email.
  void _sendPasswordReset() async {
    setState(() {
      _message = ''; // Clear previous message
    });
    try {
      if (user != null && user!.email != null) {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: user!.email!);
        setState(() {
          _message = 'Password reset email sent. Check your inbox.';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error sending password reset email.';
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: <Widget>[
          // Logout Button 
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              _signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Welcome!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 16),
            // Display User 
            Text(
              'Email: ${user?.email ?? 'Email not found'}', 
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 32),
            // Change Password Functionality 
            Text(
              'Change Password',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            Text('Click the button below to send a password reset link to your email.'),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _sendPasswordReset,
              child: Text('Send Password Reset Email'),
            ),
            SizedBox(height: 12),
            Text(
              _message,
              style: TextStyle(
                color: _message.startsWith('Error') ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

