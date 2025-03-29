// Mocks generated by Mockito 5.4.5 from annotations
// in bond_app/test/features/auth/presentation/bloc/auth_bloc_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:bond_app/features/auth/data/models/user_model.dart' as _i2;
import 'package:bond_app/features/auth/domain/repositories/auth_repository.dart'
    as _i3;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeUserModel_0 extends _i1.SmartFake implements _i2.UserModel {
  _FakeUserModel_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [AuthRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockAuthRepository extends _i1.Mock implements _i3.AuthRepository {
  MockAuthRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Stream<_i2.UserModel?> get user => (super.noSuchMethod(
        Invocation.getter(#user),
        returnValue: _i4.Stream<_i2.UserModel?>.empty(),
      ) as _i4.Stream<_i2.UserModel?>);

  @override
  _i4.Stream<bool> get authStateChanges => (super.noSuchMethod(
        Invocation.getter(#authStateChanges),
        returnValue: _i4.Stream<bool>.empty(),
      ) as _i4.Stream<bool>);

  @override
  _i4.Future<_i2.UserModel> signInWithEmailAndPassword(
    String? email,
    String? password,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #signInWithEmailAndPassword,
          [
            email,
            password,
          ],
        ),
        returnValue: _i4.Future<_i2.UserModel>.value(_FakeUserModel_0(
          this,
          Invocation.method(
            #signInWithEmailAndPassword,
            [
              email,
              password,
            ],
          ),
        )),
      ) as _i4.Future<_i2.UserModel>);

  @override
  _i4.Future<_i2.UserModel> signUpWithEmailAndPassword(
    String? email,
    String? password,
    String? displayName,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #signUpWithEmailAndPassword,
          [
            email,
            password,
            displayName,
          ],
        ),
        returnValue: _i4.Future<_i2.UserModel>.value(_FakeUserModel_0(
          this,
          Invocation.method(
            #signUpWithEmailAndPassword,
            [
              email,
              password,
              displayName,
            ],
          ),
        )),
      ) as _i4.Future<_i2.UserModel>);

  @override
  _i4.Future<_i2.UserModel> signInWithGoogle() => (super.noSuchMethod(
        Invocation.method(
          #signInWithGoogle,
          [],
        ),
        returnValue: _i4.Future<_i2.UserModel>.value(_FakeUserModel_0(
          this,
          Invocation.method(
            #signInWithGoogle,
            [],
          ),
        )),
      ) as _i4.Future<_i2.UserModel>);

  @override
  _i4.Future<_i2.UserModel> signInWithApple() => (super.noSuchMethod(
        Invocation.method(
          #signInWithApple,
          [],
        ),
        returnValue: _i4.Future<_i2.UserModel>.value(_FakeUserModel_0(
          this,
          Invocation.method(
            #signInWithApple,
            [],
          ),
        )),
      ) as _i4.Future<_i2.UserModel>);

  @override
  _i4.Future<void> sendPasswordResetEmail(String? email) => (super.noSuchMethod(
        Invocation.method(
          #sendPasswordResetEmail,
          [email],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> signOut() => (super.noSuchMethod(
        Invocation.method(
          #signOut,
          [],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> sendEmailVerification() => (super.noSuchMethod(
        Invocation.method(
          #sendEmailVerification,
          [],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<_i2.UserModel> updateUserProfile(_i2.UserModel? user) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateUserProfile,
          [user],
        ),
        returnValue: _i4.Future<_i2.UserModel>.value(_FakeUserModel_0(
          this,
          Invocation.method(
            #updateUserProfile,
            [user],
          ),
        )),
      ) as _i4.Future<_i2.UserModel>);

  @override
  _i4.Future<void> deleteAccount() => (super.noSuchMethod(
        Invocation.method(
          #deleteAccount,
          [],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);
}
