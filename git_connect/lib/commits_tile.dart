import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CommitExpansionTile extends StatelessWidget {
  final dynamic repo;

  const CommitExpansionTile({
    Key? key,
    required this.repo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(repo['name']),
      children: <Widget>[
        repo['last_commit'] != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Author: ${repo['last_commit']['author']['name']}'),
                  Text('Message: ${repo['last_commit']['message']}'),
                  TextButton(
                    onPressed: () {
                      launchURL(repo['html_url']);
                    },
                    child: Text(
                      'Link: ${repo['html_url']}',
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              )
            : const Text('No commits loaded yet'),
      ],
    );
  }

  void launchURL(String url) async {
    Uri url0 = Uri.parse(url);
    if (await canLaunchUrl(url0)) {
      await launchUrl(url0);
    } else {
      throw 'Could not launch $url0';
    }
  }
}
