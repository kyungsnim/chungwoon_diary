// @dart=2.9
import 'package:church_diary_app/model/CurrentUser.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_masked_formatter/multi_masked_formatter.dart';
import 'package:toast/toast.dart';

import 'MainPage.dart';

class EditProfilePage extends StatefulWidget {
  final String currentUserId;
  final bool byAdmin;

  EditProfilePage({this.currentUserId, this.byAdmin});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _scaffoldGlobalKey = GlobalKey<ScaffoldState>();
  bool loading = false;
  CurrentUser currentUser;
  var userName; // 수험번호
  final gradeList = [0,
    1970,
    1971,
    1972,
    1973,
    1974,
    1975,
    1976,
    1977,
    1978,
    1979,
    1980,
    1981,
    1982,
    1983,
    1984,
    1985,
    1986,
    1987,
    1988,
    1989,
    1990,
    1991,
    1992,
    1993,
    1994,
    1995,
    1996,
    1997,
    1998,
    1999,
    2000,
    2001,
    2002,
    2003,
    2004,
    2005,
    2006,
    2007,
    2008,
    2009,
    2010,
    2011,
    2012,
    2013,
    2014,
    2015,
    2016
  ];
  var grade; // 학년
  var inbodyScore;
  TextEditingController userNameController = TextEditingController();
  TextEditingController inbodyScoreController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    print('>>>>>>>>>>>>> currentUserId : ${widget.currentUserId}');
    // 화면 빌드 전 미리 해당 사용자의 값들로 셋팅해주자
    getAndDisplayUserInformation();
  }

  @override
  void dispose() {
    super.dispose();
    userNameController.dispose();
  }

  getAndDisplayUserInformation() async {
    setState(() {
      loading = true;
    });

    // DB에서 사용자 정보 가져오기
    DocumentSnapshot documentSnapshot =
        await userReference.doc(widget.currentUserId).get();
    currentUser = CurrentUser.fromDocument(documentSnapshot);

    setState(() {
      loading = false;
      userName = currentUser.userName;
      userNameController.text = userName; // 이름 설정 안한 상태면 비어두고 설정 해두었으면 설정값 불러오기
      grade = currentUser.grade;
      inbodyScore = currentUser.inbodyScore;
      inbodyScoreController.text = inbodyScore; // 인바디점수 설정 안한 상태면 비어두고 설정 해두었으면 설정값 불러오기
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldGlobalKey,
        body: loading
            ? Center(child: CircularProgressIndicator())
            : Container(
                color: Colors.white,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.black.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  offset: Offset(1, 1),
                                  blurRadius: 5,
                                  color: Colors.white24)
                            ]),
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.height * 0.07,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Icon(Icons.person, color: Colors.black),
                              SizedBox(width: 15),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  controller: userNameController,
                                  cursorColor: Colors.black,
                                  validator: (val) {
                                    if (val.isEmpty) {
                                      return '이름을 입력하세요';
                                    } else {
                                      return null;
                                    }
                                  },
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '이름',
                                      hintStyle: TextStyle(
                                          fontFamily: 'Nanum', fontSize: 15)),
                                  onChanged: (val) {
                                    userName = val;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.black.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  offset: Offset(1, 1),
                                  blurRadius: 5,
                                  color: Colors.white24)
                            ]),
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.height * 0.07,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Icon(Icons.group_outlined,
                                  color: Colors.black),
                              SizedBox(width: 15),
                              Expanded(
                                flex: 1,
                                child: DropdownButton(
                                    hint: Text(
                                      '또래 선택',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    value: grade,
                                    icon: Icon(Icons.arrow_downward),
                                    underline: Container(
                                      height: 1,
                                      color: Colors.white,
                                    ),
                                    items: gradeList.map((value) {
                                      return DropdownMenuItem(
                                        value: value,
                                        child: Text("$value",
                                            style: TextStyle(fontSize: 15)),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        grade = value;
                                      });
                                    }),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.black.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  offset: Offset(1, 1),
                                  blurRadius: 5,
                                  color: Colors.white24)
                            ]),
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.height * 0.07,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Icon(Icons.score, color: Colors.black),
                              SizedBox(width: 15),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  controller: inbodyScoreController,
                                  cursorColor: Colors.black,
                                  validator: (val) {
                                    if (val.isEmpty) {
                                      return '인바디점수를 입력하세요';
                                    } else {
                                      return null;
                                    }
                                  },
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '인바디 점수',
                                      hintStyle: TextStyle(
                                          fontFamily: 'Nanum', fontSize: 15)),
                                  onChanged: (val) {
                                    inbodyScore = val;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () {
                              if (_formKey.currentState.validate()) {
                                updateUserData();
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            MainPage(2) // ProfilePage
                                        ));
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              child: Text('수정',
                                  style: TextStyle(
                                      fontFamily: 'Nanum',
                                      color: Colors.blueAccent,
                                      fontSize: 18)),
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              child: Text('취소',
                                  style: TextStyle(
                                      fontFamily: 'Nanum',
                                      color: Colors.grey,
                                      fontSize: 18)),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )));
  }

  updateUserData() async {
    await userReference
        .doc(widget.currentUserId)
        .update({'userName': userName, 'grade': grade, 'inbodyScore': inbodyScore});
    if (mounted) {
      showToast('정보 수정 완료', duration: 2);
    }
  }

  showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }
}
