import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

enum ApiStatus { initial, loading, success, error }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ApiStatus apiStatus = ApiStatus.initial;
  TextEditingController controller = TextEditingController();

  Future<void> fetchRepository() async {
    apiStatus = ApiStatus.loading;
    setState(() {});
    try {
      final res = await http.get(
        Uri.parse('https://api.github.com/user/repos'),
        headers: {
          "Accept": "application/vnd.github+jso",
          'X-GitHub-Api-Version': '2022-11-28',
          "Authorization":
              "Bearer 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"
        },
      );
      apiStatus = ApiStatus.success;
      setState(() {});
    } catch (e) {
      apiStatus = ApiStatus.error;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Your repositories",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(width: 24),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Repository url',
                    ),
                  ),
                ),
                TextButton(
                  child: const Text('Download report'),
                  onPressed: () => fetchRepository(),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
