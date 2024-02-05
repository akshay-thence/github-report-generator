import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:github_export/function.dart';

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
    if (apiStatus == ApiStatus.loading) return;
    apiStatus = ApiStatus.loading;
    setState(() {});
    try {
      final repo = extractOwnerAndRepo(controller.text);
      final data = await fetchAllBugs(repo);
      final csv = createCsv(data);
      apiStatus = ApiStatus.success;

      setState(() {});
      download(csv);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
      apiStatus = ApiStatus.error;
      setState(() {});
    }
  }

  void download(String csv) {
    final bytes = utf8.encode(csv);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = 'report.csv';
    html.document.body?.children.add(anchor);

    // download
    anchor.click();

    // cleanup
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Github bug report generator",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(width: 24),
                ],
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: 60,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          hintText: 'Enter responsory url',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 60,
                      child: apiStatus == ApiStatus.loading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton.icon(
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              icon: const Icon(Icons.download, size: 18),
                              label: const Text('Download report'),
                              onPressed: () => fetchRepository(),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
