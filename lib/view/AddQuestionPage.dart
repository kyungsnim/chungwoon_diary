import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'MainPage.dart';

class AddQuestionPage extends StatefulWidget {
  final question;

  AddQuestionPage({this.question});

  @override
  _AddQuestionPageState createState() => _AddQuestionPageState();
}

class _AddQuestionPageState extends State<AddQuestionPage> {
  TextStyle style = TextStyle(fontFamily: 'Nanum', fontSize: 20.0);
  TextEditingController _firstQuestionController;
  TextEditingController _secondQuestionController;
  TextEditingController _thirdQuestionController;
  TextEditingController _fourthQuestionController;
  TextEditingController _fifthQuestionController;
  var _firstQuestion;
  var _secondQuestion;
  var _thirdQuestion;
  var _fourthQuestion;
  var _fifthQuestion;
  DateTime _questionDate;
  final _formKey = GlobalKey<FormState>();
  final _key = GlobalKey<ScaffoldState>();
  bool processing;
  var question;
  bool firstQuestion = false;

  @override
  void initState() {
    super.initState();
    _questionDate = DateTime.now();

    if (widget.question != null) {
      FirebaseFirestore.instance
          .collection('question')
          .doc(widget.question.id)
          .get()
          .then((value) {
        if (value.exists) {
          question = value.data();

          setState(() {
            _firstQuestion = question['firstQuestion'];
            _secondQuestion = question['secondQuestion'];
            _thirdQuestion = question['thirdQuestion'];
            _fourthQuestion = question['fourthQuestion'];
            _fifthQuestion = question['fifthQuestion'];
            _questionDate = question['questionDate'].toDate();

            _firstQuestionController =
                TextEditingController(text: _firstQuestion);
            _secondQuestionController =
                TextEditingController(text: _secondQuestion);
            _thirdQuestionController =
                TextEditingController(text: _thirdQuestion);
            _fourthQuestionController =
                TextEditingController(text: _fourthQuestion);
            _fifthQuestionController =
                TextEditingController(text: _fifthQuestion);
          });

          firstQuestion = false;
        }
      });
    } else {
      FirebaseFirestore.instance
          .collection('defaultQuestion')
          .get().then((value) {
        if (value.docs.length > 0) {
          question = value.docs[0].data();
          setState(() {
            _firstQuestion = question['firstQuestion'];
            _secondQuestion = question['secondQuestion'];
            _thirdQuestion = question['thirdQuestion'];
            _fourthQuestion = question['fourthQuestion'];
            _fifthQuestion = "";
            _questionDate = DateTime.now();

            _firstQuestionController =
                TextEditingController(text: _firstQuestion);
            _secondQuestionController =
                TextEditingController(text: _secondQuestion);
            _thirdQuestionController =
                TextEditingController(text: _thirdQuestion);
            _fourthQuestionController =
                TextEditingController(text: _fourthQuestion);
            _fifthQuestionController =
                TextEditingController(text: "");
          });
        }
      });

      firstQuestion = true;
    }
    processing = false;
  }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: false,
          title: Text(firstQuestion ? "Add Question" : "Edit Question",
              style: TextStyle(
                  fontFamily: 'Nanum',
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          elevation: 0,
          leading: IconButton(
            padding: EdgeInsets.only(left: 10),
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_outlined,
              color: Colors.black,
              size: 25,
            ),
            iconSize: 30,
          ),
        ),
        key: _key,
        body: Form(
          key: _formKey,
          child: Container(
            alignment: Alignment.center,
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                          child: Text('질문 1',
                              style: TextStyle(
                                  fontFamily: 'Nanum',
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
                SizedBox(height: 3),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border.symmetric(
                            horizontal: BorderSide(
                                color: Colors.black54, width: 0.5))),
                    width: MediaQuery.of(context).size.width * 1,
                    height: MediaQuery.of(context).size.height * 0.1,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        maxLines: null,
                        // expands: true,
                        controller: _firstQuestionController,
                        cursorColor: Colors.black,
                        validator: (val) {
                          if (val.isEmpty) {
                            return '내용을 입력하세요';
                          } else {
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            // hintText: '내용 입력',
                            hintStyle:
                            TextStyle(fontFamily: 'Nanum', fontSize: 15)),
                        onChanged: (val) {
                          setState(() {
                            _firstQuestion = val;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                          child: Text('질문 2',
                              style: TextStyle(
                                  fontFamily: 'Nanum',
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
                SizedBox(height: 3),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border.symmetric(
                            horizontal: BorderSide(
                                color: Colors.black54, width: 0.5))),
                    width: MediaQuery.of(context).size.width * 1,
                    height: MediaQuery.of(context).size.height * 0.1,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        // expands: true,
                        controller: _secondQuestionController,
                        cursorColor: Colors.black,
                        validator: (val) {
                          if (val.isEmpty) {
                            return '내용을 입력하세요';
                          } else {
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            // hintText: '내용 입력',
                            hintStyle:
                            TextStyle(fontFamily: 'Nanum', fontSize: 15)),
                        onChanged: (val) {
                          setState(() {
                            _secondQuestion = val;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                          child: Text('질문 3',
                              style: TextStyle(
                                  fontFamily: 'Nanum',
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
                SizedBox(height: 3),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border.symmetric(
                            horizontal: BorderSide(
                                color: Colors.black54, width: 0.5))),
                    width: MediaQuery.of(context).size.width * 1,
                    height: MediaQuery.of(context).size.height * 0.1,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        // expands: true,
                        controller: _thirdQuestionController,
                        cursorColor: Colors.black,
                        validator: (val) {
                          if (val.isEmpty) {
                            return '내용을 입력하세요';
                          } else {
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            // hintText: '내용 입력',
                            hintStyle:
                            TextStyle(fontFamily: 'Nanum', fontSize: 15)),
                        onChanged: (val) {
                          setState(() {
                            _thirdQuestion = val;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                          child: Text('질문 4',
                              style: TextStyle(
                                  fontFamily: 'Nanum',
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
                SizedBox(height: 3),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border.symmetric(
                            horizontal: BorderSide(
                                color: Colors.black54, width: 0.5))),
                    width: MediaQuery.of(context).size.width * 1,
                    height: MediaQuery.of(context).size.height * 0.1,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        // expands: true,
                        controller: _fourthQuestionController,
                        cursorColor: Colors.black,
                        validator: (val) {
                          if (val.isEmpty) {
                            return '내용을 입력하세요';
                          } else {
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            // hintText: '내용 입력',
                            hintStyle:
                            TextStyle(fontFamily: 'Nanum', fontSize: 15)),
                        onChanged: (val) {
                          setState(() {
                            _fourthQuestion = val;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                          child: Text('질문 5',
                              style: TextStyle(
                                  fontFamily: 'Nanum',
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
                SizedBox(height: 3),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border.symmetric(
                            horizontal: BorderSide(
                                color: Colors.black54, width: 0.5))),
                    width: MediaQuery.of(context).size.width * 1,
                    height: MediaQuery.of(context).size.height * 0.1,
                    child: Stack(children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          // expands: true,
                          controller: _fifthQuestionController,
                          cursorColor: Colors.black,
                          validator: (val) {
                            if (val.isEmpty) {
                              return '내용을 입력하세요';
                            } else {
                              return null;
                            }
                          },
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: _fifthQuestion,
                              hintStyle:
                              TextStyle(fontFamily: 'Nanum', fontSize: 15)),
                          onChanged: (val) {
                            setState(() {
                              _fifthQuestion = val;
                            });
                          },
                        ),
                      ),
                    ]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                          child: Text('질문 일자',
                              style: TextStyle(
                                  fontFamily: 'Nanum',
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
                SizedBox(height: 3),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.symmetric(
                            horizontal: BorderSide(
                                color: Colors.black54, width: 0.5))),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: ListTile(
                            title: Row(
                              children: [
                                Text(
                                    "${_questionDate.year}-${_questionDate
                                        .month}-${_questionDate.day}"),
                                SizedBox(width: 10),
                                Icon(Icons.calendar_today, color: Colors.black)
                              ],
                            ),
                            onTap: () async {
                              DateTime picked = (await showDatePicker(
                                  context: context,
                                  initialDate: _questionDate,
                                  firstDate: DateTime(_questionDate.year - 5),
                                  lastDate: DateTime(_questionDate.year + 5)));
                              if (picked != null) {
                                setState(() {
                                  _questionDate = picked;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                processing
                    ? Center(
                  child: CircularProgressIndicator(
                    valueColor:
                    new AlwaysStoppedAnimation<Color>(Colors.black),
                    strokeWidth: 10,
                  ),
                )
                    : GestureDetector(
                    onTap: () {
                      addQuestion();
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: 40,
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                          border: Border.symmetric(
                              horizontal: BorderSide(
                                  color: Colors.black54, width: 0.5))),
                      child: Text(
                          '질문 등록',
                          style: TextStyle(
                            fontFamily: 'Nanum',
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,)
                      ),
                    )),
                SizedBox(height: 20)
              ],
            ),
          ),
        ),
      );
    }

    addQuestion() async {
      if (_formKey.currentState.validate()) {
        setState(() {
          processing = true;
        });
        print(
            '>>>>>>>>>> firstQuestion : $firstQuestion');
        var id = DateTime
            .now()
            .microsecondsSinceEpoch
            .toString();
        await FirebaseFirestore.instance
            .collection('question')
            .doc(firstQuestion
            ? id
            : question[
        'id']) // 최초 질문이면 id 생성하고 아니면 기존 질문 id 로 가져오기
        // .doc(id) // 최초 질문이면 id 생성하고 아니면 기존 질문 id 로 가져오기
            .set({
          "id": firstQuestion ? id : question['id'],
          "firstQuestion": _firstQuestion,
          "secondQuestion": _secondQuestion,
          "thirdQuestion": _thirdQuestion,
          "fourthQuestion": _fourthQuestion,
          "fifthQuestion": _fifthQuestion,
          "questionDate": _questionDate,
        });

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => MainPage(2)));
        setState(() {
          processing = false;
        });
      }
    }
  }
