# Configuração do Firebase - Scheduling App

## ✅ Status do Projeto

**Project ID:** `scheduling-app-1760221340`  
**Project Name:** Scheduling App  
**Console:** https://console.firebase.google.com/project/scheduling-app-1760221340/overview

## ✅ Serviços Configurados

### 1. Firebase Apps Registrados

- ✅ **Web App:** `1:304302033275:web:9dcb7842b290ebc30515de`
- ✅ **Android App:** `1:304302033275:android:bfa98220a48f75dd0515de`
- ✅ **iOS App:** `1:304302033275:ios:146e9077866fec340515de`

### 2. Firestore Database

- ✅ **Status:** Criado e ativo
- ✅ **Location:** nam5 (América do Norte)
- ✅ **Database:** (default)
- ✅ **Rules:** Implantadas (requer autenticação)
- ✅ **Indexes:** Configurados para slots e status
- 🔗 **URL:** https://console.firebase.google.com/project/scheduling-app-1760221340/firestore/databases/-default-/data

### 3. Firebase Options File

- ✅ **File:** `lib/firebase_options.dart`
- ✅ **Status:** Atualizado com todas as configurações das plataformas

### 4. Arquivos de Configuração Criados

- ✅ `firebase.json` - Configuração do projeto
- ✅ `firestore.rules` - Regras de segurança
- ✅ `firestore.indexes.json` - Índices do Firestore
- ✅ `.firebaserc` - Alias do projeto

## ⚠️ Próximo Passo Manual Necessário

### Ativar Firebase Authentication

Para completar a configuração, você precisa ativar a autenticação manualmente no console:

1. Acesse: https://console.firebase.google.com/project/scheduling-app-1760221340/authentication/providers

2. Clique em "Get Started" (se ainda não iniciou)

3. Ative os métodos de autenticação desejados:

   - **Email/Password** (recomendado): Clique no provider "Email/Password" e ative
   - **Google** (opcional): Para login social
   - **Anônimo** (opcional): Para testes

4. Salve as alterações

## 📝 Comandos Úteis

```bash
# Ver status do Firebase
firebase projects:list

# Fazer deploy das rules do Firestore
firebase deploy --only firestore:rules

# Fazer deploy dos indexes do Firestore
firebase deploy --only firestore:indexes

# Ver logs do projeto
firebase functions:log --project scheduling-app-1760221340

# Reconfigurar o FlutterFire (se necessário)
flutterfire configure --project=scheduling-app-1760221340
```

## 🚀 Próximos Passos para Desenvolvimento

1. ✅ Firebase configurado
2. ⚠️ Ativar Authentication manualmente (link acima)
3. ✅ Rules do Firestore implantadas
4. 📱 Testar o app: `flutter run`
5. 🔍 Monitorar dados no console Firestore

## 📱 Package ID / Bundle ID

- **Android:** `com.example.scheduling_app`
- **iOS:** `com.example.schedulingApp`
- **Web:** `scheduling_app (web)`

## 🔐 Segurança

As regras do Firestore estão configuradas para:

- ✅ Requerer autenticação para todas as operações
- ✅ Permitir read/write apenas para usuários autenticados
- ✅ Regras específicas para collections `slots` e `feedback`

**⚠️ Importante:** Lembre-se de revisar e ajustar as regras de segurança conforme necessário para produção.
