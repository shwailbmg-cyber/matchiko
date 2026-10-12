/// Which UI a signed-in user gets. Decided by the server (`public.my_role()`),
/// never by the client.
enum UserRole {
  player,
  manager;

  static UserRole fromDb(String v) => UserRole.values.byName(v);
}
