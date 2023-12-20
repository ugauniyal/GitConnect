import 'package:flutter/material.dart';
import 'package:git_connect/repost_list.dart';

// A user input screen which asks for github username.
class UsernameInputScreen extends StatelessWidget {
  // Controller to get the username for which all the repositories will be fetched.
  final TextEditingController _usernameController = TextEditingController();

  UsernameInputScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter GitHub Username'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Enter GitHub Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String username = _usernameController.text.trim();
                if (username.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RepoListScreen(username: username),
                    ),
                  );
                } else {
                  print("No username found.");
                }
              },
              child: const Text('Fetch Repositories'),
            ),
          ],
        ),
      ),
    );
  }
}
