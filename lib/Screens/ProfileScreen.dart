// import 'package:flutter/material.dart';
// import 'package:quiz/Screens/HomeScreen.dart';

// // void main() {
// //   runApp(const QuizApp());
// // }

// // class QuizApp extends StatelessWidget {
// //   const QuizApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Quiz App',
// //       debugShowCheckedModeBanner: false,
// //       theme: ThemeData(
// //         colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
// //         useMaterial3: true,
// //         fontFamily: 'Roboto',
// //       ),
// //       home: const MainScreen(),
// //     );
// //   }
// // }

// // ─── Main screen with bottom nav ───────────────────────────────────────────
// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});

//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> {
//   int _selectedIndex = 0;

//   final List<Widget> _pages = const [
//     HomeScreen(),
//     PlaceholderPage(label: 'Search'),
//     ProfileScreen(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _pages[_selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         selectedItemColor: const Color(0xFF4F46E5),
//         unselectedItemColor: Colors.grey,
//         onTap: (i) => setState(() => _selectedIndex = i),
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
//           BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Categories'),
//           BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
//         ],
//       ),
//     );
//   }
// }

// class PlaceholderPage extends StatelessWidget {
//   final String label;
//   const PlaceholderPage({super.key, required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Text(label, style: const TextStyle(fontSize: 24, color: Colors.grey)),
//       ),
//     );
//   }
// }

// // ─── Profile Screen ─────────────────────────────────────────────────────────
// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   String _name = 'Swapanil Gupta';
//   String _email = 'swapanil.gupta@example.com';
//   bool _hasNotification = true;

//   static const _indigo = Color(0xFF4F46E5);

//   String get _initials {
//     final parts = _name.trim().split(' ');
//     if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
//     return parts[0][0].toUpperCase();
//   }

//   void _showToast(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         duration: const Duration(seconds: 2),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         backgroundColor: const Color(0xFF1E1E2E),
//       ),
//     );
//   }

//   // ── Edit Profile Dialog ────────────────────────────────────────────────
//   void _openEditProfile() {
//     final nameCtrl = TextEditingController(text: _name);
//     final emailCtrl = TextEditingController(text: _email);

//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text('Edit Profile', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: nameCtrl,
//               decoration: _inputDecoration('Full name'),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: emailCtrl,
//               decoration: _inputDecoration('Email address'),
//               keyboardType: TextInputType.emailAddress,
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: _indigo,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//             ),
//             onPressed: () {
//               setState(() {
//                 _name = nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : _name;
//                 _email = emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : _email;
//               });
//               Navigator.pop(ctx);
//               _showToast('Profile updated');
//             },
//             child: const Text('Save'),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Settings Dialog ────────────────────────────────────────────────────
//   void _openSettings() {
//     bool pushNotif = true;
//     bool darkMode = false;
//     bool soundFx = true;

//     showDialog(
//       context: context,
//       builder: (ctx) => StatefulBuilder(
//         builder: (ctx, setDlg) => AlertDialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           title: const Text('Settings', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _settingsToggle('Push Notifications', pushNotif, (v) => setDlg(() => pushNotif = v)),
//               _settingsToggle('Dark Mode', darkMode, (v) => setDlg(() => darkMode = v)),
//               _settingsToggle('Sound Effects', soundFx, (v) => setDlg(() => soundFx = v)),
//             ],
//           ),
//           actions: [
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: _indigo,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//               ),
//               onPressed: () {
//                 Navigator.pop(ctx);
//                 _showToast('Settings saved');
//               },
//               child: const Text('Done'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Logout Dialog ──────────────────────────────────────────────────────
//   void _confirmLogout() {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text('Logout', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
//         content: const Text('Are you sure you want to log out of your account?',
//             style: TextStyle(color: Colors.grey)),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFE24B4A),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//             ),
//             onPressed: () {
//               Navigator.pop(ctx);
//               _showToast('Logged out successfully');
//             },
//             child: const Text('Logout'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               const SizedBox(height: 32),

