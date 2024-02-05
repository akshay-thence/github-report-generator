import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;

String extractOwnerAndRepo(String githubUrl) {
  Uri uri = Uri.parse(githubUrl);

  List<String> pathSegments = uri.pathSegments;

  if (pathSegments.length >= 2) {
    String owner = pathSegments[0];
    String repo = pathSegments[1].split(".")[0];

    return '$owner/$repo';
  } else {
    throw Exception("Invalid GitHub URL");
  }
}

Future<List<Map<String, dynamic>>> getIssues({
  required String repoUrl,
  required String state,
  required int page,
  int perPage = 100,
}) async {
  final res = await http.get(
    Uri.parse(
        'https://api.github.com/repos/$repoUrl/issues?labels=bug&state=$state&per_page=$perPage&page=$page'),
    headers: {
      "Accept": "application/vnd.github+jso",
      'X-GitHub-Api-Version': '2022-11-28',
      "Authorization": "Bearer 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"
    },
  );
  if (res.statusCode == 200) {
    final List<dynamic> dataList = json.decode(res.body);
    final List<Map<String, dynamic>> data =
        dataList.cast<Map<String, dynamic>>();

    return data;
  }

  return [];
}

Future<List<Map<String, dynamic>>> fetchAllBugs(String repoUrl) async {
  try {
    List<Map<String, dynamic>> data = [];
    bool hasNextOpenIssue = true;
    bool hasNextClosedIssue = true;
    int openPage = 1;
    int closedPage = 1;

    do {
      print('Fetching open issues page $openPage');
      final issues = await getIssues(
        repoUrl: repoUrl,
        page: openPage,
        state: 'open',
      );
      data.addAll(issues);
      openPage++;
      hasNextOpenIssue = (issues.length == 100);
    } while (hasNextOpenIssue);

    do {
      final issues = await getIssues(
        repoUrl: repoUrl,
        page: closedPage,
        state: 'closed',
      );
      print('Fetching closed issues page $closedPage');
      data.addAll(issues);
      closedPage++;
      hasNextClosedIssue = (issues.length == 100);
    } while (hasNextClosedIssue);

    return data;
  } catch (e) {
    throw Exception('Failed to fetch issues');
  }
}

String createCsv(List<Map<String, dynamic>> data) {
  data.removeWhere((element) => element.containsKey('pull_request'));

  final List<List<dynamic>> output = [];
  final header = [
    'TICKET NUMBER',
    'CREATED BY',
    'CREATED ON',
    "TILE",
    "STATUS",
    "ASSIGNEE",
    "ENVIRONMENT",
    "BUILD"
        "PRIORITY",
    "PLATFORM",
    "MODULE",
    "TICKET",
    "ISSUE",
    "BUG STATUS",
    "BLOCKER",
    "DEV/PC",
  ];

  output.add(header);

  for (final i in data) {
    final number = i['number'];
    final createdBy = i['user']['login'];
    final createdOn = i['created_at'];
    final title = i['title'];
    final status = i['state'];

    final assignee = (i['assignees'].map((e) => e['login']).toList())
        .toString()
        .replaceAll('[', '')
        .replaceAll(']', '');

    List<String> labels =
        (i['labels']?.map((e) => e['name']).toList() ?? []).cast<String>();

    final env = labels.firstWhere((e) => e.toLowerCase().contains('env:'),
        orElse: () => '');

    final priority = labels.firstWhere(
        (e) => e.toLowerCase().contains('priority:'),
        orElse: () => '');
    final platform = labels.firstWhere(
        (e) => e.toLowerCase().contains('platform:'),
        orElse: () => '');
    final mod = labels.firstWhere((e) => e.toLowerCase().contains('mod:'),
        orElse: () => '');
    final ticket = labels.firstWhere((e) => e.toLowerCase().contains('ticket:'),
        orElse: () => '');
    final issue = labels.firstWhere((e) => e.toLowerCase().contains('issue:'),
        orElse: () => '');
    final bugStatus = labels.firstWhere(
        (e) => e.toLowerCase().contains('status:'),
        orElse: () => '');
    final blocker = labels.firstWhere(
        (e) => e.toLowerCase().contains('blocker:'),
        orElse: () => 'No');

    final devPc = labels.firstWhere((e) => e.toLowerCase().contains('dev/pc:'),
        orElse: () => '');

    // Extract build number
    RegExp regex = RegExp(r'Build version\n\n(.+?)\n\n', multiLine: true);
    Match? match = regex.firstMatch(i['body']);
    final build = match != null ? match.group(1)! : '';

    final _data = [
      number,
      createdBy,
      createdOn,
      title,
      status,
      assignee,
      env,
      build,
      priority.replaceAll('PRIORITY:', '').trim(),
      platform.replaceAll('PLATFORM:', '').trim(),
      mod.replaceAll('MOD: ', '').trim(),
      ticket.replaceAll('TICKET:', '').trim(),
      issue,
      bugStatus,
      blocker,
      devPc
    ];

    output.add(_data);
  }

  String csv = const ListToCsvConverter().convert(output);
  return csv;
}
