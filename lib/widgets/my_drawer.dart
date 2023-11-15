import 'package:chofair_user/global/global.dart';
import 'package:chofair_user/splashScreen/splash_screen.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatefulWidget {

final String name;
final String email;

const MyDrawer({super.key, required this.name, required this.email});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> 
{

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white, //background envolve em container e aplica color
        child: ListView(
          children: [
            //drawer header
            SizedBox(
              height: 222,
              child: DrawerHeader(
                decoration: const BoxDecoration(color: Colors.white), //topo container 
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  // mainAxisSize: MainAxisSize.max,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                         const Icon(Icons.person, 
                          size: 80,
                          color: Color(0xFF222222)),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                             Text("Olá, ${widget.name}",
                             style: const TextStyle(
                              fontSize: 18,
                              color: Color(0xFF222222),
                              fontWeight: FontWeight.bold
                            ),
                             ),
                             const SizedBox(height: 10),
                             Text(widget.email.toString(),
                             style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF222222),
                            ),
                             ),  
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 12),
          
          //drawer body
          GestureDetector(
            onTap: () {
              
            },
            child: const ListTile(
              leading: Icon(Icons.settings, color: Color(0xFF222222), size: 40),
              title: Text(
                "Minha Conta",
                style: TextStyle(
                  color: Color(0xFF222222), fontSize: 18
                )
              ),
      
            ),
          ),
          GestureDetector(
            onTap: () {
              
            },
            child: const ListTile(
              leading: Icon(Icons.history, color: Color(0xFF222222), size: 40,),
              title: Text(
                "Histórico",
                style: TextStyle(
                  color: Color(0xFF222222), fontSize: 18
                )
              ),
      
            ),
          ),
          GestureDetector(
            onTap: () {
              
            },
            child: const ListTile(
              leading: Icon(Icons.info, color: Color(0xFF222222), size: 40,),
              title: Text(
                "Sobre o App",
                style: TextStyle(
                  color: Color(0xFF222222), fontSize: 18
                )
              ),
      
            ),
          ),
          const Divider(
                      height: 1,
                      thickness: 0.1,
                      color: Colors.grey,
                    ),
          GestureDetector(
            onTap: () {
              fAuth.signOut();
              const snackBar = SnackBar(
            content: Text('Você saiu da sua conta.', textAlign: TextAlign.center),
            duration: Duration(seconds: 6),
            backgroundColor: Colors.red);
          ScaffoldMessenger.of(context).showSnackBar(snackBar,
          
          );
              Navigator.push(context, MaterialPageRoute(builder: (c) => const MySplashScreen()));
            },
            
            child: const ListTile(
              leading: Icon(Icons.logout, color: Color(0xFF222222), size: 40),
              title: Text(
                "Sair da Conta",
                style: TextStyle(
                  color: Color(0xFF222222), fontSize: 18
                )
              ),
      
            ),
          ),
      
      
          ],
        ),
      ),
    );
  }
}