//               // ── Avatar ──────────────────────────────────────────────
//               Stack(
//                 children: [
//                   CircleAvatar(
//                     radius: 44,
//                     backgroundColor: _indigo,
//                     child: Text(
//                       _initials,
//                       style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.w500),
//                     ),
//                   ),
//                   Positioned(
//                     bottom: 0,
//                     right: 0,
//                     child: GestureDetector(
//                       onTap: _openEditProfile,
//                       child: Container(
//                         width: 28,
//                         height: 28,
//                         decoration: BoxDecoration(
//                           color: _indigo,
//                           shape: BoxShape.circle,
//                           border: Border.all(color: Colors.white, width: 2),
//                         ),
//                         child: const Icon(Icons.edit, color: Colors.white, size: 13),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 12),

//               // ── Name & Email ────────────────────────────────────────
//               Text(_name,
//                   style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1E1E2E))),
//               const SizedBox(height: 4),
//               Text(_email, style: const TextStyle(fontSize: 13, color: Colors.grey)),

//               const SizedBox(height: 24),

//               // ── Stats Row ───────────────────────────────────────────
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey.shade200),
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                   child: IntrinsicHeight(
//                     child: Row(
//                       children: [
//                         _statItem('24', 'QUIZZES\nATTEMPTED', left: true),
//                         _divider(),
//                         _statItem('1250', 'TOTAL\nSCORE'),
//                         _divider(),
//                         _statItem('#12', 'GLOBAL\nRANK', right: true),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 28),

//               // ── Menu Items ──────────────────────────────────────────
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: Column(
//                   children: [
//                     _menuItem(
//                       icon: Icons.person_outline,
//                       label: 'Edit Profile',
//                       onTap: _openEditProfile,
//                     ),
//                     _menuItem(
//                       icon: Icons.history,
//                       label: 'My Quiz History',
//                       onTap: () => Navigator.push(context,
//                           MaterialPageRoute(builder: (_) => const QuizHistoryPage())),
//                     ),
//                     _menuItem(
//                       icon: Icons.bookmark_outline,
//                       label: 'Saved Quizzes',
//                       onTap: () => Navigator.push(context,
//                           MaterialPageRoute(builder: (_) => const SavedQuizzesPage())),
//                     ),
//                     _menuItem(
//                       icon: Icons.notifications_outlined,
//                       label: 'Notifications',
//                       badge: _hasNotification,
//                       onTap: () {
//                         setState(() => _hasNotification = false);
//                         Navigator.push(context,
//                             MaterialPageRoute(builder: (_) => const NotificationsPage()));
//                       },
//                     ),
//                     const Divider(height: 24, thickness: 0.5),
//                     _menuItem(
//                       icon: Icons.settings_outlined,
//                       label: 'Settings',
//                       iconColor: Colors.grey.shade600,
//                       iconBg: Colors.grey.shade100,
//                       onTap: _openSettings,
//                     ),
//                     _menuItem(
//                       icon: Icons.help_outline,
//                       label: 'Help & Support',
//                       iconColor: Colors.grey.shade600,
//                       iconBg: Colors.grey.shade100,
//                       onTap: () => Navigator.push(context,
//                           MaterialPageRoute(builder: (_) => const HelpSupportPage())),
//                     ),
//                     const SizedBox(height: 8),
//                     _menuItem(
//                       icon: Icons.logout,
//                       label: 'Logout',
//                       labelColor: const Color(0xFFE24B4A),
//                       iconColor: const Color(0xFFE24B4A),
//                       iconBg: const Color(0xFFFFF0F0),
//                       showChevron: false,
//                       onTap: _confirmLogout,
//                     ),
//                     const SizedBox(height: 24),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Helpers ──────────────────────────────────────────────────────────────

//   Widget _statItem(String value, String label,
//       {bool left = false, bool right = false}) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 14),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.only(
//             topLeft: left ? const Radius.circular(14) : Radius.zero,
//             bottomLeft: left ? const Radius.circular(14) : Radius.zero,
//             topRight: right ? const Radius.circular(14) : Radius.zero,
//             bottomRight: right ? const Radius.circular(14) : Radius.zero,
//           ),
//         ),
//         child: Column(
//           children: [
//             Text(value,
//                 style: const TextStyle(
//                     fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF4F46E5))),
//             const SizedBox(height: 4),
//             Text(label,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 0.5)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _divider() => VerticalDivider(
//         width: 1,
//         thickness: 0.5,
//         color: Colors.grey.shade200,
//         indent: 12,
//         endIndent: 12,
//       );

//   Widget _menuItem({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//     Color iconColor = const Color(0xFF4F46E5),
//     Color iconBg = const Color(0xFFEEF0FF),
//     Color? labelColor,
//     bool badge = false,
//     bool showChevron = true,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 12),
//         child: Row(
//           children: [
//             Container(
//               width: 42,
//               height: 42,
//               decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
//               child: Icon(icon, color: iconColor, size: 20),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 15,
//                   color: labelColor ?? const Color(0xFF1E1E2E),
//                 ),
//               ),
//             ),
//             if (badge)
//               Container(
//                 width: 8,
//                 height: 8,
//                 margin: const EdgeInsets.only(right: 8),
//                 decoration: const BoxDecoration(color: Color(0xFFE24B4A), shape: BoxShape.circle),
//               ),
//             if (showChevron)
//               const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _settingsToggle(String label, bool value, ValueChanged<bool> onChange) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: const TextStyle(fontSize: 14)),
//           Switch(value: value, onChanged: onChange, activeColor: const Color(0xFF4F46E5)),
//         ],
//       ),
//     );
//   }

//   InputDecoration _inputDecoration(String hint) => InputDecoration(
//         hintText: hint,
//         filled: true,
//         fillColor: Colors.grey.shade100,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide.none,
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: Color(0xFF4F46E5)),
//         ),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//       );
// }

// // ─── Quiz History Page ───────────────────────────────────────────────────────
// class QuizHistoryPage extends StatelessWidget {
//   const QuizHistoryPage({super.key});

//   static const _history = [
//     {'quiz': 'Science Basics', 'score': '85%', 'date': 'Mar 12'},
//     {'quiz': 'Computer Fundamentals', 'score': '92%', 'date': 'Mar 10'},
//     {'quiz': 'History & Culture', 'score': '78%', 'date': 'Mar 7'},
//     {'quiz': 'Art & Design', 'score': '88%', 'date': 'Mar 4'},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: _appBar(context, 'My Quiz History'),
//       body: ListView.separated(
//         padding: const EdgeInsets.all(20),
//         itemCount: _history.length,
//         separatorBuilder: (_, __) => const SizedBox(height: 10),
//         itemBuilder: (_, i) {
//           final item = _history[i];
//           return Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade50,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: Colors.grey.shade200),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   Text(item['quiz']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
//                   const SizedBox(height: 3),
//                   Text(item['date']!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
//                 ]),
//                 Text(item['score']!,
//                     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF4F46E5))),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// // ─── Saved Quizzes Page ──────────────────────────────────────────────────────
// class SavedQuizzesPage extends StatelessWidget {
//   const SavedQuizzesPage({super.key});

//   static const _quizzes = [
//     'Advanced Data Structures',
//     'Operating Systems 101',
//     'Boolean Algebra',
//     'Discrete Math',
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: _appBar(context, 'Saved Quizzes'),
//       body: ListView.separated(
//         padding: const EdgeInsets.all(20),
//         itemCount: _quizzes.length,
//         separatorBuilder: (_, __) => const SizedBox(height: 10),
//         itemBuilder: (_, i) => Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//           decoration: BoxDecoration(
//             color: Colors.grey.shade50,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.grey.shade200),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(_quizzes[i], style: const TextStyle(fontSize: 14)),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF4F46E5),
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                   textStyle: const TextStyle(fontSize: 13),
//                 ),
//                 onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text('Starting: ${_quizzes[i]}'),
//                     behavior: SnackBarBehavior.floating,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//                     backgroundColor: const Color(0xFF1E1E2E),
//                   ),
//                 ),
//                 child: const Text('Start'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─── Notifications Page ──────────────────────────────────────────────────────
// class NotificationsPage extends StatelessWidget {
//   const NotificationsPage({super.key});

//   static const _notifs = [
//     {'msg': 'You ranked #12 globally!', 'time': '2h ago'},
//     {'msg': 'New quizzes available in Computer Science', 'time': 'Yesterday'},
//     {'msg': 'Your score in Science Basics: 85%', 'time': 'Mar 12'},
//     {'msg': 'Weekly challenge starts tomorrow', 'time': 'Mar 11'},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: _appBar(context, 'Notifications'),
//       body: ListView.separated(
//         padding: const EdgeInsets.all(20),
//         itemCount: _notifs.length,
//         separatorBuilder: (_, __) => const SizedBox(height: 10),
//         itemBuilder: (_, i) {
//           final n = _notifs[i];
//           return Container(
//             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade50,
//               borderRadius: BorderRadius.circular(12),
//               border: Border(left: const BorderSide(color: Color(0xFF4F46E5), width: 3)),
//             ),
//             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Text(n['msg']!, style: const TextStyle(fontSize: 13)),
//               const SizedBox(height: 5),
//               Text(n['time']!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
//             ]),
//           );
//         },
//       ),
//     );
//   }
// }

// // ─── Help & Support Page ─────────────────────────────────────────────────────
// class HelpSupportPage extends StatelessWidget {
//   const HelpSupportPage({super.key});

//   static const _faqs = [
//     {
//       'q': 'How to attempt a quiz?',
//       'a': 'Tap any category and select a quiz. Answer all questions and submit.',
//     },
//     {
//       'q': 'How is score calculated?',
//       'a': 'Each correct answer earns 10 points. Bonus points for answer streaks.',
//     },
//     {
//       'q': 'How to reset progress?',
//       'a': 'Go to Settings > Account > Reset Progress.',
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: _appBar(context, 'Help & Support'),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             ...List.generate(_faqs.length, (i) {
//               final faq = _faqs[i];
//               return Container(
//                 margin: const EdgeInsets.only(bottom: 10),
//                 padding: const EdgeInsets.all(14),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey.shade200),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   Text(faq['q']!,
//                       style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
//                   const SizedBox(height: 6),
//                   Text(faq['a']!, style: const TextStyle(fontSize: 13, color: Colors.grey)),
//                 ]),
//               );
//             }),
//             const SizedBox(height: 12),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF4F46E5),
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   textStyle: const TextStyle(fontSize: 15),
//                 ),
//                 onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: const Text('Email sent to support@quizapp.com'),
//                     behavior: SnackBarBehavior.floating,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//                     backgroundColor: const Color(0xFF1E1E2E),
//                   ),
//                 ),
//                 child: const Text('Contact Support'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─── Shared AppBar helper ────────────────────────────────────────────────────
// PreferredSizeWidget _appBar(BuildContext context, String title) => AppBar(
//       title: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
//       backgroundColor: Colors.white,
//       foregroundColor: const Color(0xFF1E1E2E),
//       elevation: 0,
//       surfaceTintColor: Colors.white,
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF4F46E5)),
//         onPressed: () => Navigator.pop(context),
//       ),
//     );

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quiz/Screens/HomeScreen.dart';

// void main() {
//   runApp(const QuizApp());
// }

// ─── Color Palette ───────────────────────────────────────────────────────────
class AppColors {
  static const bg = Color(0xFF0F172A);
  static const surface = Color(0xFF1A1A2E);
  static const card = Color(0xFF16213E);
  static const indigo = Color(0xFF6C63FF);
  static const indigoLight = Color(0xFF8B85FF);
  static const text = Color(0xFFEEEEFF);
  static const subtext = Color(0xFF9090AA);
  static const border = Color(0xFF2A2A45);
  static const red = Color(0xFFFF5C5C);
  static const redBg = Color(0xFF2A1A1A);
}

// ─── App ─────────────────────────────────────────────────────────────────────
class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.indigo,
          surface: AppColors.surface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.bg,
          foregroundColor: AppColors.text,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
            fontFamily: 'Roboto',
          ),
        ),
        dividerColor: AppColors.border,
      ),
      home: const MainScreen(),
    );
  }
}

