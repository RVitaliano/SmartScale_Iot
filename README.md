# SmartScale 🏭⚖️

Sistema IoT completo de pesagem inteligente com classificação automática de objetos, monitoramento em tempo real via app mobile e alertas automáticos de SMS e e-mail.

---

## 📌 Problema

Em linhas de produção industriais, a separação de objetos por peso é feita manualmente — um operador fica o dia todo pesando e direcionando peças para o lado certo. O processo é lento, sujeito a erro humano e não gera nenhum dado para monitoramento.

## 💡 Solução

O SmartScale automatiza todo esse processo: pesa o objeto, classifica por faixa de peso, aciona um servo motor para direcioná-lo fisicamente e envia os dados em tempo real para a nuvem. Se o peso ultrapassar o limite, o supervisor recebe um SMS e um e-mail automaticamente — sem precisar estar na linha de produção.

---

## 🏗️ Arquitetura

```
ESP32 (Wokwi)  →  HTTP POST (a cada 20s)  →  TagoIO API
                                                  ↓
                App Flutter  ←  GET /data (a cada 5s)
                                                  ↓
                     SMS + E-mail  ←  TagoIO Actions (sobrepeso)
```

---

## ⚖️ Lógica de Classificação

| Classificação | Faixa de Peso | Servo | LED | Alerta |
|---|---|---|---|---|
| VAZIO | < 0,05 kg | 90° (neutro) | Verde | — |
| ESQUERDA | 0,05 — 2,0 kg | 0° e volta | Verde | — |
| DIREITA | 2,0 — 4,0 kg | 180° e volta | Verde | — |
| SOBREPESO | > 4,0 kg | Parado | Vermelho | SMS + E-mail |

---

## 🔧 Hardware (Simulado no Wokwi)

| Componente | Pino(s) | Função |
|---|---|---|
| ESP32 DevKit | — | Microcontrolador principal |
| Sensor HX711 | DT=19, SCK=18 | Leitura do peso bruto |
| Display OLED SSD1306 | I2C — 0x3C | Exibe peso, status e contagem regressiva |
| Servo Motor | Pino 13 | Direciona o objeto (0°, 90° ou 180°) |
| LED Verde | Pino 5 | Indica operação normal |
| LED Vermelho | Pino 4 | Indica sobrepeso |

---

## 📁 Estrutura do Repositório

```
SmartScale_Iot/
├── smartscale/
│   └── smartscale.ino        # Firmware do ESP32
├── wokwi/
│   ├── diagram.json          # Diagrama do circuito
│   └── libraries.txt         # Bibliotecas utilizadas
├── app/
│   ├── lib/
│   │   ├── main.dart         # Entry point
│   │   ├── app_colors.dart   # Paleta de cores
│   │   ├── models/           # PesagemModel
│   │   ├── services/         # TagoIOService (API REST)
│   │   ├── providers/        # SmartScaleProvider (estado)
│   │   ├── screens/          # home, historico, relatorio
│   │   └── widgets/          # Componentes reutilizáveis
│   └── pubspec.yaml
└── .gitignore
```

---

## 🚀 Como Rodar

### 1. Simulação no Wokwi

1. Acesse [wokwi.com](https://wokwi.com) e crie um novo projeto ESP32
2. Importe o `wokwi/diagram.json`
3. Cole o conteúdo de `smartscale/smartscale.ino` no editor
4. Substitua `TOKEN_TAGOIO` pelo seu Device Token do TagoIO
5. Clique em **Play**

### 2. App Flutter

```bash
cd app
flutter pub get
flutter run -d web-server --dart-define=TAGO_TOKEN=SEU_TOKEN_AQUI
```

Abra a URL exibida no terminal (ex: `http://localhost:XXXXX`) no Edge ou Chrome.

---

## 📱 App Mobile

3 telas acessíveis via BottomNavigationBar:

| Tela | Descrição |
|---|---|
| Monitoramento | Peso atual em tempo real, badge de classificação e banner de alerta de sobrepeso |
| Histórico | Gráfico de linha com as últimas 50 pesagens e linha de limite em 4,0 kg |
| Relatório | Ocorrências de sobrepeso com exportação em PDF |

---

## ☁️ Plataforma Cloud — TagoIO

O TagoIO recebe as variáveis enviadas pelo ESP32 a cada 20 segundos:

| Variável | Exemplo | Descrição |
|---|---|---|
| `peso_kg` | `1.350` | Peso medido em kg |
| `classificacao` | `ESQUERDA` | Classificação do objeto |
| `status` | `ok` / `sobrepeso` | Status da leitura |

**Actions configuradas** — disparam automaticamente quando `status == sobrepeso`:
- 📧 **E-mail** com título e descrição do alerta
- 📱 **SMS** direto para o responsável

---

## 🛠️ Stack Tecnológico

| Camada | Tecnologia |
|---|---|
| Firmware | C++ (Arduino framework) |
| Simulação | Wokwi |
| Cloud / Dashboard | TagoIO |
| App Mobile | Flutter 3 + Dart |
| Gerenciamento de estado | Provider |
| Gráficos | fl_chart |
| Exportação PDF | pdf + printing |

---

## 🔒 Segurança

O Device Token do TagoIO nunca é commitado no repositório. No app ele é injetado em tempo de compilação via `--dart-define`. O arquivo `.vscode/launch.json` com o token está no `.gitignore`.

---