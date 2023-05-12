import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance..initialize()..updateRequestConfiguration(
    RequestConfiguration(testDeviceIds: ['7C92BD192385F05DDBD6FC73370E2D63']),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Birgi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
      color: Colors.white,
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  RewardedAd? _rewardedAd;
  
  int _numRewardedLoadAttempts = 0;
  static final AdRequest request = AdRequest();

  void _createRewardedAd() {
    RewardedAd.load(
        adUnitId: 'ca-app-pub-3940256099942544/1712485313',
        // ca-app-pub-1226183858676476/8446194907
        request: request,
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            print('$ad loaded.');
            _rewardedAd = ad;
            _numRewardedLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedAd failed to load: $error');
            _rewardedAd = null;
            _numRewardedLoadAttempts += 1;
            if (_numRewardedLoadAttempts < 2) {
              _createRewardedAd();
            }
          },
        ));
  }

  void _showRewardedAd() {
    if (_rewardedAd == null) {
      print('Warning: attempt to show rewarded before loaded.');
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createRewardedAd();
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      print('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
    });
    _rewardedAd = null;
  }

    Widget _buildDraggableBottomSheet(srr) {
      return DraggableScrollableSheet(
        initialChildSize: 0.8, // Set to 1.0 for full screen
        minChildSize: 0.1, // Minimum size when user drags down to dismiss
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
            // ignore: avoid_unnecessary_containers
            child: Container(
                child: Center(
                  child: Image.memory(base64Decode(srr))
                  ),
              ),
          
          );
        },
      );
    }


  var srr = "";
  Future<void>  fetchGeneratedImage(String prompt) async {
  final response = await http.post(
    Uri.parse('http://192.168.18.18:5000/generate_image'),
    body: jsonEncode({'prompt': prompt}),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    setState(() {
      srr = jsonDecode(response.body)['image'];
    });
  } else {
    throw Exception('Failed to load generated image');
  }
}



  @override
  void initState() {
    _createRewardedAd();
    super.initState();
  }
 final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                Container(
                  height: 100,
                  width: size.width,
                  color: Color.fromARGB(255, 255, 255, 255),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top:40.0, left:20.0, bottom: 10.0),
                        child: Text("Birgi AI Art".toUpperCase(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w400),),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top:40.0,bottom: 10.0, right: 20.0),
                        child: GestureDetector(
                          onTap: (){
                            
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) =>_buildDraggableBottomSheetPro(),
                              
                            );
                            },
                          child: Container(
                            height:30,
                            width: 100,
                            decoration:  BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(20)),
                              border: Border.all(
                                color: Colors.amber,
                                width: 1,
                              ),
                              
                            ),
                            child:Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Pro".toUpperCase(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.amber), textAlign: TextAlign.center,),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top:10.0),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    height: 120,
                    width: size.width * 0.95,
                    decoration:  BoxDecoration(       
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      border: Border.all(
                        color: const Color.fromARGB(255, 89, 0, 255),
                        width: 1.5,
                      ),
                      
                    ),
                    child:  TextField(
                        
                        minLines: 1,
                        maxLines: 5, 
                        expands: false,
                        textInputAction: TextInputAction.done,
                        // controller: textController.text,
                        controller: myController,
                        // autocorrect: false,
                        decoration: InputDecoration(
                          hintText: 'Enter a prompt for what you want to create?',
                          fillColor: Colors.white,
                          filled: true,
                          hintStyle: TextStyle(fontSize: 18),
                          contentPadding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                      ),
                  ),
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left:10.0, top:10.0),
                    child: Text("Aspect Ratio", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),textAlign: TextAlign.start,),
                  ),
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left:8.0, top:8.0),
                      child: Container(
                        height:30,
                        width: 80,
                        decoration:  BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(20)),
                          border: Border.all(
                            color: Color.fromARGB(255, 0, 0, 0),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("1:1".toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color.fromARGB(255, 0, 0, 0)), textAlign: TextAlign.center,),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left:8.0, top:8.0),
                      child: Container(
                        height:30,
                        width: 80,
                        decoration:  BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(20)),
                          border: Border.all(
                            color: Color.fromARGB(255, 0, 0, 0),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("4:3".toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color.fromARGB(255, 0, 0, 0)), textAlign: TextAlign.center,),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left:8.0, top:8.0),
                      child: Container(
                        height:30,
                        width: 80,
                        decoration:  BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(20)),
                          border: Border.all(
                            color: Color.fromARGB(255, 0, 0, 0),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("3:2".toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color.fromARGB(255, 0, 0, 0)), textAlign: TextAlign.center,),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () async{
                        // ignore: await_only_futures
                         _createRewardedAd();
                           _showRewardedAd();
                        // ignore: await_only_futures
                        await fetchGeneratedImage(myController.text);
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => _buildDraggableBottomSheet(srr),
                          
                        );
                      },
                    child: Container(
                            height:80,
                            width: size.width,
                            decoration:  BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(20)),
                              color: Colors.black,
                              border: Border.all(
                                color: Color.fromARGB(255, 0, 0, 0),
                                width: 1.5,
                              ),
                            ),
                           child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Generate with an AD", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color.fromARGB(255, 255, 255, 255)), textAlign: TextAlign.center,),
                            ],
                          ),
                      ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                          width: size.width*0.45,
                          decoration:  const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Image.asset('assets/2.png'),
                      ),
                      Container(
                          width: size.width*0.45,
                          child: Image.asset('assets/1.png'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                          width: size.width*0.45,
                          decoration:  const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Image.asset('assets/4.png'),
                      ),
                      Container(
                          width: size.width*0.45,
                          child: Image.asset('assets/6.png'),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

      Widget _buildDraggableBottomSheetPro() {
        Size size = MediaQuery.of(context).size;
      return DraggableScrollableSheet(
        initialChildSize: 0.22, // Set to 1.0 for full screen
        minChildSize: 0.1, // Minimum size when user drags down to dismiss
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
            // ignore: avoid_unnecessary_containers
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(top:20.0, left:20.0, bottom: 0.0),
                      child: Text("PRO".toUpperCase(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top:5.0, left:20.0, bottom: 10.0),
                      child: Text("Remove ADs and Unlock more aspect ratios", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                            height:60,
                            width: size.width*0.95,
                            decoration:  BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(20)),
                              color: Colors.black,
                              border: Border.all(
                                color: Color.fromARGB(255, 0, 0, 0),
                                width: 1.5,
                              ),
                            ),
                           child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Buy 1 month Subscription @ 20\$", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color.fromARGB(255, 255, 255, 255)), textAlign: TextAlign.center,),
                            ],
                          ),
                      ),
                    ),
                ],
            ),
          
          );
        },
      );
    }
  
}




