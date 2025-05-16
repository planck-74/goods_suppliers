import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationState();
}

class _NotificationState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الإشعـارات',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      body: ListView.builder(
          itemCount: 10,
          itemBuilder: (context, index) {
            return const ListTile(
              title: Text('إشعار جديد'),
              subtitle: Text('لقد حصلت علي فاتورة جديدة'),
              trailing: Column(
                children: [
                  Icon(Icons.navigate_next_outlined),
                  SizedBox(
                    height: 12,
                  ),
                  Text('4-7-2005'),
                ],
              ),
            );
          }),
    );
  }
}
            // return Container(
            //     child: Row(
            //   children: [
            //     Column(
            //       children: [Text('إشعار جديد'), Text('لقد حصلت علي فاتورة جديدة')],
            //     ),
            //     Column(
            //       children: [Icon(Icons.skip_next_outlined
            //       ),
            //         Text('4 7 2005'),
            //       ],
            //     )
            //   ],
            // ));