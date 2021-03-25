import 'package:church_diary_app/model/DiaryModel.dart';
import 'package:church_diary_app/model/WeekDayQuestionModel.dart';
import 'package:church_diary_app/view/WriteDiaryPage.dart';
import 'package:church_diary_app/widget/CustomAppBar.dart';
import 'package:church_diary_app/widget/DefaultButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:toast/toast.dart';

import 'MainPage.dart';
import 'MainPage.dart';
import 'AddQuestionPage.dart';

class QuestionCalendarPage extends StatefulWidget {
  @override
  _QuestionCalendarPageState createState() => _QuestionCalendarPageState();
}

class _QuestionCalendarPageState extends State<QuestionCalendarPage> {
  CalendarController _calendarController;
  Map<DateTime, List<dynamic>> _events = {};
  List<dynamic> _selectedEvents = [];

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
  }

  void _onDaySelected(day, events, List e) {
    setState(() {
      _selectedEvents = events;
    });
  }

  Map<DateTime, List<dynamic>> _groupQuestions(List<WeekDayQuestionModel> questions) {
    Map<DateTime, List<dynamic>> data = {};
    questions.forEach((question) {
      DateTime date = DateTime(question.questionDate.year,
          question.questionDate.month, question.questionDate.day, 12);
      if (data[date] == null) data[date] = [];
      data[date].add(question);
    });
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: false,
          title: Text("Question Calendar",
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
        body: currentUser != null
            ? Container(
                height: MediaQuery.of(context).size.height * 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _viewCalendar(),
                    )
                  ],
                ),
              )
            : Center(
                child: CircularProgressIndicator(
                valueColor:
                    new AlwaysStoppedAnimation<Color>(Colors.black),
                strokeWidth: 10,
              )),
        floatingActionButton: currentUser != null
            // ? currentUser.role == 'admin'
            ? FloatingActionButton(
                backgroundColor: Colors.black,
                child: Icon(Icons.add),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddQuestionPage()));
                },
              )
            : Container()
        // : Center(
        // child: CircularProgressIndicator(
        //   valueColor:
        //   new AlwaysStoppedAnimation<Color>(Colors.black),
        //   strokeWidth: 10,
        // )
        );
    // );
  }

  Widget _viewCalendar() {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        // gradient: LinearGradient(colors: [
        //   Colors.blueGrey.withOpacity(0.1),
        //   Colors.grey.withOpacity(0.1)
        // ]),
      ),
      child: StreamBuilder<List<WeekDayQuestionModel>>(
          stream: FirebaseFirestore.instance
              .collection('question')
              .snapshots()
              .map((list) => list.docs
                  .map((doc) => WeekDayQuestionModel.fromDS(doc.id, doc.data()))
                  .toList()),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                  child: CircularProgressIndicator(
                valueColor:
                    new AlwaysStoppedAnimation<Color>(Colors.black),
                strokeWidth: 10,
              ));
            } else {
              List<WeekDayQuestionModel> allQuestions = snapshot.data;
              if (allQuestions.isNotEmpty) {
                _events = _groupQuestions(allQuestions);
              }
            }
            return ListView(children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _events != null
                      ? TableCalendar(
                          // locale: 'ko_KR',
                          events: _events,
                          initialCalendarFormat: CalendarFormat.month,
                          calendarStyle: CalendarStyle(
                            eventDayStyle: TextStyle(fontFamily: 'Nanum', color: Colors.black),
                            markersColor: Colors.grey,
                            markersMaxAmount: 1,
                            weekdayStyle: TextStyle(fontFamily: 'Nanum', color: Colors.black),
                            highlightToday: true,
                            todayColor: Colors.grey.withOpacity(0.3),
                            todayStyle:
                                TextStyle(fontFamily: 'Nanum', color: Colors.white, fontSize: 15),
                            selectedColor: Colors.redAccent,
                            selectedStyle: TextStyle(fontFamily: 'Nanum', 
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                            outsideWeekendStyle:
                                TextStyle(fontFamily: 'Nanum', color: Colors.grey.shade400),
                            outsideStyle:
                                TextStyle(fontFamily: 'Nanum', color: Colors.grey.shade400),
                            weekendStyle: TextStyle(fontFamily: 'Nanum', color: Colors.red[400]),
                            // renderDaysOfWeek: false,
                          ),
                          rowHeight: 40,
                          onDaySelected: _onDaySelected,
                          calendarController: _calendarController,
                          headerStyle: HeaderStyle(
                              leftChevronIcon: Icon(Icons.arrow_back_ios,
                                  size: 15, color: Colors.black),
                              rightChevronIcon: Icon(Icons.arrow_forward_ios,
                                  size: 15, color: Colors.black),
                              titleTextStyle: TextStyle(fontFamily: 'Nanum', 
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                              formatButtonVisible: false,
                              centerHeaderTitle: true),
                        )
                      : LinearProgressIndicator(),
                  ..._selectedEvents.map((question) => Container(
                        color: Colors.white,
                        child: ListTile(
                          tileColor: Colors.white60,
                          title: Column(
                            children: [
                              // topImage(),
                              SizedBox(height: 20),
                              questionList(
                                '1. ',
                                question.firstQuestion,
                              ),
                              SizedBox(height: 20),
                              questionList(
                                '2. ',
                                question.secondQuestion,
                              ),
                              SizedBox(height: 20),
                              questionList(
                                '3. ',
                                question.thirdQuestion,
                              ),
                              SizedBox(height: 20),
                              questionList(
                                '4. ',
                                question.fourthQuestion,
                              ),
                              SizedBox(height: 20),
                              questionList(
                                '5. ',
                                question.fifthQuestion,
                              ),
                              SizedBox(height: 40),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  InkWell(
                                    onTap: () => checkUpdatePopup(question),
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: 40,
                                      width: MediaQuery.of(context).size.width * 0.25,
                                      decoration: BoxDecoration(
                                          border: Border.symmetric(horizontal: BorderSide(color: Colors.black54, width: 0.5))
                                      ),
                                      child: Text(
                                        '수정하기',
                                        style: TextStyle(fontFamily: 'Nanum', color: Colors.black, fontSize: 20),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => checkDeletePopup(question),
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: 40,
                                      width: MediaQuery.of(context).size.width * 0.25,
                                      decoration: BoxDecoration(
                                          border: Border.symmetric(horizontal: BorderSide(color: Colors.black54, width: 0.5))
                                      ),
                                      child: Text(
                                        '삭제하기',
                                        style: TextStyle(fontFamily: 'Nanum', color: Colors.black, fontSize: 20),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onTap: () {
                            // checkCoursePopup(event);
                          },
                        ),
                      )),
                  _selectedEvents.length < 1
                      ? Container(
                          height: 100,
                          child: Column(
                            children: [
                              SizedBox(height: 20),
                              Center(
                                  child: Text(
                                '해당일자의 질문이 없습니다.',
                                    style: TextStyle(fontFamily: 'Nanum', color: Colors.black, fontSize: 20),
                              ))
                            ],
                          ))
                      : Container(),
                ],
              ),
            ]);
          }),
    );
  }

  checkUpdatePopup(question) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('질문 수정'),
            content: Text("작성된 질문을 수정하시겠습니까?",
                style: TextStyle(fontFamily: 'Nanum', color: Colors.black87)),
            actions: [
              FlatButton(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Text('확인',
                      style: TextStyle(fontFamily: 'Nanum', color: Colors.black, fontSize: 20)),
                ),
                onPressed: () async {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddQuestionPage(question: question)));
                },
              ),
              FlatButton(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Text('취소',
                      style: TextStyle(fontFamily: 'Nanum', color: Colors.grey, fontSize: 20)),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  checkDeletePopup(question) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('질문 삭제'),
            content: Text("질문을 삭제하시겠습니까?",
                style: TextStyle(fontFamily: 'Nanum', color: Colors.redAccent)),
            actions: [
              FlatButton(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Text('확인',
                      style: TextStyle(fontFamily: 'Nanum', color: Colors.black, fontSize: 20)),
                ),
                onPressed: () async {
                  // batch 생성
                  WriteBatch writeBatch = FirebaseFirestore.instance.batch();

                  // 해당 질문 삭제
                  writeBatch.delete(FirebaseFirestore.instance
                      .collection('question')
                      .doc(question.id));

                  // batch end
                  writeBatch.commit();

                  showToast("질문 삭제 완료");
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => MainPage(2)));
                },
              ),
              FlatButton(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Text('취소',
                      style: TextStyle(fontFamily: 'Nanum', color: Colors.grey, fontSize: 20)),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  questionList(number, question) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              flex: 1,
              child: Text(
                "$number $question",
                style: TextStyle(fontFamily: 'Nanum', 
                    fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ],
        ),
      ],
    );
  }

  showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }
}
