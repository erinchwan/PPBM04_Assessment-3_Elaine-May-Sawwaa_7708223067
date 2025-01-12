import 'dart:convert'; // For JSON encoding/decoding
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({Key? key}) : super(key: key);

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, String>> contacts = []; // List to store contacts
  late TabController _tabController;
  final nameController = TextEditingController();
  String phoneNumber = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadContacts(); // Load saved contacts on initialization
  }

  /// Loads contacts from SharedPreferences
  Future<void> _loadContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedContacts = prefs.getString('contacts');
    if (savedContacts != null) {
      setState(() {
        contacts = List<Map<String, String>>.from(json.decode(savedContacts));
      });
    }
  }

  /// Saves contacts to SharedPreferences
  Future<void> _saveContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('contacts', json.encode(contacts));
  }

  /// Adds a new contact and saves it persistently
  Future<void> _addContact(String name, String number) async {
    setState(() {
      contacts.add({'name': name, 'number': number});
    });
    await _saveContacts(); // Save updated contact list
  }

  /// Deletes a contact and saves the updated list
  Future<void> _deleteContact(int index) async {
    setState(() {
      contacts.removeAt(index);
    });
    await _saveContacts(); // Save updated contact list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("Contacts"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.black54,
          tabs: const [
            Tab(text: "Contact"),
            Tab(text: "Call"),
            Tab(text: "Message"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildContactsTab(),
          buildAddContactTab(),
          const Center(child: Text("Message feature coming soon")),
        ],
      ),
    );
  }

  /// Builds the Contacts tab
  Widget buildContactsTab() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    contacts[index]
                        ['name']![0], // Get the first letter of the name
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
                title: Text(contacts[index]['name']!),
                subtitle: Text(contacts[index]['number']!),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _deleteContact(index); // Delete contact
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Builds the Add Contact tab
  Widget buildAddContactTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Enter Name'),
              ),
              const SizedBox(height: 10),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Number: $phoneNumber",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty &&
                      phoneNumber.isNotEmpty) {
                    _addContact(nameController.text, phoneNumber);
                    nameController.clear(); // Clear name input field
                    setState(() {
                      phoneNumber = ""; // Reset phone number
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please fill out all fields')),
                    );
                  }
                },
                child: const Text('Add Contact'),
              ),
            ],
          ),
        ),
        const Divider(),
        buildKeypad(),
      ],
    );
  }

  /// Builds the number keypad
  Widget buildKeypad() {
    return Column(
      children: [
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.2,
          ),
          itemCount: 12,
          itemBuilder: (context, index) {
            if (index < 9) {
              return keypadButton((index + 1).toString());
            } else if (index == 9) {
              return keypadButton("Clear", isClear: true);
            } else if (index == 10) {
              return keypadButton("0");
            } else {
              return keypadButton("OK", isSave: true);
            }
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  /// Builds individual keypad buttons
  Widget keypadButton(String label,
      {bool isClear = false, bool isSave = false}) {
    return InkWell(
      onTap: () {
        setState(() {
          if (isClear) {
            if (phoneNumber.isNotEmpty) {
              phoneNumber = phoneNumber.substring(0, phoneNumber.length - 1);
            }
          } else if (isSave) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Number $phoneNumber saved!')),
            );
          } else {
            phoneNumber += label;
          }
        });
      },
      child: Center(
        child: isClear
            ? const Icon(Icons.backspace_outlined, size: 32, color: Colors.red)
            : isSave
                ? const Icon(Icons.check_circle, size: 32, color: Colors.green)
                : Text(
                    label,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
      ),
    );
  }
}
