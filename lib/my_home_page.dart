import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final cepDigitado = MaskedTextController(mask: '00000-000');
  String _cep = "";
  String _logradouro = "";
  String _complemento = "";
  String _bairro = "";
  String _localidade = "";
  String _uf = "";
  String _ddd = "";
  bool _mostraDados = false;
  String? _errorText; // Variável para armazenar a mensagem de erro

  _recuperarCep() async {
    String cepDigitadoFormatado = cepDigitado.text.replaceAll('-', '');
    String url = "https://viacep.com.br/ws/$cepDigitadoFormatado/json/";
    http.Response response = await http.get(Uri.parse(url));

    if (cepDigitadoFormatado.length != 8) {
      setState(() {
        _errorText = 'O CEP deve ter 8 dígitos';
        _mostraDados = false; // Caso a validação falhe, mantém o card oculto
      });
      return;
    }

    if (response.statusCode == 200) {
      Map<String, dynamic> retorno = json.decode(response.body);

      if (retorno.containsKey("erro")) {
        setState(() {
          _errorText = 'CEP inválido';
          _mostraDados =
              false; // Caso a resposta contenha erro, mantém o card oculto
        });
      } else {
        String cep = retorno["cep"];
        String logradouro = retorno["logradouro"];
        String complemento = retorno["complemento"];
        String bairro = retorno["bairro"];
        var localidade = retorno["localidade"];
        String uf = retorno["uf"];
        String ddd = retorno["ddd"];

        setState(() {
          _cep = cep;
          _logradouro = logradouro;
          _complemento = complemento;
          _bairro = bairro;
          _localidade = localidade;
          _uf = uf;
          _ddd = ddd;
          _mostraDados = true;
          _errorText =
              null; // Remove a mensagem de erro se os dados foram carregados com sucesso
        });
      }
    } else {
      setState(() {
        _errorText = 'Erro ao recuperar o CEP';
        _mostraDados = false; // Caso a requisição falhe, mantém o card oculto
      });
    }
  }

  @override
  void dispose() {
    cepDigitado.dispose(); // Libera o controlador quando o widget é destruído
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Image.asset(
                  'images/logo.png',
                  color: Colors.green,
                )),
                const SizedBox(height: 70),
                Center(
                  child: SizedBox(
                    width: 300,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      maxLength: 9,
                      decoration: InputDecoration(
                        labelText: 'CEP',
                        hintText: 'Digite o CEP',
                        border: const OutlineInputBorder(),
                        errorText: _errorText,
                      ),
                      style: const TextStyle(fontSize: 18),
                      controller: cepDigitado,
                      onSubmitted: (cep) {
                        _recuperarCep();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: ElevatedButton(
                    onPressed: _recuperarCep,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(150, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                      elevation: 0.5,
                    ),
                    child:
                        const Text('Pesquisar', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 20),
                _mostraDados
                    ? Center(
                        child: SizedBox(
                          width: 600,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                            onPressed: () {},
                                            icon: const Icon(Icons.copy,
                                                size: 20)),
                                        IconButton(
                                            onPressed: () {},
                                            icon: const Icon(Icons.share,
                                                size: 20)),
                                      ],
                                    ),
                                    Text('CEP: $_cep',
                                        style: const TextStyle(fontSize: 18)),
                                    Text('Logradouro: $_logradouro',
                                        style: const TextStyle(fontSize: 18)),
                                    Text('Complemento: $_complemento',
                                        style: const TextStyle(fontSize: 18)),
                                    Text('Bairro: $_bairro',
                                        style: const TextStyle(fontSize: 18)),
                                    Text(
                                      'Localidade: $_localidade',
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    Text('UF: $_uf',
                                        style: const TextStyle(fontSize: 18)),
                                    Text('DDD: $_ddd',
                                        style: const TextStyle(fontSize: 18)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
