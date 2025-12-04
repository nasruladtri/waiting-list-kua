class MarriageApplication {
  final String id;
  final String userId;
  final String status;
  final PersonData groomData;
  final PersonData brideData;
  final DocumentData documents;
  final String? rejectionReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MarriageApplication({
    required this.id,
    required this.userId,
    required this.status,
    required this.groomData,
    required this.brideData,
    required this.documents,
    this.rejectionReason,
    this.createdAt,
    this.updatedAt,
  });

  factory MarriageApplication.fromMap(String id, Map<String, dynamic> map) {
    return MarriageApplication(
      id: id,
      userId: map['userId'] ?? '',
      status: map['status'] ?? 'created',
      groomData: PersonData.fromMap(map['groomData'] ?? {}),
      brideData: PersonData.fromMap(map['brideData'] ?? {}),
      documents: DocumentData.fromMap(map['documents'] ?? {}),
      rejectionReason: map['rejectionReason'],
      createdAt: map['createdAt']?.toDate(),
      updatedAt: map['updatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'status': status,
      'groomData': groomData.toMap(),
      'brideData': brideData.toMap(),
      'documents': documents.toMap(),
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
    };
  }

  String get statusText {
    switch (status) {
      case 'created':
        return 'Menunggu Proses';
      case 'processed':
        return 'Sedang Diproses';
      case 'validated':
        return 'Tervalidasi';
      case 'finished':
        return 'Selesai';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }
}

class PersonData {
  final String name;
  final String nik;
  final DateTime? birthDate;
  final String birthPlace;
  final String address;
  final String religion;
  final String occupation;
  final String fatherName;
  final String motherName;

  PersonData({
    required this.name,
    required this.nik,
    this.birthDate,
    required this.birthPlace,
    required this.address,
    required this.religion,
    required this.occupation,
    required this.fatherName,
    required this.motherName,
  });

  factory PersonData.fromMap(Map<String, dynamic> map) {
    return PersonData(
      name: map['name'] ?? '',
      nik: map['nik'] ?? '',
      birthDate: map['birthDate']?.toDate(),
      birthPlace: map['birthPlace'] ?? '',
      address: map['address'] ?? '',
      religion: map['religion'] ?? '',
      occupation: map['occupation'] ?? '',
      fatherName: map['fatherName'] ?? '',
      motherName: map['motherName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'nik': nik,
      'birthDate': birthDate,
      'birthPlace': birthPlace,
      'address': address,
      'religion': religion,
      'occupation': occupation,
      'fatherName': fatherName,
      'motherName': motherName,
    };
  }
}

class DocumentData {
  final String? groomKK;
  final String? groomAkta;
  final String? brideKK;
  final String? brideAkta;
  final String? photo;

  DocumentData({
    this.groomKK,
    this.groomAkta,
    this.brideKK,
    this.brideAkta,
    this.photo,
  });

  factory DocumentData.fromMap(Map<String, dynamic> map) {
    return DocumentData(
      groomKK: map['groomKK'],
      groomAkta: map['groomAkta'],
      brideKK: map['brideKK'],
      brideAkta: map['brideAkta'],
      photo: map['photo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (groomKK != null) 'groomKK': groomKK,
      if (groomAkta != null) 'groomAkta': groomAkta,
      if (brideKK != null) 'brideKK': brideKK,
      if (brideAkta != null) 'brideAkta': brideAkta,
      if (photo != null) 'photo': photo,
    };
  }

  bool get isComplete {
    return groomKK != null &&
        groomAkta != null &&
        brideKK != null &&
        brideAkta != null &&
        photo != null;
  }
}
