
import 'package:chofair_user/authentication/password_recover.dart';
import 'package:chofair_user/authentication/signup_screen.dart';
import 'package:chofair_user/global/global.dart';
import 'package:chofair_user/splashScreen/splash_screen.dart';
import 'package:chofair_user/widgets/progress_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key}); //se der erros, remover


  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  TextEditingController email = TextEditingController();
  TextEditingController senha = TextEditingController();

validateForm() {
    
    if(!email.text.contains('@')) {
      const snackBar = SnackBar(
          content: Text('Utilize um e-mail válido', textAlign: TextAlign.center),
          duration: Duration(seconds: 4),backgroundColor: Colors.red);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // Fluttertoast.showToast(msg: "Insira um e-mail válido.");
    }
    else if(senha.text.isEmpty) {
      const snackBar = SnackBar(
          content: Text('Digite sua senha corretamente', textAlign: TextAlign.center),
          duration: Duration(seconds: 4),backgroundColor: Colors.red);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // Fluttertoast.showToast(msg: "Insira sua senha");
    }
    else {
      loginUserNow();
    }
  }

  //com try-catch
  loginUserNow() async {
  try {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext c) {
        return ProgressDialog(message: "Processando...");
      },
    );
    
    final User? firebaseUser = (
      await fAuth.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: senha.text.trim(),
      )
    ).user;

    if (firebaseUser != null) {
      DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("users");
      final driverKey = await usersRef.child(firebaseUser.uid).once();
      final snap = driverKey.snapshot;
      
      if (snap.value != null) {
        currentFirebaseUser = firebaseUser;
        const snackBar = SnackBar(
          content: Text('Entrada com sucesso', textAlign: TextAlign.center),
          duration: Duration(seconds: 4), backgroundColor: Colors.green);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.push(context, MaterialPageRoute(builder: (c) => const MySplashScreen()));
      } 
    } 
  } catch (e) {
    Navigator.pop(context);
    const snackBar = SnackBar(
          content: Text('E-mail ou senha incorretos', textAlign: TextAlign.center),
          duration: Duration(seconds: 4),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

  Future<void> resetPassword(String email) async {
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    // E-mail de recuperação de senha enviado com sucesso
  } catch (e) {
    const snackBar = SnackBar(
          content: Text('Erro ao enviar e-mail de recuperação de senha', textAlign: TextAlign.center),
          duration: Duration(seconds: 4),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
    print("Erro ao enviar e-mail de recuperação de senha: $e");
    // Trate o erro, como exibir uma mensagem de erro para o usuário
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [


          // Widget para a imagem de fundo em tela inteira
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/userpic1.jfif"), // Substitua pelo caminho da sua imagem de fundo
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Widget para a cor com transparência
        Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
         const Color(0xFFFFFFFF).withOpacity(0.99),          
         Colors.white.withOpacity(0.95), // Cor direita com transparência
      ],
    ),
  ),
  child: const SizedBox.expand(), // Isso faz com que o gradiente ocupe todo o espaço disponível
),



          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                   const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset("images/chofairlogo.png",
                      height: 250,
                      width: 250,
                      fit: BoxFit.fitWidth,),
                    ), 
                    const SizedBox(height: 10),
                    const Text(
                      "ENTRAR COMO PASSAGEIRO",
                      style: TextStyle(
                        fontSize: 16,
                        color:  Color(0xFF222222),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      autofocus: true,
                      style: const TextStyle(color: Color(0xFF222222)),
                      controller: email,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "E-mail",
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF222222))),
                        labelStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    TextFormField(
                      style: const TextStyle(color: Color(0xFF222222)),
                      controller: senha,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Senha",
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF222222))),
                        labelStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),     
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  SizedBox(
                    width: double.infinity, height: 45,
                    child: ElevatedButton(
                      onPressed: () {
                        validateForm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF222222),
                        shadowColor: const Color.fromARGB(255, 0, 0, 0),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)
                        ),
                        fixedSize: const Size(200, 45)
                      ),
                      child: const Text(
                        "ENTRAR",
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextButton(
                    child: const Text(
                      'Esqueci minha senha',
                      style: TextStyle(color: Color(0xFF222222), fontSize: 11),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (c) => const PasswordRecover()));
                    },
                    ),
                  TextButton(
                    child: const Text(
                      'Ainda não tem uma conta? Crie agora!',
                      style: TextStyle(color: Color(0xFF222222)),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (c) => SignUpScreen()));
                    },
                    )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ENTRE O LOGINUSERNOW ENTRE O CATCH
 else {
      Navigator.pop(context);
      // Fluttertoast.showToast(msg: "Erro ao entrar");
       const snackBar = SnackBar(
          content: Text('Não existe cadastro de passageiro com esse e-mail', textAlign: TextAlign.center),
          duration: Duration(seconds: 6),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
*/ 

//LOGINUSERNOW ANTIGO
/*  loginUserNow() async {
 // try{ trocar pelo try catch
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext c) {
          return ProgressDialog(message: "Processando...");
        }
        );
        
        final User? firebaseUser = (
          await fAuth.signInWithEmailAndPassword(
            email: email.text.trim(),
            password: senha.text.trim(),
          ).catchError((msg){
            Navigator.pop(context);
            Fluttertoast.showToast(msg: 'Error: $msg');
          })
          ).user;
        
          if(firebaseUser != null) {

            DatabaseReference usersRef= FirebaseDatabase.instance.ref().child("users");
            usersRef.child(firebaseUser.uid).once().then((driverKey)
            {
              final snap = driverKey.snapshot;
              if (snap.value != null)
              {
                currentFirebaseUser = firebaseUser;
                const snackBar = SnackBar( //abre snackbar
                  content: Text('Entrada com sucesso', textAlign: TextAlign.center),
                  duration: Duration(seconds: 6), // Duração da exibição do SnackBar
                  backgroundColor: Colors.green);
                  // Exibir o SnackBar na tela
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                // Fluttertoast.showToast(msg: "Entrada com sucesso",
                // // toastLength: Toast.LENGTH_LONG, 
                // // gravity: ToastGravity.BOTTOM,
                // // timeInSecForIosWeb: 2,
                // // backgroundColor: Colors.red,
                // // textColor: Colors.white,
                // // fontSize: 15,
                // );
                // ignore: use_build_context_synchronously
                Navigator.push(context, MaterialPageRoute(builder: (c)=> const MySplashScreen()));
              }
               else {
            Fluttertoast.showToast(msg: "Não existe cadastro de passageiro com esse e-mail");
            fAuth.signOut();
            Navigator.push(context, MaterialPageRoute(builder: (c)=> const MySplashScreen()));
          }
            }); 
            
          }
          else {
            // ignore: use_build_context_synchronously
            Navigator.pop(context);
            Fluttertoast.showToast(msg: "Erro ao entrar");
          }
  }*/

  //ELSE depois do if snap
  // else {
      //   // Fluttertoast.showToast(msg: "Não existe cadastro de passageiro com esse e-mail");
      //   const snackBar = SnackBar(
      //     content: Text('Não existe cadastro de passageiro com esse e-mail', textAlign: TextAlign.center),
      //     duration: Duration(seconds: 6),
      //     backgroundColor: Colors.red);
      //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
      //   fAuth.signOut();
      //   Navigator.push(context, MaterialPageRoute(builder: (c) => const MySplashScreen()));
      // }