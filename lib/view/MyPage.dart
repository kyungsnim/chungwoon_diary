import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:church_diary_app/model/CurrentUser.dart';
import 'package:church_diary_app/widget/CustomAppBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';

import 'EditProfilePage.dart';
import 'LoginPage/LoginPage.dart';
import 'MainPage.dart';
import 'MakePdfPage.dart';
import 'QuestionCalendarPage.dart';
import 'QuestionDefaultPage.dart';
import 'SettingUserInfoPage.dart';

class MyInfoPage extends StatefulWidget {
  @override
  _MyInfoPageState createState() => _MyInfoPageState();
}

class _MyInfoPageState extends State<MyInfoPage> {
  PickedFile _imageFile;
  File profileImage;
  final ImagePicker _picker = ImagePicker();
  var isLoading;

  @override
  void initState() {
    super.initState();
    setState(() {
      // isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final TextStyle(fontFamily: 'Nanum', fontFamily: 'Nanum', SignInAvailable = Provider.of<TextStyle(fontFamily: 'Nanum', fontFamily: 'Nanum', SignInAvailable>(context, listen: false);

    return Scaffold(
        // appBar: customAppBar('My Info'),
        body: ListView(
      children: [
        SizedBox(height: 20),
        createProfileTopView(),
        SizedBox(height: 20),
        InkWell(
          onTap: () {
            _showEditProfileDialog(context);
          },
          child: menuBox('정보수정'),
        ),
        SizedBox(height: 5),
        InkWell(
          onTap: () {
            logoutUser();
          },
          child: menuBox('로그아웃'),
        ),
        SizedBox(height: 5),
        currentUser.role == 'admin'
            ? InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SettingUserInfoPage()));
                },
                child: menuBox('최초 가입자 승인'),
              )
            : Container(),
        SizedBox(height: 5),
        currentUser.role == 'admin'
            ? InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => QuestionDefaultPage()));
                },
                child: menuBox('기본 질문 설정'),
              )
            : Container(),
        SizedBox(height: 5),
        currentUser.role == 'admin'
            ? InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => QuestionCalendarPage()));
                },
                child: menuBox('질문 캘린더'),
              )
            : Container(),
        SizedBox(height: 5),
        currentUser.role == 'admin'
            ? InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MakePdfPage()));
          },
          child: menuBox('PDF 추출'),
        )
            : Container(),
      ],
    ));
  }

  userInfo(userInfo) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.grey.withOpacity(0.2)),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          Row(
                            // 사용자 이름
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                userInfo == null ? "" : userInfo.toString(),
                                //user.userId,
                                style: TextStyle(
                                    fontFamily: 'Nanum',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 15),
                              ),
                            ],
                          ),
                        ],
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  createProfileTopView() {
    return StreamBuilder(
        // 현재 로그인한 유저의 정보로 DB 데이터 가져오기
        stream: userReference.doc(currentUser.id).get().asStream(),
        builder: (context, dataSnapshot) {
          // 가져오는 동안 Progress bar
          if (!dataSnapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          // 가져온 데이터로 User 인스턴스에 담기
          CurrentUser user = CurrentUser.fromDocument(dataSnapshot.data);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () async {
                  changeProfileImage();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              // alignment: Alignment.center,
                              height: MediaQuery.of(context).size.height * 0.15,
                              width: MediaQuery.of(context).size.height * 0.15,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      offset: Offset(0, 0),
                                      blurRadius: 5,
                                      color: Colors.black38)
                                ],
                                borderRadius: BorderRadius.circular(90),
                              ),
                              child: currentUser.url != null &&
                                      currentUser.url != ""
                                  ? CachedNetworkImage(
                                      imageUrl: currentUser.url,
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.15,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.15,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                    image: imageProvider,
                                                    fit: BoxFit.cover),
                                              )),
                                    )
                                  : Image.asset(
                                      'assets/images/animal/${currentUser.randomNumber}.png')),
                        ],
                      ),
                      Positioned(
                        bottom: 5,
                        right: MediaQuery.of(context).size.width * 0.35,
                        child: Center(
                          child: Container(
                            child: Icon(
                              Icons.camera,
                              color: Colors.black54,
                              size: 35,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Text("이메일",
                        style: TextStyle(
                            fontFamily: 'Nanum',
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              userInfo(user.email),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Text("이름",
                        style: TextStyle(
                            fontFamily: 'Nanum',
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              userInfo(user.userName),
              // Padding(
              //   padding: const EdgeInsets.all(10.0),
              //   child: Row(
              //     children: [
              //       Text("프로필 이름",
              //           style: TextStyle(fontFamily: 'Nanum',
              //               fontSize: 20, fontWeight: FontWeight.bold)),
              //     ],
              //   ),
              // ),
              // userInfo(user.profileName),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Text("또래",
                        style: TextStyle(
                            fontFamily: 'Nanum',
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              userInfo(user.grade),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Text("인바디 점수",
                        style: TextStyle(
                            fontFamily: 'Nanum',
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              userInfo(user.inbodyScore),
              // Padding(
              //   padding: const EdgeInsets.all(10.0),
              //   child: Row(
              //     children: [
              //       Text("가입일",
              //           style: TextStyle(fontFamily: 'Nanum',
              //               fontSize: 20, fontWeight: FontWeight.bold)),
              //     ],
              //   ),
              // ),
              // userInfo("${user.createdAt.year}년 ${user.createdAt.month}월 ${user.createdAt.day}일"),
              SizedBox(height: 10),
            ],
          );
        });
  }

  void changeProfileImage() async {
    // 갤러리 사진으로 선택
    final pickedFile = await _picker.getImage(source: ImageSource.gallery, imageQuality: 5);
    setState(() {
      _imageFile = pickedFile;
      isLoading = true;
    });

    // 해당 경로로 파일 생성
    profileImage = File(_imageFile.path);

    // storage에 업로드
    String fileName = '${currentUser.email}';

    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('profileImage/$fileName');

    showToast("프로필사진을 업로드 중입니다.\n잠시 기다려주세요.");

    // 위에서 생성해둔 파일로 업로드
    UploadTask uploadTask = firebaseStorageRef.putFile(profileImage);
    var _imageUrl;

    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      print('Progress: ${snapshot.totalBytes / snapshot.bytesTransferred}');
    }, onError: (Object e) {
      print(e);
    });

    // Future.delayed(Duration(seconds: 10));
    // upload 완료된 경우 url 경로 저장해두기
    uploadTask.then((TaskSnapshot taskSnapshot) {
      taskSnapshot.ref.getDownloadURL().then((value) async {
        setState(() {
          _imageUrl = value;
        });

        // firestore에 이미지 정보 수정
        WriteBatch writeBatch = FirebaseFirestore.instance.batch();

        writeBatch.update(
            FirebaseFirestore.instance.collection('users').doc(currentUser.id),
            {
              // currentUser.id 변경해야 함
              'url': _imageUrl,
              'updatedAt': DateTime.now(),
            });

        // batch end
        writeBatch.commit();

        showToast("프로필사진 변경 완료");

        DocumentSnapshot documentSnapshot =
            await userReference.doc(currentUser.id).get();

        // 최초 로그인에 한해 푸쉬알림 전송을 위한 토큰 별도로 저장해두기 (애플 로그인)
        // _saveDeviceToken(user.uid);

        // 현재 유저정보에 값 셋팅하기
        setState(() {
          currentUser = CurrentUser.fromDocument(documentSnapshot);
          isLoading = false;
        });

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MainPage(2)));
      });
    });
  }

  void _showEditProfileDialog(context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('정보 수정',
              style: TextStyle(
                  fontFamily: 'Nanum',
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 18)),
          actionsPadding: EdgeInsets.only(right: 10),
          elevation: 0.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          content: Container(
              width: MediaQuery.of(context).size.width * 1,
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: EditProfilePage(currentUserId: currentUser.id)),
        );
      },
    );
  }

  menuBox(text) {
    return Container(
        width: MediaQuery.of(context).size.width * 1,
        height: 40,
        decoration: BoxDecoration(
          border: Border.symmetric(
              horizontal:
                  BorderSide(width: 1, color: Colors.grey.withOpacity(0.3))),
        ),
        child: Row(
          children: [
            Expanded(flex: 1, child: Container()),
            Expanded(flex: 1, child: Container()),
            Expanded(
              flex: 4,
              child: Center(
                  child: Text(text,
                      style: TextStyle(
                          fontFamily: 'Nanum',
                          color: Colors.grey,
                          fontSize: 18,
                          fontWeight: FontWeight.bold))),
            ),
            Expanded(flex: 1, child: Container()),
            Expanded(
                flex: 1,
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                )),
            SizedBox(width: 10)
          ],
        ));
  }

  logoutUser() async {
    try {
      switch (currentUser.loginType) {
        case "Google":
          // 구글 사용자 로그아웃
          bool isGoogleSignedIn = await googleSignIn.isSignedIn();
          if (isGoogleSignedIn) {
            await googleSignIn.signOut();
          }
          break;
        case "Apple":
          // 애플 로그아웃
          await FlutterSecureStorage().deleteAll();
          break;
      }

      Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => LoginPage()))
          .then((_) {
        if (mounted) {
          setState(() {
            currentUser = null;
          });
        }
      });
    } catch (e) {
      print(e);
    }

    // Navigator.pushReplacement(context, MaterialPageRoute(
    //     builder: (context) => HomePage(0)
    // ));
  }

  showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }
}
