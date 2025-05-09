


# App de Monitoramento - BitDogLab

![App Monitoramento BitDogLab](https://drive.google.com/uc?export=view&id=1KYW2uizXd-RLCiOwLvnLJaGI7kOdM0PW)

Aplicativo mobile desenvolvido em **Flutter** para monitoramento em tempo real de variáveis obtidas por um **Raspberry Pi Pico W**, como **temperatura**, **estado de botões** e **posição do joystick**. Ele consome dados de uma **API local em Node.js**, que recebe os dados via HTTPS do microcontrolador.

---

## 🚀 Tecnologias Utilizadas

- **Flutter** (Frontend mobile)
- **Dart** (linguagem do Flutter)
- **Node.js** (API REST para coleta dos dados)
- **Raspberry Pi Pico W** (dispositivo embarcado)
- **pico_https_client** (biblioteca C/C++ para envio HTTPS)

---

## 📱 Funcionalidades

- Visualização em tempo real:
  - **Temperatura ambiente**
  - **Direção do Joystick** (cima, baixo, esquerda, direita)
  - **Botões A e B** (pressionado ou solto)
- Atualização automática dos dados a cada 1 segundo
- Interface simples e responsiva

---

## 📁 Estrutura do Projeto

```

lib/
├── main.dart       # Ponto de entrada do app
└── home.dart       # Tela principal de monitoramento com lógica de consumo da API

````

---

## 🧠 Explicação do Código

### `main.dart`

```
void main() {
  runApp(const MyApp()); // Inicia o app chamando o widget principal
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove a faixa "debug"
      title: 'BitDogLab Monitoramento',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(), // Define HomePage como a tela inicial
    );
  }
}
````

* Este arquivo apenas configura o tema e a tela inicial da aplicação, sem conter lógica de monitoramento.

---

### `home.dart`

* Declara variáveis para armazenar os dados recebidos:

```dart
String temperatura = '';
String direcao = '';
String botaoA = '';
String botaoB = '';
```

* Função `getData()` que consome a API local:

```dart
final response = await http.get(Uri.parse("http://192.168.100.105:3000/dados"));
```

* Converte a resposta JSON para valores exibidos na tela.
* Usa `Timer.periodic()` no `initState()` para atualizar os dados a cada 1 segundo.
* Interface exibe os dados usando `Text()`:

```dart
Text("Temperatura: $temperatura"),
Text("Direção do Joystick: $direcao"),
Text("Botão A: $botaoA"),
Text("Botão B: $botaoB"),
```

---

## 🧪 Como Executar

### Pré-requisitos:

* Flutter instalado (`flutter doctor` deve estar OK)
* Backend Node.js rodando localmente na porta `3000`
* Raspberry Pi Pico W configurado para enviar dados HTTPS

### Passos:

```bash
# Clone o repositório
git clone https://github.com/Uenderson-Mendes/app_monitoramento_bitdoglab

# Acesse a pasta
cd app_monitoramento_bitdoglab

# Instale as dependências do Flutter
flutter pub get

# Execute no emulador ou dispositivo
flutter run
```

---

## 🌐 Backend e Hardware

* A API deve estar disponível em `http://192.168.100.105:3000/dados`
* O Raspberry Pi Pico W envia os dados via HTTPS com a biblioteca `pico_https_client`
* Exemplo de estrutura de resposta JSON esperada:

```json
{
  "temperatura": "26.5",
  "direcao": "CIMA",
  "botaoA": "pressionado",
  "botaoB": "solto"
}
```

---

## 📸 Imagem da Aplicação

A interface da aplicação pode ser visualizada na imagem no topo deste README.


