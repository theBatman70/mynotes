
abstract class AppUser {
  String? firstName;
  String? lastName;
  String? email;
  String id;

  AppUser({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
  });
}
