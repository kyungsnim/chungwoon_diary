import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'MainPage.dart';

class QuestionDefaultPage extends StatefulWidget {
  @override
  _QuestionDefaultPageState createState() => _QuestionDefaultPageState();
}

class _QuestionDefaultPageState extends State<QuestionDefaultPage> {
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
  final _formKey = GlobalKey<FormState>();
  final _key = GlobalKey<ScaffoldState>();
  bool processing;
  var question;
  bool firstQuestion = false;

  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
        .collection('defaultQuestion')
        .get().then((value) {
      if(value.docs != null) {
        question = value.docs[0].data();

        setState(() {
          _firstQuestion = question['firstQuestion'];
          _secondQuestion = question['secondQuestion'];
          _thirdQuestion = question['thirdQuestion'];
          _fourthQuestion = question['fourthQuestion'];
          _fifthQuestion = question['fifthQuestion'];

          _firstQuestionController = TextEditingController(text: _firstQuestion);
          _secondQuestionController = TextEditingController(text: _secondQuestion);
          _thirdQuestionController = TextEditingController(text: _thirdQuestion);
          _fourthQuestionController = TextEditingController(text: _fourthQuestion);
          _fifthQuestionController = TextEditingController(text: _fifthQuestion);
        });

        firstQuestion = false;

      } else {

        setState(() {
          _firstQuestion = "";
          _secondQuestion = "";
          _thirdQuestion = "";
          _fourthQuestion = "";
          _fifthQuestion = "";

          _firstQuestionController = TextEditingController(text: "");
          _secondQuestionController = TextEditingController(text: "");
          _thirdQuestionController = TextEditingController(text: "");
          _fourthQuestionController = TextEditingController(text: "");
          _fifthQuestionController = TextEditingController(text: "");
        });

        firstQuestion = true;
      }
    });

    processing = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: false,
        title: Text("Default Question",
            style: TextStyle(fontFamily: 'Nanum', 
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
                            style: TextStyle(fontFamily: 'Nanum', 
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
                      border:
                      Border.all(color: Colors.black.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            offset: Offset(1, 1),
                            blurRadius: 5,
                            color: Colors.white24)
                      ]),
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
                          hintStyle: TextStyle(fontFamily: 'Nanum', fontSize: 15)),
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
                            style: TextStyle(fontFamily: 'Nanum', 
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
                      border:
                      Border.all(color: Colors.black.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            offset: Offset(1, 1),
                            blurRadius: 5,
                            color: Colors.white24)
                      ]),
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
                          hintStyle: TextStyle(fontFamily: 'Nanum', fontSize: 15)),
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
                            style: TextStyle(fontFamily: 'Nanum', 
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
                      border:
                      Border.all(color: Colors.black.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            offset: Offset(1, 1),
                            blurRadius: 5,
                            color: Colors.white24)
                      ]),
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
                          hintStyle: TextStyle(fontFamily: 'Nanum', fontSize: 15)),
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
                            style: TextStyle(fontFamily: 'Nanum', 
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
                      border:
                      Border.all(color: Colors.black.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            offset: Offset(1, 1),
                            blurRadius: 5,
                            color: Colors.white24)
                      ]),
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
                          hintStyle: TextStyle(fontFamily: 'Nanum', fontSize: 15)),
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
                            style: TextStyle(fontFamily: 'Nanum', 
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
                      border:
                      Border.all(color: Colors.black.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            offset: Offset(1, 1),
                            blurRadius: 5,
                            color: Colors.white24)
                      ]),
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
                            hintStyle: TextStyle(fontFamily: 'Nanum', fontSize: 15)),
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
              processing
                  ? Center(
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(
                      Colors.black),
                  strokeWidth: 10,
                ),
              )
                  : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(30.0),
                  color: Colors.black,
                  child: MaterialButton(
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        setState(() {
                          processing = true;
                        });
                        print('>>>>>>>>>> firstQuestion : $firstQuestion');
                        var id = DateTime.now()
                            .microsecondsSinceEpoch
                            .toString();
                        await FirebaseFirestore.instance
                            .collection('defaultQuestion')
                            .doc(firstQuestion ? id : question['id']) // 최초 질문이면 id 생성하고 아니면 기존 질문 id 로 가져오기
                            .set({
                          "id": firstQuestion ? id : question['id'],
                          "firstQuestion": _firstQuestion,
                          "secondQuestion": _secondQuestion,
                          "thirdQuestion": _thirdQuestion,
                          "fourthQuestion": _fourthQuestion,
                          "fifthQuestion": _fifthQuestion,
                        });

                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MainPage(2)));
                        setState(() {
                          processing = false;
                        });
                      }
                    },
                    child: Text(
                      "질문 등록(수정)",
                      style: style.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20)
            ],
          ),
        ),
      ),
    );
  }
}