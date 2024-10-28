import 'dart:async';
import 'dart:ui';

import 'package:alarm_smoking/background_service.dart';
import 'package:alarm_smoking/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


DatabaseReference _countRef = FirebaseDatabase.instance.ref('SensorDat');//       FirebaseDatabase.instance.ref('Data/da6J63iVOSh2YdTFrHP22NPQmWw1/readings');
Map dataChild=<dynamic,dynamic>{};
int temp=1;
class AlarmWidgetState extends StatefulWidget {
  const AlarmWidgetState({super.key});

  @override
  State<AlarmWidgetState> createState() => _AlarmWidgetStateState();
}

class _AlarmWidgetStateState extends State<AlarmWidgetState> {
  addValueToSF(int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.reload();
    prefs.setInt('Value', value);
  }

  @override
    void initState(){
    init(); getData();
    super.initState();
  }

  Future<void> init() async {    
    final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
     
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
    
  );
 
  }

  void getData() {    
    _countRef.onValue.listen((DatabaseEvent event){
    setState(() {
        dataChild=event.snapshot.value as Map;
        addValueToSF(dataChild['sensor1']+dataChild['sensor2']+dataChild['sensor3']);
        print('add data');
      });
    });
  }

  @override
  bool operator ==(Object other) {
    // TODO: implement ==
    return super == other;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 223, 109, 2),
        //centerTitle: true,
        title: const Text("",style: TextStyle(fontSize: 17,color: Colors.white,letterSpacing: 0.53),
                  ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            //bottom: Radius.circular(30)
          )
        ),

        bottom: PreferredSize( 
            preferredSize: const Size.fromHeight(40.0), 
            child: getAppBottomView()
)
        
        
        
        ),
        
      body: Container(
        color: Colors.grey[200],
        padding: const EdgeInsets.all(10),
        child: ListView(children: [
          Card(
            elevation: 0,
            color: dataChild['sensor1']==0 ? Colors.blue:Colors.red,
            child:  ListTile(
              title: const Text('WC 1'),
              subtitle: const Text('Phòng số 1'),
              trailing: const Icon(Icons.arrow_forward),
              leading: dataChild['sensor1']==0?  const Icon(Icons.smoke_free,size:32,):const Icon(Icons.smoking_rooms),
              contentPadding: const EdgeInsets.all(20),
              dense: true,
              iconColor: Colors.white,
              textColor: Colors.white,
              //tileColor: Colors.indigo,
              //enabled: false,
            ),
          ),
             Card(
            elevation: 0,
            color: dataChild['sensor2']==0 ? Colors.blue:Colors.red,
            child:  ListTile(
              title: const Text('WC 2'),
              subtitle: const Text('Phòng số 2'),
              trailing: const Icon(Icons.arrow_forward),
              leading: dataChild['sensor2']==0?  const Icon(Icons.smoke_free,size:30,):const Icon(Icons.smoking_rooms),
              contentPadding: const EdgeInsets.all(20),
              dense: true,
              iconColor: Colors.white,
              textColor: Colors.white,
              //tileColor: Colors.indigo,
              //enabled: false,
            ),
          ),
            Card(
            elevation: 0,
            color: dataChild['sensor3']==0 ? Colors.blue:Colors.red,
            child:  ListTile(
              title: const Text('WC 3'),
              subtitle: const Text('Phòng số 3'),
              trailing: const Icon(Icons.arrow_forward),
              leading: dataChild['sensor3']==0?  const Icon(Icons.smoke_free,size:30,):const Icon(Icons.smoking_rooms),
              contentPadding: const EdgeInsets.all(20),
              dense: true,
              iconColor: Colors.white,
              textColor: Colors.white,
              //tileColor: Colors.indigo,
              //enabled: false,
            ),
          ),
        ],),
      ),
    );
  }
  
}

Widget getAppBottomView() {
    return Container(
      padding: const EdgeInsets.only(left: 30, bottom: 10),
      child: Row(
        children: [
          getProfileView(),
          Container(
            margin: const EdgeInsets.only(left: 20),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Giám sát hút thuốc',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
                Text(
                  ' c2.tanhung.baria.brvt@moet.edu.vn',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
                Text(
                  ' 0254 3826069',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

Widget getProfileView() {
    return const Stack(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.white,
          backgroundImage: AssetImage('assets/images/logo.jpg'),          
        ),
        
      ],
    );
  }
 
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // bring to foreground
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    DartPluginRegistrant.ensureInitialized();
    int temp=await getValuesSF();
    //print(temp);
    if(temp>0)
    {
      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          
          service.setForegroundNotificationInfo(
            title: "Alarm smoking Tân Hưng",
            content: "Updated at ${DateTime.now()}",
            
          );
        }
      }
    }
    /// you can see this log in logcat
    //print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');
    
    service.invoke(
      'update',
      {
        //"current_date": DateTime.now().toIso8601String(),
        "sensor1": dataChild['sensor1'],
        
      },
    );
  });
}

getValuesSF() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //Return String
  prefs.reload();
  int? value = prefs.getInt('Value');
  if (value == null) {
    print('get value: $value');
    return 0;
  }
  print('get value: $value');
  return value;
}