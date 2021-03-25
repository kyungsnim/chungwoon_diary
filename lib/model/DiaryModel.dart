import 'package:cloud_firestore/cloud_firestore.dart';

class DiaryModel {
  String id;
  String writer; // 게시자 이메일
  int grade; // 게시자 또래
  String userName; // 게시자 이름
  String profileUrl; // 게시자 프로필 url
  String imageUrl; // 게시물의 이미지 url
  int randomNumber; // 게시자 프로필 url 없는 경우 보여줄...
  String firstQuestion; // 1 질문
  String secondQuestion; // 2 질문
  String thirdQuestion; // 3 질문
  String fourthQuestion; // 4 질문
  String fifthQuestion; // 5 질문
  String firstAnswer; // 1 답변
  String secondAnswer; // 2 답변
  String thirdAnswer; // 3 답변
  String fourthAnswer; // 4 답변
  String fifthAnswer; // 5 답변
  bool isCompleteToFeed; // 피드 공유여부
  DateTime summitDate; // 작성 일시

  DiaryModel({
    this.id,
    this.writer,
    this.grade,
    this.userName,
    this.profileUrl,
    this.imageUrl,
    this.randomNumber,
    this.firstQuestion,
    this.secondQuestion,
    this.thirdQuestion,
    this.fourthQuestion,
    this.fifthQuestion,
    this.firstAnswer,
    this.secondAnswer,
    this.thirdAnswer,
    this.fourthAnswer,
    this.fifthAnswer,
    this.isCompleteToFeed,
    this.summitDate,
  });

  // factory DiaryModel.fromMap(Map data) {
  //   return DiaryModel(
  //     id: data['id'],
  //     writer: data['writer'],
  //     firstQuestion: data['firstQuestion'],
  //     secondQuestion: data['secondQuestion'],
  //     thirdQuestion: data['thirdQuestion'],
  //     fourthQuestion: data['fourthQuestion'],
  //     fifthQuestion: data['fifthQuestion'],
  //     firstAnswer: data['firstAnswer'],
  //     secondAnswer: data['secondAnswer'],
  //     thirdAnswer: data['thirdAnswer'],
  //     fourthAnswer: data['fourthAnswer'],
  //     fifthAnswer: data['fifthAnswer'],
  //     summitDate: data['summitDate'].toDate(),
  //   );
  // }

  factory DiaryModel.fromDS(String id, Map<String, dynamic> data) {
    return DiaryModel(
      id: data['id'],
      writer: data['writer'],
      grade: data['grade'],
      userName: data['userName'],
      profileUrl: data['profileUrl'].toString(),
      imageUrl: data['imageUrl'],
      randomNumber: data['randomNumber'],
      firstQuestion: data['firstQuestion'],
      secondQuestion: data['secondQuestion'] != null ? data['secondQuestion'] : "",
      thirdQuestion: data['thirdQuestion'] != null ? data['thirdQuestion'] : "",
      fourthQuestion: data['fourthQuestion'] != null ? data['fourthQuestion'] : "",
      fifthQuestion: data['fifthQuestion'] != null ? data['fifthQuestion'] : "",
      firstAnswer: data['firstAnswer'],
      secondAnswer: data['secondAnswer'] != null ? data['secondAnswer'] : "",
      thirdAnswer: data['thirdAnswer'] != null ? data['thirdAnswer'] : "",
      fourthAnswer: data['fourthAnswer'] != null ? data['fourthAnswer'] : "",
      fifthAnswer: data['fifthAnswer'] != null ? data['fifthAnswer'] : "",
      isCompleteToFeed: data['isCompleteToFeed'],
      summitDate: data['summitDate'].toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "writer": writer,
      "grade": grade,
      "userName": userName,
      "profileUrl": profileUrl,
      "imageUrl": imageUrl,
      "randomNumber": randomNumber,
      "firstQuestion": firstQuestion,
      "secondQuestion": firstQuestion,
      "thirdQuestion": thirdQuestion,
      "fourthQuestion": fourthQuestion,
      "fifthQuestion": fifthQuestion,
      "firstAnswer": firstAnswer,
      "secondAnswer": firstAnswer,
      "thirdAnswer": thirdAnswer,
      "fourthAnswer": fourthAnswer,
      "fifthAnswer": fifthAnswer,
      "isCompleteToFeed": isCompleteToFeed,
      "summitDate": summitDate,
    };
  }

  DiaryModel.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        writer = map['writer'],
        grade = map['grade'],
        userName = map['userName'],
        profileUrl = map['profileUrl'],
        imageUrl = map['imageUrl'],
        randomNumber = map['randomNumber'],
        firstQuestion = map['firstQuestion'],
        secondQuestion = map['secondQuestion'],
        thirdQuestion = map['thirdQuestion'],
        fourthQuestion = map['fourthQuestion'],
        fifthQuestion = map['fifthQuestion'],
        firstAnswer = map['firstAnswer'],
        secondAnswer = map['secondAnswer'],
        thirdAnswer = map['thirdAnswer'],
        fourthAnswer = map['fourthAnswer'],
        fifthAnswer = map['fifthAnswer'],
        isCompleteToFeed = map['isCompleteToFeed'],
        summitDate = map['summitDate'].toDate();

  DiaryModel.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data());
}
