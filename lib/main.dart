import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(MaterialApp(home: Myapp()));
//const String url = 'http://raspberrytronxi.ddns.net/conexionBD-spring/dato/';
const String url = "http://192.168.0.5/conexionBD-spring/dato/";

class Dato {
  final int id;
  final String nombre;

  Dato({this.id, this.nombre});

  factory Dato.fromJson(Map<String, dynamic> json) {
    return Dato(
      id: json['id'],
      nombre: json['nombre'],
    );
  }
}

Future<List<Dato>> fetchDatos(http.Client client) async {
  final response = await client.get(url);
  return compute(parseDatos, response.body);
}

List<Dato> parseDatos(String responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Dato>((json) => Dato.fromJson(json)).toList();
}

class Myapp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<Myapp> {
  final TextEditingController controllerEnviar = new TextEditingController();
  final TextEditingController controllerBorrar = new TextEditingController();

  Color colorFondoBoton = Colors.lightBlueAccent;

  TextStyle estiloTextoBoton = TextStyle(
    color: Colors.white,
    fontSize: 16
  );
  String mensajeEnviar = "";
  String mensajeBorrar = "";
  bool mostrar;
  FutureBuilder<List<Dato>> wd;

  MyAppState() {
    mostrar = false;
    wd = construir();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.yellowAccent,
          title: Text("Conexion-BD", style: TextStyle(
            color: Colors.black
          ),),
        ),
        body: Container(
            padding: EdgeInsets.all(8.0),
            child: Center(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(hintText: "introduce el id"),
                    onChanged: (String value) {
                      onChangedBorrar(value);
                    },
                    controller: controllerBorrar,
                  ),
                  Padding(padding: EdgeInsets.all(8.0)),
                  RaisedButton(
                    child: Text(
                      "Borrar",
                      style: estiloTextoBoton
                    ),
                    color: colorFondoBoton,
                    onPressed: onPressBorrar,
                  ),
                  Padding(padding: EdgeInsets.all(8.0)),
                  TextField(
                    decoration:
                        InputDecoration(hintText: "introduce el nombre"),
                    onChanged: (String value) {
                      onChangedEnviar(value);
                    },
                    controller: controllerEnviar,
                  ),
                  Padding(padding: EdgeInsets.all(8.0)),
                  RaisedButton(
                    child: Text(
                      "Enviar",
                      style: estiloTextoBoton
                    ),
                    color: colorFondoBoton,
                    onPressed: onPressEnviar,
                  ),
                  Padding(padding: EdgeInsets.all(8.0)),
                  RaisedButton(
                    child: Text(
                      "Actualizar",
                      style: estiloTextoBoton,
                    ),
                    color: colorFondoBoton,
                    onPressed: onPressActualizar,
                  ),
                  Padding(padding: EdgeInsets.all(8.0)),
                  mostrar ? wd : Container(),
                ]))));
  }

  FutureBuilder<List<Dato>> construir() {
    return FutureBuilder<List<Dato>>(
        future: fetchDatos(http.Client()),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);
          return snapshot.hasData
              ? DatoWidget(datos: snapshot.data)
              : Center(child: CircularProgressIndicator());
        });
  }

  void onChangedBorrar(String borrar) {
    setState(() {
      mensajeBorrar = borrar;
    });
  }

  void onChangedEnviar(String enviar) {
    setState(() {
      mensajeEnviar = enviar;
    });
  }

  void onPressBorrar() {
    setState(() {
      var urlBorrar = url + mensajeBorrar;
      http.delete(urlBorrar,
          headers: {"Content-Type": "application/json"}).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");
      });
      controllerBorrar.text = "";
    });
  }

  void onPressActualizar() {
    setState(() {
      mostrar = true;
      wd = construir();
    });
  }

  void onPressEnviar() {
    Map data = {'nombre': mensajeEnviar};
    var body = json.encode(data);
    setState(() {
      http
          .post(url, headers: {"Content-Type": "application/json"}, body: body)
          .then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");
      });
      controllerEnviar.text = "";
    });
  }
}

class DatoWidget extends StatelessWidget {
  final List<Dato> datos;

  DatoWidget({Key key, this.datos}) : super(key: key);

  String _crearTexto() {
    String texto = "";
    for (int i = 0; i < datos.length; i++) {
      texto += '${datos[i].id} ${datos[i].nombre}\n';
    }
    return texto;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
            flex: 1,
            child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                reverse: true,
                child: Text(_crearTexto())));
  }
}
