import 'dart:io';
import 'package:dio/dio.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:file_cryptor/file_cryptor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:videoplayer/themes/themestate.dart';
import '../../class/videoclass.dart';
import '../loginscreen/loginscreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  late FlickManager flickManager;
  bool _ontab = false;
  late List<VideoClass> videos;
  String streamVideo = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4";
  int selectedIndex =0;
  late VideoClass currentVideoInfo;
  Directory directory= Directory('/storage/emulated/0/Download');
  late File file;
  FileCryptor fileCryptor = FileCryptor(
    key: "0IfSLn8F33SIiWlYTyT4j7n6jnNP74xN",
    iv: 16,
    dir: "/storage/emulated/0/Download",
  );
  final storage = GetStorage();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    disableCapture();
    videoData();
    currentVideoInfo = videos[0];
    file = File(directory.path+"/${currentVideoInfo.videoname}.mp4");
    streamInitialize();
  }

  @override
  void dispose() {
    flickManager.dispose();
    videos.clear();
    file.delete();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: drawer(),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Stack(
          children: [
            Column(
              children: [
                FlickVideoPlayer(flickManager: flickManager),
                SizedBox(height: 25.0,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: Material(
                        color: Colors.black12, // Button color
                        child: InkWell(
                          splashColor: Colors.grey, // Splash color
                          onTap: () {
                            if(selectedIndex <= videos.length - 1 && selectedIndex > 0)
                              {
                                setState(() {
                                  File(directory.path+"/${currentVideoInfo.videoname}.mp4").delete();
                                  selectedIndex = selectedIndex -1;
                                  currentVideoInfo = videos[selectedIndex];
                                  streamVideo = videos[selectedIndex].videoUrl;
                                });
                                compareOnlineStreamOrStorageStream();
                              }
                          },
                          child: const SizedBox(width: 40, height: 40, child: Icon(Icons.arrow_back_ios,size: 17,)),
                        ),
                      ),
                    ),

                    RaisedButton(
                      color: Colors.white,
                      padding: const EdgeInsets.only(left: 15,right: 15,top: 8,bottom: 8),
                      onPressed: () async{
                        if(_ontab == false){
                          setState(() {_ontab = true;});
                        }else{
                          setState(() {_ontab = false;});
                        }

                        Map<Permission, PermissionStatus> statuses = await [Permission.storage, Permission.videos].request();

                        if(await File(directory.path+"/${currentVideoInfo.videoname}.mp4").exists() == true)
                        {
                          dialogBox(context,"Warning", "Already Downloaded File... !");
                        }else{
                          if(statuses[Permission.storage]!.isGranted){
                            var dir = await DownloadsPathProvider.downloadsDirectory;
                            if(dir != null){
                              String savename = "${currentVideoInfo.videoname}.mp4";
                              String savePath = dir.path + "/$savename";
                              //output:  /storage/emulated/0/Download/banner.png
                              try {
                                await Dio().download(currentVideoInfo.videoUrl, savePath,
                                    onReceiveProgress: (received, total) {
                                      if (total != -1) {
                                        print((received / total * 100).toStringAsFixed(0) + "%");
                                      }
                                    });
                                dialogBox(context,"Sucessfull","File Downloaded..!");
                                File encryptedFile = await fileCryptor.encrypt(inputFile: "${currentVideoInfo.videoname}.mp4", outputFile: "${currentVideoInfo.videoname}.aes");
                                File(directory.path+"/${currentVideoInfo.videoname}.mp4").delete();
                              } on DioError catch (e) {
                                dialogBox(context,"Warning", e.message);
                              }
                            }
                          }else{
                            dialogBox(context,"Permission", "No permission to read and write !");
                          }
                        }
                      },
                      child:  Row(
                        children: const <Widget>[
                          Icon(Icons.download,size: 19,color: Colors.green,),
                          SizedBox(width: 10,),
                          Text("Download"),
                        ],
                      ),
                    ),

                    ClipOval(
                      child: Material(
                        color: Colors.black12,
                        child: InkWell(
                          splashColor: Colors.grey,
                          onTap: () {
                            if(selectedIndex < videos.length - 1 && selectedIndex >= 0)
                            {
                              setState(() {
                                File(directory.path+"/${currentVideoInfo.videoname}.mp4").delete();
                                selectedIndex = selectedIndex +1;
                                currentVideoInfo = videos[selectedIndex];
                                streamVideo = videos[selectedIndex].videoUrl;
                              });
                              compareOnlineStreamOrStorageStream();
                            }
                          },
                          child: const SizedBox(width: 40, height: 40, child: Icon(Icons.arrow_forward_ios,size: 17,)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0,),
                Container(
                  height: MediaQuery.of(context).size.height * .65,
                  width: MediaQuery.of(context).size.width * 1,
                  child: ListView.separated(
                    separatorBuilder: (context, index) => const SizedBox(height: 10,),
                      shrinkWrap: true,
                      itemCount: videos.length,
                      itemBuilder: (context,index){
                        return Padding(
                          padding: const EdgeInsets.only(left: 20,right: 20),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color:index == selectedIndex ? Colors.blue : Colors.black26,
                            ),
                            padding: const EdgeInsets.only(top: 5,bottom: 5),
                            width: MediaQuery.of(context).size.width * 1,
                            //color: Colors.green,
                            child: ListTile(
                              leading: InkWell(
                                onTap: () async{
                                  setState(() {
                                    selectedIndex = index;
                                    File(directory.path+"/${currentVideoInfo.videoname}.mp4").delete();
                                    currentVideoInfo = videos[index];
                                    streamVideo = videos[index].videoUrl;
                                    acessingFilefromInternalStoraqge();
                                  });
                                  compareOnlineStreamOrStorageStream();
                                },
                                child: ConstrainedBox(
                                    constraints: const BoxConstraints(minWidth: 50, minHeight: 50),
                                    child: Image.asset(videos[index].image, width: 50, height: 50,)),
                              ),
                              title: Text(videos[index].videoname, style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold,color: Colors.white),),
                              subtitle: Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Text(videos[index].videoid.toString(), style: const TextStyle(fontWeight: FontWeight.bold),),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                  ),
                ),
              ],
            ),

            _ontab == true ? const SizedBox(): Positioned(
              top: 55,
              right: 20,
              child: GestureDetector(
                onTap: () => scaffoldKey.currentState!.openDrawer(),
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Image.asset("assets/images/usericon.png", fit: BoxFit.cover,)
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void acessingFilefromInternalStoraqge() async{
    if(await File(directory.path+"/${currentVideoInfo.videoname}.aes").exists() == true){
      File decryptedFile = await fileCryptor.decrypt(inputFile: "${currentVideoInfo.videoname}.aes", outputFile: "${currentVideoInfo.videoname}.mp4");
      file = File(directory.path+"/${currentVideoInfo.videoname}.mp4");
    }
  }

  void compareOnlineStreamOrStorageStream() async{
    if(await File(directory.path+"/${currentVideoInfo.videoname}.mp4").exists() == true) {
      flickManager.handleChangeVideo(VideoPlayerController.file(file));
    }else{
      flickManager.handleChangeVideo(VideoPlayerController.network(streamVideo));
    }
  }

  void videoData(){
    videos = [
      VideoClass(videoid: 1,videoUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",videoname: "Cartone CN",isDownload: false,image: "assets/images/icon.jpg"),
      VideoClass(videoid: 2,videoUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",videoname: "News -Live",isDownload: false,image: "assets/images/icon.jpg"),
      VideoClass(videoid: 3,videoUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",videoname: "Turisam",isDownload: false,image: "assets/images/icon.jpg"),
      VideoClass(videoid: 4,videoUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",videoname: "Films New",isDownload: false,image: "assets/images/icon.jpg"),
      VideoClass(videoid: 5,videoUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",videoname: "Technology",isDownload: false,image: "assets/images/icon.jpg"),
    ];
  }

  void streamInitialize() {
    if( File(directory.path+"/${currentVideoInfo.videoname}.mp4").exists() == true){
      flickManager = FlickManager(videoPlayerController:VideoPlayerController.file(file));
    }else{
      flickManager = FlickManager(videoPlayerController: VideoPlayerController.network(streamVideo),);
    }
  }

  void dialogBox(BuildContext context,String heading,String content){
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(heading),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Container(
             // color: Colors.blueAccent,
              padding: const EdgeInsets.only(left: 5,right: 5,top: 2,bottom: 2),
              child: const Text("OK"),
            ),
          ),
        ],
      ),
    );
  }

  Widget drawer(){
    String names = storage.read('name') ?? "Default";
    return Drawer(
      child:  ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
           UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.black12,
            ),
            accountName: Text(names),
            accountEmail: Text("default@gmail.com"),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.black,
              child: Text("A", style: TextStyle(fontSize: 40.0),),
            ),
          ),
          PopupMenuItem(child: ListTile(title: Text("Dark Theme"), trailing: Switch(value:Provider.of<ThemeState>(context).theme == ThemeType.DARK, onChanged: (value){
            Provider.of<ThemeState>(context,listen: false).theme = value ? ThemeType.DARK : ThemeType.LIGHT;
            setState(() {
            });
          }),)),
          Align(
              alignment: FractionalOffset.bottomCenter,
              child: Container(
                  child: Column(
                    children:  <Widget>[
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.logout),
                        onTap: () async{
                          await FirebaseAuth.instance.signOut();
                          storage.write('name', "");
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                        },
                        title: Text('Logout'),
                      ),
                      const ListTile(
                          leading: Icon(Icons.help),
                          title: Text('Help and Feedback'))
                    ],
                  )
              )
          )
        ],
      ),
    );
  }

  ///method for prevent screenshot
  Future<void> disableCapture() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }
}