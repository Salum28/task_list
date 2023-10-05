import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Atributes
  List _taskList = [];
  Map<String, dynamic> _lastRemovedTask = {};
  final TextEditingController _taskController = TextEditingController();

  // Methods
  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/data.json');
  }


  _saveFile() async {
    File file = await  _getFile();
    String data = json.encode(_taskList);
    file.writeAsString(data);
  }

  _saveTask() {
    String typedText = _taskController.text;

    // Adding Data
    Map<String, dynamic> task = {};
    task['title'] = typedText;
    task['done'] = false;
    setState(() {
      _taskList.add(task);
    });
    _saveFile();
    _taskController.text = '';
  }

  _readFile() async {
    try {
      final File file = await _getFile();
      return file.readAsString();
    } catch(e) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _readFile().then((data) {
      setState(() {
        _taskList = json.decode(data);
      });
    });
  }

  Widget? createListItem(BuildContext context, int index) {
    return Dismissible(
        direction: DismissDirection.startToEnd,
        background: Container(
            color: Colors.red,
            padding: const EdgeInsets.only(right: 10),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.delete)
              ],
            )
        ),
        key: Key(DateTime.now().microsecondsSinceEpoch.toString()),
        onDismissed: (direction) {
          // Retrieve last removed item
          _lastRemovedTask = _taskList[index];

          // Remove item from list
          setState(() {
            _taskList.removeAt(index);
          });
          _saveFile();

          // Snackbar
          final snackbar = SnackBar(
            duration: const Duration(seconds: 5),
            content: const Text('Você confirma a remoção da tarefa?'),
            action: SnackBarAction(
              label: 'Desfazer',
              onPressed: () {
                // Inserindo item novamente
                setState(() {
                  _taskList.insert(index, _lastRemovedTask);
                });
                _saveFile();
              },
            )
          );
          ScaffoldMessenger.of(context).showSnackBar(snackbar);
        },
        child: CheckboxListTile(
            title: Text(_taskList[index]['title']),
            value: _taskList[index]['done'],
            onChanged: (changedValue) {
              setState(() {
                _taskList[index]['done'] = changedValue;
              });
              _saveFile();
            }
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Tarefas'),
        backgroundColor: Colors.purple,
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _taskList.length,
                itemBuilder: createListItem
              )
            )
          ],
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Adicionar Tarefa'),
                content: TextField(
                  keyboardType: TextInputType.text,
                  controller: _taskController,
                  decoration: const InputDecoration(
                    labelText: 'Tarefa'
                  ),
                  onChanged: (text) {

                  },
                ),
                actions: [
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith((states) => Colors.purple)
                    ),
                    child: const Text('Cancelar')
                  ),
                  FilledButton(
                    onPressed: () {
                      _saveTask();
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith((states) => Colors.purple)
                    ),
                    child: const Text('Salvar')
                  )
                ],
              );
            }
          );
        },
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
