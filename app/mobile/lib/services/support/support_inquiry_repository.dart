import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore `support_inquiries` 문서 모델.
class SupportInquiry {
  SupportInquiry({
    required this.id,
    required this.subject,
    required this.category,
    required this.status,
    required this.body,
    required this.createdAtMs,
    required this.updatedAtMs,
    this.answeredAtMs,
  });

  final String id;
  final String subject;
  final String category;
  final String status;
  final String body;
  final int createdAtMs;
  final int updatedAtMs;
  final int? answeredAtMs;

  factory SupportInquiry.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return SupportInquiry.fromMap(doc.id, data);
  }

  factory SupportInquiry.fromMap(String id, Map<String, dynamic> data) {
    return SupportInquiry(
      id: id,
      subject: data['subject'] as String? ?? '',
      category: data['category'] as String? ?? 'other',
      status: data['status'] as String? ?? 'open',
      body: data['body'] as String? ?? '',
      createdAtMs: (data['createdAtMs'] as num?)?.toInt() ?? 0,
      updatedAtMs: (data['updatedAtMs'] as num?)?.toInt() ?? 0,
      answeredAtMs: (data['answeredAtMs'] as num?)?.toInt(),
    );
  }
}


/// 문의 스레드 메시지.
class SupportInquiryMessage {
  SupportInquiryMessage({
    required this.id,
    required this.authorType,
    required this.text,
    required this.createdAtMs,
  });

  final String id;
  final String authorType;
  final String text;
  final int createdAtMs;

  factory SupportInquiryMessage.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return SupportInquiryMessage(
      id: doc.id,
      authorType: data['authorType'] as String? ?? 'user',
      text: data['text'] as String? ?? '',
      createdAtMs: (data['createdAtMs'] as num?)?.toInt() ?? 0,
    );
  }
}


/// 본인 문의 Firestore 조회.
class SupportInquiryRepository {
  SupportInquiryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const _collection = 'support_inquiries';


  /// 로그인 사용자 문의 목록(최신순).
  Stream<List<SupportInquiry>> watchMyInquiries(String uid) {
    return _firestore
        .collection(_collection)
        .where('uid', isEqualTo: uid)
        .orderBy('createdAtMs', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map(SupportInquiry.fromDoc).toList(growable: false),
        );
  }


  /// 문의 단건 스트림.
  Stream<SupportInquiry?> watchInquiry(String inquiryId) {
    return _firestore.collection(_collection).doc(inquiryId).snapshots().map((snap) {
      if (!snap.exists) return null;
      final data = snap.data();
      if (data == null) return null;
      return SupportInquiry.fromMap(snap.id, data);
    });
  }


  /// 문의 메시지 스트림.
  Stream<List<SupportInquiryMessage>> watchInquiryMessages(String inquiryId) {
    return _firestore
        .collection(_collection)
        .doc(inquiryId)
        .collection('messages')
        .orderBy('createdAtMs', descending: false)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map(SupportInquiryMessage.fromDoc).toList(growable: false),
        );
  }
}
