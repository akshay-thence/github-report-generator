import 'dart:convert';
import 'dart:html' as html;

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:github_export/function.dart';
import 'package:github_export/models/issue_model.dart';
import 'package:github_export/models/report_summary_model.dart';

enum ApiStatus { initial, loading, success, error }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ApiStatus apiStatus = ApiStatus.initial;
  TextEditingController controller = TextEditingController();
  TextEditingController tokenController = TextEditingController();

  List<ReportSummary> reportSummary = [];
  List<FormattedIssueModel>? formattedData;

  Future<void> fetchRepository() async {
    if (apiStatus == ApiStatus.loading) return;
    apiStatus = ApiStatus.loading;
    setState(() {});
    try {
      final repo = extractOwnerAndRepo(controller.text);
      final data = await fetchAllBugs(repo, tokenController.text.trim());

      formattedData = formatData(data);
      reportSummary = generateSummary(formattedData ?? []);

      apiStatus = ApiStatus.success;
      setState(() {});
      // download(csv);
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

  void exportCsv() {
    List<List<dynamic>> csvData = [
      [
        'Ticket number',
        'Created by',
        'Created on',
        'Title',
        'Status',
        'Assignee',
        'Environment',
        'Build',
        'Priority',
        'Platform',
        'Module',
        'Ticket',
        'Issue',
        'Bug status',
        'Blocker',
        'Dev pc',
        'Invalid bug',
        'Duplicate bug',
      ],
      ...formattedData?.map((e) => e.toArray()).toList() ?? []
    ];
    final csvString = const ListToCsvConverter().convert(csvData);
    download(csvString);
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
              const SizedBox(height: 16),
              SizedBox(
                height: 60,
                child: TextField(
                  controller: tokenController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    hintText: 'Github token',
                  ),
                ),
              ),
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
                              icon: const Icon(Icons.search, size: 18),
                              label: const Text('View Report'),
                              onPressed: () => fetchRepository(),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (apiStatus == ApiStatus.success)
                ElevatedButton.icon(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Download CSV'),
                  onPressed: () => exportCsv(),
                ),
              if (apiStatus == ApiStatus.success && reportSummary.isNotEmpty)
                Flexible(
                  child: ListView.separated(
                    padding: const EdgeInsets.only(top: 20),
                    shrinkWrap: true,
                    itemCount: reportSummary.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (BuildContext context, int i) {
                      return SelectionArea(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(),
                            Text(
                              'Sprint: ${reportSummary[i].sprint} Version: ${reportSummary[i].version}',
                            ),
                            Text(
                              'Total bugs count: ${reportSummary[i].bugsCount}',
                            ),
                            Text(
                              'Resolved bugs count: ${reportSummary[i].resolvedBugsCount}',
                            ),
                            Text(
                              'Pending bugs count: ${reportSummary[i].pendingBugsCount}',
                            ),
                            Text(
                              'Invalid bugs count: ${reportSummary[i].invalidBugsCount}',
                            ),
                            Text(
                              'Duplicate bugs count:: ${reportSummary[i].duplicateBugsCount}',
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