// ─── Main Screen ─────────────────────────────────────────────────────────────
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    _PlaceholderPage(label: 'Search'),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.indigo,
          unselectedItemColor: AppColors.subtext,
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          elevation: 0,
          onTap: (i) => setState(() => _selectedIndex = i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String label;
  const _PlaceholderPage({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: Text(
          label,
          style: const TextStyle(fontSize: 24, color: AppColors.subtext),
        ),
      ),
    );
  }
}

// ─── Profile Screen ──────────────────────────────────────────────────────────
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'Swapanil Gupta';
  String _email = 'swapanil.gupta@example.com';
  bool _hasNotification = true;
  
  File? _profileImage;

Future<void> _pickProfileImage() async {
  final ImagePicker picker = ImagePicker();

  final XFile? image = await picker.pickImage(
    source: ImageSource.gallery, // you can change to camera
    imageQuality: 80,
  );

  if (image != null) {
    setState(() {
      _profileImage = File(image.path);
    });
  }
}

  String get _initials {
    final parts = _name.trim().split(' ');
    return parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : parts[0][0].toUpperCase();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: AppColors.text)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.border),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openEditProfile() {
    final nameCtrl = TextEditingController(text: _name);
    final emailCtrl = TextEditingController(text: _email);
    showDialog(
      context: context,
      builder: (ctx) => _DarkDialog(
        title: 'Edit Profile',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _darkInput(nameCtrl, 'Full name'),
            const SizedBox(height: 12),
            _darkInput(
              emailCtrl,
              'Email address',
              type: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          _dialogBtn('Cancel', onTap: () => Navigator.pop(ctx), outlined: true),
          _dialogBtn(
            'Save',
            onTap: () {
              setState(() {
                if (nameCtrl.text.trim().isNotEmpty) {
                  _name = nameCtrl.text.trim();
                }
                if (emailCtrl.text.trim().isNotEmpty) {
                  _email = emailCtrl.text.trim();
                }
              });
              Navigator.pop(ctx);
              _toast('Profile updated');
            },
          ),
        ],
      ),
    );
  }

  void _openSettings() {
    bool pushNotif = true;
    bool darkMode = true;
    bool soundFx = true;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => _DarkDialog(
          title: 'Settings',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _toggle(
                'Push Notifications',
                pushNotif,
                (v) => setDlg(() => pushNotif = v),
              ),
              _toggle('Dark Mode', darkMode, (v) => setDlg(() => darkMode = v)),
              _toggle(
                'Sound Effects',
                soundFx,
                (v) => setDlg(() => soundFx = v),
              ),
            ],
          ),
          actions: [
            _dialogBtn(
              'Done',
              onTap: () {
                Navigator.pop(ctx);
                _toast('Settings saved');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => _DarkDialog(
        title: 'Logout',
        content: const Text(
          'Are you sure you want to log out of your account?',
          style: TextStyle(color: AppColors.subtext, fontSize: 14),
        ),
        actions: [
          _dialogBtn('Cancel', onTap: () => Navigator.pop(ctx), outlined: true),
          _dialogBtn(
            'Logout',
            onTap: () {
              Navigator.pop(ctx);
              _toast('Logged out successfully');
            },
            color: AppColors.red,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 36),

              // ── Avatar ──────────────────────────────────────────────────
              // Stack(
              //   children: [
              //     Container(
              //       width: 92,
              //       height: 92,
              //       decoration: BoxDecoration(
              //         shape: BoxShape.circle,
              //         gradient: const LinearGradient(
              //           colors: [Color(0xFF6C63FF), Color(0xFF9B59B6)],
              //           begin: Alignment.topLeft,
              //           end: Alignment.bottomRight,
              //         ),
              //         boxShadow: [
              //           BoxShadow(
              //             color: AppColors.indigo.withOpacity(0.4),
              //             blurRadius: 20,
              //             offset: const Offset(0, 6),
              //           ),
              //         ],
              //       ),
              //       child: Center(
              //         child: Text(
              //           _initials,
              //           style: const TextStyle(
              //             fontSize: 30,
              //             color: Colors.white,
              //             fontWeight: FontWeight.w600,
              //           ),
              //         ),
              //       ),
              //     ),
              //     Positioned(
              //       bottom: 2,
              //       right: 2,
              //       child: GestureDetector(
              //         onTap: _openEditProfile,
              //         child: Container(
              //           width: 28,
              //           height: 28,
              //           decoration: BoxDecoration(
              //             color: AppColors.indigo,
              //             shape: BoxShape.circle,
              //             border: Border.all(color: AppColors.bg, width: 2),
              //           ),
              //           child: const Icon(
              //             Icons.camera_alt_outlined,
              //             color: Colors.white,
              //             size: 13,
              //           ),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),

              Stack(
  children: [
    Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF9B59B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.indigo.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipOval(
        child: _profileImage != null
            ? Image.file(
                _profileImage!,
                fit: BoxFit.cover,
              )
            : Center(
                child: Text(
                  _initials,
                  style: const TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
      ),
    ),

    Positioned(
      bottom: 2,
      right: 2,
      child: GestureDetector(
        onTap: _pickProfileImage, // 👈 changed function
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.indigo,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.bg, width: 2),
          ),
          child: const Icon(
            Icons.camera_alt_outlined,
            color: Colors.white,
            size: 13,
          ),
        ),
      ),
    ),
  ],
),
              const SizedBox(height: 14),

              // ── Name & Email ─────────────────────────────────────────────
              Text(
                _name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _email,
                style: const TextStyle(fontSize: 13, color: AppColors.subtext),
              ),

              const SizedBox(height: 28),

              // ── Stats Row ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        _statItem('24', 'QUIZZES\nATTEMPTED', left: true),
                        VerticalDivider(
                          width: 1,
                          thickness: 0.5,
                          color: AppColors.border,
                        ),
                        _statItem('1250', 'TOTAL\nSCORE'),
                        VerticalDivider(
                          width: 1,
                          thickness: 0.5,
                          color: AppColors.border,
                        ),
                        _statItem('#12', 'GLOBAL\nRANK', right: true),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Menu ─────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _menuItem(
                      icon: Icons.person_outline,
                      label: 'Edit Profile',
                      onTap: _openEditProfile,
                    ),
                    _menuItem(
                      icon: Icons.history_rounded,
                      label: 'My Quiz History',
                      onTap: () => _push(const QuizHistoryPage()),
                    ),
                    _menuItem(
                      icon: Icons.bookmark_outline,
                      label: 'Saved Quizzes',
                      onTap: () => _push(const SavedQuizzesPage()),
                    ),
                    _menuItem(
                      icon: Icons.notifications_outlined,
                      label: 'Notifications',
                      badge: _hasNotification,
                      onTap: () {
                        setState(() => _hasNotification = false);
                        _push(const NotificationsPage());
                      },
                    ),
                    Divider(
                      height: 24,
                      thickness: 0.5,
                      color: AppColors.border,
                    ),
                    _menuItem(
                      icon: Icons.settings_outlined,
                      label: 'Settings',
                      iconColor: AppColors.subtext,
                      iconBg: AppColors.card,
                      onTap: _openSettings,
                    ),
                    _menuItem(
                      icon: Icons.help_outline,
                      label: 'Help & Support',
                      iconColor: AppColors.subtext,
                      iconBg: AppColors.card,
                      onTap: () => _push(const HelpSupportPage()),
                    ),
                    const SizedBox(height: 8),
                    _menuItem(
                      icon: Icons.logout_rounded,
                      label: 'Logout',
                      labelColor: AppColors.red,
                      iconColor: AppColors.red,
                      iconBg: AppColors.redBg,
                      showChevron: false,
                      onTap: _confirmLogout,
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _push(Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  Widget _statItem(
    String value,
    String label, {
    bool left = false,
    bool right = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: left ? const Radius.circular(16) : Radius.zero,
            bottomLeft: left ? const Radius.circular(16) : Radius.zero,
            topRight: right ? const Radius.circular(16) : Radius.zero,
            bottomRight: right ? const Radius.circular(16) : Radius.zero,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.indigoLight,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.subtext,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = AppColors.indigoLight,
    Color iconBg = const Color(0xFF1F1F35),
    Color? labelColor,
    bool badge = false,
    bool showChevron = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.indigo.withOpacity(0.08),
        highlightColor: AppColors.indigo.withOpacity(0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 21),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    color: labelColor ?? AppColors.text,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              if (badge)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: const BoxDecoration(
                    color: AppColors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              if (showChevron)
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.subtext,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toggle(String label, bool value, ValueChanged<bool> onChange) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: AppColors.text),
            ),
            Switch(
              value: value,
              onChanged: onChange,
              activeThumbColor: AppColors.indigo,
              trackColor: WidgetStateProperty.resolveWith(
                (s) => s.contains(WidgetState.selected)
                    ? AppColors.indigo.withOpacity(0.3)
                    : AppColors.border,
              ),
            ),
          ],
        ),
      );

  Widget _darkInput(
    TextEditingController ctrl,
    String hint, {
    TextInputType? type,
  }) => TextField(
    controller: ctrl,
    keyboardType: type,
    style: const TextStyle(color: AppColors.text, fontSize: 14),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.subtext),
      filled: true,
      fillColor: AppColors.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.indigo),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
  );

  Widget _dialogBtn(
    String label, {
    required VoidCallback onTap,
    bool outlined = false,
    Color color = AppColors.indigo,
  }) {
    return outlined
        ? OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.subtext,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: onTap,
            child: Text(label),
          )
        : ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: onTap,
            child: Text(label),
          );
  }
}

