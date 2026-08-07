import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/Controllers/ComposeNotificationController.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/View/NotificationsSend/Widgets/ComposeNotificationTab.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/View/NotificationsSend/Widgets/NotificationHeader.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/View/NotificationsSend/Widgets/NotificationTabs.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/View/NotificationsSend/Widgets/SentNotificationsTab.dart';



class NotificationsSend extends StatefulWidget {
  const NotificationsSend({super.key});

  @override
  State<NotificationsSend> createState() => _NotificationsSendState();
}

class _NotificationsSendState extends State<NotificationsSend> {
   final controller = Get.find<ComposeNotificationController>();
  @override
  void dispose() {
    controller.resetForm();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;

    return KeyboardDismissOnTap(
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: DefaultTabController(
              length: 2,

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  SizedBox(
                    height: size.height * .015,
                  ),


                  const NotificationHeader(),


                  SizedBox(
                    height: size.height * .025,
                  ),


                  const NotificationTabs(),


                  const SizedBox(
                    height: 20,
                  ),


                  Expanded(
                    child: TabBarView(
                      physics:
                          const BouncingScrollPhysics(),

                      children: const [

                        ComposeNotificationTab(),

                        SentNotificationsTab(),

                      ],
                    ),
                  )

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}