// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:travel_app_project/features/auth/presentation/pages/login_page.dart';
// // import 'package:travel_app_project/features/auth/presentation/pages/signup_page.dart'; // لاحقًا
// import 'package:travel_app_project/features/home/presentation/pages/home_page.dart'; // قم بإنشاء ملف وهمي له الآن
// import 'package:travel_app_project/features/splash/presentation/pages/splash_page.dart'; // قم بإنشاء ملف وهمي له الآن

// // في هذا المثال المبسط، لن نمرر AuthBloc الآن.
// // سنضيف منطق التحقق من المصادقة والتوجيه لاحقًا.

// class AppRouter {
//   AppRouter();

//   static const String splashPath = '/';
//   static const String loginPath = '/login';
//   static const String signupPath = '/signup'; // لاحقًا
//   static const String homePath = '/home';
//   static const String forgotPasswordPath = '/forgot-password'; // لاحقًا

//   late final GoRouter config = GoRouter(
//     initialLocation: splashPath, // ابدأ من شاشة البداية
//     debugLogDiagnostics: true, // مفيد للتصحيح
//     routes: <RouteBase>[
//       GoRoute(
//         path: splashPath,
//         name: 'splash',
//         builder: (BuildContext context, GoRouterState state) => const SplashPage(),
//       ),
//       GoRoute(
//         path: loginPath,
//         name: 'login',
//         builder: (BuildContext context, GoRouterState state) => const LoginPage(),
//       ),
//       // GoRoute(
//       //   path: signupPath,
//       //   name: 'signup',
//       //   builder: (BuildContext context, GoRouterState state) => const SignupPage(),
//       // ),
//       GoRoute(
//         path: homePath,
//         name: 'home',
//         builder: (BuildContext context, GoRouterState state) => const HomePage(),
//       ),
//     ],
//     // redirect: (BuildContext context, GoRouterState state) {
//     //   // سيتم إضافة منطق التوجيه المعتمد على حالة المصادقة هنا لاحقًا
//     //   // مثال: إذا كان المستخدم مسجلاً دخوله ويحاول الوصول إلى /login، وجهه إلى /home
//     //   // إذا لم يكن مسجلاً دخوله ويحاول الوصول إلى /home، وجهه إلى /login
//     //   return null; // لا يوجد توجيه الآن
//     // },
//   );
// }
