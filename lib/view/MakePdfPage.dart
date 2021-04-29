import 'dart:io';
import 'dart:typed_data';

import 'package:church_diary_app/model/CurrentUser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_image/firebase_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;

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
  var imageLoad = new List<dynamic>(200);
  List<Future<String>> imageDownloadPath = new List<Future<String>>(200);
  Directory appDocDir;
  // var finalImage;
  Uint8List imageBytes;
  int index = 0;

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
    getDirectoryPath();
  }

  getDirectoryPath() async {
    appDocDir = await getApplicationDocumentsDirectory();
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
                                  .orderBy('summitDate')
                                  .get()
                                  .then((value) {
                                if (value.size > 0) {
                                  try {
                                    final pdf = pw.Document();

                                    // final Uint8List fontData = File('/fonts/NanumMyeongjo.ttf').readAsBytesSync();
                                    final ttf = pw.Font.ttf(fontData);

                                    // if (ds.docs[i].data()['profileName'] ==
                                    //     '제이티비') {
                                      if(i < 5) {
                                      // 일기별로 돌면서 pdf에 페이지 추가
                                      for (int j = 0;
                                          j < value.docs.length;
                                          j++) {

                                        var flag = false;

                                        if(value.docs[j].data()['imageUrl'] != "") {
                                          var year = value.docs[j]
                                              .data()['summitDate']
                                              .toDate()
                                              .toString()
                                              .substring(0, 4);
                                          var month = value.docs[j]
                                              .data()['summitDate']
                                              .toDate()
                                              .toString()
                                              .substring(5, 7);
                                          var day = value.docs[j]
                                              .data()['summitDate']
                                              .toDate()
                                              .toString()
                                              .substring(8, 10);
                                          var fileName = 'image_$year$month${day}_${ds.docs[i].data()['id']}';
                                          print('>>>>>>> summitDate : ' +
                                              value.docs[j].data()['summitDate']
                                                  .toDate()
                                                  .toString());
                                          // url, 폴더 경로를 이용해 파일 다운로드 받기
                                          print('>>>>>>>>> fileName : ' +
                                              fileName);
                                          Reference imageRef = FirebaseStorage
                                              .instance.ref(
                                              '/uploads/${ds.docs[i]
                                                  .data()['id']}/image_$year$month$day');

                                          if (imageRef != null) {
                                            // imageBytes = null;
                                            print('>>>>>>>>> imageRef : ' +
                                                imageRef.toString());
                                            // File finalImage = await File('${appDocDir.path}/$fileName.jpg').create();
                                            // imageBytes = await finalImage.readAsBytes();
                                            // if(imageBytes != null) imageBytes.clear();
                                            // imageBytes = await finalImage.readAsBytes();
                                            setState(() {
                                              imageBytes = null;
                                            });
                                            downloadFileExample(
                                                imageRef, fileName);
                                            print('================== imageBytes : $imageBytes');
                                            flag = true;
                                          }
                                        }

                                        pdf.addPage(pw.Page(
                                            pageFormat: PdfPageFormat.a4,
                                            build: (pw.Context context) {
                                              return pw.Stack(children: [
                                                pw.Column(
                                                  crossAxisAlignment: pw
                                                      .CrossAxisAlignment.start,
                                                  children: [
                                                    flag ? pw.Image(pw.MemoryImage(imageBytes)) : pw.SizedBox(),
                                                    pw.Text(value.docs[j]
                                                        .data()['summitDate']
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
                                    // if (ds.docs[i].data()['profileName'] ==
                                    //     '제이티비') {
                                    if(i < 5) {
                                      // 일기별로 돌면서 pdf에 페이지 추가
                                      for (int j = 0;
                                      j < value.docs.length;
                                      j++) {
                                        // 다운로드 받을 폴더 경로 지정
                                        if(value.docs[j].data()['imageUrl'] != "") {
                                          var year = value.docs[j]
                                              .data()['summitDate']
                                              .toDate()
                                              .toString()
                                              .substring(0, 4);
                                          var month = value.docs[j]
                                              .data()['summitDate']
                                              .toDate()
                                              .toString()
                                              .substring(5, 7);
                                          var day = value.docs[j]
                                              .data()['summitDate']
                                              .toDate()
                                              .toString()
                                              .substring(8, 10);
                                          var fileName = 'image_$year$month$day';
                                          print('>>>>>>> summitDate : ' +
                                              value.docs[j].data()['summitDate']
                                                  .toDate()
                                                  .toString());
                                          // url, 폴더 경로를 이용해 파일 다운로드 받기
                                          print('>>>>>>>>> fileName : ' +
                                              fileName);
                                          Reference imageRef = FirebaseStorage
                                              .instance.ref(
                                              '/uploads/${ds.docs[i]
                                                  .data()['id']}/image_$year$month$day');
                                          print('>>>>>>>>> imageRef : ' +
                                              imageRef.toString());
                                          downloadFileExample(
                                              imageRef, fileName);
                                        }
                                        // getImageFromFirebase(value.docs[j].data()['imageUrl'], j);
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
                      TextButton(onPressed: () async {
                        try {
                          // // Saved with this method.
                          // var imageId = await ImageDownloader.downloadImage("https://raw.githubusercontent.com/wiki/ko2ic/image_downloader/images/flutter.png",
                          // destination: AndroidDestinationType.directoryDownloads);
                          // if (imageId == null) {
                          //   return;
                          // }
                          //
                          // // Below is a method of obtaining saved image information.
                          // var fileName = await ImageDownloader.findName(imageId);
                          // imageDownloadPath = ImageDownloader.findPath(imageId);
                          // var size = await ImageDownloader.findByteSize(imageId);
                          // var mimeType = await ImageDownloader.findMimeType(imageId);

                        } on PlatformException catch (error) {
                          print(error);
                        }
                      },
                          child: Text('image download Test'))
                    ],
                  ),
          ),
        ));
  }

  getImageFromFirebase(imageUrl, index) async {
    imageId[index] = ImageDownloader.downloadImage(imageUrl,
        destination: AndroidDestinationType.directoryDownloads);

    // 여러개 사진 받을 때 너무 빨라서 그런지 4개 중 뒤에 2개 이미지 파일을 다운받지 못하고 에러가 난다... 원인 파악 중
    // imageId[index].then((value) {
    //   imageDownloadPath[index] = ImageDownloader.findPath(imageId[index]);
    // });
    imageId[index].then((value) {
      imageDownloadPath[index] = ImageDownloader.findPath(value);
      print('****** imageId : $value');
    });
    // imageDownloadPath[index] = ImageDownloader.findPath(await imageId[index]);

    print('>>>>>>>>>> imageId[index] : ${imageId[index]}');
    print('>>>>>>>>>> imageDownloadPath[index] : ${imageDownloadPath[index].then((value) => print('value: $value'))}');


    // try {
    //   // Saved with this method.
    //   var imageId = await ImageDownloader.downloadImage(imageUrl,
    //       destination: AndroidDestinationType.directoryDownloads);
    //   if (imageId == null) {
    //     return;
    //   }
    //
    //   // Below is a method of obtaining saved image information.
    //   var fileName = await ImageDownloader.findName(imageId);
    //   var path = await ImageDownloader.findPath(imageId);
    //   var size = await ImageDownloader.findByteSize(imageId);
    //   var mimeType = await ImageDownloader.findMimeType(imageId);
    //   print('>>>>>>>>> fileName : $fileName');
    //   print('>>>>>>>>> path : $path');
    //   print('>>>>>>>>> size : $size');
    //   print('>>>>>>>>> mimeType : $mimeType');
    // } on PlatformException catch (error) {
    //   print(error);
    // }
  }

  Future<void> downloadFileExample(Reference ref, String fileName) async {

    print('&&&&&&&&&& appDocDir: ${appDocDir.path}');
    // File downloadToFile = File('${appDocDir.path}/download-logo.png');
    // final Directory systemTempDir = Directory.current;// getTemporaryDirectory();Directory.systemTemp;
    File downloadToFile = File('${appDocDir.path}/$fileName.jpg');
    // File ff = await File('${appDocDir.path}/$fileName.jpg').create();
    //
    File finalImage = await File('${appDocDir.path}/$fileName.jpg').create();

    // if(imageBytes != null) imageBytes.clear();
    imageBytes = finalImage.readAsBytesSync();
    // index++

    try {
      // await ref
      //     .writeToFile(downloadToFile);
      final DownloadTask task = ref.writeToFile(downloadToFile);
      await task.then((_) => print('complete'));
    } on FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
    }
  }

  Future<void> downloadFile(Reference ref, String fileName) async {
    final String url = await ref.getDownloadURL();
    final http.Response downloadData = await http.get(url);
    final Directory systemTempDir = Directory.current;// getTemporaryDirectory();Directory.systemTemp;
    final File tempFile = File('${systemTempDir.path}/fileName.jpg');
    if (tempFile.existsSync()) {
      await tempFile.delete();
    }
    await tempFile.create();
    final DownloadTask task = ref.writeToFile(tempFile);
    // final int byteCount = (await task.whenComplete(() => null)).totalByteCount;
    var bodyBytes = downloadData.bodyBytes;
    final String name = await ref.getName();
    final String path = await ref.getPath();
    print(
      'Success!\nDownloaded $name \nUrl: $url'
          '\npath: $path \n',
    );

    showToast("Complete");
    // _scaffoldKey.currentState.showSnackBar(
    //   SnackBar(
    //     backgroundColor: Colors.white,
    //     content: Image.memory(
    //       bodyBytes,
    //       fit: BoxFit.fill,
    //     ),
    //   ),
    // );
  }


  // Future<String> downloadFile(String url, String fileName, String dir) async {
  //   HttpClient httpClient = new HttpClient();
  //   File file;
  //   String filePath = '';
  //   String myUrl = '';
  //
  //   try {
  //     myUrl = url+'/'+fileName;
  //     var request = await httpClient.getUrl(Uri.parse(myUrl));
  //     var response = await request.close();
  //     if(response.statusCode == 200) {
  //       var bytes = await consolidateHttpClientResponseBytes(response);
  //       filePath = '$dir/$fileName';
  //       file = File(filePath);
  //       await file.writeAsBytes(bytes);
  //     }
  //     else
  //       filePath = 'Error code: '+response.statusCode.toString();
  //   }
  //   catch(ex){
  //     filePath = 'Can not fetch url';
  //   }
  //
  //   return filePath;
  // }


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
