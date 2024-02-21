class FormattedIssueModel {
  FormattedIssueModel({
    required this.ticketNumber,
    required this.createdBy,
    required this.createdOn,
    required this.title,
    required this.status,
    required this.assignee,
    required this.environment,
    required this.build,
    required this.priority,
    required this.platform,
    required this.module,
    required this.ticket,
    required this.issue,
    required this.bugStatus,
    required this.blocker,
    required this.devPc,
    required this.isInvalidBug,
    required this.isDuplicate,
    required this.milestone,
  });

  toArray() {
    return [
      ticketNumber,
      createdBy,
      createdOn,
      title,
      status,
      assignee,
      environment,
      build,
      priority,
      platform,
      module,
      ticket,
      issue,
      bugStatus,
      blocker,
      devPc,
      isInvalidBug ? 'Yes' : 'No',
      isDuplicate ? 'Yes' : 'No',
      milestone,
    ];
  }

  String ticketNumber;
  String createdBy;
  String createdOn;
  String title;
  String status;
  String assignee;
  String environment;
  String build;
  String priority;
  String platform;
  String module;
  String ticket;
  String issue;
  String bugStatus;
  String blocker;
  String devPc;
  bool isInvalidBug;
  bool isDuplicate;
  String milestone;
}
