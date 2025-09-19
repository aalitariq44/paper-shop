import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج المستخدم
class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final String? address;
  final String? profileImageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isProfileComplete; // هل الملف الشخصي مكتمل
  final String? fcmToken; // رمز الإشعارات

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.address,
    this.profileImageUrl,
    this.createdAt,
    this.updatedAt,
    this.isProfileComplete = false,
    this.fcmToken,
  });

  /// إنشاء UserModel من بيانات Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      phoneNumber: data['phoneNumber'],
      address: data['address'],
      profileImageUrl: data['profileImageUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      isProfileComplete: data['isProfileComplete'] ?? false,
      fcmToken: data['fcmToken'],
    );
  }

  /// إنشاء UserModel من Map
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      displayName: map['displayName'],
      phoneNumber: map['phoneNumber'],
      address: map['address'],
      profileImageUrl: map['profileImageUrl'],
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      isProfileComplete: map['isProfileComplete'] ?? false,
      fcmToken: map['fcmToken'],
    );
  }

  /// تحويل UserModel إلى Map
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'address': address,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isProfileComplete': isProfileComplete,
      'fcmToken': fcmToken,
    };
  }

  /// نسخ UserModel مع تعديل بعض القيم
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? address,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isProfileComplete,
    String? fcmToken,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  /// التحقق من اكتمال الملف الشخصي
  bool get hasCompleteProfile {
    return displayName != null &&
        displayName!.isNotEmpty &&
        phoneNumber != null &&
        phoneNumber!.isNotEmpty &&
        address != null &&
        address!.isNotEmpty;
  }

  /// الحصول على الاسم المختصر للعرض
  String get shortDisplayName {
    if (displayName != null && displayName!.isNotEmpty) {
      return displayName!;
    }
    return email.split('@').first;
  }

  /// الحصول على الأحرف الأولى من الاسم
  String get initials {
    if (displayName != null && displayName!.isNotEmpty) {
      final names = displayName!.split(' ');
      if (names.length >= 2) {
        return '${names.first[0]}${names.last[0]}'.toUpperCase();
      } else {
        return displayName![0].toUpperCase();
      }
    }
    return email[0].toUpperCase();
  }

  /// التحقق من صحة رقم الهاتف السعودي
  bool get hasValidPhoneNumber {
    if (phoneNumber == null || phoneNumber!.isEmpty) return false;

    // تنظيف رقم الهاتف
    final cleanPhone = phoneNumber!.replaceAll(RegExp(r'[^\d+]'), '');

    // التحقق من الأنماط المختلفة للأرقام السعودية
    final patterns = [
      RegExp(r'^05\d{8}$'), // 05xxxxxxxx
      RegExp(r'^\+9665\d{8}$'), // +9665xxxxxxxx
      RegExp(r'^9665\d{8}$'), // 9665xxxxxxxx
    ];

    return patterns.any((pattern) => pattern.hasMatch(cleanPhone));
  }

  /// تنسيق رقم الهاتف للعرض
  String get formattedPhoneNumber {
    if (phoneNumber == null || phoneNumber!.isEmpty) return '';

    final cleanPhone = phoneNumber!.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanPhone.startsWith('05') && cleanPhone.length == 10) {
      return '${cleanPhone.substring(0, 3)} ${cleanPhone.substring(3, 6)} ${cleanPhone.substring(6)}';
    }

    return phoneNumber!;
  }

  @override
  String toString() {
    return 'UserModel{uid: $uid, email: $email, displayName: $displayName, isProfileComplete: $isProfileComplete}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