// ─── Dark Dialog Widget ──────────────────────────────────────────────────────
class _DarkDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget> actions;
  const _DarkDialog({
    required this.title,
    required this.content,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 16),
            content,
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions
                  .map(
                    (a) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: a,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sub-Pages ───────────────────────────────────────────────────────────────

PreferredSizeWidget _darkAppBar(BuildContext context, String title) => AppBar(
  title: Text(title),
  backgroundColor: AppColors.bg,
  leading: IconButton(
    icon: const Icon(
      Icons.arrow_back_ios_new,
      size: 18,
      color: AppColors.indigoLight,
    ),
    onPressed: () => Navigator.pop(context),
  ),
  bottom: PreferredSize(
    preferredSize: const Size.fromHeight(0.5),
    child: Container(height: 0.5, color: AppColors.border),
  ),
);

// ── Quiz History ──────────────────────────────────────────────────────────────
class QuizHistoryPage extends StatelessWidget {
  const QuizHistoryPage({super.key});

  static const _history = [
    {'quiz': 'Science Basics', 'score': '85%', 'date': 'Mar 12'},
    {'quiz': 'Computer Fundamentals', 'score': '92%', 'date': 'Mar 10'},
    {'quiz': 'History & Culture', 'score': '78%', 'date': 'Mar 7'},
    {'quiz': 'Art & Design', 'score': '88%', 'date': 'Mar 4'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: _darkAppBar(context, 'My Quiz History'),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _history.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final item = _history[i];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['quiz']!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['date']!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.subtext,
                      ),
                    ),
                  ],
                ),
                Text(
                  item['score']!,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.indigoLight,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Saved Quizzes ─────────────────────────────────────────────────────────────
class SavedQuizzesPage extends StatelessWidget {
  const SavedQuizzesPage({super.key});

  static const _quizzes = [
    'Advanced Data Structures',
    'Operating Systems 101',
    'Boolean Algebra',
    'Discrete Math',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: _darkAppBar(context, 'Saved Quizzes'),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _quizzes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _quizzes[i],
                style: const TextStyle(fontSize: 14, color: AppColors.text),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Starting: ${_quizzes[i]}',
                      style: const TextStyle(color: AppColors.text),
                    ),
                    backgroundColor: AppColors.surface,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                child: const Text('Start'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Notifications ─────────────────────────────────────────────────────────────
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  static const _notifs = [
    {'msg': 'You ranked #12 globally!', 'time': '2h ago'},
    {'msg': 'New quizzes available in Computer Science', 'time': 'Yesterday'},
    {'msg': 'Your score in Science Basics: 85%', 'time': 'Mar 12'},
    {'msg': 'Weekly challenge starts tomorrow', 'time': 'Mar 11'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: _darkAppBar(context, 'Notifications'),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _notifs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final n = _notifs[i];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border(
                left: const BorderSide(color: AppColors.indigo, width: 3),
                top: BorderSide(color: AppColors.border),
                right: BorderSide(color: AppColors.border),
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  n['msg']!,
                  style: const TextStyle(fontSize: 13, color: AppColors.text),
                ),
                const SizedBox(height: 5),
                Text(
                  n['time']!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.subtext,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Help & Support ────────────────────────────────────────────────────────────
class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  static const _faqs = [
    {
      'q': 'How to attempt a quiz?',
      'a':
          'Tap any category and select a quiz. Answer all questions and submit.',
    },
    {
      'q': 'How is score calculated?',
      'a':
          'Each correct answer earns 10 points. Bonus points for answer streaks.',
    },
    {
      'q': 'How to reset progress?',
      'a': 'Go to Settings > Account > Reset Progress.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: _darkAppBar(context, 'Help & Support'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ...List.generate(_faqs.length, (i) {
              final faq = _faqs[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      faq['q']!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      faq['a']!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.subtext,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Email sent to support@quizapp.com',
                      style: TextStyle(color: AppColors.text),
                    ),
                    backgroundColor: AppColors.surface,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                child: const Text('Contact Support'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
