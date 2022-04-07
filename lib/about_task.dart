import 'package:flutter/material.dart';
import 'package:todo/hive/todo_hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AboutTaskScreen extends StatefulWidget {
  AboutTaskScreen({Key? key, required this.dataModel, required this.dataBox, required this.modelKey}) : super(key: key);

  late DataModel dataModel;
  late Box<DataModel> dataBox;
  late int modelKey;

  @override
  State<AboutTaskScreen> createState() => _AboutTaskScreenState();
}

class _AboutTaskScreenState extends State<AboutTaskScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.arrow_back),
            onPressed: (){Navigator.pop(context);},
          ),
          body: Column(
            children: [
              Container(
                padding: EdgeInsets.all(20),
                child: Text(widget.dataModel.title, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
              ),
              const Divider(thickness: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(

                      value: widget.dataModel.complete,
                      onChanged: (a){
                        DataModel dataModel = DataModel(
                            title: widget.dataModel.title,
                            description: widget.dataModel.description,
                            complete: !(widget.dataModel.complete)
                        );
                        widget.dataBox.put(widget.modelKey, dataModel);
                        setState(() {
                          widget.dataModel = dataModel;
                        });
                      })
                ],
              ),
              const Divider(thickness: 10,),
              Container(
                padding: const EdgeInsets.all(20),
                child: Text(widget.dataModel.description, style: const TextStyle(fontSize: 18),),
              )
            ],
          ),
        )
    );
  }
}
