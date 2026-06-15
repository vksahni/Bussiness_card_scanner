class Organization {
  const Organization({
    required this.id,
    required this.name,
    required this.adminEmail,
    required this.employeeCount,
    required this.sharedSheetId,
    required this.totalScans,
  });

  final String id;
  final String name;
  final String adminEmail;
  final int employeeCount;
  final String sharedSheetId;
  final int totalScans;
}
