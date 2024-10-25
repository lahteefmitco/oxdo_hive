import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:oxdo_hive/person/person.dart';

late final Box<Person> boxPerson;
void main() async {
  // Initialize Hive and register adapters if needed
  await Hive.initFlutter();

  // Register the adapter
  Hive.registerAdapter(PersonAdapter());

  //open a new personBox
  boxPerson = await Hive.openBox<Person>("personBox");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Hive',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _ageFocus = FocusNode();

  SaveButtonMode _saveButtonMode = SaveButtonMode.save;
  int? _indexToUpdate;

  void _addPerson(Person person) async {
    await boxPerson.add(person);
    _nameController.clear();
    _ageController.clear();

    _unFocusAllFocusNode();
  }

  void _bringPersonToUpdate(Person person, int index) async {
    _nameController.text = person.name;
    _ageController.text = person.age.toString();

    _indexToUpdate = index;

    _saveButtonMode = SaveButtonMode.edit;

    setState(() {});
  }

// Update person
  void _updatePerson(Person person) async {
    await boxPerson.putAt(_indexToUpdate!, person);
    _nameController.clear();
    _ageController.clear();
    _saveButtonMode = SaveButtonMode.save;
    _indexToUpdate = null;
    setState(() {});
    _unFocusAllFocusNode();

  }

  // delete person
  void _deletePerson(int index) async {
    await boxPerson.deleteAt(index);
  }

  // un focus text fields,  hide keyboard
  void _unFocusAllFocusNode() {
    _nameFocusNode.unfocus();
    _ageFocus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Hive"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _nameController,
                focusNode: _nameFocusNode,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(
                height: 8,
              ),
              TextField(
                controller: _ageController,
                focusNode: _ageFocus,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(
                height: 8,
              ),
              ElevatedButton(
                onPressed: () {
                  if (_saveButtonMode == SaveButtonMode.save) {
                    // To save
                    final person = Person(_nameController.text.trim(),
                        int.tryParse(_ageController.text.trim()) ?? 0);
                    _addPerson(person);
                  } else {
                    // To update
                    final person = Person(_nameController.text.trim(),
                        int.tryParse(_ageController.text.trim()) ?? 0);
                    _updatePerson(person);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _saveButtonMode == SaveButtonMode.save
                      ? Colors.green
                      : Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                    _saveButtonMode == SaveButtonMode.save ? "Save" : "Update"),
              ),
              const SizedBox(
                height: 8,
              ),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: boxPerson.listenable(),
                  builder: (context, Box<Person> box, _) {
                    final values = box.values.toList().cast<Person>();
                    return ListView.separated(
                        itemBuilder: (context, index) {
                          final person = values[index];
                          return Card(
                            child: ListTile(
                              title: Text("Name:- ${person.name}"),
                              subtitle: Text("Age:- ${person.age}"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      // take data to update
                                      _bringPersonToUpdate(person, index);
                                    },
                                    icon: const Icon(Icons.edit),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      _deletePerson(index);
                                    },
                                    color: Colors.red,
                                    icon: const Icon(Icons.delete),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const Divider();
                        },
                        itemCount: values.length);
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() async {
    _nameController.dispose();
    _ageController.dispose();

    _nameFocusNode.dispose();
    _ageFocus.dispose();

    await boxPerson.close();
    super.dispose();
  }
}

enum SaveButtonMode { save, edit }
