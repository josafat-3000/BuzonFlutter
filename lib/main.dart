import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:math';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PasswordProv()),
      ],
      child: MaterialApp(
        home: HomeScreen(),
      ),
    ),
  );
}

class PasswordProv extends ChangeNotifier {
  bool _dis1 = true;
  bool _dis2 = true;
  bool _dis3 = true;
  bool _dis4 = true;

  String _password1 = '';
  String _password2 = '';
  String _password3 = '';
  String _password4 = '';

  bool get dis1 => _dis1;
  bool get dis2 => _dis2;
  bool get dis3 => _dis3;
  bool get dis4 => _dis4;

  String get password1 => _password1;
  String get password2 => _password2;
  String get password3 => _password3;
  String get password4 => _password4;

  void setDis1(bool nuevoValor) {
    _dis1 = nuevoValor;
    notifyListeners();
  }

  void setDis2(bool nuevoValor) {
    _dis2 = nuevoValor;
    notifyListeners();
  }

  void setDis3(bool nuevoValor) {
    _dis3 = nuevoValor;
    notifyListeners();
  }

  void setDis4(bool nuevoValor) {
    _dis4 = nuevoValor;
    notifyListeners();
  }

  void setPassword1(String nuevaPassword) {
    _password1 = nuevaPassword;
    notifyListeners();
  }

  void setPassword2(String nuevaPassword) {
    _password2 = nuevaPassword;
    notifyListeners();
  }

  void setPassword3(String nuevaPassword) {
    _password3 = nuevaPassword;
    notifyListeners();
  }

  void setPassword4(String nuevaPassword) {
    _password4 = nuevaPassword;
    notifyListeners();
  }

}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PrimeraPagina()),
                );
              },
              child: Text('Incrementar'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context)=>SegundaPagina()),
                );
              },
              child: Text('Visualizar'),
            ),
          ],
        ),
      ),
    );
  }
}

class PrimeraPagina extends StatefulWidget {
  @override
  _PrimeraPaginaState createState() => _PrimeraPaginaState();
}

class _PrimeraPaginaState extends State<PrimeraPagina> {
  UsbPort? _port;
  String _status = "Idle";
  List<Widget> _ports = [];
  List<Widget> _serialData = [];

  StreamSubscription<String>? _subscription;
  Transaction<String>? _transaction;
  UsbDevice? _device;

