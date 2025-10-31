// import 'package:expert_connect/src/auth/repo/auth_repo_manager.dart';
// import 'package:expert_connect/src/extension/string_extensions.dart';
// import 'package:flutter/material.dart';

// class SettingsWidget {
//   static AuthStateManager authStateManager = AuthStateManager();

//   static Widget profile() {
//     return SliverToBoxAdapter(
//       child: Container(
//         padding: const EdgeInsets.all(24),
//         child: Row(
//           children: [
//             Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(20),
//                 gradient: const LinearGradient(
//                   colors: [Color(0xFFFFB347), Color(0xFFFF8C00)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.orange.withOpacity(0.3),
//                     blurRadius: 15,
//                     offset: const Offset(0, 8),
//                   ),
//                 ],
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(20),
//                 child: Image.asset(
//                   'assets/profile_image.jpg',
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) {
//                     return Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(20),
//                         gradient: const LinearGradient(
//                           colors: [Color(0xFFFFB347), Color(0xFFFF8C00)],
//                         ),
//                       ),
//                       child: const Icon(
//                         Icons.person,
//                         color: Colors.white,
//                         size: 40,
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ),
//             const SizedBox(width: 20),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     authStateManager.user!.name.capitalizeWords(),
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.w700,
//                       color: const Color(0xFF1A1A1A),
//                       letterSpacing: -0.5,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     authStateManager.user!.phone,
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: const Color(0xFF6B7280),
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     authStateManager.user!.email,
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: const Color(0xFF6B7280),
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
