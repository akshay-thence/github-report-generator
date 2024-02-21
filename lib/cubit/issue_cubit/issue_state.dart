part of 'issue_cubit.dart';

class IssueState {
  IssueState({
    this.repoUrl,
    this.apiStatus = ApiStatus.initial,
    this.openTicket = const [],
    this.closedTicket = const [],
  });

  copyWith({
    String? repoUrl,
    ApiStatus? apiStatus,
    List<Map<String, dynamic>>? openTicket,
    List<Map<String, dynamic>>? closedTicket,
  }) {
    return IssueState(
      repoUrl: repoUrl ?? this.repoUrl,
      apiStatus: apiStatus ?? this.apiStatus,
      openTicket: openTicket ?? this.openTicket,
      closedTicket: closedTicket ?? this.closedTicket,
    );
  }

  final ApiStatus apiStatus;
  final String? repoUrl;
  final List<Map<String, dynamic>> openTicket;
  final List<Map<String, dynamic>> closedTicket;
}
