import 'dart:developer';

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

  void _addData(Person person) {
    boxPerson.add(person);
    _nameController.clear();
    _ageController.clear();
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
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(
                height: 8,
              ),
              TextField(
                controller: _ageController,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(
                height: 8,
              ),
              ElevatedButton(
                onPressed: () {
                  final person = Person(_nameController.text.trim(),
                      int.tryParse(_ageController.text.trim()) ?? 0);
                  _addData(person);
                },
                child: const Text("Save"),
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
                          return ListTile(
                            title: Text(person.name),
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
    await boxPerson.close();
    super.dispose();
  }
}
