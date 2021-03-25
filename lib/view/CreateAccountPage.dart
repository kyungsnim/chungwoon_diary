import 'dart:async';
import 'dart:math';
import 'package:church_diary_app/widget/DefaultButton.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:multi_masked_formatter/multi_masked_formatter.dart';

class CreateAccountPage extends StatefulWidget {
  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  String userName;
  TextEditingController userNameController;
  TextEditingController inbodyScoreController;
  var _checkValue = false;
  final gradeList = [
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
  var grade = 1990; // 학년
  var inbodyScore = "";

  submitUsernameAndGrade() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      List<dynamic> info = new List(3);

      var randomGenerator = Random();
      var nameList = [
        '순진한',
        '배고픈',
        '행복한',
        '졸린',
        '어리석은',
        '멍한',
        '기뻐하는',
        '우울한',
        '재미있는',
        '재치있는',
        '흥겨운',
        '외로운',
        '피곤한',
        '산뜻한',
        '귀여운',
        '예쁜',
        '유쾌한',
        '발랄한',
        '다부진',
        '신나는'
      ];
      var nameTwoList = [
        '돌고래',
        '여우',
        '강아지',
        '고양이',
        '사자',
        '나무늘보',
        '코끼리',
        '미국인',
        '영국인',
        '가나인',
        '한국인',
        '중국인',
        '태국인',
        '베트콩',
        '몽골인',
        '참새',
        '딱따구리',
        '앵무새',
        '낙타',
        '쥐',
        '조랑말',
        '타조'
      ];
      var nameRandomNumber = randomGenerator.nextInt(nameList.length - 1);
      var nameTwoRandomNumber = randomGenerator.nextInt(nameTwoList.length - 1);
      var userRandomNumber = randomGenerator.nextInt(9999);
      // 입력한 username, phoneNumber 추가
      setState(() {
        info[0] = userName != null && userName.length > 0
            ? userName
            : "${nameList[nameRandomNumber]}${nameTwoList[nameTwoRandomNumber]}$userRandomNumber";
        info[1] = grade != null ? grade : 1950;
        info[2] = inbodyScore != null ? inbodyScore : "";
      });

      // if(userName)
      // SnackBar snackBar = SnackBar(content: Text('Welcome ' + userName));
      // _scaffoldKey.currentState.showSnackBar(snackBar);

      // 회원가입시 push notification 사용을 위한 사용자 푸쉬 토큰 저장해주기
      // _saveDeviceToken();

      Timer(Duration(seconds: 1), () {
        Navigator.pop(context, info); // 사용자 추가정보 넘기기
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      grade = 1990;
      inbodyScore = "";
    });
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
        key: _scaffoldKey,
        body: ListView(
          children: <Widget>[
            SizedBox(height: 200),
            Container(
                child: Column(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.all(16),
                    child: Container(
                        child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                            offset: Offset(1, 1),
                                            blurRadius: 5,
                                            color: Colors.white24)
                                      ]),
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  height:
                                      MediaQuery.of(context).size.height * 0.07,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(Icons.face, color: Colors.black),
                                        SizedBox(width: 15),
                                        Expanded(
                                          child: TextFormField(
                                            validator: (val) {
                                              if (val.trim().length == 1) {
                                                return '이름이 너무 짧지 않나요?';
                                              } else if (val.trim().length >
                                                  10) {
                                                return '이름이 너무 길지 않나요?';
                                              } else {
                                                return null;
                                              }
                                            },
                                            onSaved: (val) => userName = val,
                                            decoration: InputDecoration(
                                              labelText: '이름을 입력하세요 (선택사항)',
                                              labelStyle: TextStyle(
                                                  fontFamily: 'Nanum',
                                                  fontSize: 16),
                                            ),
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
                                      border: Border.all(color: Colors.black),
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                            offset: Offset(1, 1),
                                            blurRadius: 5,
                                            color: Colors.white24)
                                      ]),
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  height:
                                      MediaQuery.of(context).size.height * 0.07,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Row(
                                      children: [
                                        Icon(Icons.perm_contact_cal_outlined,
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
                                                      style: TextStyle(
                                                          fontSize: 15)),
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
                                      border: Border.all(color: Colors.black),
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                            offset: Offset(1, 1),
                                            blurRadius: 5,
                                            color: Colors.white24)
                                      ]),
                                  width:
                                  MediaQuery.of(context).size.width * 0.8,
                                  height:
                                  MediaQuery.of(context).size.height * 0.07,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      children: [
                                        Icon(Icons.score, color: Colors.black),
                                        SizedBox(width: 15),
                                        Expanded(
                                          child: TextFormField(
                                            validator: (val) {
                                              if (val.trim().length == 1) {
                                                return '인바디점수가 너무 짧지 않나요?';
                                              } else if (val.trim().length >
                                                  10) {
                                                return '인바디점수가 너무 길지 않나요?';
                                              } else {
                                                return null;
                                              }
                                            },
                                            onSaved: (val) => inbodyScore = val,
                                            decoration: InputDecoration(
                                              labelText: '인바디 점수를 입력하세요 (선택사항)',
                                              labelStyle: TextStyle(
                                                  fontFamily: 'Nanum',
                                                  fontSize: 16),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.start,
                                //   children: [
                                //     Checkbox(
                                //       value: _checkValue,
                                //       onChanged: (value) {
                                //         setState(() {
                                //           _checkValue = value;
                                //         });
                                //       },
                                //     ),
                                //     SizedBox(width: 5),
                                //     Row(
                                //       children: [
                                //         InkWell(
                                //             onTap: () async => await launch('https://peronal-infomation-site.firebaseapp.com', forceWebView: false, forceSafariVC: false),
                                //             child: Text('개인정보 처리방침',
                                //                 style: TextStyle(fontFamily: 'Nanum',
                                //                     fontWeight: FontWeight.bold,
                                //                     color: Colors.blue))),
                                //         Text('에 동의합니다.')
                                //       ],
                                //     ),
                                //   ],
                                // )
                              ],
                            )))),
                GestureDetector(
                    onTap: () {
                      // if(_checkValue) {
                      submitUsernameAndGrade();
                      // } else {
                      //   mustCheckPopup();
                      // }
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
                        '가입 완료',
                        style: TextStyle(
                            fontFamily: 'Nanum',
                            color: Colors.black,
                            fontSize: 20),
                      ),
                    ))
              ],
            ))
          ],
        ));
  }

  mustCheckPopup() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text("To sign up, you must agree to our privacy policy.",
                style: TextStyle(
                  fontFamily: 'Nanum',
                )),
            actions: [
              FlatButton(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Text('OK',
                      style: TextStyle(
                          fontFamily: 'Nanum',
                          color: Colors.grey,
                          fontSize: 20)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
}
