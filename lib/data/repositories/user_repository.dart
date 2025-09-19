import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paper_shop/data/models/user_model.dart';
import 'package:paper_shop/core/services/auth_service.dart';

/// مستودع بيانات المستخدمين
class UserRepository {
  static UserRepository? _instance;

  UserRepository._();

  static UserRepository get instance {
    _instance ??= UserRepository._();
    return _instance!;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService.instance;

  // ========== عمليات المستخدم الحالي ==========

  /// الحصول على بيانات المستخدم الحالي
  Future<UserModel?> getCurrentUser() async {
    try {
      if (!_authService.isSignedIn) return null;

      final doc = await _firestore
          .collection('users')
          .doc(_authService.currentUser!.uid)
          .get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('❌ Error getting current user: $e');
      return null;
    }
  }

  /// stream للمستخدم الحالي
  Stream<UserModel?> getCurrentUserStream() {
    if (!_authService.isSignedIn) {
      return Stream.value(null);
    }

    return _firestore
        .collection('users')
        .doc(_authService.currentUser!.uid)
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return UserModel.fromFirestore(doc);
          }
          return null;
        })
        .handleError((error) {
          print('❌ Error in current user stream: $error');
          return null;
        });
  }

  /// تحديث بيانات المستخدم الحالي
  Future<UserModel?> updateCurrentUser({
    String? displayName,
    String? phoneNumber,
    String? address,
    String? profileImageUrl,
  }) async {
    try {
      if (!_authService.isSignedIn) return null;

      final userId = _authService.currentUser!.uid;
      final userRef = _firestore.collection('users').doc(userId);

      // الحصول على البيانات الحالية
      final currentDoc = await userRef.get();
      if (!currentDoc.exists) return null;

      final currentUser = UserModel.fromFirestore(currentDoc);

      // إعداد البيانات للتحديث
      final updateData = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (displayName != null) updateData['displayName'] = displayName;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (address != null) updateData['address'] = address;
      if (profileImageUrl != null)
        updateData['profileImageUrl'] = profileImageUrl;

      // إنشاء المستخدم المحدث للتحقق من اكتمال الملف
      final updatedUser = currentUser.copyWith(
        displayName: displayName,
        phoneNumber: phoneNumber,
        address: address,
        profileImageUrl: profileImageUrl,
        updatedAt: DateTime.now(),
      );

      // تحديث حالة اكتمال الملف الشخصي
      updateData['isProfileComplete'] = updatedUser.hasCompleteProfile;

      // تحديث البيانات في Firestore
      await userRef.update(updateData);

      // إرجاع البيانات المحدثة
      final updatedDoc = await userRef.get();
      return UserModel.fromFirestore(updatedDoc);
    } catch (e) {
      print('❌ Error updating current user: $e');
      return null;
    }
  }

  /// إنشاء أو تحديث مستخدم
  Future<UserModel?> createOrUpdateUser(UserModel user) async {
    try {
      final userRef = _firestore.collection('users').doc(user.uid);

      // التحقق من وجود المستخدم
      final doc = await userRef.get();

      if (doc.exists) {
        // تحديث البيانات الأساسية فقط
        await userRef.update({
          'email': user.email,
          'displayName': user.displayName,
          'profileImageUrl': user.profileImageUrl,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      } else {
        // إنشاء مستخدم جديد
        await userRef.set(user.toMap());
      }

      // إرجاع البيانات المحدثة
      final updatedDoc = await userRef.get();
      return UserModel.fromFirestore(updatedDoc);
    } catch (e) {
      print('❌ Error creating/updating user: $e');
      return null;
    }
  }

  /// التحقق من اكتمال الملف الشخصي
  Future<bool> isProfileComplete() async {
    try {
      final user = await getCurrentUser();
      return user?.hasCompleteProfile ?? false;
    } catch (e) {
      print('❌ Error checking profile completion: $e');
      return false;
    }
  }

  /// الحصول على المعلومات الأساسية للمستخدم
  Future<Map<String, dynamic>?> getUserBasicInfo() async {
    try {
      final user = await getCurrentUser();
      if (user == null) return null;

      return {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'profileImageUrl': user.profileImageUrl,
        'isProfileComplete': user.hasCompleteProfile,
      };
    } catch (e) {
      print('❌ Error getting user basic info: $e');
      return null;
    }
  }

  // ========== عمليات على مستخدمين آخرين (للإدارة) ==========

  /// الحصول على مستخدم بواسطة ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('❌ Error getting user by ID: $e');
      return null;
    }
  }

  /// stream لمستخدم معين
  Stream<UserModel?> getUserByIdStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return UserModel.fromFirestore(doc);
          }
          return null;
        })
        .handleError((error) {
          print('❌ Error in user by ID stream: $error');
          return null;
        });
  }

  /// الحصول على جميع المستخدمين (للإدارة)
  Future<List<UserModel>> getAllUsers({
    int? limit,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection('users')
          .orderBy('createdAt', descending: true);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Error getting all users: $e');
      return [];
    }
  }

  /// البحث عن المستخدمين
  Future<List<UserModel>> searchUsers(String searchTerm, {int? limit}) async {
    try {
      Query query = _firestore.collection('users');

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      // فلترة النتائج محلياً
      final users = querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .where((user) {
            final searchLower = searchTerm.toLowerCase();
            return user.email.toLowerCase().contains(searchLower) ||
                (user.displayName?.toLowerCase().contains(searchLower) ??
                    false) ||
                (user.phoneNumber?.contains(searchTerm) ?? false);
          })
          .toList();

      return users;
    } catch (e) {
      print('❌ Error searching users: $e');
      return [];
    }
  }

  /// الحصول على المستخدمين حسب حالة الملف الشخصي
  Future<List<UserModel>> getUsersByProfileStatus({
    required bool isComplete,
    int? limit,
  }) async {
    try {
      Query query = _firestore
          .collection('users')
          .where('isProfileComplete', isEqualTo: isComplete)
          .orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Error getting users by profile status: $e');
      return [];
    }
  }

  /// حذف مستخدم (للإدارة)
  Future<bool> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      return true;
    } catch (e) {
      print('❌ Error deleting user: $e');
      return false;
    }
  }

  /// تحديث FCM token للمستخدم الحالي
  Future<bool> updateFCMToken(String fcmToken) async {
    try {
      if (!_authService.isSignedIn) return false;

      await _firestore
          .collection('users')
          .doc(_authService.currentUser!.uid)
          .update({
            'fcmToken': fcmToken,
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          });

      return true;
    } catch (e) {
      print('❌ Error updating FCM token: $e');
      return false;
    }
  }

  // ========== إحصائيات المستخدمين ==========

  /// الحصول على إحصائيات المستخدمين
  Future<UserStats> getUsersStats() async {
    try {
      // العدد الإجمالي
      final totalSnapshot = await _firestore.collection('users').get();

      // المستخدمين ذوو الملفات المكتملة
      final completeProfilesSnapshot = await _firestore
          .collection('users')
          .where('isProfileComplete', isEqualTo: true)
          .get();

      // المستخدمين الجدد (آخر 30 يوم)
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final recentUsersSnapshot = await _firestore
          .collection('users')
          .where('createdAt', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
          .get();

      return UserStats(
        totalUsers: totalSnapshot.docs.length,
        completeProfiles: completeProfilesSnapshot.docs.length,
        incompleteProfiles:
            totalSnapshot.docs.length - completeProfilesSnapshot.docs.length,
        recentUsers: recentUsersSnapshot.docs.length,
      );
    } catch (e) {
      print('❌ Error getting users stats: $e');
      return UserStats.empty();
    }
  }

  /// الحصول على عدد المستخدمين المسجلين اليوم
  Future<int> getTodayRegistrations() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final snapshot = await _firestore
          .collection('users')
          .where('createdAt', isGreaterThan: Timestamp.fromDate(startOfDay))
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('❌ Error getting today registrations: $e');
      return 0;
    }
  }

  /// التحقق من وجود رقم هاتف مستخدم من قبل
  Future<bool> isPhoneNumberUsed(
    String phoneNumber, {
    String? excludeUserId,
  }) async {
    try {
      Query query = _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber);

      final snapshot = await query.get();

      // إذا كان هناك مستخدم للاستبعاد (في حالة التحديث)
      if (excludeUserId != null) {
        return snapshot.docs.any((doc) => doc.id != excludeUserId);
      }

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('❌ Error checking phone number usage: $e');
      return false;
    }
  }

  /// إعادة تعيين إعدادات المستخدم
  Future<bool> resetUserSettings() async {
    try {
      if (!_authService.isSignedIn) return false;

      await _firestore
          .collection('users')
          .doc(_authService.currentUser!.uid)
          .update({
            'fcmToken': FieldValue.delete(),
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          });

      return true;
    } catch (e) {
      print('❌ Error resetting user settings: $e');
      return false;
    }
  }
}

// ========== نماذج مساعدة ==========

/// إحصائيات المستخدمين
class UserStats {
  final int totalUsers;
  final int completeProfiles;
  final int incompleteProfiles;
  final int recentUsers;

  UserStats({
    required this.totalUsers,
    required this.completeProfiles,
    required this.incompleteProfiles,
    required this.recentUsers,
  });

  factory UserStats.empty() {
    return UserStats(
      totalUsers: 0,
      completeProfiles: 0,
      incompleteProfiles: 0,
      recentUsers: 0,
    );
  }

  @override
  String toString() {
    return 'UserStats{totalUsers: $totalUsers, completeProfiles: $completeProfiles, incompleteProfiles: $incompleteProfiles, recentUsers: $recentUsers}';
  }
}
