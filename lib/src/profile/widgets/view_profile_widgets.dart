// import 'package:expert_connect/src/app/app_constant.dart';
// import 'package:expert_connect/src/app/routes_name.dart';
// import 'package:expert_connect/src/extension/string_extensions.dart';
// import 'package:expert_connect/src/models/vendors.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class ViewProfileWidgets {
  
//   Widget _buildDynamicSection(HomeState state) {
//     String title;

//     switch (selectedCategory) {
//       case 'Rating':
//         title = 'Top Rated ${widget.category}';
//         break;
//       case 'Location':
//         title = '${widget.category} Near You';
//         break;
//       case 'Experience':
//         title = 'Most Experienced ${widget.category}';

//         break;
//       default: // Featured
//         title = 'Featured ${widget.category}';
//     }

//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 4,
//                 height: 24,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF3B82F6),
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF1E293B),
//                 ),
//               ),
//               const Spacer(),
//               Text(
//                 'View All',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: const Color(0xFF3B82F6),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           SizedBox(
//             height: 240.h, // Fixed height for consistent layout
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               physics: const BouncingScrollPhysics(),
//               itemCount: state.vendors.length,
//               itemBuilder: (context, index) {
//                 final vendor = state.vendors[index];
//                 return Container(
//                   width: 200,
//                   margin: EdgeInsets.only(
//                     right: index < state.vendors.length - 1 ? 16 : 0,
//                     bottom: 10,
//                   ),
//                   child: _buildFeaturedLawyerCard(vendor),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFeaturedLawyerCard(Vendor vendor) {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [Colors.white, Colors.grey.shade50],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 20,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(20),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 10,
//                         vertical: 6,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.green.shade100,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Container(
//                             width: 6,
//                             height: 6,
//                             decoration: BoxDecoration(
//                               color: Colors.green.shade600,
//                               borderRadius: BorderRadius.circular(3),
//                             ),
//                           ),
//                           const SizedBox(width: 6),
//                           Text(
//                             'Online',
//                             style: TextStyle(
//                               color: Colors.green.shade700,
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Icon(
//                       Icons.favorite_border_rounded,
//                       color: Colors.grey.shade400,
//                       size: 20,
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 Container(
//                   width: 80,
//                   height: 80,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(20),
//                     gradient: LinearGradient(
//                       colors: [
//                         const Color(0xFF3B82F6),
//                         const Color(0xFF60A5FA),
//                       ],
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: const Color(0xFF3B82F6).withOpacity(0.3),
//                         blurRadius: 12,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(3),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(17),
//                         color: Colors.white,
//                       ),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(17),
//                         child: Image.network(
//                           'https://images.unsplash.com/photo-${550}9734-2b71ea197ec2?w=160&h=160&fit=crop&crop=face',
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) => Icon(
//                             Icons.person_rounded,
//                             size: 40,
//                             color: Colors.grey[400],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   vendor.name.capitalizeWords(),
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF1E293B),
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   AppConstant.getSubCategoryNameById(vendor.subCategoryId),
//                   style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     _buildStatItem(Icons.star_rounded, "4.5", Colors.amber),
//                     _buildStatItem(
//                       Icons.work_outline_rounded,
//                       '${vendor.exp}y',
//                       const Color(0xFF3B82F6),
//                     ),
//                     _buildStatItem(Icons.gavel_rounded, "${10}", Colors.green),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 Container(
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
//                     ),
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: const Color(0xFF3B82F6).withOpacity(0.3),
//                         blurRadius: 8,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Material(
//                     color: Colors.transparent,
//                     child: InkWell(
//                       onTap: () {
//                         Get.toNamed(
//                           RoutesName.profile,
//                           arguments: {"id": vendor.id},
//                         );
//                       },
//                       borderRadius: BorderRadius.circular(12),
//                       child: const Padding(
//                         padding: EdgeInsets.symmetric(vertical: 12),
//                         child: Text(
//                           'Talk Now',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStatItem(IconData icon, String value, Color color) {
//     return Column(
//       children: [
//         Icon(icon, size: 16, color: color),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w600,
//             color: Color(0xFF1E293B),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildModernSearchBar() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 20,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: TextField(
//         controller: _searchController,
//         onTap: () => setState(() => isSearchFocused = true),
//         onSubmitted: (_) => setState(() => isSearchFocused = false),
//         decoration: InputDecoration(
//           hintText: 'Search lawyers, specializations...',
//           hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
//           prefixIcon: Container(
//             padding: const EdgeInsets.all(12),
//             child: Icon(
//               Icons.search_rounded,
//               color: Colors.grey[600],
//               size: 24,
//             ),
//           ),
//           suffixIcon: isSearchFocused
//               ? IconButton(
//                   onPressed: () {
//                     _searchController.clear();
//                     setState(() => isSearchFocused = false);
//                   },
//                   icon: const Icon(Icons.clear_rounded),
//                 )
//               : Container(
//                   margin: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF3B82F6),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: const Icon(
//                     Icons.tune_rounded,
//                     color: Colors.white,
//                     size: 20,
//                   ),
//                 ),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(16),
//             borderSide: BorderSide.none,
//           ),
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 20,
//             vertical: 16,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildAnimatedFilterChips() {
//     return Padding(
//       padding: const EdgeInsets.only(left: 20),
//       child: SizedBox(
//         height: 40,
//         child: ListView.builder(
//           scrollDirection: Axis.horizontal,
//           physics: const BouncingScrollPhysics(),
//           itemCount: categories.length,
//           itemBuilder: (context, index) {
//             final isSelected = selectedCategory == categories[index];
//             return AnimatedContainer(
//               duration: const Duration(milliseconds: 300),
//               margin: EdgeInsets.only(left: index == 0 ? 0 : 12, right: 0),
//               child: Material(
//                 color: Colors.transparent,
//                 child: InkWell(
//                   borderRadius: BorderRadius.circular(20),
//                   onTap: () {
//                     setState(() {
//                       selectedCategory = isSelected ? '' : categories[index];
//                     });
//                   },
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 300),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 10,
//                     ),
//                     decoration: BoxDecoration(
//                       color: isSelected
//                           ? const Color(0xFF3B82F6)
//                           : Colors.white,
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(
//                         color: isSelected
//                             ? const Color(0xFF3B82F6)
//                             : Colors.grey.withOpacity(0.3),
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.05),
//                           blurRadius: 8,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: Text(
//                       categories[index],
//                       style: TextStyle(
//                         color: isSelected
//                             ? Colors.white
//                             : const Color(0xFF64748B),
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildStatsSection() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             const Color(0xFF1E40AF).withOpacity(0.1),
//             const Color(0xFF3B82F6).withOpacity(0.05),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildStatsCard(
//             '500+',
//             'Expert Lawyers',
//             Icons.person_outline_rounded,
//           ),
//           _buildStatsCard('50K+', 'Cases Solved', Icons.gavel_rounded),
//           _buildStatsCard('4.8★', 'Average Rating', Icons.star_outline_rounded),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatsCard(String number, String label, IconData icon) {
//     return Column(
//       children: [
//         Icon(icon, color: const Color(0xFF3B82F6), size: 24),
//         const SizedBox(height: 8),
//         Text(
//           number,
//           style: const TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Color(0xFF1E293B),
//           ),
//         ),
//         Text(
//           label,
//           style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }

// }