  Future<void> _connectTo(device) async {
    _serialData.clear();

    if (_subscription != null) {
      _subscription!.cancel();
      _subscription = null;
    }

    if (_transaction != null) {
      _transaction!.dispose();
      _transaction = null;
    }

    if (_port != null) {
      _port!.close();
      _port = null;
    }

    if (device == null) {
      _device = null;
      setState(() {
        _status = "Disconnected";
      });
      return;
    }

    _port = await device.create();
    if (await (_port!.open()) != true) {
      setState(() {
        _status = "Failed to open port";
      });
      return;
    }
    _device = device;

    await _port!.setDTR(true);
    await _port!.setRTS(true);
    await _port!.setPortParameters(
        115200, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

    _transaction = Transaction.stringTerminated(
        _port!.inputStream as Stream<Uint8List>, Uint8List.fromList([13, 10]));

    _subscription = _transaction!.stream.listen((String line) {
      setState(() {
        _serialData.add(Text(line));
        if (_serialData.length > 20) {
          _serialData.removeAt(0);
        }
      });
    });

    setState(() {
      _status = "Connected";
    });
  }

  Future<void> _sendData(String data) async {
    if (_port != null) {
      await _port!.write(Uint8List.fromList(data.codeUnits));
    }
  }

  void _getPorts() async {
    List<UsbDevice> devices = await UsbSerial.listDevices();

    // Filtrar dispositivos CP2102
    List<UsbDevice> cp2102Devices = devices.where((device) {
      return device.manufacturerName == "Silicon Labs" &&
          device.productName == "CP2102 USB to UART Bridge Controller";
    }).toList();

    if (cp2102Devices.isNotEmpty) {
      // Conectar automáticamente al primer dispositivo CP2102
      await _connectTo(cp2102Devices.first);
    } else {
      // No se encontraron dispositivos CP2102, desconectar
      await _connectTo(null);
    }
  }


  @override
  void initState() {
    super.initState();

    UsbSerial.usbEventStream!.listen((UsbEvent event) {
      _getPorts();
    });

    _getPorts();
  }

  @override
  void dispose() {
    super.dispose();
    _connectTo(null);
  }

  _cambiarEstado1(ps,email) {
    enviarCorreo(ps, email);
    _sendData("1\n");
    Provider.of<PasswordProv>(context, listen: false).setDis1(false);
  }

  _cambiarEstado2(ps,email) {
    enviarCorreo(ps, email);
    _sendData("2\n");
    Provider.of<PasswordProv>(context, listen: false).setDis2(false);
  }

    _cambiarEstado3(ps,email) {
    enviarCorreo(ps, email);
    _sendData("4\n");
    Provider.of<PasswordProv>(context, listen: false).setDis3(false);
  }

    _cambiarEstado4(ps,email) {
    enviarCorreo(ps, email);
    _sendData("4\n");
    Provider.of<PasswordProv>(context, listen: false).setDis4(false);
  }


  
  String generatePassword() {
  const String validChars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

  final Random random = Random();
  StringBuffer password = StringBuffer();

  for (int i = 0; i < 5; i++) {
    int randomIndex = random.nextInt(validChars.length);
    password.write(validChars[randomIndex]);
  }

  return password.toString();
}

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        duration: const Duration(seconds: 4), // Duración del mensaje en pantalla
      ),
    );
  }
  Future <void> enviarCorreo(ps,to) async{

    try {
      var from = 'josafat30000@gmail.com';
      var message = Message();
      message.subject = "Contraseña de buzon";
      message.text = 'Tu contraseña es: $ps';
      message.from = Address (from.toString());
      message.recipients.add(to);
      var smtpServer = gmail(from, "soyqvpkmblbeymck");
      await send(message, smtpServer);
    } catch (e){
      _mostrarMensaje(e.toString());
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Primera Página'),
      ),
      body: Center(
        child: Consumer<PasswordProv>(
              builder: (context, passwordProv, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Status: $_status\n'),
            Text('info: ${_port.toString()}\n'),
            ElevatedButton(
              onPressed: _port == null ? null : () {
                if (passwordProv.dis1 == true) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EmailTextField(emailController: TextEditingController(),
                    onPress: (email){
                      Provider.of<PasswordProv>(context, listen: false).setPassword1(generatePassword());
                      _cambiarEstado1(passwordProv.password1,email);
                    },
                    onBack: () {
                      // Llamada cuando se presiona el botón de regreso
                      Navigator.pop(context);
                    },
                    ),

                    ),
                  );
                  } else {
                    _mostrarMensaje("El espacio ya ha sido asignado");
                  }
              },
              child: const Text("Button 1"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
            onPressed: _port == null ? null : () {
                if (passwordProv.dis2 == true) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EmailTextField(emailController: TextEditingController(),
                    onPress: (email){
                      Provider.of<PasswordProv>(context, listen: false).setPassword2(generatePassword());
                      _cambiarEstado2(passwordProv.password2,email);
                    },
                    onBack: () {
                      // Llamada cuando se presiona el botón de regreso
                      Navigator.pop(context);
                    },
                    ),

                    ),
                  );
                  } else {
                    _mostrarMensaje("El espacio ya ha sido asignado");
                  }
              },
              child: const Text("Button 2"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
            onPressed: _port == null ? null : () {
                if (passwordProv.dis3 == true) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EmailTextField(emailController: TextEditingController(),
                    onPress: (email){
                      Provider.of<PasswordProv>(context, listen: false).setPassword3(generatePassword());
                      _cambiarEstado3(passwordProv.password3,email);
                    },
                    onBack: () {
                      // Llamada cuando se presiona el botón de regreso
                      Navigator.pop(context);
                    },
                    ),

                    ),
                  );
                  } else {
                    _mostrarMensaje("El espacio ya ha sido asignado");
                  }
              },
              child: const Text("Button 3"),
            ),
             SizedBox(height: 10),
           ElevatedButton(
            onPressed: _port == null ? null : () {
                if (passwordProv.dis4== true) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EmailTextField(emailController: TextEditingController(),
                    onPress: (email){
                      Provider.of<PasswordProv>(context, listen: false).setPassword4(generatePassword());
                      _cambiarEstado4(passwordProv.password4,email);
                    },
                    onBack: () {
                      // Llamada cuando se presiona el botón de regreso
                      Navigator.pop(context);
                    },
                    ),

                    ),
                  );
                  } else {
                    _mostrarMensaje("El espacio ya ha sido asignado");
                  }
              },
              child: const Text("Button 4"),
            ),
             SizedBox(height: 10),
          ],
        );
  }),
    ),
    );
  }
}

