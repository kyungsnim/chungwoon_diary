import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_helpers/firebase_helpers.dart';

class SaturDayQuestionModel {
  String id;
  String firstQuestion; // 1 질문
  DateTime questionDate; // 질문 일자

  SaturDayQuestionModel({ this.id,
    this.firstQuestion,
    this.questionDate,
  });

  factory SaturDayQuestionModel.fromDS(String id, Map<String, dynamic> data) {
    return SaturDayQuestionModel(
      id: data['id'],
      firstQuestion: data['firstQuestion'],
      questionDate: data['questionDate'].toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "firstQuestion": firstQuestion,
      "questionDate": questionDate,
    };
  }

  SaturDayQuestionModel.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        firstQuestion = map['firstQuestion'],
        questionDate = map['questionDate'].toDate();

  SaturDayQuestionModel.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data());

}
