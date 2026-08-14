// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:travel_app_project/core/auth_service.dart';
// import 'package:travel_app_project/features/auth/login_screen.dart';

// class ProfileTabWidget extends StatelessWidget {
//   const ProfileTabWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final AuthService authService = AuthService();
//     final User? currentUser =
//         authService.getCurrentUser(); // أو FirebaseAuth.instance.currentUser
//     final primaryColor = Theme.of(context).primaryColor;
//     final screenWidth = MediaQuery.of(context).size.width;

//     // دالة لعرض رسالة SnackBar (للوظائف التي لم تنفذ بعد)
//     void _showComingSoonSnackBar(BuildContext context, String featureName) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('$featureName قيد التطوير، سيتم إضافتها قريبًا!',
//               style: GoogleFonts.cairo(color: Colors.white)),
//           backgroundColor: Colors.blueGrey,
//           behavior: SnackBarBehavior.floating,
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//           margin: const EdgeInsets.all(10),
//         ),
//       );
//     }

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: <Widget>[
//           // الصورة الرمزية والاسم/الإيميل
//           CircleAvatar(
//             radius: screenWidth * 0.15,
//             backgroundColor: primaryColor.withOpacity(0.2),
//             // يمكنك استخدام currentUser.photoURL إذا كان المستخدم لديه صورة
//             // child: currentUser?.photoURL != null
//             //     ? ClipOval(child: Image.network(currentUser!.photoURL!, fit: BoxFit.cover))
//             //     : Icon(Icons.person_rounded, size: screenWidth * 0.15, color: primaryColor),
//             // مؤقتًا سنستخدم أيقونة
//             child: Icon(Icons.person_rounded,
//                 size: screenWidth * 0.18, color: primaryColor),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             // يمكنك استخدام currentUser.displayName إذا قمت بحفظه
//             currentUser?.displayName ??
//                 currentUser?.email?.split('@')[0] ??
//                 'المستخدم',
//             style: GoogleFonts.cairo(
//               fontSize: screenWidth * 0.06,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           Text(
//             currentUser?.email ?? 'لا يوجد بريد إلكتروني',
//             style: GoogleFonts.cairo(
//               fontSize: screenWidth * 0.04,
//               color: Colors.grey[700],
//             ),
//           ),
//           const SizedBox(height: 24),
//           Divider(color: Colors.grey[300]),
//           const SizedBox(height: 16),

//           // قائمة الخيارات
//           _buildProfileOptionItem(
//             context,
//             icon: Icons.edit_outlined,
//             title: 'تعديل الملف الشخصي',
//             onTap: () => _showComingSoonSnackBar(context, 'تعديل الملف الشخصي'),
//           ),
//           _buildProfileOptionItem(
//             context,
//             icon: Icons.settings_outlined,
//             title: 'الإعدادات',
//             onTap: () => _showComingSoonSnackBar(context, 'الإعدادات'),
//           ),
//           _buildProfileOptionItem(
//             context,
//             icon: Icons.payment_outlined, // أيقونة للمدفوعات المحفوظة (اختياري)
//             title: 'طرق الدفع',
//             onTap: () => _showComingSoonSnackBar(context, 'طرق الدفع'),
//           ),
//           _buildProfileOptionItem(
//             context,
//             icon: Icons.notifications_outlined,
//             title: 'الإشعارات',
//             onTap: () => _showComingSoonSnackBar(context, 'الإشعارات'),
//           ),
//           _buildProfileOptionItem(
//             context,
//             icon: Icons.help_outline_rounded,
//             title: 'مركز المساعدة',
//             onTap: () => _showComingSoonSnackBar(context, 'مركز المساعدة'),
//           ),
//           Divider(color: Colors.grey[300]),
//           _buildProfileOptionItem(
//             context,
//             icon: Icons.info_outline_rounded,
//             title: 'عن التطبيق',
//             onTap: () => _showComingSoonSnackBar(context, 'عن التطبيق'),
//           ),
//           const SizedBox(height: 16),
//           // زر تسجيل الخروج
//           SizedBox(
//             width: double.infinity, // لجعل الزر يمتد بعرض الشاشة
//             child: ElevatedButton.icon(
//               icon: const Icon(Icons.logout_rounded, color: Colors.white),
//               label: Text('تسجيل الخروج',
//                   style: GoogleFonts.cairo(fontSize: 17, color: Colors.white)),
//               onPressed: () async {
//                 await authService.signOut();
//                 if (context.mounted) {
//                   Navigator.of(context).pushAndRemoveUntil(
//                     MaterialPageRoute(builder: (context) => const LoginPage()),
//                     (Route<dynamic> route) => false,
//                   );
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor:
//                     Colors.redAccent[400], // لون مميز لتسجيل الخروج
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10.0)),
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           Text(
//             'إصدار التطبيق: 1.0.0', // يمكنك جعله ديناميكيًا لاحقًا
//             style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey[500]),
//           ),
//         ],
//       ),
//     );
//   }

//   // ويدجت مساعد لبناء كل عنصر في قائمة خيارات الملف الشخصي
//   Widget _buildProfileOptionItem(BuildContext context,
//       {required IconData icon,
//       required String title,
//       required VoidCallback onTap}) {
//     return ListTile(
//       dense: true, // لجعل العنصر أصغر قليلاً
//       leading: Icon(icon,
//           color: Theme.of(context).primaryColor.withOpacity(0.8), size: 26),
//       title: Text(
//         title,
//         style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w500),
//       ),
//       trailing: const Icon(Icons.arrow_forward_ios_rounded,
//           size: 18, color: Colors.grey),
//       onTap: onTap,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       // visualDensity: VisualDensity.compact,
//     );
//   }
// }
