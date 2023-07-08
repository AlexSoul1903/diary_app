import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

//Alex Manuel Frias Molina.
//Matricula: 2021-1954.

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text('Bienvenido. Cualquier inquietud contactar a:'),
            accountEmail: Text('alexmanuel19frias@gmail.com'),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.asset(
                  'assets/imgs/diary.png',
                  fit: BoxFit.cover,
                  width: 90,
                  height: 90,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.home,
              color: Colors.green,
            ),
            title: const Text('Home.'),
            onTap: () => Navigator.pushNamed(context, '/'),
          ),
          ListTile(
            leading: const Icon(Icons.contact_mail, color: Colors.blueAccent),
            title: const Text('Contratame.'),
            onTap: () => Navigator.pushReplacementNamed(context, '/Contratame'),
          ),
        ],
      ),
    );
  }
}
