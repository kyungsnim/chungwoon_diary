import 'dart:io';

import 'package:church_diary_app/model/CurrentUser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'FeedPage.dart';
import 'MainPage.dart';
import 'MyPage.dart';
import 'CalendarDiaryPage.dart';
import 'package:flutter_icons/flutter_icons.dart';

final GoogleSignIn googleSignIn = new GoogleSignIn();
final userReference =
    FirebaseFirestore.instance.collection('users'); // 사용자 정보 저장을 위한 ref
CurrentUser currentUser;
// variable for firestore collection 'users'
final diaryReference =
    FirebaseFirestore.instance.collection('diarys'); // 과제 정보 저장을 위한 ref

class MainPage extends StatefulWidget {
  final getPageIndex;

  MainPage(this.getPageIndex);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // 페이지 컨트롤
  PageController pageController;
  int getPageIndex;

  @override
  void initState() {
    super.initState();
    setState(() {
      getPageIndex = widget.getPageIndex;
    });
    pageController = PageController(
        // 다른 페이지에서 넘어올 때도 controller를 통해 어떤 페이지 보여줄 것인지 셋팅
        initialPage: getPageIndex != null ? this.getPageIndex : 0);
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  whenPageChanges(int pageIndex) {
    setState(() {
      this.getPageIndex = pageIndex;
    });
  }

  onTapChangePage(int pageIndex) {
    pageController.animateToPage(pageIndex,
        duration: Duration(milliseconds: 100), curve: Curves.bounceInOut);
  }

  // back 버튼 클릭시 종료할건지 물어보는
  Future<bool> _onBackPressed() async {
    return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("종료하시겠습니까?",
                style: TextStyle(fontFamily: 'Nanum', fontSize: 18)),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  "확인",
                  style: TextStyle(
                      fontFamily: 'Nanum', fontSize: 18, color: Colors.blue),
                ),
                onPressed: () {
                  SystemNavigator.pop();
                },
              ),
              FlatButton(
                child: Text(
                  "취소",
                  style: TextStyle(
                      fontFamily: 'Nanum', fontSize: 18, color: Colors.grey),
                ),
                onPressed: () => Navigator.pop(context, false),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: PageView(
          children: [
            FeedPage(),
            CalendarDiaryPage(),
            MyInfoPage(),
          ],
          controller: pageController, // controller를 지정해주면 각 페이지별 인덱스로 컨트롤 가능
          onPageChanged:
              whenPageChanges, // page가 바뀔때마다 whenPageChanges 함수가 호출되고 현재 pageIndex 업데이트해줌
        ),
        bottomNavigationBar: SizedBox(
          // height: 130,
          child: BottomNavigationBar(
            // Bar에 텍스트 라벨 안보이게 변경
            showSelectedLabels: false,
            showUnselectedLabels: false,
            backgroundColor: Colors.white.withOpacity(0.8),
            currentIndex: this.getPageIndex,
            onTap: onTapChangePage,
            selectedItemColor: Colors.black,
            selectedIconTheme: IconThemeData(color: Colors.black, size: 40),
            selectedFontSize: 20,
            selectedLabelStyle:
                TextStyle(fontFamily: 'Nanum', fontWeight: FontWeight.bold),
            unselectedItemColor: Colors.white70,
            unselectedFontSize: 12,

            iconSize: 40,
            type: BottomNavigationBarType.fixed,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  // icon: Icon(Icons.share_outlined),
                  // activeIcon: Icon(Icons.share_sharp),
                  // label: ''),
                  icon: Image.asset(
                    'assets/icon/7.png',
                    width: 40,
                  ),
                  activeIcon: Image.asset(
                    'assets/icon/8.png',
                    width: 40,
                  ),
                  label: ''),
              BottomNavigationBarItem(
                  icon: Image.asset(
                    'assets/icon/9.png',
                    width: 40,
                  ),
                  activeIcon: Image.asset(
                    'assets/icon/10.png',
                    width: 40,
                  ),
                  label: ''),
              // icon: Icon(FontAwesome.edit),
              // label: '',
              // activeIcon: Icon(FontAwesome.edit),),
              BottomNavigationBarItem(
                  icon: Image.asset(
                    'assets/icon/11.png',
                    width: 40,
                  ),
                  activeIcon: Image.asset(
                    'assets/icon/12.png',
                    width: 40,
                  ),
                  label: ''),
              // activeIcon: Icon(FontAwesome.heartbeat),
              // icon: Icon(FontAwesome.heart_o),
              // label: ''),
            ],
          ),
        ),
      ),
    );
  }
}
