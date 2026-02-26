import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

// -------------------------------------------------------------------
// 1. نظام التهيئة وبداية التشغيل
// -------------------------------------------------------------------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAWClslrgk7HHSKqxQ2qkRcNzZCqopAGDQ",
      authDomain: "tawasulapp-3b850.firebaseapp.com",
      projectId: "tawasulapp-3b850",
      storageBucket: "tawasulapp-3b850.firebasestorage.app",
      messagingSenderId: "356682208765",
      appId: "1:356682208765:web:9ea1be477d4795e7a53594",
      databaseURL: "https://tawasulapp-3b850-default-rtdb.firebaseio.com",
    ),
  );
  runApp(const TawasulProApp());
}

class TawasulProApp extends StatelessWidget {
  const TawasulProApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مركز تواصل المتكامل الإصدار الاحترافي',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, primary: Colors.teal[900]),
        fontFamily: 'Arial',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// -------------------------------------------------------------------
// 2. شاشة البداية المتحركة (Splash Screen) لزيادة طول الكود والاحترافية
// -------------------------------------------------------------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.teal.shade900, Colors.teal.shade500])),
        child: FadeTransition(
          opacity: _animation,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.diversity_1, size: 100, color: Colors.white),
              SizedBox(height: 20),
              Text("تـواصـل PRO", style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------
// 3. شاشة تسجيل الدخول المطورة (Login)
// -------------------------------------------------------------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError("يرجى ملء كافة الحقول");
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      
      if (!mounted) return;

      if (email == "admin@tawasul.com") {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminMainDashboard()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UserDashboard(email: email)));
      }
    } catch (e) {
      _showError("عذراً، البريد أو كلمة المرور غير صحيحة");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, textAlign: TextAlign.right),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              const Icon(Icons.lock_person, size: 80, color: Colors.teal),
              const SizedBox(height: 20),
              const Text("تسجيل الدخول", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                textAlign: TextAlign.right,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: "البريد الإلكتروني", suffixIcon: Icon(Icons.email)),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                textAlign: TextAlign.right,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: "كلمة المرور",
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              _isLoading 
                ? const CircularProgressIndicator() 
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 60),
                      backgroundColor: Colors.teal[800],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: _handleLogin,
                    child: const Text("دخول للنظام", style: TextStyle(color: Colors.white, fontSize: 20)),
                  ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                child: const Text("ليس لديك حساب؟ سجل طفلك الآن", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------
// 4. لوحة تحكم المدير المتقدمة (Admin Dashboard)
// -------------------------------------------------------------------
class AdminMainDashboard extends StatefulWidget {
  const AdminMainDashboard({super.key});
  @override State<AdminMainDashboard> createState() => _AdminMainDashboardState();
}

class _AdminMainDashboardState extends State<AdminMainDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      appBar: AppBar(
        title: const Text("لوحة التحكم الإدارية"),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => Navigator.pop(context))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            _buildQuickStats(),
            const SizedBox(height: 25),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _buildMenuCard(context, "إدارة الحجوزات", Icons.event_note, Colors.blue, const AdminBookingsList()),
                _buildMenuCard(context, "الرسائل الواردة", Icons.chat_bubble, Colors.orange, const AdminChatsList()),
                _buildMenuCard(context, "إضافة تقارير", Icons.post_add, Colors.purple, const AdminAddReportPage()),
                _buildMenuCard(context, "إدارة المستخدمين", Icons.people_alt, Colors.green, const AdminManageUsers()),
                _buildMenuCard(context, "سجل النشاطات", Icons.history_edu, Colors.brown, const PlaceholderPage(t: "سجل النشاطات")),
                _buildMenuCard(context, "إعدادات المركز", Icons.settings_applications, Colors.blueGrey, const PlaceholderPage(t: "الإعدادات")),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statCol("15", "طلب جديد", Colors.blue),
          const VerticalDivider(thickness: 1),
          _statCol("8", "شات نشط", Colors.orange),
          const VerticalDivider(thickness: 1),
          _statCol("120", "طفل مسجل", Colors.teal),
        ],
      ),
    );
  }

  Widget _statCol(String v, String l, Color c) => Column(children: [Text(v, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: c)), Text(l, style: const TextStyle(color: Colors.grey))]);

  Widget _buildMenuCard(BuildContext ctx, String title, IconData icon, Color color, Widget page) {
    return InkWell(
      onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (context) => page)),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 8, spreadRadius: 2)]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(radius: 30, backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color, size: 35)),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}// -------------------------------------------------------------------
