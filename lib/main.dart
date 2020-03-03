import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const requestUrl = 'https://api.hgbrasil.com/finance?key=e7b29d22';

void main() async {
  runApp(MaterialApp(
    title: 'Conversor de Moedas',
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
        focusedBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        hintStyle: TextStyle(color: Colors.amber),
      )),
  )
  );
}

Future<Map> getData() async {
  http.Response response = await http.get(requestUrl);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  void _realChanged( String text ){
    if( text.isEmpty ){
      clearAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real /_dolar).toStringAsFixed(2);
    euroController.text = ( real / _euro).toStringAsFixed(2);
  }

  void _dolarChanged( String text ){
    if( text.isEmpty ){
      clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = ( dolar * _dolar).toStringAsFixed(2);
    euroController.text = ( dolar * _dolar/_euro).toStringAsFixed(2);
  }
  
  void _euroChanged( String text ){
    if( text.isEmpty ){
      clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text = ( euro * _euro).toStringAsFixed(2);
    dolarController.text = ( euro * _euro / _dolar).toStringAsFixed(2);
  }

  void clearAll(){
    realController.text = '';
    dolarController.text = '';
    euroController.text = '';
  }

  double _dolar;
  double _euro;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('\$ Conversor de Moedas \$'),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  "Carregando dados...",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Erro ao carregar dados :C ",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                _dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                _euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

              return SingleChildScrollView(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Icon(Icons.monetization_on, size: 150.0, color: Colors.amber,),
                    buildTextFild('Reais', 'R\$',realController, _realChanged),
                    Divider(),
                    buildTextFild("Dolares", "\$", dolarController, _dolarChanged),
                    Divider(),
                    buildTextFild('Euros', "€", euroController, _euroChanged)
                  ],
                ),
              );
            }
          }
        },
      ),
    );
  }
}

Widget buildTextFild( 
    String label, 
    String prefix, 
    TextEditingController controler,
    Function onChange,
    ){
  return TextField(
    keyboardType: TextInputType.number,
    onChanged: onChange,
    controller: controler,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.amber,
      ),
      border: OutlineInputBorder(),
      prefixText: prefix
    ),
    style: TextStyle(
      color: Colors.amber,
      fontSize: 25.0,
    ),
  );
}
