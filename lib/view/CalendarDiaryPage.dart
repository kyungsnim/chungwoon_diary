import 'package:cached_network_image/cached_network_image.dart';
import 'package:church_diary_app/model/DiaryModel.dart';
import 'package:church_diary_app/view/WriteDiaryPage.dart';
import 'package:church_diary_app/widget/CustomAppBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:toast/toast.dart';

import 'MainPage.dart';

class CalendarDiaryPage extends StatefulWidget {
  @override
  _CalendarDiaryPageState createState() => _CalendarDiaryPageState();
}

class _CalendarDiaryPageState extends State<CalendarDiaryPage> {
  CalendarController _calendarController;
  Map<DateTime, List<dynamic>> _events = {};
  List<dynamic> _selectedEvents = [];
  // var _selectedDay;

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
      // _selectedDay = day;
    });
  }

  Map<DateTime, List<dynamic>> _groupDiarys(List<DiaryModel> diarys) {
    Map<DateTime, List<dynamic>> data = {};
    diarys.forEach((diary) {
      DateTime date = DateTime(diary.summitDate.year, diary.summitDate.month,
          diary.summitDate.day, 12);
      if (data[date] == null) data[date] = [];
      data[date].add(diary);
    });
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: customAppBar('Calendar'),
      // currentUser 값 가져오는 동안은 인디케이터, 관리자승인안된자는 승인후 이용가능 페이지 보여줄 것
        body: currentUser != null
            ? currentUser.validateByAdmin != null && currentUser.validateByAdmin ? Container(
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
            : Center(child: Text('관리자 승인 후 이용 가능합니다.', style: TextStyle(fontFamily: 'Nanum', fontSize: 18),)) : Center(
                child: CircularProgressIndicator(
                valueColor:
                    new AlwaysStoppedAnimation<Color>(Colors.grey),
                strokeWidth: 10,
              )),
        floatingActionButton: currentUser != null && currentUser.validateByAdmin != null && currentUser.validateByAdmin
      // ? currentUser.role == 'admin'
            ? FloatingActionButton(
                backgroundColor: Colors.black54,
                child: Icon(Icons.edit_outlined, size: 35,),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => WriteDiaryPage()));
                },
              )
            : Container()
        // : Center(
        // child: CircularProgressIndicator(
        //   valueColor:
        //   new AlwaysStoppedAnimation<Color>(Colors.blueAccent),
        //   strokeWidth: 10,
        // )
        );
    // );
  }

  Widget _viewCalendar() {
    print('currentUser: ${currentUser.id}');
    return Container(
      margin: EdgeInsets.fromLTRB(8,8,8,8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        // gradient: LinearGradient(colors: [
        //   Colors.blueGrey.withOpacity(0.1),
        //   Colors.grey.withOpacity(0.1)
        // ]),
      ),
      child: StreamBuilder<List<DiaryModel>>(
          stream: userReference
              .doc(currentUser.id)
              .collection('diarys')
              .snapshots()
              .map((list) => list.docs
                  .map((doc) => DiaryModel.fromDS(doc.id, doc.data()))
                  .toList())
          // currentUser.role == 'admin'
          //     ? diaryReference.snapshots().map((list) => list.docs
          //     .map((doc) => DiaryModel.fromDS(doc.id, doc.data()))
          //     .toList())
          //     : diaryReference
          //     .where('courseGrade', isEqualTo: currentUser.grade)
          //     .snapshots()
          //     .map((list) => list.docs
          //     .map((doc) => DiaryModel.fromDS(doc.id, doc.data()))
          //     .toList()),
          ,
          builder: (context, snapshot) {
            print(snapshot);
            if (!snapshot.hasData) {
              return Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.green,
                valueColor:
                    new AlwaysStoppedAnimation<Color>(Colors.grey),
                strokeWidth: 10,
              ));
            } else {
              List<DiaryModel> allDiarys = snapshot.data;
              if (allDiarys.isNotEmpty) {
                _events = _groupDiarys(allDiarys);
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
                            markersMaxAmount: 10,
                            weekdayStyle: TextStyle(fontFamily: 'Nanum', color: Colors.black),
                            highlightToday: true,
                            todayColor: Colors.grey.withOpacity(0.3),
                            todayStyle:
                                TextStyle(fontFamily: 'Nanum', color: Colors.black, fontSize: 15),
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
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold),
                              formatButtonVisible: false,
                              centerHeaderTitle: true),
                        )
                      : LinearProgressIndicator(),
                  ..._selectedEvents.map((diary) => Container(
                        color: Colors.white,
                        child: ListTile(
                          tileColor: Colors.white60,
                          title: Column(
                            children: [
                              topImage(diary),
                              questionAndAnswer('1. ', diary.firstQuestion,
                                  diary.firstAnswer),
                              SizedBox(height: 10),
                              // 주말의 경우엔 1개 질문만 보이기 위해 주중인지 날짜체크해서 목록 개수 변동시켜주자.
                              diary.summitDate.weekday > 0 && diary.summitDate.weekday < 6 ?
                                  Column(
                                    children: [
                                      questionAndAnswer('2. ', diary.secondQuestion,
                                          diary.secondAnswer),
                                      SizedBox(height: 10),
                                      questionAndAnswer('3. ', diary.thirdQuestion,
                                          diary.thirdAnswer),
                                      SizedBox(height: 10),
                                      questionAndAnswer('4. ', diary.fourthQuestion,
                                          diary.fourthAnswer),
                                      SizedBox(height: 10),
                                      questionAndAnswer('5. ', diary.fifthQuestion,
                                          diary.fifthAnswer),
                                    ],
                                  ) : SizedBox(),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  diary.isCompleteToFeed ? InkWell(
                                    child: InkWell(
                                      onTap: () => checkFeedUndoPopup(diary),
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 40,
                                        width: MediaQuery.of(context).size.width * 0.25,
                                        decoration: BoxDecoration(
                                            border: Border.symmetric(horizontal: BorderSide(color: Colors.black54, width: 0.5))
                                        ),
                                        child: Text(
                                          '공유취소',
                                          style: TextStyle(fontFamily: 'Nanum', color: Colors.redAccent, fontSize: 20),
                                        ),
                                      ),
                                    ),
                                  ) : InkWell(
                                    onTap: () => checkFeedPopup(diary),
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: 40,
                                      width: MediaQuery.of(context).size.width * 0.25,
                                      decoration: BoxDecoration(
                                          border: Border.symmetric(horizontal: BorderSide(color: Colors.black54, width: 0.5))
                                      ),
                                      child: Text(
                                        '공유하기',
                                        style: TextStyle(fontFamily: 'Nanum', color: Colors.black, fontSize: 20),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => checkUpdatePopup(diary),
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
                                    onTap: () => checkDeletePopup(diary),
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
                              SizedBox(height: 20),
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
                              Flexible(
                                child: Center(
                                    child: Text(
                                  '작성된 일기가 없습니다.',
                                  style: TextStyle(fontFamily: 'Nanum', color: Colors.black, fontSize: 20),
                                )),
                              )
                            ],
                          ))
                      : Container(),
                ],
              ),
            ]);
          }),
    );
  }

  checkUpdatePopup(diary) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('일기 수정', style: TextStyle(fontFamily: 'Nanum', )),
            content: Text("작성된 일기를 수정하시겠습니까?",
                style: TextStyle(fontFamily: 'Nanum', color: Colors.black87)),
            actions: [
              TextButton(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Text('확인',
                      style: TextStyle(fontFamily: 'Nanum', 
                          color: Colors.blueAccent, fontSize: 20)),
                ),
                onPressed: () async {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => WriteDiaryPage(diary: diary)));
                },
              ),
              TextButton(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Text('취소',
                      style: TextStyle(fontFamily: 'Nanum', 
                          color: Colors.grey, fontSize: 20)),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  checkDeletePopup(diary) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('일기 삭제', style: TextStyle(fontFamily: 'Nanum', )),
            content: Text("작성한 일기를 삭제하시겠습니까?\n삭제하는 경우 피드에 공유한 일기도 함께 삭제됩니다.",
                style: TextStyle(fontFamily: 'Nanum', color: Colors.redAccent)),
            actions: [
              TextButton(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Text('확인',
                      style: TextStyle(fontFamily: 'Nanum', 
                          color: Colors.blueAccent, fontSize: 20)),
                ),
                onPressed: () async {

                  // batch 생성
                  WriteBatch writeBatch =
                  FirebaseFirestore.instance.batch();

                  // Feed 게시글 삭제
                  writeBatch.delete(FirebaseFirestore.instance.collection('feed').doc(diary.id));

                  // 기존 게시글 삭제
                  writeBatch.delete(FirebaseFirestore.instance.collection('users').doc(currentUser.id).collection('diarys').doc(diary.id));

                  // batch end
                  writeBatch.commit();

                  showToast("일기 삭제 완료");
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MainPage(1)));
                },
              ),
              TextButton(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Text('취소',
                      style: TextStyle(fontFamily: 'Nanum', 
                          color: Colors.grey, fontSize: 20)),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  checkFeedPopup(diary) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('공유하기', style: TextStyle(fontFamily: 'Nanum', )),
            content: Text("모두가 볼 수 있도록 공유하시겠습니까?",
                style: TextStyle(fontFamily: 'Nanum', color: Colors.black87)),
            actions: [
              TextButton(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Text('확인',
                      style: TextStyle(fontFamily: 'Nanum', 
                          color: Colors.blueAccent, fontSize: 20)),
                ),
                onPressed: () async {

                  // batch 생성
                  WriteBatch writeBatch =
                  FirebaseFirestore.instance.batch();

                  diary.summitDate.weekday > 0 && diary.summitDate.weekday < 6 ?
                  // Feed 게시글 생성
                  writeBatch.set(FirebaseFirestore.instance.collection('feed').doc(diary.id), {
                    'id': diary.id,
                    'writer': currentUser.email,
                    'grade': currentUser.grade,
                    'userName': currentUser.userName,
                    'profileUrl': currentUser.url != null && currentUser.url != "" ? currentUser.url : currentUser.randomNumber,
                    'firstQuestion': diary.firstQuestion,
                    'secondQuestion': diary.secondQuestion,
                    'thirdQuestion': diary.thirdQuestion,
                    'fourthQuestion': diary.fourthQuestion,
                    'fifthQuestion': diary.fifthQuestion,
                    'firstAnswer': diary.firstAnswer,
                    'secondAnswer': diary.secondAnswer,
                    'thirdAnswer': diary.thirdAnswer,
                    'fourthAnswer': diary.fourthAnswer,
                    'fifthAnswer': diary.fifthAnswer,
                    'imageUrl': diary.imageUrl != null ? diary.imageUrl : "",
                    'summitDate': diary.summitDate,
                    'createdAt': DateTime.now()
                  }) : // Feed 게시글 생성
                  writeBatch.set(FirebaseFirestore.instance.collection('feed').doc(diary.id), {
                    'id': diary.id,
                    'writer': currentUser.email,
                    'grade': currentUser.grade,
                    'userName': currentUser.userName,
                    'profileUrl': currentUser.url != null && currentUser.url != "" ? currentUser.url : currentUser.randomNumber,
                    'firstQuestion': diary.firstQuestion,
                    'firstAnswer': diary.firstAnswer,
                    'imageUrl': diary.imageUrl != null ? diary.imageUrl : "",
                    'summitDate': diary.summitDate,
                    'createdAt': DateTime.now()
                  });

                  // 기존 게시글 피드공유 처리
                  writeBatch.update(FirebaseFirestore.instance.collection('users').doc(currentUser.id).collection('diarys').doc(diary.id), {
                    'isCompleteToFeed': true
                  });

                  // batch end
                  writeBatch.commit();

                  showToast("피드 공유 완료");
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MainPage(0)));
                },
              ),
              TextButton(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Text('취소',
                      style: TextStyle(fontFamily: 'Nanum', 
                          color: Colors.grey, fontSize: 20)),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  checkFeedUndoPopup(diary) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('공유 취소', style: TextStyle(fontFamily: 'Nanum', )),
            content: Text("피드에 게시된 일기 공유를 취소하시겠습니까?",
                style: TextStyle(fontFamily: 'Nanum', color: Colors.black87)),
            actions: [
              TextButton(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Text('확인',
                      style: TextStyle(fontFamily: 'Nanum',
                          color: Colors.blueAccent, fontSize: 20)),
                ),
                onPressed: () async {

                  // batch 생성
                  WriteBatch writeBatch =
                  FirebaseFirestore.instance.batch();

                  // Feed 게시글 삭제
                  writeBatch.delete(FirebaseFirestore.instance.collection('feed').doc(diary.id));

                  // 기존 게시글 피드공유 취소처리
                  writeBatch.update(FirebaseFirestore.instance.collection('users').doc(currentUser.id).collection('diarys').doc(diary.id), {
                    'isCompleteToFeed': false
                  });

                  // batch end
                  writeBatch.commit();

                  showToast("공유 취소 완료");
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MainPage(0)));
                },
              ),
              TextButton(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Text('취소',
                      style: TextStyle(fontFamily: 'Nanum',
                          color: Colors.grey, fontSize: 20)),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  topImage(diary) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        child: ClipRRect(
          child: diary.imageUrl != null ?
          CachedNetworkImage(
            imageUrl: diary.imageUrl,
            placeholder: (context, url) => CircularProgressIndicator(
            ),
            errorWidget: (context, url, error) => Icon(Icons.error),
          )
          // Image.network(diary.imageUrl)
              : Image.asset(
            'assets/images/diary_background.jpg',
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.width * 0.25,
            fit: BoxFit.fill,
          ),
        ),
        decoration:
            BoxDecoration(boxShadow: [
          BoxShadow(offset: Offset(0, 0), blurRadius: 2, color: Colors.black54)
        ]),
      ),
    );
  }

  questionAndAnswer(number, question, answer) {
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
        Divider(color: Colors.black,),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              flex: 1,
              child: Text(
                "$answer",
                style: TextStyle(fontFamily: 'Nanum', color: Colors.black87),
              ),
            ),
          ],
        ),
        Divider(color: Colors.black,),
        SizedBox(height: 10),
      ],
    );
  }

  showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }
}
