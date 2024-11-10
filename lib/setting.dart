import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_notifier.dart'; // Import ThemeNotifier

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.green[800],
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Display',
              style: TextStyle(fontSize: 14.0, color: Colors.grey),
            ),
          ),
          ListTile(
            leading: Icon(Icons.brightness_6_outlined),
            title: Text('Theme'),
            subtitle: Text('System default', style: TextStyle(color: Colors.grey)),
            onTap: () {
              _showThemeDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Choose Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Light'),
                onTap: () {
                  Provider.of<ThemeNotifier>(context, listen: false).setLightMode();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Dark'),
                onTap: () {
                  Provider.of<ThemeNotifier>(context, listen: false).setDarkMode();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
