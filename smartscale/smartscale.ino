#include <WiFi.h>
#include <HTTPClient.h>
#include <ESP32Servo.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>

// --- CONFIGURACOES DE REDE ---
#define WIFI_SSID  "Wokwi-GUEST"
#define WIFI_PASS  ""
#define BRIDGE_URL "SUA_URL_NGROK" 

// --- OLED ---
#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64
#define OLED_RESET -1
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

// --- HX711 ---
#define DT  19
#define SCK 18
#define RAW_ZERO 0
#define RAW_REF  420
#define PESO_REF 1.0

// --- CLASSIFICACAO ---
#define PESO_MINIMO 0.05
#define PESO_MEDIO  2.5
#define PESO_MAXIMO 5.0

// --- TEMPORIZACAO ---
#define INTERVALO_MS 5000

// --- VARIAVEIS GLOBAIS ---
Servo myServo;
int posicaoAtual = 90;
unsigned long ultimaMedicao = 0;
float pesoAtual = 0;

long lerHX711() {
  unsigned long inicio = millis();
  while (digitalRead(DT) == HIGH) {
    if (millis() - inicio > 100) return -1;
  }
  long valor = 0;
  for (int i = 0; i < 24; i++) {
    digitalWrite(SCK, HIGH);
    delayMicroseconds(1);
    valor = (valor << 1) | digitalRead(DT);
    digitalWrite(SCK, LOW);
    delayMicroseconds(1);
  }
  digitalWrite(SCK, HIGH);
  delayMicroseconds(1);
  digitalWrite(SCK, LOW);
  if (valor & 0x800000) valor |= 0xFF000000;
  return valor;
}

float rawParaKg(long raw) {
  float fator = (float)(RAW_REF - RAW_ZERO) / PESO_REF;
  float kg = (float)(raw - RAW_ZERO) / fator;
  return kg < 0 ? 0 : kg;
}

float mediaMovel(float novoPeso) {
  static float historico[4] = {0, 0, 0, 0};
  static int idx = 0;
  static float ultimo = 0;
  if (abs(novoPeso - ultimo) > 0.1) {
    for (int i = 0; i < 4; i++) historico[i] = novoPeso;
    idx = 0;
  }
  ultimo = novoPeso;
  historico[idx] = novoPeso;
  idx = (idx + 1) % 4;
  float soma = 0;
  for (int i = 0; i < 4; i++) soma += historico[i];
  return soma / 4.0;
}

void setServo(int angulo) {
  if (angulo != posicaoAtual) {
    myServo.write(angulo);
    posicaoAtual = angulo;
  }
}

void setLED(bool verde) {
  digitalWrite(5, verde ? HIGH : LOW);
  digitalWrite(4, verde ? LOW  : HIGH);
}

void atualizarDisplay(float peso, String status, int segundosRestantes) {
  display.clearDisplay();
  display.setTextSize(1);
  display.setTextColor(SSD1306_WHITE);
  display.setCursor(0, 0);
  display.println("  === BALANCA ===");
  display.drawLine(0, 10, 127, 10, SSD1306_WHITE);
  display.setTextSize(3);
  display.setCursor(10, 18);
  display.print(peso, 2);
  display.setTextSize(2);
  display.print(" kg");
  display.setTextSize(1);
  display.setCursor(0, 48);
  display.print("Status: ");
  display.println(status);
  display.setCursor(0, 57);
  display.print("Prox. em: ");
  display.print(segundosRestantes);
  display.print("s");
  display.display();
}

void mostrarAlerta(float peso) {
  display.clearDisplay();
  display.setTextSize(1);
  display.setTextColor(SSD1306_WHITE);
  display.setCursor(20, 0);
  display.println("!!! ALERTA !!!");
  display.drawLine(0, 10, 127, 10, SSD1306_WHITE);
  display.setTextSize(2);
  display.setCursor(10, 18);
  display.print(peso, 2);
  display.print(" kg");
  display.setTextSize(1);
  display.setCursor(10, 45);
  display.println("ACIMA DE 5 kg!");
  display.setCursor(10, 55);
  display.println("Verifique carga");
  display.display();
}

void conectarWiFi() {
  WiFi.begin(WIFI_SSID, WIFI_PASS);
  Serial.print("Conectando ao Wi-Fi");
  int tentativas = 0;
  while (WiFi.status() != WL_CONNECTED && tentativas < 20) {
    delay(500);
    Serial.print(".");
    tentativas++;
  }
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\nWi-Fi conectado! IP: " + WiFi.localIP().toString());
  } else {
    Serial.println("\nFalha ao conectar. Continuando sem rede...");
  }
}

void enviarParaBridge(float peso, String status) {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("Wi-Fi nao conectado, pulando envio.");
    return;
  }
  HTTPClient http;
  http.begin(BRIDGE_URL);
  http.addHeader("Content-Type", "application/json");
  String corpo = "{\"peso\":" + String(peso, 3) + ",\"status\":\"" + status + "\"}";
  int httpCode = http.POST(corpo);
  if (httpCode == 200) {
    Serial.println("Enviado com sucesso!");
  } else {
    Serial.println("Erro ao enviar. Codigo HTTP: " + String(httpCode));
  }
  http.end();
}

void setup() {
  Serial.begin(9600);
  pinMode(DT, INPUT);
  pinMode(SCK, OUTPUT);
  digitalWrite(SCK, LOW);
  pinMode(5, OUTPUT);
  pinMode(4, OUTPUT);
  setLED(true);
  myServo.attach(13);
  myServo.write(90);
  if (!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) {
    Serial.println("OLED nao encontrado!");
    while (true);
  }
  display.clearDisplay();
  display.setTextSize(2);
  display.setTextColor(SSD1306_WHITE);
  display.setCursor(15, 20);
  display.println("Iniciando");
  display.setCursor(30, 42);
  display.println("...");
  display.display();
  delay(2000);
  conectarWiFi();
  Serial.println("Pronto!");
  ultimaMedicao = millis() - INTERVALO_MS;
}

void loop() {
  unsigned long agora = millis();
  int segundosRestantes = (INTERVALO_MS - (agora - ultimaMedicao)) / 1000 + 1;
  if (segundosRestantes < 1) segundosRestantes = 1;
  atualizarDisplay(pesoAtual, "Aguardando...", segundosRestantes);
  if (agora - ultimaMedicao >= INTERVALO_MS) {
    ultimaMedicao = agora;
    long raw = lerHX711();
    if (raw == -1) {
      Serial.println("Sensor sem resposta, tentando novamente...");
      ultimaMedicao = millis() - INTERVALO_MS + 1000;
      return;
    }
    float peso = rawParaKg(raw);
    peso = mediaMovel(peso);
    pesoAtual = peso;
    String status = "";
    if (peso < PESO_MINIMO) {
      status = "Vazio";
      setServo(90);
      setLED(true);
      atualizarDisplay(peso, status, 5);
    } else if (peso <= PESO_MEDIO) {
      status = "ESQUERDA";
      setLED(true);
      atualizarDisplay(peso, status, 5);
      setServo(0);
      delay(700);
      setServo(90);
    } else if (peso <= PESO_MAXIMO) {
      status = "DIREITA";
      setLED(true);
      atualizarDisplay(peso, status, 5);
      setServo(180);
      delay(700);
      setServo(90);
    } else {
      status = "SOBREPESO";
      setLED(false);
      mostrarAlerta(peso);
      delay(2000);
      setLED(true);
    }
    enviarParaBridge(peso, status);
  }
  delay(200);
}