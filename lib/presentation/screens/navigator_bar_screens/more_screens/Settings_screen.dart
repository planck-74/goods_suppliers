// import 'package:flutter/material.dart';
// import 'package:goods/data/global/theme/theme_data.dart';
// import 'package:goods/presentation/custom_widgets/custom_buttons/custom_buttons.dart';

// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({super.key});

//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen> {
//   String selectedLanguage = 'en';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'الإعدادات',
//           style: Theme.of(context).textTheme.bodyMedium,
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             customButtonMoreScreenWithImage(
//               context: context,
//               text: 'المظهر',
//               icon: 'assets/icons/mode.png',
//               color: darkBlueColor,
//             ),
//             ExpansionTile(
//               title:
//                   Text('اللغة', style: Theme.of(context).textTheme.bodyMedium),
//               leading: const Icon(Icons.language, color: darkBlueColor),
//               children: [
//                 RadioListTile<String>(
//                   title: const Text('English'),
//                   value: 'en',
//                   groupValue: selectedLanguage,
//                   onChanged: (value) {
//                     setState(() {
//                       selectedLanguage = value!;
//                     });
//                   },
//                 ),
//                 RadioListTile<String>(
//                   title: const Text('العربية'),
//                   value: 'ar',
//                   groupValue: selectedLanguage,
//                   onChanged: (value) {
//                     setState(() {
//                       selectedLanguage = value!;
//                     });
//                   },
//                 ),
//               ],
//             ),
//             customButtonMoreScreen(
//               context: context,
//               text: 'حجم الخط',
//               icon: Icons.font_download,
//               color: darkBlueColor,
//             ),
//             customButtonMoreScreen(
//               context: context,
//               text: 'إدارة الموقع',
//               icon: Icons.location_history_outlined,
//               color: darkBlueColor,
//             ),
//             customButtonMoreScreen(
//               context: context,
//               text: 'إدارة الإشعارات',
//               icon: Icons.notifications_none_outlined,
//               color: darkBlueColor,
//             ),
//             customButtonMoreScreen(
//               context: context,
//               text: 'إدارة الحساب',
//               icon: Icons.account_tree_outlined,
//               color: darkBlueColor,
//             ),
//             customButtonMoreScreen(
//               context: context,
//               text: 'حذف الحساب',
//               icon: Icons.delete_outline,
//               color: primaryColor,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
