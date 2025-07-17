import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

enum AuthMethod { email, oauth }

abstract class AuthState extends Equatable {
  final bool isLoading;
  final AuthMethod? authMethod;
  
  const AuthState({this.isLoading = false, this.authMethod});
  
  AuthState copyWith({bool? isLoading, AuthMethod? authMethod});
  
  @override
  List<Object?> get props => [isLoading, authMethod];
}

class AuthInitial extends AuthState {
  const AuthInitial() : super();
  
  @override
  AuthState copyWith({bool? isLoading, AuthMethod? authMethod}) {
    return const AuthInitial();
  }
}

class AuthLoading extends AuthState {
  const AuthLoading({AuthMethod? authMethod}) : super(isLoading: true, authMethod: authMethod);
  
  @override
  AuthState copyWith({bool? isLoading, AuthMethod? authMethod}) {
    return AuthLoading(authMethod: authMethod ?? this.authMethod);
  }
}

class AuthAuthenticated extends AuthState {
  final sb.User user;
  
  const AuthAuthenticated(this.user) : super();
  
  @override
  List<Object?> get props => [user, ...super.props];
  
  @override
  AuthState copyWith({bool? isLoading, AuthMethod? authMethod}) {
    return AuthAuthenticated(user);
  }
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated() : super();
  
  @override
  AuthState copyWith({bool? isLoading, AuthMethod? authMethod}) {
    return const AuthUnauthenticated();
  }
}

class AuthError extends AuthState {
  final String message;
  
  const AuthError(this.message) : super();
  
  @override
  List<Object?> get props => [message, ...super.props];
  
  @override
  AuthState copyWith({bool? isLoading, AuthMethod? authMethod}) {
    return AuthError(message);
  }
}
