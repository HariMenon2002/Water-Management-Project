import 'package:flutter/material.dart';
import 'package:contactus/contactus.dart';

class Contact extends StatefulWidget {
  const Contact({super.key});

  @override
  State<Contact> createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body:ContactUs(
        cardColor: Colors.white,
        textColor: Colors.teal.shade900,
        logo: const AssetImage('images/logo.jpg'),
        email: 'ultronhari7@gmail.com',
        companyName: '',
        companyColor: Colors.teal.shade100,
        dividerThickness: 2,
        phoneNumber: '+917818044311',
        website: 'https://google.com',

        tagLine: 'Water Treatment',
        taglineColor: Colors.white,

      ),

    );
  }
}
