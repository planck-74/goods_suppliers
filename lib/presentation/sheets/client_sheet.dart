import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goods/data/functions/open_google_maps.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:goods/data/models/client_model.dart';

class ClientDetailsSheet extends StatelessWidget {
  final ClientModel client;

  const ClientDetailsSheet({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Client Image Section
                _buildImageSection(),
                
                // Content Section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          
                          // Header
                          _buildHeader(),
                          
                          const SizedBox(height: 20),
                          
                          // Business Name
                          _buildInfoTile(
                            icon: const ImageIcon(
                              AssetImage('assets/images/market.png'),
                              color: Colors.blue,
                            ),
                            title: '${client.businessName} - ${client.category}',
                            subtitle: 'اسم المكان',
                          ),
                          
                          // First Phone Number
                          _buildPhoneTile(
                            phoneNumber: client.phoneNumber,
                            subtitle: 'رقم الهاتف الأساسي',
                            icon: Icons.phone,
                            isMain: true,
                          ),
                          
                          // Second Phone Number
                          if (client.secondPhoneNumber.isNotEmpty)
                            _buildPhoneTile(
                              phoneNumber: client.secondPhoneNumber,
                              subtitle: 'رقم الهاتف الثاني',
                              icon: Icons.phone_android_sharp,
                              isMain: false,
                            ),
                          
                          // Typed Address
                          if (client.addressTyped.isNotEmpty)
                            _buildInfoTile(
                              icon: const Icon(Icons.location_on_outlined, color: Colors.orange),
                              title: client.addressTyped,
                              subtitle: 'العنوان المكتوب',
                            ),
                          
                          // Location with Maps Button
                          _buildLocationTile(),
                          
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: client.imageUrl.isNotEmpty
            ? Image.network(
                client.imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderImage();
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              )
            : _buildPlaceholderImage(),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade300, Colors.grey.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 50, color: Colors.white),
            SizedBox(height: 8),
            Text(
              'لا توجد صورة',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.person, color: Colors.blue),
          SizedBox(width: 12),
          Text(
            'بيانات العميل',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required Widget icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: icon,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.blueGrey.shade600,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildPhoneTile({
    required String phoneNumber,
    required String subtitle,
    required IconData icon,
    required bool isMain,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(
          phoneNumber,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.blueGrey.shade600,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.call, color: Colors.green),
              onPressed: () => _makePhoneCall(phoneNumber),
            ),
            IconButton(
              icon: const Icon(Icons.copy, color: Colors.blue),
              onPressed: () => _copyToClipboard(phoneNumber),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildLocationTile() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: const Icon(Icons.location_on, color: Colors.red),
        title: Text(
          '${client.government} ${client.town}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          'الموقع الجغرافي',
          style: TextStyle(
            fontSize: 14,
            color: Colors.blueGrey.shade600,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.map, color: Colors.blue, size: 16),
              SizedBox(width: 4),
              Text(
                'خرائط',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          openGoogleMaps(
            client.geoLocation.latitude,
            client.geoLocation.longitude,
          );
                },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
    } else {
      // Handle error - you can use your showTopBar here
      print('لا يمكن فتح تطبيق الهاتف');
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    // Handle success - you can use your showTopBar here
    print('تم النسخ إلى الحافظة');
  }
}
