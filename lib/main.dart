import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'hive/todo_hive.dart';
import 'about_task.dart';


void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(DataModelAdapter());
  await Hive.openBox<DataModel>('task');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/' : (context) => HomeScreen()
      },
    );
  }
}

enum DataFilter {ALL, COMPLETED, PROGRESS}

class HomeScreen extends StatefulWidget {

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<DataModel> dataBox;
  ValueNotifier<int> _actualFilter = ValueNotifier<int>(0);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dataBox = Hive.box<DataModel>('task');
  }

  void _floatingOnPress(BuildContext context){
    String title = '';
    String description = '';

    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        // title: Row(
        //   crossAxisAlignment: CrossAxisAlignment.center,
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: const [
        //     Text('Добавить таск'),
        //   ],
        // ),
        content: Container(
          height: 200,
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Заголовок'
                ),
                onChanged: (a){title = a;},
              ),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Описание'
                ),
                onChanged: (a){description = a;},
              ),
              Container(
                height: 35,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(8)
                ),
                //padding: const EdgeInsets.fromLTRB(2, 2, 4, 2),
                child: TextButton(
                  child: const Text('Добавить', style: TextStyle(color: Colors.white, fontSize: 16),),
                  onPressed: () {
                    if(title == ''){
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Введите заголовок')));
                    } else {
                        DataModel dataModel = DataModel(title: title, description: description, complete: false);
                        dataBox.add(dataModel);
                        Navigator.pop(context);
                    }}),
                ),
            ],
          ),
        )
      );
    });
  }

  void showTaskData(BuildContext context, DataModel dataModel, int key){
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => AboutTaskScreen(dataModel: dataModel,
          dataBox: dataBox, modelKey: key,))
    );
  }

  Widget drawerBody(BuildContext context){
    const TextStyle textStyle = TextStyle(color: Colors.white, fontSize: 24);
    return Center(
      child: Container(
        height: 250,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const FlutterLogo(size: 30,),
            TextButton(onPressed: (){setState(() {_actualFilter.value = 0;}); Navigator.pop(context);}, child: const Text('Все', style: textStyle,)),
            TextButton(onPressed: (){setState(() {_actualFilter.value = 1;}); Navigator.pop(context);}, child: const Text('Выполненные', style: textStyle,)),
            TextButton(onPressed: (){setState(() {_actualFilter.value = 2;}); Navigator.pop(context);}, child: const Text('Не выполненные', style: textStyle,))
          ],
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('TASK'),
        actions: [
          IconButton(onPressed: () => _floatingOnPress(context), icon: Icon(Icons.add))
        ],
      ),
      drawer: Drawer(
        backgroundColor: Theme.of(context).primaryColor,
        child: drawerBody(context),
      ),
      body: ValueListenableBuilder(
        valueListenable: dataBox.listenable(),
        builder: (context, Box<DataModel> items, _){
          return ValueListenableBuilder<int>(
              valueListenable: _actualFilter,
              builder: (context, filterIndex, _){
                print(filterIndex);
                List<int> keys = items.keys.cast<int>().toList();
                if (DataFilter.ALL.index == filterIndex){
                  List<int> keys = items.keys.cast<int>().toList();
                } else if (DataFilter.COMPLETED.index == filterIndex){
                  keys = items.keys.cast<int>().where((key)
                  => items.get(key)!.complete).toList();
                } else if (DataFilter.PROGRESS.index == filterIndex){
                  keys = items.keys.cast<int>().where((key)
                  => !items.get(key)!.complete).toList();
                }
                return ListView.separated(
                    itemBuilder: ((context, index) {
                      final int key = keys[index];
                      final DataModel? data = items.get(key);
                      return InkWell(
                        onLongPress: (){dataBox.delete(key);},
                        onTap: () => showTaskData(context, data!, key),
                        child: Container(
                          margin: const EdgeInsets.only(left: 10, right: 10),
                          padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data!.title,
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),),
                                    Text(
                                      data.description,
                                      overflow: TextOverflow.ellipsis,),
                                  ],
                                ),
                              ),
                              Checkbox(
                                  value: data.complete,
                                  onChanged: (a){
                                    DataModel dataModel = DataModel(
                                        title: data.title,
                                        description: data.description,
                                        complete: !(data.complete)
                                    );
                                    dataBox.put(key, dataModel);
                                  })
                            ],
                          ),
                        ),
                      );
                    }),
                    separatorBuilder: (_, index) => const Divider(),
                    itemCount: keys.length
                );
              });
        },
      ),
    );
  }
}
