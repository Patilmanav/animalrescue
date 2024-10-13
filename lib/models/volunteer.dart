class Volunteer {
  final String name;
  final String email;
  final dynamic id; // Use the appropriate type if known
  final dynamic status; // Use the appropriate type if known
  final dynamic phone; // Use the appropriate type if known

  // Constructor with required parameters
  Volunteer({
    required this.name,
    required this.email,
    required this.id, // Initialize id here
    required this.status,
    required this.phone, // Initialize status here
  });
}