class EmailTextField extends StatelessWidget {
  final TextEditingController emailController;
  final Function(String) onPress;
  final VoidCallback onBack;

  const EmailTextField({Key? key, required this.emailController, required this.onPress, required this.onBack, })
      : super(key: key);

   void _mostrarMensaje(BuildContext context, mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        duration: Duration(seconds: 4), // Duración del mensaje en pantalla
      ),
    );
  }
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Primera Página'),
      ),
      body: Center(
        child: Column(
      children: [
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Correo Electrónico',
            hintText: 'ejemplo@dominio.com',
            prefixIcon: Icon(Icons.email),
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed:  () {
            
            // Obtén el valor del TextField
            String email = emailController.text;
            
            // Llama a la función onPress pasando el email
            onPress(email);
            
            // Llama a la función onBack
            onBack(); // Llamada cuando se presiona el botón de envío
            _mostrarMensaje(context, email);
          },
          child: Text('Botón del Correo Electrónico'),
        ),
      ],
    )
    )
    );
  }
}

class SegundaPagina extends StatefulWidget {
  @override
  _SegundaPaginaState createState() => _SegundaPaginaState();
}

class _SegundaPaginaState extends State<SegundaPagina> {
  UsbPort? _port;
  String _status = "Idle";
  List<Widget> _ports = [];
  List<Widget> _serialData = [];

  StreamSubscription<String>? _subscription;
  Transaction<String>? _transaction;
  UsbDevice? _device;

