# 📋 Instruções para Atualizar Java

## ✅ Atualizações já feitas no projeto:
- ✅ Kotlin atualizado para **1.9.22**
- ✅ Android Gradle Plugin atualizado para **8.3.0**
- ✅ Gradle atualizado para **8.5**
- ✅ Java compatibility atualizado para **Java 17**

---

## 📥 Passo 1: Baixar e Instalar Java JDK

### Opção A: Eclipse Temurin (OpenJDK) - **RECOMENDADO**
1. Acesse: https://adoptium.net/temurin/releases/
2. Selecione:
   - **Version**: 21 (LTS)
   - **Operating System**: Windows
   - **Architecture**: x64
   - **Package Type**: JDK
   - **Format**: .msi
3. Clique em "Download"
4. Execute o instalador `.msi`
5. Durante a instalação:
   - ✅ Marque "Add to PATH"
   - ✅ Marque "Set JAVA_HOME variable"
   - Anote o caminho de instalação (ex: `C:\Program Files\Eclipse Adoptium\jdk-21.0.x-hotspot\`)

### Opção B: Oracle JDK
1. Acesse: https://www.oracle.com/java/technologies/downloads/
2. Baixe o JDK 21 para Windows
3. Execute o instalador

---

## ⚙️ Passo 2: Configurar Variáveis de Ambiente (se não foi automático)

### Via Interface Gráfica:
1. Pressione `Win + R` e digite: `sysdm.cpl`
2. Vá na aba **"Avançado"**
3. Clique em **"Variáveis de Ambiente"**
4. Em **"Variáveis do Sistema"**:
   - Clique em **"Novo"**
   - Nome: `JAVA_HOME`
   - Valor: `C:\Program Files\Eclipse Adoptium\jdk-21.0.x-hotspot` (ajuste conforme seu caminho)
5. Edite a variável **"Path"**:
   - Adicione: `%JAVA_HOME%\bin`
6. Clique em **"OK"** em todas as janelas

### Via PowerShell (como Administrador):
```powershell
# Defina o caminho correto do seu JDK
[System.Environment]::SetEnvironmentVariable('JAVA_HOME', 'C:\Program Files\Eclipse Adoptium\jdk-21.0.x-hotspot', 'Machine')
[System.Environment]::SetEnvironmentVariable('Path', $env:Path + ';%JAVA_HOME%\bin', 'Machine')
```

---

## 🔍 Passo 3: Verificar Instalação

**IMPORTANTE**: Feche e abra um NOVO terminal PowerShell após configurar as variáveis.

Execute:
```powershell
java -version
```

Você deve ver algo como:
```
openjdk version "21.0.x" 2024-xx-xx LTS
OpenJDK Runtime Environment Temurin-21.0.x+x (build 21.0.x+x-LTS)
OpenJDK 64-Bit Server VM Temurin-21.0.x+x (build 21.0.x+x-LTS, mixed mode, sharing)
```

Também execute:
```powershell
echo $env:JAVA_HOME
```

Deve mostrar o caminho do JDK.

---

## 🚀 Passo 4: Testar o Build do Flutter

1. **Limpe o projeto**:
   ```powershell
   flutter clean
   ```

2. **Tente construir o APK**:
   ```powershell
   flutter build apk
   ```

---

## ⚠️ Problemas Comuns

### Problema: "java -version" ainda mostra Java 8
**Solução**: 
- Certifique-se de fechar e abrir um novo terminal
- Verifique se o `%JAVA_HOME%\bin` está no início da variável PATH
- Remova referências antigas do Java 8 do PATH

### Problema: JAVA_HOME não está definido
**Solução**: 
- Verifique se definiu a variável de ambiente corretamente
- Certifique-se de que é uma variável de **SISTEMA**, não de usuário
- Reinicie o computador se necessário

### Problema: Build ainda falha
**Solução**:
```powershell
# Limpe o cache do Gradle
cd android
./gradlew clean
cd ..

# Limpe o Flutter
flutter clean

# Tente novamente
flutter build apk
```

---

## 📞 Próximos Passos

Após instalar o Java e configurar as variáveis de ambiente:

1. ✅ Feche e abra um novo terminal
2. ✅ Execute `java -version` para confirmar
3. ✅ Execute `flutter clean`
4. ✅ Execute `flutter build apk`
5. ✅ Ative o **Modo de Desenvolvedor** do Windows (se ainda não fez)

---

**Boa sorte! 🚀**



