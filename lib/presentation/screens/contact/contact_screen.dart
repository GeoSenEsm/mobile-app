import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_frontend/l10n/get_localizations.dart';
import 'package:survey_frontend/presentation/controllers/contact_controller.dart';

class ContactScreen extends GetView<ContactController> {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(getAppLocalizations().contact)),
      body: Obx(() {
        if (controller.isLoadingContacts.value) {
          return Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor),
          );
        }

        if (controller.loadingError.value) {
          return _buildErrorInfo();
        }

        if (controller.contacts.isEmpty) {
          return _buildNoContactsInfo();
        }

        return _buildContactsList(context);
      }),
    );
  }

  Widget _buildErrorInfo() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              getAppLocalizations().errorLoadingContacts,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
            ),
            ElevatedButton(
                onPressed: controller.loadContacts,
                child: Text(getAppLocalizations().refreshContacts))
          ],
        ),
      ),
    );
  }

  Widget _buildNoContactsInfo() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              getAppLocalizations().noContacts,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsList(BuildContext context) {
    return ListView.builder(
      itemCount: controller.contacts.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            15,
            8,
            8,
            15,
          ),
          child: Row(
            children: [
              Text(
                controller.contacts[index].name,
                style: const TextStyle(fontSize: 20),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  controller.call(controller.contacts[index]);
                },
                child: Text(
                  getAppLocalizations().call,
                  style: const TextStyle(fontSize: 20),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