// 5. شاشة إضافة التقارير (حل مشكلة الـ Null والـ Dropdown)
// -------------------------------------------------------------------
class AdminAddReportPage extends StatefulWidget {
  const AdminAddReportPage({super.key});
  @override State<AdminAddReportPage> createState() => _AdminAddReportPageState();
}

class _AdminAddReportPageState extends State<AdminAddReportPage> {
  final _reportContent = TextEditingController(); 
  String? _selectedKidID; 
  bool _isSaving = false; 
  double _sessionRating = 5.0; 

  void _saveReport() async {
    if (_selectedKidID == null || _reportContent.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("يرجى اختيار طفل وكتابة التقرير")));
      return;
    }
    setState(() => _isSaving = true);
    try {
      await FirebaseDatabase.instance.ref("reports/$_selectedKidID").push().set({
        "content": _reportContent.text,
        "rating": _sessionRating.round(),
        "date": DateTime.now().toIso8601String().split('T')[0],
        "timestamp": ServerValue.timestamp,
      });
      _reportContent.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم حفظ التقرير بنجاح")));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("فشل في الحفظ")));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("تقرير جلسة جديد")),
      body: StreamBuilder(
        stream: FirebaseDatabase.instance.ref("users").onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snap) {
          if (!snap.hasData || snap.data!.snapshot.value == null) {
            return const Center(child: CircularProgressIndicator());
          }
          
          Map usersData = snap.data!.snapshot.value as Map;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text("اختر الطفل المستهدف:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(border: Border.all(color: Colors.teal), borderRadius: BorderRadius.circular(10)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text("قائمة الأطفال المسجلين"),
                      value: _selectedKidID,
                      items: usersData.entries.map((e) {
                        Map val = e.value as Map;
                        return DropdownMenuItem<String>(
                          value: e.key.toString(),
                          child: Text(val['childName']?.toString() ?? "اسم غير متوفر"),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedKidID = v),
                    ),
                  ),
                ),
                const SizedBox(height: 25), 
                const Text("تقييم أداء الطفل في الجلسة:", style: TextStyle(fontWeight: FontWeight.bold)), 
                Slider(
                  value: _sessionRating,
                  min: 1.0, max: 10.0, divisions: 9,
                  label: _sessionRating.round().toString(),
                  activeColor: Colors.purple,
                  onChanged: (double value) => setState(() => _sessionRating = value),
                ),
                Center(child: Text("${_sessionRating.round()} / 10", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple))),
                const SizedBox(height: 20),
                const Text("تفاصيل الجلسة والتقدم:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                TextField(
                  controller: _reportContent,
                  maxLines: 5,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    hintText: "اكتب هنا تفاصيل الجلسة...",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 30),
                _isSaving 
                  ? const Center(child: CircularProgressIndicator()) 
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 55),
                        backgroundColor: Colors.purple[700],
                      ),
                      onPressed: _saveReport,
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text("حفظ وإرسال لولي الأمر", style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// -------------------------------------------------------------------
// 6. لوحة تحكم ولي الأمر (User Dashboard)
// -------------------------------------------------------------------
// -------------------------------------------------------------------
// 6. لوحة تحكم ولي الأمر (User Dashboard) - نسخة منسقة ومصححة
// -------------------------------------------------------------------
class UserDashboard extends StatefulWidget {
  final String email;
  const UserDashboard({super.key, required this.email});
  @override State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  String childName = "جارِ التحميل...";
  
  @override
  void initState() {
    super.initState();
    _fetchChildInfo();
  }

  _fetchChildInfo() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final snap = await FirebaseDatabase.instance.ref("users/$uid").get();
      if (snap.exists) {
        Map data = snap.value as Map;
        setState(() => childName = data['childName'] ?? "بطلنا");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("بوابة ولي الأمر"),
        centerTitle: true,
        backgroundColor: Colors.teal[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildUserHeader(), // الجزء العلوي الأخضر
            const SizedBox(height: 10),
            _buildProgressSection(), // قسم الرسم البياني
            const SizedBox(height: 10),
            _buildGridMenu(), // الأزرار المربعة
          ],
        ),
      ),
    );
  }

  // الجزء العلوي (الترحيب)
  Widget _buildUserHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.teal[800],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Icon(Icons.child_care, size: 50, color: Colors.teal),
          ),
          const SizedBox(height: 15),
          Text("مرحباً بولي أمر البطل:", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16)),
          Text(childName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // قسم الرسم البياني (تم تصحيح المسافات هنا)
  Widget _buildProgressSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.trending_up, color: Colors.green),
              Text("مستوى تطور الطفل (آخر 5 جلسات)", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [4, 6, 5, 8, 9].map((rating) => Column(
              children: [
                Container(
                  width: 25,
                  height: rating * 12.0, // طول العمود
                  decoration: BoxDecoration(
                    color: Colors.teal[300],
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(height: 5),
                const Text("ج", style: TextStyle(fontSize: 10)),
              ],
            )).toList(),
          ),
        ],
      ),
    );
  }

  // قائمة الأزرار (Grid)
  Widget _buildGridMenu() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.1, // لضبط تناسق طول وعرض المربعات
        children: [
          _uButton("حجز جلسة", Icons.calendar_month, Colors.teal, const UserBookingScreen()),
          _uButtonWithBadge("التقارير", Icons.assignment, Colors.purple, const UserReportsView()),
          _uButton("المحادثة", Icons.chat, Colors.orange, PlaceholderPage(t: "المحادثة")),
          _uButton("المواعيد", Icons.history, Colors.blue, const UserHistoryScreen()),
        ],
      ),
    );
  }

  // زر عادي
  Widget _uButton(String t, IconData i, Color c, Widget p) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => p)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(i, color: c, size: 35),
            const SizedBox(height: 8),
            Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  // زر مع إشعار "جديد"
  Widget _uButtonWithBadge(String t, IconData i, Color c, Widget p) {
    return Stack(
      children: [
        SizedBox(width: double.infinity, height: double.infinity, child: _uButton(t, i, c, p)),
        Positioned(
          right: 10,
          top: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
            child: const Text("جديد", style: TextStyle(color: Colors.white, fontSize: 10)),
          ),
        ),
      ],
    );
  }
}

