part of 'admin_bloc.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();
  @override
  List<Object?> get props => [];
}

// ── Load / refresh ────────────────────────────────────────────────────────────

class AdminLoaded extends AdminEvent {
  const AdminLoaded();
}

class AdminRefreshRequested extends AdminEvent {
  const AdminRefreshRequested();
}

// ── User CRUD ─────────────────────────────────────────────────────────────────

class AdminUserCreateRequested extends AdminEvent {
  const AdminUserCreateRequested({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    this.role = 'user',
    this.phone,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String role;
  final String? phone;

  @override
  List<Object?> get props => [email];
}

class AdminUserUpdateRequested extends AdminEvent {
  const AdminUserUpdateRequested({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.role,
    this.phone,
  });

  final String id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? role;
  final String? phone;

  @override
  List<Object?> get props => [id];
}

class AdminUserDeleteRequested extends AdminEvent {
  const AdminUserDeleteRequested(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

class AdminUserToggleRequested extends AdminEvent {
  const AdminUserToggleRequested(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

class AdminUserPasswordResetRequested extends AdminEvent {
  const AdminUserPasswordResetRequested({required this.id, required this.newPassword});
  final String id;
  final String newPassword;
  @override
  List<Object?> get props => [id];
}

class AdminUserSubscriptionsRequested extends AdminEvent {
  const AdminUserSubscriptionsRequested(this.userId);
  final String userId;
  @override
  List<Object?> get props => [userId];
}

// ── Service CRUD ──────────────────────────────────────────────────────────────

class AdminServiceCreateRequested extends AdminEvent {
  const AdminServiceCreateRequested({
    required this.name,
    required this.defaultAmount,
    required this.billingCycle,
    this.description,
    this.categoryId,
    this.logoFile,
  });

  final String name;
  final double defaultAmount;
  final String billingCycle;
  final String? description;
  final int? categoryId;
  final File? logoFile;

  @override
  List<Object?> get props => [name];
}

class AdminServiceUpdateRequested extends AdminEvent {
  const AdminServiceUpdateRequested({
    required this.id,
    this.name,
    this.defaultAmount,
    this.billingCycle,
    this.description,
    this.categoryId,
    this.logoFile,
  });

  final int id;
  final String? name;
  final double? defaultAmount;
  final String? billingCycle;
  final String? description;
  final int? categoryId;
  final File? logoFile;

  @override
  List<Object?> get props => [id];
}

class AdminServiceDeleteRequested extends AdminEvent {
  const AdminServiceDeleteRequested(this.id);
  final int id;
  @override
  List<Object?> get props => [id];
}

// ── Misc ──────────────────────────────────────────────────────────────────────

class AdminActionErrorCleared extends AdminEvent {
  const AdminActionErrorCleared();
}
