import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'text_to_speech.dart';
import 'speech_to_text.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:io';
import 'image_grid_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainPage extends StatefulWidget {
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  HeadlessInAppWebView? headlessWebView;
  HeadlessInAppWebView? headlessImageView;
  String url = "";
  String _result = '';
  double bsize = 40;
  List<dynamic> images = [];
  List<dynamic> _images = [];
  double pad = 30;
  bool isLoading = true;
  String _recognizedSpeech = 'hello';
  final SpeechRecognition _speechRecognition = SpeechRecognition();
  TextToSpeech tts = TextToSpeech();

  @override
  void initState() {
    super.initState();
    _fetchImages();
    fakeBrowser();
    imageBrowser();
    // initScrape();
    // initImageScraper();
  }

  Future imageBrowser() async {
    headlessImageView = HeadlessInAppWebView(
        // initialUrlRequest: URLRequest(
        //     url: Uri.parse(
        //         "https://you.com/search?q=${_recognizedSpeech.replaceAll(' ', '+')}&tbm=isch")),
        initialUrlRequest: URLRequest(
            url: Uri.parse(
                "https://www.bing.com/images/search?q=m${_recognizedSpeech.replaceAll(' ', '+')}&qft=+filterui:color2-color+filterui:photo-photo+filterui:aspect-square&form=IRFLTR&first=1")),
        onWebViewCreated: (controller) {
          // final snackBar = SnackBar(
          //   content: Text('HeadlessInAppWebView created!'),
          //   duration: Duration(seconds: 8),
          // );
          // ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },
        onConsoleMessage: (controller, consoleMessage) {
          // if (consoleMessage.message.contains('[Report Only]')) {
          //   print('Error Found');
          // } else if (consoleMessage.message.contains('geolocation')) {
          //   isLoading = false;
          //   Future.delayed(Duration(seconds: 8), () {
          getImage();
          //     print(_result);
          //   });
        },
        //   final snackBar = SnackBar(
        //     content: Text('Please wait...'),
        //     duration: const Duration(seconds: 3),
        //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
        // } else {
        //   print(consoleMessage.message);

        // final snackBar = SnackBar(
        //   content: Text('Console Message: ${consoleMessage.message}'),
        //   duration: const Duration(seconds: 1),
        // );
        // ScaffoldMessenger.of(context).showSnackBar(snackBar);
        //
        onLoadStart: (controller, url) async {
          //   final snackBar = SnackBar(
          //     content: Text('onLoadStart $url'),
          //     duration: Duration(seconds: 1),
          //   );
          //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
          //
          //   setState(() {
          //     this.url = url?.toString() ?? '';
          //   });
        },
        onLoadStop: (controller, url) async {
          //   final snackBar = SnackBar(
          //     content: Text('onLoadStop $url'),
          //     duration: Duration(seconds: 1),
          //   );
          //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
          //
          //   setState(() {
          //     this.url = url?.toString() ?? '';
          //   });
        });
  }

  Future fakeBrowser() async {
    headlessWebView = HeadlessInAppWebView(
        initialUrlRequest: URLRequest(
            url: Uri.parse(
                "https://you.com/search?q=${_recognizedSpeech.replaceAll(' ', '+')}&tbm=youchat")),
        onWebViewCreated: (controller) {
          //   final snackBar = SnackBar(
          //     content: Text('HeadlessInAppWebView created!'),
          //     duration: Duration(seconds: 1),
          //   );
          //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },
        onConsoleMessage: (controller, consoleMessage) {
          if (consoleMessage.message.contains('[Report Only]')) {
            print('Error Found');
          } else {
            print(consoleMessage.message);
          }
          if (consoleMessage.message.contains('geolocation')) {
            reloadImageUrl();
            isLoading = false;
            Future.delayed(Duration(seconds: 8), () {
              getAnswer();
              print(_result);
            });
          }
          //   final snackBar = SnackBar(
          //     content: Text('Please wait...'),
          //     duration: const Duration(seconds: 8),
          //   );
          //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
          // }
          // final snackBar = SnackBar(
          //   content: Text('Console Message: ${consoleMessage.message}'),
          //   duration: const Duration(seconds: 1),
          // );
          // ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },
        onLoadStart: (controller, url) async {
          //   final snackBar = SnackBar(
          //     content: Text('onLoadStart $url'),
          //     duration: Duration(seconds: 1),
          //   );
          //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
          //
          //   setState(() {
          //     this.url = url?.toString() ?? '';
          //   });
        },
        onLoadStop: (controller, url) async {
          //   final snackBar = SnackBar(
          //     content: Text('onLoadStop $url'),
          //     duration: Duration(seconds: 1),
          //   );
          //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
          //
          //   setState(() {
          //     this.url = url?.toString() ?? '';
          //   });
        });
  }

  Future initImageScraper() async {
    await headlessImageView?.dispose();
    await headlessImageView?.run();
  }

  _fetchImages() async {
    var response = await http.get(
        'https://www.bing.com/images/search?q=$_recognizedSpeech&qft=+filterui:color2-color+filterui:photo-photo+filterui:aspect-square&form=IRFLTR&first=1'
            as Uri);
    var jsonData = jsonDecode(response.body);
    _images = jsonData['value'];
    setState(() {});
  }

  Future reloadImageUrl() async {
    var url = Uri.parse(
        "https://www.bing.com/images/search?q=${_recognizedSpeech.replaceAll(' ', '+')}&qft=+filterui:color2-color+filterui:photo-photo+filterui:aspect-square&form=IRFLTR&first=1");
    // var url = Uri.parse(
    //     "https://you.com/search?q=${_recognizedSpeech.replaceAll(' ', '+')}&tbm=isch");
    await headlessImageView?.webViewController
        .loadUrl(urlRequest: URLRequest(url: url));
  }

  Future getImage() async {
    // if (!isLoading) {
    if (headlessImageView?.isRunning() ?? false) {
      List<dynamic> img = await headlessImageView?.webViewController
          .evaluateJavascript(
              source:
                  'let imageLinks = []; let images = document.querySelectorAll(\'.mimg\'); images.forEach(image => { let src = image.src; imageLinks.push(src.toString()); });imageLinks;');
      print(img[0]);
      setState(() {
        images = img;
      });
    }
    // }
  }

  Future initScrape() async {
    isLoading = true;
    await headlessWebView?.dispose();
    await headlessWebView?.run();
  }

  Future recognizeSpeach() async {
    String recognizedSpeech = await _speechRecognition.recognizeSpeech();
    setState(() {
      _recognizedSpeech = recognizedSpeech;
    });
  }

  Future reloadUrl() async {
    isLoading = true;
    var url = Uri.parse(
        "https://you.com/search?q=${_recognizedSpeech.replaceAll(' ', '+')}&fromSearchBar=true&tbm=youchat");
    await headlessWebView?.webViewController
        .loadUrl(urlRequest: URLRequest(url: url));
  }

  Future getAnswer() async {
    if (!isLoading) {
      if (headlessWebView?.isRunning() ?? false) {
        String? answer = await headlessWebView?.webViewController
            .evaluateJavascript(
                source:
                    'var elements = document.querySelectorAll("#chatHistory > * > * > * > p");var mergedText = "";for (var i = 0; i < elements.length; i++) {mergedText += elements[i].innerText.trim().replace(/\\s+/g, " ");}');
        // print(result);
        setState(() {
          _result = answer!;
        });
        Future.delayed(const Duration(milliseconds: 50), () {
          tts.speak(_result);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Presentation Bot'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(30),
              child: Text(_recognizedSpeech),
            ),
            Padding(
              padding: EdgeInsets.all(30),
              child: Text(_result),
            ),
            SizedBox(
              height: 250,
            ),
            Container(
              height: 200.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                itemBuilder: (BuildContext context, int index) {
                  return Image.network(images[index]);
                },
              ),
            ),
            BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    onPressed: () async {
                      await initScrape();
                      // await initImageScraper();
                    },
                    icon: Icon(
                      Icons.circle_outlined,
                      size: bsize,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: pad),
                  ),
                  IconButton(
                    onPressed: () async {
                      await recognizeSpeach();
                      // await reloadImageUrl();
                      // await getImage();
                      await getAnswer();
                      await _fetchImages();
                    },
                    icon: Icon(
                      Icons.play_arrow_outlined,
                      size: bsize,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: pad),
                  ),
                  IconButton(
                    onPressed: () async {
                      // await reloadUrl();
                      // await reloadImageUrl();
                      _fetchImages();
                    },
                    icon: Icon(
                      Icons.refresh_outlined,
                      size: bsize,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: pad),
                  ),
                  IconButton(
                    onPressed: () async {
                      // await getImage();
                    },
                    icon: Icon(
                      Icons.image_outlined,
                      size: bsize,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: pad),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