  Future<void> _connectTo(device) async {
    _serialData.clear();

    if (_subscription != null) {
      _subscription!.cancel();
      _subscription = null;
    }

    if (_transaction != null) {
      _transaction!.dispose();
      _transaction = null;
    }

    if (_port != null) {
      _port!.close();
      _port = null;
    }

    if (device == null) {
      _device = null;
      setState(() {
        _status = "Disconnected";
      });
      return;
    }

    _port = await device.create();
    if (await (_port!.open()) != true) {
      setState(() {
        _status = "Failed to open port";
      });
      return;
    }
    _device = device;

    await _port!.setDTR(true);
    await _port!.setRTS(true);
    await _port!.setPortParameters(
        115200, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

    _transaction = Transaction.stringTerminated(
        _port!.inputStream as Stream<Uint8List>, Uint8List.fromList([13, 10]));

    _subscription = _transaction!.stream.listen((String line) {
      setState(() {
        _serialData.add(Text(line));
        if (_serialData.length > 20) {
          _serialData.removeAt(0);
        }
      });
    });

    setState(() {
      _status = "Connected";
    });
  }

  Future<void> _sendData(String data) async {
    if (_port != null) {
      await _port!.write(Uint8List.fromList(data.codeUnits));
    }
  }

  void _getPorts() async {
    List<UsbDevice> devices = await UsbSerial.listDevices();

    // Filtrar dispositivos CP2102
    List<UsbDevice> cp2102Devices = devices.where((device) {
      return device.manufacturerName == "Silicon Labs" &&
          device.productName == "CP2102 USB to UART Bridge Controller";
    }).toList();

    if (cp2102Devices.isNotEmpty) {
      // Conectar automáticamente al primer dispositivo CP2102
      await _connectTo(cp2102Devices.first);
    } else {
      // No se encontraron dispositivos CP2102, desconectar
      await _connectTo(null);
    }
  }


  @override
  void initState() {
    super.initState();

    UsbSerial.usbEventStream!.listen((UsbEvent event) {
      _getPorts();
    });

    _getPorts();
  }

  @override
  void dispose() {
    super.dispose();
    _connectTo(null);
  }

  _cambiarEstado1(pswdProv, pswd) {
    if(pswd==pswdProv){
      _sendData("1\n");
      Provider.of<PasswordProv>(context, listen: false).setDis1(true);
    }
    else{
      _mostrarMensaje("Contraseña incorrecta");
    } 
  }
  _cambiarEstado2(pswdProv, pswd) {
    if(pswd==pswdProv){
      _sendData("2\n");
      Provider.of<PasswordProv>(context, listen: false).setDis2(true);
    }
    else{
      _mostrarMensaje("Contraseña incorrecta");
    } 
  }
  _cambiarEstado3(pswdProv, pswd) {
    if(pswd==pswdProv){
      _sendData("3\n");
      Provider.of<PasswordProv>(context, listen: false).setDis3(true);
    }
    else{
      _mostrarMensaje("Contraseña incorrecta");
    } 
  }
  _cambiarEstado4(pswdProv, pswd) {
    if(pswd==pswdProv){
      _sendData("4\n");
      Provider.of<PasswordProv>(context, listen: false).setDis4(true);
    }
    else{
      _mostrarMensaje("Contraseña incorrecta");
    } 
  }
  


  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        duration: Duration(seconds: 4), // Duración del mensaje en pantalla
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Segunda Página'),
      ),
      body:Center(
        child: Consumer<PasswordProv>(
            builder: (context, passwordProv, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Status: $_status\n'),
            Text('info: ${_port.toString()}\n'),
            ElevatedButton(
              onPressed: _port == null ? null : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PasswordTextField(
                      pswdController: TextEditingController(),
                      onPress: (psw){
                        _cambiarEstado1(passwordProv.password1,psw);
                      },
                      onBack: () {
                        // Llamada cuando se presiona el botón de regreso
                        Navigator.pop(context);
                      },
                    )),
                  );
              },
              child: Text("Button 2"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _port == null ? null : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PasswordTextField(
                      pswdController: TextEditingController(),
                      onPress: (psw){
                        _cambiarEstado2(passwordProv.password2,psw);

                      },
                      onBack: () {
                        // Llamada cuando se presiona el botón de regreso
                        Navigator.pop(context);
                      },
                    )),
                  );
              },
              child: Text("Button 3"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _port == null ? null : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PasswordTextField(
                      pswdController: TextEditingController(),
                      onPress: (psw){
                        _cambiarEstado3(passwordProv.password3,psw);
                      },
                      onBack: () {
                        // Llamada cuando se presiona el botón de regreso
                        Navigator.pop(context);
                      },
                    )),
                  );
              },
              child: Text("Button 4"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _port == null ? null : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PasswordTextField(
                      pswdController: TextEditingController(),
                      onPress: (psw){
                        _cambiarEstado4(passwordProv.password4,psw);
                      },
                      onBack: () {
                        // Llamada cuando se presiona el botón de regreso
                        Navigator.pop(context);
                      },
                    )),
                  );
              },
              child: Text("Button 4"),
            ),
            SizedBox(height: 10),
           
          ],
        );}
        ),
      ),
    );
  }
}



class PasswordTextField extends StatelessWidget {
  final TextEditingController pswdController;
  final Function(String) onPress;
  final VoidCallback onBack;

  const PasswordTextField({Key? key, required this.pswdController, required this.onPress, required this.onBack, })
      : super(key: key);

   void _mostrarMensaje(BuildContext context, mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        duration: Duration(seconds: 4), // Duración del mensaje en pantalla
      ),
    );
  }
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Página contraseña'),
      ),
      body: Center(
        child: Column(
      children: [
        TextField(
          controller: pswdController,
          keyboardType: TextInputType.visiblePassword,
          decoration: InputDecoration(
            labelText: 'Ingresa la clave',
            hintText: 'Contraseña',
            prefixIcon: Icon(Icons.key),
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed:  () {
            
            // Obtén el valor del TextField
            String pass = pswdController.text;
            
            // Llama a la función onPress pasando el email
            onPress(pass);
            
            // Llama a la función onBack
            onBack(); // Llamada cuando se presiona el botón de envío
            _mostrarMensaje(context, pass);
          },
          child: Text('Ingresar'),
        ),
      ],
    )
    )
    );
  }
}






// class DisplayScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Visualizar'),
//       ),
//       body: Center(
//         child: Consumer<CounterModel>(
//           builder: (context, counterModel, child) {
//             return Text(
//               'Current Counter Value: ${counterModel.counter}',
//               style: Theme.of(context).textTheme.headline4,
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
