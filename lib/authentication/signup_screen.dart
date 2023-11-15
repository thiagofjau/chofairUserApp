import 'package:chofair_user/authentication/login_screen.dart';
import 'package:chofair_user/global/global.dart';
import 'package:chofair_user/splashScreen/splash_screen.dart';
import 'package:chofair_user/widgets/progress_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';


class SignUpScreen extends StatefulWidget {

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController nome = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController celular = TextEditingController();
  TextEditingController senha = TextEditingController();

  validateForm() { ///substituir pelo VALIDATOR
    if(nome.text.length < 3) {
      const snackBar = SnackBar(
          content: Text('Digite seu nome completo', textAlign: TextAlign.center),
          duration: Duration(seconds: 4),backgroundColor: Colors.red);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // Fluttertoast.showToast(msg: "O nome deve ter pelo menos 3 letras");
    }
    else if(!email.text.contains('@')) {
      const snackBar = SnackBar(
          content: Text('Insira um e-mail válido', textAlign: TextAlign.center),
          duration: Duration(seconds: 4),backgroundColor: Colors.red);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // Fluttertoast.showToast(msg: "Insira um e-mail válido.");
    }
    else if(celular.text.isEmpty || celular.text.length < 10 || celular.text.length > 15) {
      const snackBar = SnackBar(
          content: Text('Insira um número válido', textAlign: TextAlign.center),
          duration: Duration(seconds: 4),backgroundColor: Colors.red);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // Fluttertoast.showToast(msg: "Insira um número válido");

    }
    else if(senha.text.length < 6) {
      const snackBar = SnackBar(
          content: Text('A senha deve ter pelo menos 6 caracteres', textAlign: TextAlign.center),
          duration: Duration(seconds: 4),backgroundColor: Colors.red);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // Fluttertoast.showToast(msg: "A senha deve ter pelo menos 6 caracteres");
    }
    else {
      saveUserInfoNow();
    }
  }


  //try-catch
  saveUserInfoNow() async {
  try {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext c) {
        return ProgressDialog(message: "Processando...");
      },
    );

    final User? firebaseUser = (
      await fAuth.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: senha.text.trim(),
      )
    ).user;

    if (firebaseUser != null) {
      Map userMap = {
        "id": firebaseUser.uid,
        "name": nome.text.trim(),
        "email": email.text.trim(),
        "phone": celular.text.trim(),
      };
      DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("users");
      usersRef.child(firebaseUser.uid).set(userMap);

      currentFirebaseUser = firebaseUser;
      const snackBar = SnackBar( //abre snackbar
                  content: Text('Conta criada com sucesso', textAlign: TextAlign.center),
                  duration: Duration(seconds: 6), // Duração da exibição do SnackBar
                  backgroundColor: Colors.green);
                  // Exibir o SnackBar na tela
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // ignore: use_build_context_synchronously
      Navigator.push(context, MaterialPageRoute(builder: (c) => const MySplashScreen()));
    } 
    
  } catch (e) {
    Navigator.pop(context);
    const snackBar = SnackBar( //abre snackbar
                  content: Text('E-mail já cadastrado. Utilize outro ou recupere sua senha', textAlign: TextAlign.center),
                  duration: Duration(seconds: 4), // Duração da exibição do SnackBar
                  backgroundColor: Colors.red);
                  // Exibir o SnackBar na tela
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset("images/chofairlogo.png",
                  height: 250,
                  width: 250,
                  fit: BoxFit.fitWidth),
              ),
              //const SizedBox(height: 10),
              const Text(
                "REGISTRAR COMO PASSAGEIRO",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF222222),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                autofocus: true,
                style: const TextStyle(color: Color(0xFF222222)),
                controller: nome,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: "Nome",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF9E9E9E)),
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
                controller: celular,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Celular",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color.fromRGBO(158, 158, 158, 1)),
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
                  // Navigator.push(context, MaterialPageRoute(builder: (c) => CarInfoScreen()));
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
                  "CRIAR CONTA",
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            TextButton(
                child: const Text(
                  'Já tem uma conta? Acesse aqui!',
                  style: TextStyle(color:  Color(0xFF222222)),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (c) => LoginScreen()));
                },
                )
            ],
          ),
        ),
      ),
    );
  }
}


//SE DER ERROS, VOLTAR PARA O saveUserInfoNow() ABAIXO SEM TRY-CATCH


// saveUserInfoNow() async {
//  // try{ trocar pelo try catch
//     showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext c) {
//           return ProgressDialog(message: "Processando...");
//         }
//         );
        
//         final User? firebaseUser = (
//           await fAuth.createUserWithEmailAndPassword(
//             email: email.text.trim(),
//             password: senha.text.trim(),
//           ).catchError((msg){
//             Navigator.pop(context);
//             Fluttertoast.showToast(msg: 'Error: $msg');
//           })
//           ).user;
        
//           if(firebaseUser != null) {
//             Map userMap = {
//               "id": firebaseUser.uid,
//               "name": nome.text.trim(),
//               "email": email.text.trim(),
//               "phone": celular.text.trim(),
//             };
//             DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("users");
//             usersRef.child(firebaseUser.uid).set(userMap);

//             currentFirebaseUser = firebaseUser;
//             Fluttertoast.showToast(msg: "Conta criada com sucesso");
//             // ignore: use_build_context_synchronously
//             Navigator.push(context, MaterialPageRoute(builder: (c)=> const MySplashScreen()));
//           }
//           else {
//             // ignore: use_build_context_synchronously
//             Navigator.pop(context);
//             Fluttertoast.showToast(msg: "Não foi possível criar sua conta");
//           }
//   }
// else { (SE DER ERRO VOLTAR ESSE ELSE)
    //   // ignore: use_build_context_synchronously
    //   Navigator.pop(context);
    //   Fluttertoast.showToast(msg: "Não foi possível criar sua conta");
    // }