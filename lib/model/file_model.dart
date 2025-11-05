import 'package:cloud_firestore/cloud_firestore.dart';

class FileModel {
  String? fileName;
  String? fileDesc;
  Timestamp? fileAddOn;

  FileModel({this.fileName, this.fileAddOn, this.fileDesc});

  Map<String, dynamic> toMap() {
    return {
      'file_name': fileName,
      'file_add_on': fileAddOn,
      'file_description': fileDesc,
    };
  }

  static FileModel fromMap(Map<String, dynamic> map) {
    return FileModel(
      fileName: map['file_name'],
      fileAddOn: map['file_add_on'],
      fileDesc: map['file_description'],
    );
  }
}