// -------------------------------------------------------------------
// 7. شاشة تسجيل طفل جديد (Register)
// -------------------------------------------------------------------
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("فتح ملف طفل جديد")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            TextField(controller: _name, textAlign: TextAlign.right, decoration: const InputDecoration(labelText: "اسم الطفل الثلاثي", prefixIcon: Icon(Icons.person))),
            const SizedBox(height: 15),
            TextField(controller: _email, textAlign: TextAlign.right, decoration: const InputDecoration(labelText: "البريد الإلكتروني للأب/الأم", prefixIcon: Icon(Icons.email))),
            const SizedBox(height: 15),
            TextField(controller: _pass, obscureText: true, textAlign: TextAlign.right, decoration: const InputDecoration(labelText: "إنشاء كلمة مرور", prefixIcon: Icon(Icons.lock))),
            const SizedBox(height: 30),
            _loading ? const CircularProgressIndicator() : ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 55), backgroundColor: Colors.teal),
              onPressed: _register,
              child: const Text("تأكيد التسجيل", style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  void _register() async {
    if (_name.text.isEmpty || _email.text.isEmpty || _pass.text.isEmpty) return;
    setState(() => _loading = true);
    try {
      UserCredential u = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(), password: _pass.text.trim());
      await FirebaseDatabase.instance.ref("users/${u.user!.uid}").set({
        "childName": _name.text,
        "email": _email.text,
        "joinDate": DateTime.now().toIso8601String(),
      });
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("فشل التسجيل: تأكد من البيانات")));
    } finally {
      setState(() => _loading = false);
    }
  }
}

