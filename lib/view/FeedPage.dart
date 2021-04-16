import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:church_diary_app/model/DiaryModel.dart';
import 'package:church_diary_app/widget/CustomAppBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:characters/characters.dart';

import 'MainPage.dart';

class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  var _lastRow = 0;
  final FETCH_ROW = 10;
  var stream;
  var randomGenerator = Random();
  var weekDayList = ['일', '월', '화', '수', '목', '금', '토', '일'];

  // int min = 1, max = 49;
  // var randomNumber = 1 + rnd.nextInt(48);일
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    stream = newStream();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() => stream = newStream());
      }
    });
  }

  Stream<QuerySnapshot> newStream() {
    return FirebaseFirestore.instance
        .collection('feed')
        .orderBy("createdAt", descending: true)
        .limit(FETCH_ROW * (_lastRow + 1))
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: customAppBar('Home'),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    // print("warning");
    return Scrollbar(
      thickness: 15,
      child: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();
          return _buildList(context, snapshot.data.docs);
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        controller: _scrollController,
        itemCount: snapshot.length,
        itemBuilder: (context, i) {
          // print("i : " + i.toString());
          final currentRow = (i + 1) ~/ FETCH_ROW;
          if (_lastRow != currentRow) {
            _lastRow = currentRow;
          }
          // print("lastrow : " + _lastRow.toString());
          return _buildListItem(context, snapshot[i]);
        });
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final diary = DiaryModel.fromSnapshot(data);
    return Padding(
      key: ValueKey(diary.id),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.withOpacity(0.6)),
          boxShadow: [
            BoxShadow(
                offset: Offset(0, 0), blurRadius: 5, color: Colors.black38)
          ],
        ),
        child: InkWell(
          onTap: () {
            feedPopup(diary);
          },
          child: ListTile(
            title: Stack(children: [
              Positioned(
                right: 5,
                top: 30,
                child: Text(
                  '${diary.summitDate.toString().substring(0, 10)}(${weekDayList[diary.summitDate.weekday]})',
                  style: TextStyle(
                      fontFamily: 'Nanum', color: Colors.grey, fontSize: 12),
                ),
              ),
              Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  // height: 200,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            // CircleAvatar(
                            //   backgroundImage: diary.profileUrl != "" && diary.profileUrl.length > 5
                            //       ? diary.profileUrl != null
                            //           ? NetworkImage(diary.profileUrl)
                            //           : Center(
                            //               child: CircularProgressIndicator())
                            //       : AssetImage(
                            //           'assets/images/animal/${currentUser.randomNumber}.png'),
                            //   backgroundColor: Colors.grey,
                            // ),
                            SizedBox(width: 20),
                            Stack(children: [
                              Text(
                                '${diary.grade} ${diary.userName}',
                                style: TextStyle(fontFamily: 'Nanum'),
                              ),
                              // Column(
                              //   children: [
                              //     SizedBox(height: 10),
                              //     Container(
                              //       alignment: Alignment.bottomCenter,
                              //       color: Colors.grey.withOpacity(0.4),
                              //       height: 10,
                              //       width: 80,
                              //     ),
                              //   ],
                              // )
                            ])
                            // 이 뿐 name, grade 로 변경돼야
                          ],
                        ),
                      ),
                      Divider(
                        thickness: 1,
                      ),
                      diary.imageUrl != null
                          ? diary.imageUrl != ""
                              ? CachedNetworkImage(imageUrl: diary.imageUrl)
                              : Container()
                          : Center(child: CircularProgressIndicator()),
                      SizedBox(height: 5),
                      questionAndAnswer(diary.firstQuestion, diary.firstAnswer.characters),
                      SizedBox(height: 5),
                      questionAndAnswer(
                          diary.secondQuestion, diary.secondAnswer.characters),
                      SizedBox(height: 5),
                      questionAndAnswer(diary.thirdQuestion, diary.thirdAnswer.characters),
                      SizedBox(height: 5),
                      questionAndAnswer(
                          diary.fourthQuestion, diary.fourthAnswer.characters),
                      SizedBox(height: 5),
                      questionAndAnswer(diary.fifthQuestion, diary.fifthAnswer.characters),
                      SizedBox(height: 5),
                    ],
                  )),
              Positioned(
                  right: 5,
                  bottom: 5,
                  child: InkWell(
                      onTap: () {
                        // 관리자 게시글 삭제기능
                        checkDeletePopup(diary);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30)
                        ),
                        child: Icon(
                          Icons.delete_forever_outlined,
                          color: Colors.redAccent.withOpacity(0.8),
                          size: 30,
                        ),
                      ))),
            ]),
          ),
        ),
      ),
    );
  }

  feedPopup(diary) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Stack(children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: diary.profileUrl != null &&
                            diary.profileUrl.length > 4
                        ? NetworkImage(diary.profileUrl)
                        : AssetImage(
                            '/assets/images/animal/${diary.randomNumber}.png'),
                    backgroundColor: Colors.grey,
                  ),
                  SizedBox(width: 20),
                  Text(
                    '${diary.grade} ${diary.userName}',
                    style: TextStyle(fontFamily: 'Nanum'),
                  )
                ],
              ),
            ]),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  diary.imageUrl != null
                      ? diary.imageUrl != ""
                          ? CachedNetworkImage(imageUrl: diary.imageUrl)
                          : Container()
                      : Center(child: CircularProgressIndicator()),
                  SizedBox(height: 5),
                  questionAndAnswerAll(diary.firstQuestion, diary.firstAnswer),
                  SizedBox(height: 5),
                  diary.summitDate.weekday > 0 && diary.summitDate.weekday < 6
                      ? Column(
                          children: [
                            questionAndAnswerAll(
                                diary.secondQuestion, diary.secondAnswer),
                            SizedBox(height: 5),
                            questionAndAnswerAll(
                                diary.thirdQuestion, diary.thirdAnswer),
                            SizedBox(height: 5),
                            questionAndAnswerAll(
                                diary.fourthQuestion, diary.fourthAnswer),
                            SizedBox(height: 5),
                            questionAndAnswerAll(
                                diary.fifthQuestion, diary.fifthAnswer),
                            SizedBox(height: 5),
                          ],
                        )
                      : SizedBox()
                ],
              ),
            ),
            insetPadding: EdgeInsets.all(10),
            actions: [
              TextButton(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Text('닫기',
                      style: TextStyle(
                          fontFamily: 'Nanum',
                          color: Colors.grey,
                          fontSize: 20)),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  questionAndAnswer(question, Characters answer) {
    var subStringAnswer;
    var answerLength = answer.length;
    if(answer != null && answerLength > 30) {
      subStringAnswer = answer.skipLast(30).toString();
    } else {
      subStringAnswer = answer;
    }

    return question == null
        ? SizedBox()
        : Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 1,
                    child: Text(
                      question != null && question.length > 30
                          ? "$question".substring(0, 30) + "..."
                          : "$question",
                      style: TextStyle(
                          fontFamily: 'Nanum',
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 1,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 1,
                      decoration: BoxDecoration(
                          border: Border.symmetric(
                              horizontal: BorderSide(
                                  color: Colors.black54, width: 0.5))),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Text(
                          // answer != null && answer.length > 30
                          //     ? "${answer.skipLast(30).toString()}" + "..."
                          //     : "$answer",
                          subStringAnswer.toString(),
                          style: TextStyle(
                              fontFamily: 'Nanum',
                              color: Colors.black87,
                              fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
            ],
          );
  }

  questionAndAnswerAll(question, answer) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              flex: 1,
              child: Text(
                "$question",
                style: TextStyle(
                    fontFamily: 'Nanum',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black),
              ),
            ),
          ],
        ),
        SizedBox(height: 3),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              flex: 1,
              child: Container(
                width: MediaQuery.of(context).size.width * 1,
                decoration: BoxDecoration(
                    border: Border.symmetric(
                        horizontal:
                            BorderSide(color: Colors.black54, width: 0.5))),
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text(
                    "$answer",
                    style: TextStyle(
                        fontFamily: 'Nanum',
                        color: Colors.black87,
                        fontSize: 13),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5),
      ],
    );
  }

  checkDeletePopup(diary) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('피드 삭제',
                style: TextStyle(
                  fontFamily: 'Nanum',
                )),
            content: Text("해당 게시글을 삭제하시겠습니까?",
                style: TextStyle(fontFamily: 'Nanum', color: Colors.redAccent)),
            actions: [
              TextButton(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Text('확인',
                      style: TextStyle(
                          fontFamily: 'Nanum',
                          color: Colors.blueAccent,
                          fontSize: 20)),
                ),
                onPressed: () async {
                  // batch 생성
                  WriteBatch writeBatch = FirebaseFirestore.instance.batch();

                  // Feed 게시글 삭제
                  writeBatch.delete(FirebaseFirestore.instance
                      .collection('feed')
                      .doc(diary.id));

                  // batch end
                  writeBatch.commit();

                  showToast("게시글 삭제 완료");
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => MainPage(1)));
                },
              ),
              TextButton(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Text('취소',
                      style: TextStyle(
                          fontFamily: 'Nanum',
                          color: Colors.grey,
                          fontSize: 20)),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }
}
