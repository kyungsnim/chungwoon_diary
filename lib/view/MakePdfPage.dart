import 'dart:io';
import 'dart:typed_data';

import 'package:church_diary_app/model/CurrentUser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:toast/toast.dart';

import 'EditProfilePage.dart';

class MakePdfPage extends StatefulWidget {
  @override
  _MakePdfPageState createState() => _MakePdfPageState();
}

class _MakePdfPageState extends State<MakePdfPage> {
  Stream snapshot;
  QuerySnapshot ds;
  bool isLoading;

  getAllUserData() async {
    snapshot = FirebaseFirestore.instance.collection('users').snapshots();
    FirebaseFirestore.instance.collection('users').get().then((value) {
      setState(() {
        ds = value;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = false;
    });
    getAllUserData();
  }

  CurrentUser getUserModelFromDataSnapshot(
      DocumentSnapshot userInfoSnapshot, int index) {
    CurrentUser userModel = new CurrentUser(
      id: userInfoSnapshot.data()['id'],
      grade: userInfoSnapshot.data()['grade'],
      profileName: userInfoSnapshot.data()['profileName'],
      email: userInfoSnapshot.data()['email'],
    );
    return userModel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Pdf 추출')),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: ds == null
                ? CircularProgressIndicator()
                : Container(
                    child: TextButton(
                    child: Text('PDF'),
                    onPressed: () {
                      if (ds.size > 0) {
                        // 모든 사용자 돌면서 pdf 저장시켜줘야 함
                        for (int i = 0; i < ds.docs.length; i++) {
                          // diary 데이터 불러오기
                          ds.docs[i].reference
                              .collection('diarys')
                              .get()
                              .then((value) {
                            if (value.size > 0) {
                              try {
                                var data;
                                rootBundle
                                    .load("fonts/NanumMyeongjo.ttf")
                                    .then((value) {
                                  setState(() {
                                    data = value;
                                  });
                                });
                                final pdf = pw.Document();
                                // final Uint8List fontData = File(
                                //     '/fonts/NanumMyeongjo.ttf')
                                //     .readAsBytesSync();
                                final ttf = pw.Font.ttf(data);

                                // final image = pw.MemoryImage(
                                //   File
                                // )
                                // 일기별로 돌면서 pdf에 페이지 추가
                                for (int j = 0; j < value.docs.length; j++) {
                                  print(value.docs[j].data()['firstQuestion']);
                                  pdf.addPage(pw.Page(
                                      pageFormat: PdfPageFormat.a4,
                                      build: (pw.Context context) {
                                        return pw.Center(
                                            child: pw.Column(
                                          children: [
                                            pw.Text(
                                                value.docs[j]
                                                    .data()['firstQuestion'],
                                                style: pw.TextStyle(
                                                    font: ttf,
                                                    fontSize: 20,
                                                    fontWeight:
                                                        pw.FontWeight.bold)),
                                            pw.Text(
                                                value.docs[j]
                                                    .data()['firstAnswer'],
                                                style: pw.TextStyle(
                                                    font: ttf, fontSize: 15)),
                                            // pw.Text(value.docs[j].data()['firstQuestion'], style: pw.TextStyle(font: ttf, fontSize: 20)),
                                            // pw.Text(value.docs[j].data()['firstQuestion'], style: pw.TextStyle(font: ttf, fontSize: 20)),
                                            // pw.Text(value.docs[j].data()['firstQuestion'], style: pw.TextStyle(font: ttf, fontSize: 20)),
                                            // pw.Text(value.docs[j].data()['firstQuestion'], style: pw.TextStyle(font: ttf, fontSize: 20)),
                                          ],
                                        )); // Center
                                      })); // Page
                                }

                                savePdf(pdf, ds.docs[i].data()['profileName']);

                                // pdf 업로드하기
                              } catch (e) {
                                print(e);
                              }
                            }
                          });
                        }
                      }
                    },
                  )),
          ),
        ));
  }

  savePdf(pdf, userName) async {
    final file = File("$userName.pdf");
    await file.writeAsBytes(await pdf.save());

    Reference diaryRef =
        FirebaseStorage.instance.ref().child('diarys/$userName.pdf');
    // // upload Task는 제공되나 아직 실제 업로드 전
    UploadTask uploadTask = diaryRef.putFile(file);
    // 실제 파일 업로드 (중간에 중단, 취소 등 하지 않을 것이므로 최대한 심플하게 가보자.)
    await uploadTask
        .whenComplete(() => showToast('$userName 파일 업로드 완료', duration: 2));
  }

  showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }
}

class UserInfoTile extends StatefulWidget {
  final CurrentUser searchUser;
  final int index;

  UserInfoTile({this.searchUser, this.index});

  @override
  _UserInfoTileState createState() => _UserInfoTileState();
}

class _UserInfoTileState extends State<UserInfoTile> {
  // void _showEditProfileDialog(context) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('정보 수정',
  //             style: TextStyle(
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.blueAccent,
  //                 fontSize: 18)),
  //         actionsPadding: EdgeInsets.only(right: 10),
  //         elevation: 0.0,
  //         shape:
  //         RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
  //         content: Container(
  //             width: MediaQuery.of(context).size.width * 1,
  //             height: MediaQuery.of(context).size.height * 0.45,
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(10),
  //             ),
  //             alignment: Alignment.center,
  //             child: EditProfilePage(
  //                 currentUserId: widget.searchUser.id, byAdmin: true)),
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
      child: ListTile(
        tileColor: Colors.blueGrey.withOpacity(0.2),
        title: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.searchUser.grade == null
                    ? ""
                    : widget.searchUser.grade.toString(),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(width: 10),
              Text(
                widget.searchUser.profileName == null
                    ? ""
                    : widget.searchUser.profileName,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              Spacer(),
              RaisedButton(
                color: Colors.black,
                onPressed: () async {
                  // 유저 정보 상세페이지로 이동 (수정 가능토록)
                  // _showEditProfileDialog(context);
                },
                child: Icon(
                  Icons.picture_as_pdf,
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.searchUser.email == null ? "" : widget.searchUser.email,
              style: TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