// شاشات مكملة ضرورية لتشغيل الكود
class PlaceholderPage extends StatelessWidget {
  final String t;
  const PlaceholderPage({super.key, required this.t});
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(t)), body: Center(child: Text("قسم $t قيد التحديث")));
}

class AdminManageUsers extends StatelessWidget {
  const AdminManageUsers({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إدارة ملفات الأطفال"), centerTitle: true),
      body: StreamBuilder(
        stream: FirebaseDatabase.instance.ref("users").onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snap) {
          if (!snap.hasData || snap.data!.snapshot.value == null) return const Center(child: CircularProgressIndicator());
          Map data = snap.data!.snapshot.value as Map;
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: data.length,
            itemBuilder: (context, i) {
              var uid = data.keys.elementAt(i);
              var user = data.values.elementAt(i);
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.teal[100], child: const Icon(Icons.person, color: Colors.teal)),
                  title: Text(user['childName'] ?? "بدون اسم", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(user['email'] ?? ""),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () {}),
                      IconButton(
                        icon: const Icon(Icons.delete_forever, color: Colors.red),
                        onPressed: () => _confirmDelete(context, uid),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, String uid) {
    showDialog(context: context, builder: (c) => AlertDialog(
      title: const Text("حذف الملف", textAlign: TextAlign.right),
      content: const Text("هل أنت متأكد من حذف ملف هذا الطفل نهائياً؟", textAlign: TextAlign.right),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text("إلغاء")),
        TextButton(onPressed: () {
          FirebaseDatabase.instance.ref("users/$uid").remove();
          Navigator.pop(c);
        }, child: const Text("حذف", style: TextStyle(color: Colors.red))),
      ],
    ));
  }
}

class UserBookingScreen extends StatefulWidget {
  const UserBookingScreen({super.key});
  @override State<UserBookingScreen> createState() => _UserBookingScreenState();
}

class _UserBookingScreenState extends State<UserBookingScreen> {
  String selectedDept = "تخاطب";
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
  final List<String> depts = ["تخاطب", "تعديل سلوك", "علاج وظيفي", "علاج طبيعي", "تنمية مهارات"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("حجز جلسة جديدة")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text("اختر نوع الجلسة:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: depts.map((d) => ChoiceChip(
                label: Text(d),
                selected: selectedDept == d,
                onSelected: (s) => setState(() => selectedDept = d),
              )).toList(),
            ),
            const SizedBox(height: 30),
            const Text("اختر التاريخ المفضل:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            CalendarDatePicker(
              initialDate: selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 60)),
              onDateChanged: (d) => setState(() => selectedDate = d),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 60), backgroundColor: Colors.teal[900]),
              onPressed: _submitBooking,
              child: const Text("تأكيد طلب الحجز", style: TextStyle(color: Colors.white, fontSize: 18)),
            )
          ],
        ),
      ),
    );
  }

  void _submitBooking() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final snap = await FirebaseDatabase.instance.ref("users/$uid").get();
    String cName = (snap.value as Map)['childName'] ?? "غير معروف";

    await FirebaseDatabase.instance.ref("bookings").push().set({
      "uid": uid,
      "childName": cName,
      "department": selectedDept,
      "date": selectedDate.toIso8601String().split('T')[0],
      "status": "قيد المراجعة",
      "createdAt": ServerValue.timestamp
    });
    if (mounted) Navigator.pop(context);
  }
}

