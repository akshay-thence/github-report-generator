// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:github_export/models/issue_model.dart';
import 'package:github_export/models/report_summary_model.dart';
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
  required String token,
  required String state,
  required int page,
  int perPage = 100,
}) async {
  final res = await http.get(
    Uri.parse(
        'https://api.github.com/repos/$repoUrl/issues?state=$state&per_page=$perPage&page=$page'),
    headers: {
      "Accept": "application/vnd.github+jso",
      'X-GitHub-Api-Version': '2022-11-28',
      "Authorization": "Bearer $token"
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

Future<List<Map<String, dynamic>>> fetchAllBugs(
  String repoUrl,
  String token,
) async {
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
        token: token,
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
        token: token,
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

List<FormattedIssueModel> formatData(List<Map<String, dynamic>> data) {
  data.removeWhere((element) => element.containsKey('pull_request'));

  final List<FormattedIssueModel> output = [];

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

    final invalidBug = labels.firstWhere(
        (e) => e.toLowerCase().contains('blocker'),
        orElse: () => '');

    final duplicateBug = labels.firstWhere(
      (e) => e.toLowerCase().contains('duplicate'),
      orElse: () => '',
    );

    final milestone = i['milestone']?['title'] ?? 'na';

    // Extract build number
    RegExp regex = RegExp(r'Build version\n\n(.+?)\n\n', multiLine: true);
    Match? match = regex.firstMatch(i['body'] ?? '');
    final build = match != null ? match.group(1)! : '';

    FormattedIssueModel model = FormattedIssueModel(
      ticketNumber: number.toString(),
      createdBy: createdBy,
      createdOn: createdOn,
      title: title,
      status: status,
      assignee: assignee,
      environment: env,
      build: build,
      priority: priority.replaceAll('PRIORITY:', '').trim(),
      platform: platform.replaceAll('PLATFORM:', '').trim(),
      module: mod.replaceAll('MOD: ', '').trim(),
      ticket: ticket.replaceAll('TICKET:', '').trim(),
      issue: issue,
      bugStatus: bugStatus,
      blocker: blocker,
      devPc: devPc,
      isInvalidBug: invalidBug.isNotEmpty,
      isDuplicate: duplicateBug.isNotEmpty,
      milestone: milestone ?? 'NA',
    );

    output.add(model);
  }

  return output;
}

List<ReportSummary> generateSummary(List<FormattedIssueModel> data) {
  Map<String, Map<String, List<FormattedIssueModel>>> groupedData = {};

  // Group the data by version and milestone
  for (var issue in data) {
    if (!groupedData.containsKey(issue.milestone)) {
      groupedData[issue.milestone] = {};
    }

    if (!groupedData[issue.milestone]!.containsKey(issue.build)) {
      groupedData[issue.milestone]![issue.build] = [];
    }

    groupedData[issue.milestone]![issue.build]!.add(issue);
  }

  List<ReportSummary> summary = [];

  groupedData.forEach((milestones, versions) {
    versions.forEach((version, issues) {
      int totalBugs = issues.length;
      int totalResolved =
          issues.where((element) => element.status == 'closed').length;
      int totalPending =
          issues.where((element) => element.status == 'open').length;
      int invalidBugs =
          issues.where((element) => element.devPc.isNotEmpty).length;
      int duplicateBugs =
          issues.where((element) => element.devPc.isNotEmpty).length;

      summary.add(ReportSummary(
        sprint: milestones,
        version: version,
        bugsCount: totalBugs,
        resolvedBugsCount: totalResolved,
        pendingBugsCount: totalPending,
        invalidBugsCount: invalidBugs,
        duplicateBugsCount: duplicateBugs,
      ));
    });
  });

  return summary;
}
