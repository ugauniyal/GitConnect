import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:git_connect/commits_tile.dart';
import 'dart:convert';

class RepoListScreen extends StatefulWidget {
  final String username;

  const RepoListScreen({Key? key, required this.username}) : super(key: key);

  @override
  _RepoListScreenState createState() => _RepoListScreenState();
}

class _RepoListScreenState extends State<RepoListScreen> {
  late Future<List<dynamic>> _fetchRepos;
  List<dynamic> allRepos = [];
  int page = 1;
  bool isLoading = false;
  bool isFetchingCommits = false;

  // Taking token for authorized API calls. Unauthorized calls have rate limits.
  static const token = 'GITHUB_TOKEN'; // Replace with your GitHub token
  final headers = {
    'Authorization': 'token $token',
    'Accept': 'application/vnd.github.v3+json',
  };

// Scroller Controller for scrolling through repos.
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchRepos = fetchRepositories(widget.username);
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

// ScrollListener so that when user reaches the end, then load another set of repositories.
  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        !isLoading) {
      setState(() {
        isLoading = true;
        page++;
        fetchRepositories(widget.username);
      });
    }
  }

// Funtion to fetch the last commit of particular repositroory
  Future<void> fetchLastCommit(repo, headers) async {
    try {
      final commitResponse = await http.get(
        Uri.parse(
            'https://api.github.com/repos/${widget.username}/${repo['name']}/commits'),
        headers: headers,
      );

      if (commitResponse.statusCode == 200) {
        List<dynamic> commits = json.decode(commitResponse.body);

        // Get the latest commit by comparing dates.
        if (commits.isNotEmpty) {
          commits.sort((a, b) {
            var aDate = DateTime.parse(a['commit']['author']['date']);
            var bDate = DateTime.parse(b['commit']['author']['date']);
            return bDate.compareTo(aDate);
          });

          repo['last_commit'] = commits[0]['commit'];
          setState(() {});
        }
      } else {
        print('Failed to load commits for ${repo['name']}');
      }
    } catch (e) {
      print('Error fetching commits: $e');
    }
  }

// Function get retrieve or fetch repositories in a pagination manner. Getting 20 repos at a time.
  Future<List<dynamic>> fetchRepositories(String username) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://api.github.com/users/$username/repos?page=$page&per_page=20'),
        headers: headers,
      );

      // Add the new loaded repos to the main list which includes all the repositories
      if (response.statusCode == 200) {
        List<dynamic> repos = json.decode(response.body);
        if (repos.isEmpty) {
          return allRepos;
        } else {
          allRepos.addAll(repos);
          isLoading = false;
          setState(() {});

          // Fetch commits for all repos after repositories are loaded
          fetchLastCommitsForAll();
        }
      } else {
        throw Exception('Failed to load repositories');
      }

      return allRepos;
    } catch (e) {
      print('Error fetching repositories: $e');
      return allRepos;
    }
  }

  // Function to fetch last commit for all the repositories async.
  Future<void> fetchLastCommitsForAll() async {
    try {
      // Create a copy of the list to iterate over
      List<dynamic> reposCopy = List.from(allRepos);

      // Fetch last commit for each repo
      for (var repo in reposCopy) {
        if (repo['last_commit'] == null) {
          await fetchLastCommit(repo, headers);
        }
      }
    } catch (e) {
      print('Error fetching commits for all repos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GitHub Repositories'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _fetchRepos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              controller: _scrollController,
              itemCount: allRepos.length +
                  (isLoading ? 1 : 0), // Add one for loading indicator
              itemBuilder: (context, index) {
                if (index == allRepos.length) {
                  // Show loading indicator at the bottom
                  return const Center(child: CircularProgressIndicator());
                }
                var repo = allRepos[index];
                return CommitExpansionTile(
                  repo: repo,
                );
              },
            );
          }
        },
      ),
    );
  }
}
