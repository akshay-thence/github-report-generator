class ReportSummary {
  ReportSummary({
    this.sprint = 'unknown',
    this.version = 'unknown',
    this.bugsCount = 0,
    this.resolvedBugsCount = 0,
    this.pendingBugsCount = 0,
    this.invalidBugsCount = 0,
    this.duplicateBugsCount = 0,
  });

  String sprint;
  String version;
  int bugsCount;
  int resolvedBugsCount;
  int pendingBugsCount;
  int invalidBugsCount;
  int duplicateBugsCount;
}
