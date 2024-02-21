// ignore_for_file: avoid_print

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_export/function.dart';
import 'package:github_export/home.dart';

part 'issue_state.dart';

const pageSize = 100;

class IssueCubit extends Cubit<IssueState> {
  IssueCubit() : super(IssueState());

  Future<void> fetchAllIssues(String repoUrl) async {
    bool hasNextOpenIssue = true;
    bool hasNextClosedIssue = true;
    int openPage = 1;
    int closedPage = 1;

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
    } catch (e) {
      throw Exception('Failed to fetch issues');
    }
  }
}
