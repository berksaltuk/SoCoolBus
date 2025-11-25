import 'package:my_app/my_enum.dart';

class Document {
  final String documentId;
  final DocumentType type;
  DateTime? date = DateTime.now();
  final String description;
  final bool status;

  Document(
      {required this.documentId,
      required this.type,
      this.date,
      required this.description,
      required this.status});

  factory Document.fromJson(Map<dynamic, dynamic> json) {
    print(json);
    DocumentType t = DocumentType.license;
    if (json['documentType'] == "LICENCE") {
      t = DocumentType.license;
    } else if (json['documentType'] == "PSYCHOTECHNIC") {
      t = DocumentType.psychotechnic;
    } else if (json['documentType'] == "REGISTRATION") {
      t = DocumentType.registration;
    }
    if (json['documentDate'] == null) {
      return Document(
        documentId: json['_id'],
        type: t,
        description: json['documentNote'],
        status: json['isApproved'],
      );
    } else {
      return Document(
        documentId: json['_id'],
        type: t,
        date: DateTime.parse(json['documentDate']),
        description: json['documentNote'],
        status: json['isApproved'],
      );
    }
  }
}
