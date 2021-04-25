import 'dart:io';

import 'package:church_diary_app/model/CurrentUser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_image/firebase_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
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
  PdfDocument document = PdfDocument();
  Printing pt;
  var imageId = new List<dynamic>(200);
  List<Future<String>> imageDownloadPath = new List<Future<String>>(200);
  var imageLoad = new List<dynamic>(200);

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

  // Future downloadImageFromFirebaseStorage(String imageUrl) async {
  //   // var imageId = await ImageDownloader.downloadImage(imageUrl, destination: AndroidDestinationType.custom(directory:'sample'));
  //   if (imageId == null) {
  //     return "is not exist";
  //   }
  //   var path = await ImageDownloader.findPath(imageId);
  //   return path;
  // }

  getImageFromFirebase(imageUrl, index) async {
    imageId[index] = await ImageDownloader.downloadImage(imageUrl,
        destination: AndroidDestinationType.directoryDownloads);

    // 여러개 사진 받을 때 너무 빨라서 그런지 4개 중 뒤에 2개 이미지 파일을 다운받지 못하고 에러가 난다... 원인 파악 중
    imageId[index].then((value) {
      imageDownloadPath[index] = ImageDownloader.findPath(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Pdf 추출')),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: ds == null || isLoading
                ? CircularProgressIndicator()
                : Column(
                    children: [
                      Container(
                          child: TextButton(
                        child: Text('PDF'),
                        onPressed: () async {
                          // 로딩 시작
                          setState(() {
                            isLoading = true;
                          });

                          final fontData =
                              await rootBundle.load('fonts/NanumMyeongjo.ttf');

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
                                    final pdf = pw.Document();

                                    // final Uint8List fontData = File('/fonts/NanumMyeongjo.ttf').readAsBytesSync();
                                    final ttf = pw.Font.ttf(fontData);

                                    if (ds.docs[i].data()['profileName'] ==
                                        '제이티비') {
                                      // if(i < 5) {
                                      // 일기별로 돌면서 pdf에 페이지 추가
                                      for (int j = 0;
                                          j < value.docs.length;
                                          j++) {
                                        imageDownloadPath[j].then((valueString) {
                                          imageLoad[j] = File(valueString).readAsBytesSync();
                                        });

                                        // rootBundle.load('assets/images/background.jpg').then((value) {
                                        //   imageLoad = value.buffer.asUint8List;
                                        // });
                                        pdf.addPage(pw.Page(
                                            pageFormat: PdfPageFormat.a4,
                                            build: (pw.Context context) {
                                              return pw.Stack(children: [
                                                pw.Column(
                                                  crossAxisAlignment: pw
                                                      .CrossAxisAlignment.start,
                                                  children: [
                                                    // Image 인터엣 상에서 가져와서 pdf로 저장하는 부분이 계속 안되고 있다.
                                                    value.docs[j]
                                                        .data()['imageUrl'] != null &&
                                                        value.docs[j]
                                                            .data()['imageUrl'] != ""
                                                        ?
                                                    pw.Image(pw.MemoryImage(imageLoad[j])) : pw.SizedBox(),
                                                    pw.Text(value.docs[j]
                                                        .data()['createdAt']
                                                        .toDate()
                                                        .toString()
                                                        .substring(0, 10)),
                                                    pw.SizedBox(height: 10),
                                                    pw.Text(
                                                        value.docs[j]
                                                            .data()[
                                                                'firstQuestion']
                                                            .toString(),
                                                        style: pw.TextStyle(
                                                            font: ttf,
                                                            fontSize: 11,
                                                            fontWeight: pw
                                                                .FontWeight
                                                                .bold)),
                                                    pw.Divider(thickness: 0.5),
                                                    pw.Text(
                                                        value.docs[j]
                                                            .data()[
                                                                'firstAnswer']
                                                            .toString(),
                                                        style: pw.TextStyle(
                                                            font: ttf,
                                                            fontSize: 10)),
                                                    pw.Divider(thickness: 0.5),
                                                    pw.SizedBox(height: 8),
                                                    value.docs[j].data()[
                                                                'secondQuestion'] !=
                                                            null
                                                        ? pw.Text(
                                                            value.docs[j]
                                                                    .data()[
                                                                'secondQuestion'],
                                                            style: pw.TextStyle(
                                                                font: ttf,
                                                                fontSize: 11))
                                                        : pw.SizedBox(),
                                                    value.docs[j].data()[
                                                                'secondQuestion'] !=
                                                            null
                                                        ? pw.Divider(
                                                            thickness: 0.5)
                                                        : pw.SizedBox(),
                                                    value.docs[j].data()[
                                                                'secondAnswer'] !=
                                                            null
                                                        ? pw.Text(
                                                            value.docs[j]
                                                                    .data()[
                                                                'secondAnswer'],
                                                            style: pw.TextStyle(
                                                                font: ttf,
                                                                fontSize: 10))
                                                        : pw.SizedBox(),
                                                    value.docs[j].data()[
                                                                'secondQuestion'] !=
                                                            null
                                                        ? pw.Divider(
                                                            thickness: 0.5)
                                                        : pw.SizedBox(),
                                                    value.docs[j].data()[
                                                                'secondQuestion'] !=
                                                            null
                                                        ? pw.SizedBox(height: 8)
                                                        : pw.SizedBox(),
                                                    value.docs[j].data()[
                                                                'thirdQuestion'] !=
                                                            null
                                                        ? pw.Text(
                                                            value.docs[j]
                                                                    .data()[
                                                                'thirdQuestion'],
                                                            style: pw.TextStyle(
                                                                font: ttf,
                                                                fontSize: 11))
                                                        : pw.SizedBox(),
                                                    value.docs[j].data()[
                                                                'thirdQuestion'] !=
                                                            null
                                                        ? pw.Divider(
                                                            thickness: 0.5)
                                                        : pw.SizedBox(),
                                                    value.docs[j].data()[
                                                                'thirdAnswer'] !=
                                                            null
                                                        ? pw.Text(
                                                            value.docs[j]
                                                                    .data()[
                                                                'thirdAnswer'],
                                                            style: pw.TextStyle(
                                                                font: ttf,
                                                                fontSize: 10))
                                                        : pw.SizedBox(),
                                                    value.docs[j].data()[
                                                                'thirdQuestion'] !=
                                                            null
                                                        ? pw.Divider(
                                                            thickness: 0.5)
                                                        : pw.SizedBox(),
                                                    value.docs[j].data()[
                                                                'thirdQuestion'] !=
                                                            null
                                                        ? pw.SizedBox(height: 8)
                                                        : pw.SizedBox(),
                                                    value.docs[j].data()[
                                                                'fourthQuestion'] !=
                                                            null
                                                        ? pw.Text(
                                                            value.docs[j]
                                                                    .data()[
                                                                'fourthQuestion'],
                                                            style: pw.TextStyle(
                                                                font: ttf,
                                                                fontSize: 11))
                                                        : pw.SizedBox(),
                                                    value.docs[j].data()[
                                                                'fourthQuestion'] !=
                                                            null
                                                        ? pw.Divider(
                                                            thickness: 0.5)
                                                        : pw.SizedBox(),
                                                    value.docs[j].data()[
                                                                'fourthAnswer'] !=
                                                            null
                                                        ? pw.Text(
                                                            value.docs[j]
                                                                    .data()[
                                                                'fourthAnswer'],
                                                            style: pw.TextStyle(
                                                                font: ttf,
                                                                fontSize: 10))
                                                        : pw.SizedBox(),
                                                    value.docs[j].data()[
                                                                'fourthQuestion'] !=
                                                            null
                                                        ? pw.Divider(
                                                            thickness: 0.5)
                                                        : pw.SizedBox(),
                                                    value.docs[j].data()[
                                                                'fourthQuestion'] !=
                                                            null
                                                        ? pw.SizedBox(height: 8)
                                                        : pw.SizedBox(),
                                                    value.docs[j].data()[
                                                                'fifthQuestion'] !=
                                                            null
                                                        ? pw.Text(
                                                            value.docs[j]
                                                                    .data()[
                                                                'fifthQuestion'],
                                                            style: pw.TextStyle(
                                                                font: ttf,
                                                                fontSize: 11))
                                                        : pw.SizedBox(),
                                                    value.docs[j].data()[
                                                                'fifthQuestion'] !=
                                                            null
                                                        ? pw.Divider(
                                                            thickness: 0.5)
                                                        : pw.SizedBox(),
                                                    value.docs[j].data()[
                                                                'fifthAnswer'] !=
                                                            null
                                                        ? pw.Text(
                                                            value.docs[j]
                                                                    .data()[
                                                                'fifthAnswer'],
                                                            style: pw.TextStyle(
                                                                font: ttf,
                                                                fontSize: 10))
                                                        : pw.SizedBox(),
                                                    value.docs[j].data()[
                                                                'fifthQuestion'] !=
                                                            null
                                                        ? pw.Divider(
                                                            thickness: 0.5)
                                                        : pw.SizedBox(),
                                                  ],
                                                ),

                                              ]); // Center
                                            })); // Page
                                      }

                                      savePdf(
                                          pdf,
                                          ds.docs[i]
                                                  .data()['grade']
                                                  .toString() +
                                              ' ' +
                                              ds.docs[i].data()['profileName']);
                                    }
                                    // pdf 업로드하기
                                  } catch (e) {
                                    print(e);
                                  }
                                }
                              });
                            }
                          }

                          // 로딩 끝
                          setState(() {
                            isLoading = false;
                          });
                        },
                        // onPressed: createPdf,
                      )),
                      TextButton(onPressed: () async {
                        try {
                          // 로딩 시작
                          setState(() {
                            isLoading = true;
                          });

                          final fontData =
                          await rootBundle.load('fonts/NanumMyeongjo.ttf');

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
                                    if (ds.docs[i].data()['profileName'] ==
                                        '제이티비') {
                                    // if(i < 5) {
                                      // 일기별로 돌면서 pdf에 페이지 추가
                                      for (int j = 0;
                                      j < value.docs.length;
                                      j++) {
                                        getImageFromFirebase(value.docs[j].data()['imageUrl'], j);
                                      }
                                    }
                                    // pdf 업로드하기
                                  } catch (e) {
                                    print(e);
                                  }
                                }
                              });
                            }
                          }

                          // 로딩 끝
                          setState(() {
                            isLoading = false;
                          });
                        } on PlatformException catch (error) {
                          print(error);
                        }
                      },
                          child: Text('image download All')),
                      // TextButton(onPressed: () async {
                      //   try {
                      //     // Saved with this method.
                      //     var imageId = await ImageDownloader.downloadImage("https://raw.githubusercontent.com/wiki/ko2ic/image_downloader/images/flutter.png",
                      //     destination: AndroidDestinationType.directoryDownloads);
                      //     if (imageId == null) {
                      //       return;
                      //     }
                      //
                      //     // Below is a method of obtaining saved image information.
                      //     var fileName = await ImageDownloader.findName(imageId);
                      //     imageDownloadPath = ImageDownloader.findPath(imageId);
                      //     var size = await ImageDownloader.findByteSize(imageId);
                      //     var mimeType = await ImageDownloader.findMimeType(imageId);
                      //   } on PlatformException catch (error) {
                      //     print(error);
                      //   }
                      // },
                      //     child: Text('image download Test'))
                    ],
                  ),
          ),
        ));
  }

  savePdf(pdf, userName) async {
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/$userName.pdf");
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