class UserReportsView extends StatelessWidget {
  const UserReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(title: const Text("سجل التقارير الطبية")),
      body: StreamBuilder(
        stream: FirebaseDatabase.instance.ref("reports/$uid").onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snap) {
          if (!snap.hasData || snap.data!.snapshot.value == null) return const Center(child: Text("لا توجد تقارير طبية صادرة حتى الآن"));
          Map data = snap.data!.snapshot.value as Map;
          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: data.length,
            itemBuilder: (context, i) {
              var report = data.values.elementAt(i);
              return Card(
                elevation: 5,
                margin: const EdgeInsets.only(bottom: 15),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(report['date'] ?? "", style: const TextStyle(color: Colors.grey)),
                          const Icon(Icons.verified, color: Colors.green),
                        ],
                      ),
                      const Divider(),
                      Text(report['content'] ?? "", textAlign: TextAlign.right, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class UserChatScreen extends StatefulWidget {
  final String email;
  const UserChatScreen({super.key, required this.email});
  @override State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  final _msg = TextEditingController();
  @override
  Widget build(BuildContext context) {
    String chatId = widget.email.replaceAll('.', '_');
    return Scaffold(
      appBar: AppBar(title: const Text("محادثة الإدارة")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseDatabase.instance.ref("chats/$chatId").onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snap) {
                if (!snap.hasData || snap.data!.snapshot.value == null) return const Center(child: Text("ابدأ المحادثة مع الإدارة الآن"));
                Map d = snap.data!.snapshot.value as Map;
                var list = d.values.toList()..sort((a, b) => a['time'].compareTo(b['time']));
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    bool isMe = list[i]['sender'] == widget.email;
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue[100] : Colors.teal[50],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(list[i]['text']),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(child: TextField(controller: _msg, textAlign: TextAlign.right, decoration: const InputDecoration(hintText: "اكتب رسالتك هنا..."))),
                IconButton(icon: const Icon(Icons.send, color: Colors.blue), onPressed: () {
                  if (_msg.text.isEmpty) return;
                  FirebaseDatabase.instance.ref("chats/$chatId").push().set({
                    "sender": widget.email,
                    "text": _msg.text,
                    "time": ServerValue.timestamp
                  });
                  _msg.clear();
                }),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class UserHistoryScreen extends StatelessWidget {
  const UserHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    return Scaffold(
      appBar: AppBar(title: const Text("سجل مواعيدي")),
      body: StreamBuilder(
        stream: FirebaseDatabase.instance.ref("bookings").orderByChild("uid").equalTo(uid).onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snap) {
          if (!snap.hasData || snap.data!.snapshot.value == null) return const Center(child: Text("لا يوجد سجل مواعيد سابق"));
          Map data = snap.data!.snapshot.value as Map;
          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: data.length,
            itemBuilder: (context, i) {
              var booking = data.values.elementAt(i);
              Color statusColor = booking['status'] == "تم القبول" ? Colors.green : Colors.orange;
              return Card(
                child: ListTile(
                  leading: Icon(Icons.event, color: statusColor),
                  title: Text("قسم: ${booking['department']}"),
                  subtitle: Text("التاريخ: ${booking['date']}"),
                  trailing: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
                    child: Text(booking['status'], style: TextStyle(color: statusColor, fontSize: 12)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// شاشة قائمة المحادثات للمدير
class AdminChatsList extends StatelessWidget {
  const AdminChatsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("صندوق رسائل الأهل"), centerTitle: true),
      body: StreamBuilder(
        stream: FirebaseDatabase.instance.ref("chats").onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snap) {
          if (!snap.hasData || snap.data!.snapshot.value == null) {
            return const Center(child: Text("لا توجد رسائل واردة"));
          }
          Map chats = snap.data!.snapshot.value as Map;
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, i) {
              String userEmailKey = chats.keys.elementAt(i);
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(userEmailKey.replaceAll('_', '.')),
                  subtitle: const Text("اضغط لمتابعة المحادثة"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (context) => AdminChatDetailScreen(chatId: userEmailKey)
                  )),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// شاشة تفاصيل الدردشة للمدير
class AdminChatDetailScreen extends StatefulWidget {
  final String chatId;
  const AdminChatDetailScreen({super.key, required this.chatId});
  @override State<AdminChatDetailScreen> createState() => _AdminChatDetailScreenState();
}

class _AdminChatDetailScreenState extends State<AdminChatDetailScreen> {
  final _msgController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.chatId.replaceAll('_', '.'))),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseDatabase.instance.ref("chats/${widget.chatId}").onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snap) {
                if (!snap.hasData || snap.data!.snapshot.value == null) return const SizedBox();
                Map msgs = snap.data!.snapshot.value as Map;
                var sortedMsgs = msgs.values.toList()..sort((a, b) => a['time'].compareTo(b['time']));
                return ListView.builder(
                  itemCount: sortedMsgs.length,
                  itemBuilder: (context, i) {
                    bool isAdmin = sortedMsgs[i]['sender'] == "admin@tawasul.com";
                    return Align(
                      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isAdmin ? Colors.teal[100] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(sortedMsgs[i]['text']),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.send, color: Colors.teal), onPressed: _sendMsg),
                Expanded(child: TextField(controller: _msgController, textAlign: TextAlign.right, decoration: const InputDecoration(hintText: "اكتب ردك هنا..."))),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _sendMsg() {
    if (_msgController.text.isEmpty) return;
    FirebaseDatabase.instance.ref("chats/${widget.chatId}").push().set({
      "sender": "admin@tawasul.com",
      "text": _msgController.text,
      "time": ServerValue.timestamp
    });
    _msgController.clear();
  }
}

class AdminBookingsList extends StatelessWidget {
  const AdminBookingsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("طلبات الحجز المعلقة"), centerTitle: true),
      body: StreamBuilder(
        stream: FirebaseDatabase.instance.ref("bookings").onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snap) {
          if (!snap.hasData || snap.data!.snapshot.value == null) {
            return const Center(child: Text("لا توجد طلبات جديدة حالياً"));
          }
          Map data = snap.data!.snapshot.value as Map;
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: data.length,
            itemBuilder: (context, i) {
              String key = data.keys.elementAt(i);
              var val = data.values.elementAt(i);
              if (val['status'] == "تم القبول") return const SizedBox(); // عرض المعلق فقط

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.pending_actions)),
                        title: Text("الطفل: ${val['childName']}"),
                        subtitle: Text("القسم: ${val['department']}\nالتاريخ المقترح: ${val['date']}"),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[100]),
                            onPressed: () => _updateStatus(key, "تم القبول"),
                            child: const Text("قبول", style: TextStyle(color: Colors.green)),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[100]),
                            onPressed: () => _updateStatus(key, "مرفوض"),
                            child: const Text("رفض", style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _updateStatus(String key, String newStatus) {
    FirebaseDatabase.instance.ref("bookings/$key").update({"status": newStatus});
  }
}
class AdminStatsScreen extends StatelessWidget {
  const AdminStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إحصائيات المركز")),
      body: StreamBuilder(
        stream: FirebaseDatabase.instance.ref().onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          
          Map root = snap.data!.snapshot.value as Map;
          int usersCount = (root['users'] as Map).length;
          int bookingsCount = (root['bookings'] as Map).length;
          int reportsCount = (root['reports'] as Map).length;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _statTile("إجمالي الأطفال المسجلين", usersCount.toString(), Colors.teal),
                _statTile("إجمالي طلبات الحجز", bookingsCount.toString(), Colors.blue),
                _statTile("إجمالي التقارير الصادرة", reportsCount.toString(), Colors.purple),
                const SizedBox(height: 30),
                const Text("تحليل أداء المركز لهذا الشهر", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Icon(Icons.bar_chart, size: 150, color: Colors.grey), // Placeholder للرسم البياني
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statTile(String title, String val, Color col) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: Icon(Icons.analytics, color: col),
        title: Text(title),
        trailing: Text(val, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: col)),
      ),
    );
  }
}