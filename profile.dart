import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {


  bool isLogin = true; 

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final TextEditingController universityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      extendBodyBehindAppBar: true,
      body: StreamBuilder<User?>(
        // This listens for login/logout events
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // If a user is logged in, show the Profile. Otherwise, show Registration.
          if (snapshot.hasData) {
            return _buildProfileContent(context, snapshot.data!.uid);
          } else {
            return _buildAuthBox();
          }
        },
      ),
    );
  }
 Widget _buildAuthBox() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Text(
              isLogin ? "Welcome Back" : "Create Account",
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            
            // Only show the Name field if we are NOT in login mode
            if (!isLogin) ...[
              _buildTextField(nameController, "Full Name", Icons.person_outline),
              const SizedBox(height: 15),
            ],
            
            _buildTextField(emailController, "University Email", Icons.email_outlined),
            const SizedBox(height: 15),
            _buildTextField(passwordController, "Password", Icons.lock_outline, isPassword: true),
            
            const SizedBox(height: 30),

            // Main Action Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () async {
                if (isLogin) {
                  await AuthService().loginUser(emailController.text.trim(), passwordController.text.trim());
                } else {
await AuthService().registerUser(
  emailController.text.trim(), 
  passwordController.text.trim(), 
  nameController.text.trim(), 
  universityController.text.trim(), // <--- Add this 4th argument
);                }
              },
              child: Text(isLogin ? "Login" : "Register", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),

            // The Toggle Link
            TextButton(
              onPressed: () {
                // This 'setState' is what fixed your error!
                // It tells Flutter: "Hey, I changed the isLogin variable, redraw the screen!"
                setState(() {
                  isLogin = !isLogin;
                });
              },
              child: Text(
                isLogin ? "New here? Create an account" : "Log in",
                style: const TextStyle(color: Colors.white38),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- REGISTRATION UI ---
  Widget _buildRegistrationBox(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

   return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const Text("Academic Vault", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            // These text fields "capture" the data for our AuthService
            _buildTextField(nameController, "Full Name", Icons.person_outline),
            const SizedBox(height: 15),
            _buildTextField(emailController, "University Email", Icons.email_outlined),
            const SizedBox(height: 15),
            _buildTextField(passwordController, "Password", Icons.lock_outline, isPassword: true),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () => AuthService().registerUser(
                emailController.text.trim(),
                passwordController.text.trim(),
                nameController.text.trim(),
                universityController.text.trim(),
              ),
              child: const Text("Register", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // --- ACTUAL PROFILE UI ---
  Widget _buildProfileContent(BuildContext context, String uid) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: AuthService().getUserData(uid),
      builder: (context, snapshot) {
        // Show "CS Student" while the real name is loading from the database
        String name = "Loading...";
        String level = "Scholar";
        
        if (snapshot.hasData && snapshot.data != null) {
          name = snapshot.data!['username'];
          level = snapshot.data!['level'] ?? 'bigginer';
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2C2C2E), Color(0xFF1A1A1C)],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 120,
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: const Color(0xFF121212),
                      child: CircleAvatar(
                        radius: 51,
                        backgroundColor: const Color(0xFF2C2C2E),
                        child: Text(name[0].toUpperCase(), style: const TextStyle(fontSize: 40, color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 70),
              Text(name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              Text(level, style: const TextStyle(color: Colors.white38, fontSize: 14)),
              const SizedBox(height: 25),
              // Log Out Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: ElevatedButton(
                  onPressed: () => AuthService().signOut(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E1E1E),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("Log Out", style: TextStyle(color: Colors.redAccent)),
                ),
              ),
              const SizedBox(height: 30),
              _buildOptionsList(),
            ],
          ),
        );
      },
    );
  }

  // Helper Widgets for clean code
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white38),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildOptionsList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          _buildOption(Icons.auto_graph_rounded, "My Contributions", "0 Sessions"),
          _buildDivider(),
          _buildOption(Icons.calendar_month_outlined, "Join Date", "Today"),
        ],
      ),
    );
  }

  Widget _buildOption(IconData icon, String title, String trailing) {
    return ListTile(
      leading: Icon(icon, color: Colors.redAccent, size: 20),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: Text(trailing, style: const TextStyle(color: Colors.white38)),
    );
  }

  Widget _buildDivider() => Divider(color: Colors.white.withOpacity(0.05), height: 1, indent: 50);
}