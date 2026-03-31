# Smart Quiz

![Status](https://img.shields.io/badge/status-em%20desenvolvimento-yellow)
![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.1.0-blue?logo=flutter)
![Supabase](https://img.shields.io/badge/Backend-Supabase-3ECF8E?logo=supabase)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

---

## Sobre o Projeto

O **Smart Quiz** é um aplicativo multiplataforma de quiz acadêmico, desenvolvido como **Projeto de Ensino** do **Centro Universitário UniCV**. A plataforma auxilia alunos na preparação para avaliações como **ENADE**, **Prova Diagnóstica**, **Exame da Ordem (OAB)** e outras, oferecendo quizzes interativos, feedback imediato e gamificação integrada.

O projeto conecta acadêmicos e professores em um processo colaborativo, transformando teoria em prática e promovendo inovação na educação.

---

## Links

- **Protótipo (Figma):** [Acessar protótipo](https://www.figma.com/design/GidS299VRzBeauUL8XFqjD/UniCV-Tech---Vers%C3%A3o-Principal?node-id=82-26&p=f&t=gxetva9GrY8AXUmv-0)
- **Deploy (Vercel):** [smartquiz.unicvtech.com.br](https://smartquiz.unicvtech.com.br/)
- **Documentação Completa:** [`docs/DOCUMENTACAO_COMPLETA.md`](docs/DOCUMENTACAO_COMPLETA.md)

---

## Funcionalidades

| Módulo | Descrição |
|---|---|
| **Autenticação** | Login, registro e recuperação de senha via Supabase Auth |
| **Cursos** | Listagem e seleção de cursos disponíveis |
| **Simulados** | Configuração e realização de provas com questões de múltipla escolha |
| **Resultados** | Feedback imediato com revisão detalhada das respostas |
| **Histórico** | Acompanhamento de tentativas anteriores e evolução |
| **Gamificação** | Sistema de pontos, níveis, medalhas e ranking entre alunos |
| **Perfil** | Edição de nome, senha e visualização de progresso |
| **Módulo Professor** | Criação de questões, provas, matérias, categorias e visualização de estatísticas |

---

## Tecnologias

- **Frontend:** Flutter / Dart
- **Backend:** Supabase (PostgreSQL, Auth, Realtime)
- **Gerenciamento de Estado:** Provider (MVVM)
- **CI/CD:** GitHub Actions
- **Deploy Web:** Vercel

---

## Arquitetura

O projeto segue o padrão **MVVM (Model-View-ViewModel)** com **Provider** para gerenciamento de estado e **Repository Pattern** para acesso a dados.

```
lib/
├── constants/          # Configurações (Supabase, etc.)
├── models/             # Modelos de dados (Course, Exam, Question, User, etc.)
├── repositories/       # Interfaces e implementações Supabase
│   └── auth/           # Repositórios de autenticação
├── services/           # Lógica de negócio (AuthService, SessionManager, etc.)
├── viewmodels/         # ViewModels com ChangeNotifier
│   └── teacher/        # ViewModels do módulo professor
├── views/              # Telas do aplicativo
│   └── teacher/        # Telas do módulo professor
├── ui/
│   ├── components/     # Componentes reutilizáveis (prefixo default_)
│   └── theme/          # Cores e estilos
├── routes/             # Definição centralizada de rotas
├── widgets/            # Widgets utilitários (ProtectedRoute)
└── main.dart           # Ponto de entrada
```

### Fluxo de Dados

```
Seleção de Curso → Configuração do Quiz → Tela do Exame → Resultado
```

Os ViewModels buscam dados via repositórios que abstraem a comunicação com o Supabase.

---

## Pré-requisitos

- **Flutter SDK** >= 3.1.0
- **Dart SDK** (incluído no Flutter)
- Conta no **Supabase** (para backend)

---

## Instalação

1. **Clone o repositório:**
   ```bash
   git clone git@github.com:UNICV-TECH/smart_quiz_mvp.git
   cd smart_quiz_mvp
   ```

2. **Instale as dependências:**
   ```bash
   flutter pub get
   ```

3. **Configure o ambiente:**

   Para desenvolvimento nativo (Android/iOS), crie o arquivo `assets/dotenv.env`:
   ```env
   SUPABASE_URL=sua_url_aqui
   SUPABASE_ANON_KEY=sua_chave_aqui
   ```

   Para desenvolvimento web via VS Code, crie `.vscode/dev.json`:
   ```json
   {
     "SUPABASE_URL": "sua_url_aqui",
     "SUPABASE_ANON_KEY": "sua_chave_aqui"
   }
   ```

4. **Execute o projeto:**
   ```bash
   # Web (Chrome)
   flutter run -d chrome

   # Com variáveis locais (VS Code)
   flutter run --dart-define-from-file=.vscode/dev.json

   # Android
   flutter run -d android

   # Ou pressione F5 no VS Code (configuração inclusa)
   ```

---

## Comandos Úteis

```bash
# Análise estática
flutter analyze

# Testes
flutter test
flutter test --coverage

# Build para produção
flutter build web --release
flutter build apk
flutter build ios

# Geração de mocks (se necessário)
dart run build_runner build
```

---

## Banco de Dados

As migrações ficam em `supabase/migrations/` e devem ser aplicadas em ordem numérica via Supabase CLI ou Dashboard SQL Editor.

**Principais tabelas:** `user`, `course`, `exam`, `question`, `answerchoice`, `examquestion`, `user_exam_attempts`, `user_responses`, `teacher_question`, `subject`, `question_category`, `gamification_level`, `gamification_points`, `gamification_season`

---

## CI/CD

O pipeline de GitHub Actions (`.github/workflows/deploy.yml`) executa na branch `main`:

1. **Analyze** — `flutter analyze`
2. **Test** — `flutter test`
3. **Build & Deploy** — Build web com secrets injetados via `--dart-define`

Os segredos `SUPABASE_URL` e `SUPABASE_ANON_KEY` são configurados nos GitHub Secrets do repositório.

---

## Estrutura de Pastas (Raiz)

```
smart_quiz_mvp/
├── .github/workflows/     # CI/CD (GitHub Actions)
├── android/               # Projeto Android nativo
├── assets/images/         # Imagens, logos e medalhas
├── docs/                  # Documentação completa
├── ios/                   # Projeto iOS nativo
├── lib/                   # Código-fonte Flutter/Dart
├── supabase/migrations/   # Migrações do banco de dados
├── test/                  # Testes unitários e de integração
├── web/                   # Configuração web
├── windows/               # Projeto Windows nativo
├── linux/                 # Projeto Linux nativo
├── macos/                 # Projeto macOS nativo
├── pubspec.yaml           # Dependências e configuração do projeto
└── README.md
```

---

## Documentação

A documentação técnica completa está disponível em [`docs/DOCUMENTACAO_COMPLETA.md`](docs/DOCUMENTACAO_COMPLETA.md), incluindo:

- Requisitos funcionais e não funcionais
- Diagramas de arquitetura e entidade-relacionamento
- Detalhamento de modelos, repositórios, serviços e ViewModels
- Configuração de banco de dados e RLS (Row Level Security)
- Manuais do professor e do aluno

---

## Contribuição

1. Crie uma branch a partir de `main`
2. Implemente suas alterações seguindo o padrão MVVM do projeto
3. Execute `flutter analyze` e `flutter test` antes do commit
4. Abra um Pull Request para `main`

---

> **Projeto de Ensino — Centro Universitário UniCV** | Edição 2025/26

