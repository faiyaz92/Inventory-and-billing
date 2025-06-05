import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:requirment_gathering_app/core_module/services/firestore_provider.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart'
    as uInfo;
import 'package:requirment_gathering_app/super_admin_module/data/user_info_dto.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/roles.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'account_repository.dart';

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:requirment_gathering_app/core_module/services/firestore_provider.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart' as uInfo;
import 'package:requirment_gathering_app/super_admin_module/data/user_info_dto.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/roles.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'account_repository.dart';

class AccountRepositoryImpl implements AccountRepository {
  final FirebaseAuth _firebaseAuth;
  final IFirestorePathProvider _firestorePathProvider;

  AccountRepositoryImpl(this._firebaseAuth, this._firestorePathProvider);

  @override
  Future<UserInfoDto> signIn(String email, String password) async {
    UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    String userId = userCredential.user!.uid;

    DocumentSnapshot superAdminSnapshot = await _firestorePathProvider.superAdminPath.doc(userId).get();

    if (superAdminSnapshot.exists) {
      UserInfoDto userInfo = UserInfoDto(
        userId: userId,
        email: email,
        role: Role.SUPER_ADMIN,
        companyId: null,
        name: '',
        userName: '',
      );

      await _storeUserInfo(uInfo.UserInfo.fromDto(userInfo));
      return userInfo;
    }

    QuerySnapshot query = await _firestorePathProvider
        .getCommonUsersPath()
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception("User not found in any Tenant Company.");
    }

    UserInfoDto userInfo = UserInfoDto.fromMap(query.docs.first.data() as Map<String, dynamic>);
    await _storeUserInfo(uInfo.UserInfo.fromDto(userInfo));
    return userInfo;
  }

  @override
  Future<void> _storeUserInfo(uInfo.UserInfo userInfo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userInfoJson = jsonEncode(userInfo.toJson());
    await prefs.setString('userInfo', userInfoJson);
  }

  @override
  Future<uInfo.UserInfo?> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userInfoJson = prefs.getString('userInfo');
    if (userInfoJson == null) return null;
    Map<String, dynamic> userInfoMap = jsonDecode(userInfoJson);
    return uInfo.UserInfo.fromJson(userInfoMap);
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  @override
  bool isUserLoggedIn() {
    return _firebaseAuth.currentUser != null;
  }

  @override
  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}

