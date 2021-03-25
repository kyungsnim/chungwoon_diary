import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_helpers/firebase_helpers.dart';

class WeekDayQuestionModel {
  String id;
  String firstQuestion; // 1 질문
  String secondQuestion; // 2 질문
  String thirdQuestion; // 3 질문
  String fourthQuestion; // 4 질문
  String fifthQuestion; // 5 질문
  DateTime questionDate; // 질문 일자

  WeekDayQuestionModel({ this.id,
    this.firstQuestion,
    this.secondQuestion,
    this.thirdQuestion,
    this.fourthQuestion,
    this.fifthQuestion,
    this.questionDate,
  });

  factory WeekDayQuestionModel.fromDS(String id, Map<String, dynamic> data) {
    return WeekDayQuestionModel(
      id: data['id'],
      firstQuestion: data['firstQuestion'],
      secondQuestion: data['secondQuestion'],
      thirdQuestion: data['thirdQuestion'],
      fourthQuestion: data['fourthQuestion'],
      fifthQuestion: data['fifthQuestion'],
      questionDate: data['questionDate'].toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "firstQuestion": firstQuestion,
      "secondQuestion": secondQuestion,
      "thirdQuestion": thirdQuestion,
      "fourthQuestion": fourthQuestion,
      "fifthQuestion": fifthQuestion,
      "questionDate": questionDate,
    };
  }

  WeekDayQuestionModel.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        firstQuestion = map['firstQuestion'],
        secondQuestion = map['secondQuestion'],
        thirdQuestion = map['thirdQuestion'],
        fourthQuestion = map['fourthQuestion'],
        fifthQuestion = map['fifthQuestion'],
        questionDate = map['questionDate'].toDate();

  WeekDayQuestionModel.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data());

}
