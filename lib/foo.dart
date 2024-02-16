// import 'dart:convert';
// import 'dart:io';
// 
// import 'package:csv/csv.dart';
// import 'package:http/http.dart' as http;
// 
// Future<List<Map<String, dynamic>>> getIssues({
//   required String state,
//   required int page,
//   int perPage = 100,
// }) async {
//   final res = await http.get(
//     Uri.parse(
//         'https://api.github.com/repos/akshay-thence/OKR/issues?state=$state&per_page=$perPage&page=$page'),
//     headers: {
//       "Accept": "application/vnd.github+jso",
//       'X-GitHub-Api-Version': '2022-11-28',
//       "Authorization":
//           "Bearer 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"
//     },
//   );
//   if (res.statusCode == 200) {
//     return json.decode(res.body);
//   }
// 
//   return [];
// }
// 
// Future<void> fetchAllBugs() async {
//   List<Map<String, dynamic>> data = [];
// 
//   try {} catch (e) {}
// }
// 
// void createCsv(List<Map<String, dynamic>> data) async {
//   data.removeWhere((element) => element.containsKey('pull_request'));
//   print('Merged data from all JSON files');
// 
//   final List<List<dynamic>> output = [];
//   final header = [
//     'TICKET NUMBER',
//     'CREATED BY',
//     'CREATED ON',
//     "TILE",
//     "STATUS",
//     "ASSIGNEE",
//     "ENVIRONMENT",
//     "PRIORITY",
//     "PLATFORM",
//     "MODULE",
//     "TICKET",
//     "ISSUE",
//     "BUG STATUS",
//     "BLOCKER",
//     "DEV/PC",
//   ];
// 
//   output.add(header);
// 
//   for (final i in data) {
//     final number = i['number'];
//     final createdBy = i['user']['login'];
//     final createdOn = i['created_at'];
//     final title = i['title'];
//     final status = i['state'];
// 
//     final assignee = (i['assignees'].map((e) => e['login']).toList())
//         .toString()
//         .replaceAll('[', '')
//         .replaceAll(']', '');
// 
//     List<String> labels =
//         (i['labels']?.map((e) => e['name']).toList() ?? []).cast<String>();
// 
//     final env = labels.firstWhere((e) => e.toLowerCase().contains('env:'),
//         orElse: () => '');
// 
//     final priority = labels.firstWhere(
//         (e) => e.toLowerCase().contains('priority:'),
//         orElse: () => '');
//     final platform = labels.firstWhere(
//         (e) => e.toLowerCase().contains('platform:'),
//         orElse: () => '');
//     final mod = labels.firstWhere((e) => e.toLowerCase().contains('mod:'),
//         orElse: () => '');
//     final ticket = labels.firstWhere((e) => e.toLowerCase().contains('ticket:'),
//         orElse: () => '');
//     final issue = labels.firstWhere((e) => e.toLowerCase().contains('issue:'),
//         orElse: () => '');
//     final bugStatus = labels.firstWhere(
//         (e) => e.toLowerCase().contains('status:'),
//         orElse: () => '');
//     final blocker = labels.firstWhere(
//         (e) => e.toLowerCase().contains('blocker:'),
//         orElse: () => 'No');
// 
//     final devPc = labels.firstWhere((e) => e.toLowerCase().contains('dev/pc:'),
//         orElse: () => '');
// 
//     final _data = [
//       number,
//       createdBy,
//       createdOn,
//       title,
//       status,
//       assignee,
//       env,
//       priority.replaceAll('PRIORITY:', '').trim(),
//       platform.replaceAll('PLATFORM:', '').trim(),
//       mod.replaceAll('MOD: ', '').trim(),
//       ticket.replaceAll('TICKET:', '').trim(),
//       issue,
//       bugStatus,
//       blocker,
//       devPc
//     ];
// 
//     output.add(_data);
//   }
// 
//   String csv = const ListToCsvConverter().convert(output);
// 
//   File f = File("output/output.csv");
//   f.writeAsString(csv);
// }
