# SMART QUIZ - Documentacao Tecnica Completa

> Projeto de Extensao - Centro Universitario UniCV
> Versao: 1.0.0 | Data: Fevereiro 2026

---

## SUMARIO

1. [Introducao](#1-introducao)
2. [Requisitos do Sistema](#2-requisitos-do-sistema)
   - 2.1 Requisitos Funcionais
   - 2.2 Requisitos Nao-Funcionais
3. [Arquitetura do Sistema](#3-arquitetura-do-sistema)
   - 3.1 Padrao Arquitetural
   - 3.2 Stack Tecnologica
   - 3.3 Estrutura de Diretorios
   - 3.4 Fluxo de Dados
4. [Modelos de Dados (Dart)](#4-modelos-de-dados-dart)
5. [Camada de Repositorios](#5-camada-de-repositorios)
6. [Camada de Servicos](#6-camada-de-servicos)
7. [ViewModels](#7-viewmodels)
8. [Telas e Navegacao](#8-telas-e-navegacao)
9. [Componentes de UI Reutilizaveis](#9-componentes-de-ui-reutilizaveis)
10. [Sistema de Autenticacao](#10-sistema-de-autenticacao)
11. [Sistema de Gamificacao](#11-sistema-de-gamificacao)
12. [Banco de Dados Supabase](#12-banco-de-dados-supabase)
    - 12.1 Diagrama Entidade-Relacionamento
    - 12.2 Tabelas Detalhadas
    - 12.3 Views
    - 12.4 Stored Procedures / Funcoes
    - 12.5 Row Level Security (RLS)
13. [CI/CD e Deploy](#13-cicd-e-deploy)
14. [Configuracao de Ambiente](#14-configuracao-de-ambiente)
15. [Guia de Contribuicao](#15-guia-de-contribuicao)
16. [Manual do Professor](#16-manual-do-professor)
17. [Manual do Aluno](#17-manual-do-aluno)
18. [Roadmap](#18-roadmap)

---

## 1. INTRODUCAO

### 1.1 Visao Geral

O **Smart Quiz** e uma aplicacao multiplataforma de quiz academico desenvolvida como **projeto de extensao** do **Centro Universitario UniCV**. A plataforma auxilia alunos na preparacao para exames academicos como ENADE, OAB e outros concursos, oferecendo uma experiencia interativa de questoes de multipla escolha com gamificacao integrada.

### 1.2 Objetivo

Fornecer uma ferramenta digital de estudo que:
- Permita que professores criem e gerenciem bancos de questoes organizados por curso, materia e categoria
- Oferca aos alunos uma experiencia de simulado com feedback imediato e detalhado
- Motive o estudo continuo atraves de pontuacao, niveis, medalhas e rankings competitivos
- Forneca dados de desempenho para acompanhamento pedagogico

### 1.3 Publico-Alvo

Uso exclusivo por **alunos e professores da UniCV**. O sistema possui tres papeis:

| Papel | Descricao | Permissoes |
|-------|-----------|------------|
| **student** | Aluno da instituicao | Realizar quizzes, ver ranking, ver historico, perfil |
| **teacher** | Professor da instituicao | Tudo de student + criar questoes, montar provas, dashboard |
| **admin** | Administrador do sistema | Tudo de teacher + gestao completa |

### 1.4 Equipe

Time de **4 a 6 pessoas** atuando no projeto de extensao.

### 1.5 Cursos Atendidos

O sistema atende inicialmente 5 cursos, com possibilidade de expansao:

| Curso | Chave (course_key) |
|-------|-------------------|
| Psicologia | `psicologia` |
| Direito | `direito` |
| Medicina | `medicina` |
| Engenharia | `engenharia` |
| Administracao | `administracao` |

---

## 2. REQUISITOS DO SISTEMA

### 2.1 Requisitos Funcionais

#### RF01 - Autenticacao e Controle de Acesso
| ID | Descricao | Prioridade |
|----|-----------|-----------|
| RF01.1 | O sistema deve permitir cadastro de novos usuarios com e-mail e senha | Alta |
| RF01.2 | O sistema deve enviar e-mail de confirmacao apos o cadastro | Alta |
| RF01.3 | O sistema deve permitir login com e-mail e senha | Alta |
| RF01.4 | O sistema deve permitir recuperacao de senha em 2 etapas (e-mail + nova senha) | Alta |
| RF01.5 | O sistema deve manter sessao persistente com renovacao automatica de token | Alta |
| RF01.6 | O sistema deve redirecionar automaticamente para login quando a sessao expirar | Alta |
| RF01.7 | O sistema deve proteger rotas autenticadas impedindo acesso sem login | Alta |
| RF01.8 | O sistema deve identificar o papel do usuario (student/teacher/admin) e direcionar para a interface correspondente | Alta |
| RF01.9 | O sistema deve funcionar em modo degradado (sem Supabase) com autenticacao desabilitada | Baixa |

#### RF02 - Modulo do Aluno - Selecao e Configuracao de Quiz
| ID | Descricao | Prioridade |
|----|-----------|-----------|
| RF02.1 | O sistema deve listar os cursos disponiveis com icone e titulo | Alta |
| RF02.2 | O aluno deve poder selecionar um curso para iniciar um quiz | Alta |
| RF02.3 | O sistema deve exibir tela de configuracao com quantidade de questoes disponiveis | Alta |
| RF02.4 | O aluno deve poder escolher a quantidade de questoes do quiz | Alta |
| RF02.5 | O sistema deve informar o total de questoes disponiveis para o curso selecionado | Media |

#### RF03 - Modulo do Aluno - Realizacao de Prova
| ID | Descricao | Prioridade |
|----|-----------|-----------|
| RF03.1 | O sistema deve exibir as questoes uma por vez com enunciado e alternativas (A-E) | Alta |
| RF03.2 | O sistema deve exibir textos de apoio (texto, imagem, codigo, tabela) quando disponivel | Alta |
| RF03.3 | O aluno deve poder navegar entre questoes (avancar/voltar) | Alta |
| RF03.4 | O sistema deve registrar o tempo gasto em cada questao | Media |
| RF03.5 | O sistema deve registrar o tempo total da prova em segundos | Alta |
| RF03.6 | O aluno deve poder finalizar a prova a qualquer momento | Alta |
| RF03.7 | O sistema deve selecionar questoes aleatoriamente do banco do curso | Alta |
| RF03.8 | O sistema deve permitir refazer a prova com novas questoes (evitando repetir as anteriores quando possivel) | Media |
| RF03.9 | O sistema deve criar registros de tentativa (user_exam_attempts) e respostas (user_responses) | Alta |

#### RF04 - Modulo do Aluno - Resultado e Historico
| ID | Descricao | Prioridade |
|----|-----------|-----------|
| RF04.1 | O sistema deve exibir tela de resultado com: total de acertos, nota percentual, tempo gasto | Alta |
| RF04.2 | O sistema deve exibir feedback de gamificacao com pontos ganhos e mensagem motivacional | Alta |
| RF04.3 | O sistema deve mostrar animacao de level-up quando o aluno subir de nivel | Media |
| RF04.4 | O sistema deve exibir detalhamento questao a questao com resposta correta e selecionada | Alta |
| RF04.5 | O sistema deve manter historico de todas as tentativas do aluno | Alta |
| RF04.6 | O aluno deve poder consultar historico de provas anteriores agrupado por curso | Alta |
| RF04.7 | O aluno deve poder visualizar detalhes de cada tentativa passada | Media |

#### RF05 - Modulo do Aluno - Perfil e Gamificacao
| ID | Descricao | Prioridade |
|----|-----------|-----------|
| RF05.1 | O sistema deve exibir perfil do aluno com nome, e-mail e avatar | Alta |
| RF05.2 | O aluno deve poder editar seu nome de exibicao | Media |
| RF05.3 | O sistema deve exibir nivel atual, medalha, pontos e progresso no perfil | Alta |
| RF05.4 | O sistema deve exibir historico de temporadas com medalha, pontos e posicao | Media |
| RF05.5 | O sistema deve exibir tela de ranking com 3 abas: Global, Por Curso, Por Prova | Alta |
| RF05.6 | O ranking deve destacar top 3 com cores diferenciadas (ouro, prata, bronze) | Media |
| RF05.7 | O ranking deve mostrar a posicao do usuario atual mesmo fora do top 50 | Media |
| RF05.8 | O ranking Por Prova deve indicar quais templates o aluno ja tentou | Baixa |

#### RF06 - Modulo do Professor - Gestao de Questoes
| ID | Descricao | Prioridade |
|----|-----------|-----------|
| RF06.1 | O professor deve poder criar questoes com: enunciado, nivel de dificuldade, pontuacao, curso, materia, categoria | Alta |
| RF06.2 | O professor deve poder adicionar ate 5 alternativas (A-E) com indicacao de resposta correta | Alta |
| RF06.3 | O professor deve poder adicionar textos de apoio com tipos: texto, imagem, codigo, tabela | Media |
| RF06.4 | O sistema deve numerar automaticamente as questoes por curso | Media |
| RF06.5 | O professor deve poder listar e filtrar suas questoes | Alta |
| RF06.6 | O professor deve poder editar questoes existentes (enunciado, alternativas, textos de apoio) | Alta |
| RF06.7 | O professor deve poder ativar/desativar questoes | Media |

#### RF07 - Modulo do Professor - Gestao de Materias e Categorias
| ID | Descricao | Prioridade |
|----|-----------|-----------|
| RF07.1 | O professor deve poder criar materias vinculadas a um curso | Alta |
| RF07.2 | O professor deve poder criar categorias vinculadas a um curso e opcionalmente a uma materia | Alta |
| RF07.3 | O professor deve poder listar e gerenciar materias e categorias | Alta |
| RF07.4 | Categorias devem ter nome unico por curso | Media |

#### RF08 - Modulo do Professor - Templates de Prova
| ID | Descricao | Prioridade |
|----|-----------|-----------|
| RF08.1 | O professor deve poder criar templates de prova com: nome, descricao, curso, tempo limite, quantidade de questoes | Alta |
| RF08.2 | O professor deve poder associar questoes especificas ao template | Alta |
| RF08.3 | O professor deve poder associar categorias ao template com quantidade de questoes por categoria | Media |
| RF08.4 | O professor deve poder configurar: nota de corte, embaralhar questoes, embaralhar alternativas, mostrar gabarito, permitir revisao, maximo de tentativas | Media |
| RF08.5 | O professor deve poder publicar/despublicar templates | Alta |
| RF08.6 | Alunos so podem ver e realizar templates publicados e ativos | Alta |

#### RF09 - Modulo do Professor - Dashboard e Estatisticas
| ID | Descricao | Prioridade |
|----|-----------|-----------|
| RF09.1 | O sistema deve exibir dashboard com estatisticas de questoes por curso: total, ativas, categorias usadas, media de pontos | Alta |
| RF09.2 | O sistema deve exibir estatisticas de provas: templates criados, publicados, total de realizacoes, media de nota, total de aprovados | Alta |
| RF09.3 | O professor deve poder visualizar respostas detalhadas dos alunos em suas provas | Media |
| RF09.4 | O professor deve poder visualizar ranking de gamificacao de seus templates | Media |

#### RF10 - Sistema de Gamificacao
| ID | Descricao | Prioridade |
|----|-----------|-----------|
| RF10.1 | O sistema deve calcular pontos base por resposta correta (escala com quantidade de questoes) | Alta |
| RF10.2 | O sistema deve conceder bonus de tempo quando o aluno atinge >=70% de acerto em <=80% do tempo normal | Alta |
| RF10.3 | O sistema deve implementar politica "best score only" - apenas melhorias sao registradas | Alta |
| RF10.4 | O sistema deve manter 4 niveis de progressao: Iniciante (0-100), Explorador (101-200), Mestre do Conteudo (201-300), Lendario (301+) | Alta |
| RF10.5 | O sistema deve operar em temporadas semestrais (1o sem: fev-jul, 2o sem: ago-dez) | Alta |
| RF10.6 | O sistema deve criar automaticamente a temporada ativa baseada no semestre atual | Alta |
| RF10.7 | O sistema deve exibir mensagens motivacionais contextuais baseadas no desempenho | Media |

---

### 2.2 Requisitos Nao-Funcionais

#### RNF01 - Desempenho
| ID | Descricao |
|----|-----------|
| RNF01.1 | O tempo de carregamento das telas nao deve exceder 3 segundos em conexoes 4G |
| RNF01.2 | As queries do banco devem utilizar indices otimizados para consultas frequentes |
| RNF01.3 | O sistema deve utilizar IndexedStack para manter estado das abas sem recriar widgets |
| RNF01.4 | O ranking deve ser calculado via views SQL para evitar processamento no cliente |

#### RNF02 - Seguranca
| ID | Descricao |
|----|-----------|
| RNF02.1 | Credenciais do Supabase nunca devem ser commitadas no repositorio |
| RNF02.2 | Variaveis sensiveis devem ser injetadas via `--dart-define` no CI/CD |
| RNF02.3 | Tabelas criticas devem utilizar Row Level Security (RLS) do Supabase |
| RNF02.4 | Funcoes criticas do banco devem usar SECURITY DEFINER com validacao de role |
| RNF02.5 | Sessoes expiradas (JWT expired) devem ser detectadas e o usuario redirecionado para login |
| RNF02.6 | Rotas autenticadas devem ser protegidas pelo widget ProtectedRoute |

#### RNF03 - Usabilidade
| ID | Descricao |
|----|-----------|
| RNF03.1 | A interface deve seguir Material Design 3 com tema personalizado (verde institucional) |
| RNF03.2 | A fonte padrao deve ser Poppins (Google Fonts) |
| RNF03.3 | A navegacao do aluno deve usar bottom navigation bar com 4 abas |
| RNF03.4 | A navegacao do professor deve usar side menu lateral com secoes colapsaveis |
| RNF03.5 | Feedbacks visuais devem ser fornecidos para acoes do usuario (SnackBar, dialogs) |
| RNF03.6 | Animacoes devem ser usadas para level-up e transicoes de tela |

#### RNF04 - Portabilidade
| ID | Descricao |
|----|-----------|
| RNF04.1 | O sistema deve funcionar em Web (Chrome, Firefox, Safari) |
| RNF04.2 | O sistema deve funcionar em Android 5.0+ |
| RNF04.3 | O sistema deve funcionar em iOS 12+ |
| RNF04.4 | A mesma base de codigo deve ser utilizada para todas as plataformas |

#### RNF05 - Manutenibilidade
| ID | Descricao |
|----|-----------|
| RNF05.1 | O codigo deve seguir o padrao MVVM com separacao clara entre camadas |
| RNF05.2 | Repositorios devem ser abstraidos por interfaces para permitir mock em testes |
| RNF05.3 | O sistema deve operar em modo degradado quando o Supabase nao esta configurado |
| RNF05.4 | Migracoes do banco devem ser versionadas e aplicadas em ordem |
| RNF05.5 | O pipeline CI/CD deve executar analise estatica e testes antes do deploy |

#### RNF06 - Escalabilidade
| ID | Descricao |
|----|-----------|
| RNF06.1 | O banco utiliza o plano Free do Supabase (500MB DB, 1GB storage) |
| RNF06.2 | Indices devem ser criados em todas as colunas usadas em WHERE, JOIN e ORDER BY |
| RNF06.3 | Views materializadas devem ser usadas para rankings complexos |

---

## 3. ARQUITETURA DO SISTEMA

### 3.1 Padrao Arquitetural

O projeto segue o padrao **MVVM (Model-View-ViewModel)** com **Provider** para gerenciamento de estado.

```
┌──────────────────────────────────────────────────────────┐
│                     PRESENTATION                         │
│  ┌─────────┐    ┌──────────────┐    ┌─────────────────┐  │
│  │  Views   │◄──│  ViewModels  │◄──│   Components    │  │
│  │(Screens) │   │(ChangeNotif.)│   │  (Widgets)      │  │
│  └─────────┘    └──────┬───────┘    └─────────────────┘  │
│                        │                                  │
├────────────────────────┼─────────────────────────────────┤
│                  BUSINESS LOGIC                           │
│  ┌─────────────┐  ┌────┴────────┐  ┌──────────────────┐  │
│  │  Services   │  │ Repositories│  │   Calculator     │  │
│  │(AuthService)│  │ (Interfaces)│  │ (Gamification)   │  │
│  └─────────────┘  └──────┬──────┘  └──────────────────┘  │
│                          │                                │
├──────────────────────────┼───────────────────────────────┤
│                     DATA LAYER                            │
│  ┌───────────────┐  ┌────┴──────────┐  ┌──────────────┐  │
│  │    Models     │  │   Supabase    │  │  dotenv/.env  │  │
│  │  (Dart POJOs) │  │ Repositories  │  │  (Config)     │  │
│  └───────────────┘  └───────────────┘  └──────────────┘  │
│                          │                                │
├──────────────────────────┼───────────────────────────────┤
│                     BACKEND                               │
│  ┌───────────────────────┴───────────────────────────┐   │
│  │              Supabase (PostgreSQL)                 │   │
│  │   Auth  │  Database  │  RLS  │  Functions/Views   │   │
│  └───────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────┘
```

### 3.2 Stack Tecnologica

| Camada | Tecnologia | Versao/Plano |
|--------|-----------|--------------|
| Frontend | Flutter (Dart) | SDK >=3.1.0 <4.0.0 |
| Backend | Supabase (PostgreSQL + Auth) | Free tier |
| State Management | Provider + ChangeNotifier | ^6.1.5 |
| Fonte | Google Fonts (Poppins) | ^6.3.2 |
| CI/CD | GitHub Actions | Flutter 3.38.5 |
| Hosting Web | Vercel | Dominio padrao |
| Controle de Versao | Git + GitHub | - |

### 3.3 Estrutura de Diretorios

```
smart_quiz_mvp/
├── .github/workflows/deploy.yml       # Pipeline CI/CD (analyze -> test -> build+deploy)
├── assets/images/                      # Logo, medalhas (medal_iniciante.png, etc.)
├── lib/
│   ├── main.dart                       # Ponto de entrada, inicializacao Supabase, MultiProvider
│   ├── constants/
│   │   ├── app_strings.dart            # Strings centralizadas da UI
│   │   └── supabase_options.dart       # URL e AnonKey (dotenv ou --dart-define)
│   ├── models/                         # 14 modelos de dados
│   │   ├── answer_choice.dart
│   │   ├── auth_result.dart
│   │   ├── auth_user.dart
│   │   ├── course.dart
│   │   ├── exam.dart
│   │   ├── exam_history.dart
│   │   ├── exam_template.dart
│   │   ├── exam_template_category.dart
│   │   ├── exam_template_question.dart
│   │   ├── gamification_level.dart
│   │   ├── gamification_points.dart
│   │   ├── gamification_season.dart
│   │   ├── question.dart
│   │   ├── ranking_entry.dart
│   │   ├── supporting_text.dart
│   │   ├── teacher_question.dart
│   │   ├── teacher_stats.dart
│   │   ├── user_exam_attempt.dart
│   │   ├── user_model.dart
│   │   └── user_response.dart
│   ├── viewmodels/                     # ViewModels com ChangeNotifier
│   │   ├── course_selection_view_model.dart
│   │   ├── exam_detail_view_model.dart
│   │   ├── exam_history_view_model.dart
│   │   ├── exam_view_model.dart
│   │   ├── gamification_view_model.dart
│   │   ├── login_view_model.dart
│   │   ├── profile_view_model.dart
│   │   ├── quiz_config_view_model.dart
│   │   ├── signup_view_model.dart
│   │   ├── teacher_exam_template_view_model.dart
│   │   └── teacher/
│   │       ├── exam_template_view_model.dart
│   │       ├── question_list_view_model.dart
│   │       ├── teacher_dashboard_view_model.dart
│   │       └── teacher_gamification_view_model.dart
│   ├── views/                          # Telas do aplicativo
│   │   ├── splash_screen.dart
│   │   ├── welcome_screen.dart
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   ├── reset_password_screen1.dart
│   │   ├── reset_password_screen2.dart
│   │   ├── main_navigation_screen.dart     # Container com BottomNavBar (4 abas)
│   │   ├── home.screen.dart                # Selecao de curso
│   │   ├── QuizConfig_screen.dart          # Configuracao do quiz
│   │   ├── quiz_config_screen_wrapper.dart
│   │   ├── exam_screen.dart                # Realizacao da prova
│   │   ├── exam_result_screen.dart         # Resultado + gamificacao
│   │   ├── exam_detail_screen.dart         # Detalhes de tentativa
│   │   ├── exam_history_screen.dart        # Historico de provas
│   │   ├── ranking_screen.dart             # Rankings (3 abas)
│   │   ├── profile_screen.dart             # Perfil + nivel + historico de seasons
│   │   ├── about_screen.dart
│   │   ├── help_screen.dart
│   │   └── teacher/
│   │       ├── teacher_main_screen.dart         # Container com SideMenu
│   │       ├── teacher_create_question.dart      # Criar questao
│   │       ├── teacher_edit_question_screen.dart  # Editar questao
│   │       ├── teacher_question_list_screen.dart  # Listar questoes
│   │       ├── teacher_subject_list_screen.dart   # Gerenciar materias
│   │       ├── teacher_category_list_screen.dart  # Gerenciar categorias
│   │       ├── teacher_exam_templates_screen.dart # Templates de prova
│   │       ├── teacher_stats_screen.dart          # Dashboard
│   │       ├── teacher_gamification_screen.dart   # Gamificacao dos alunos
│   │       └── teacher_create_test.dart           # Criar prova
│   ├── repositories/                   # Camada de acesso a dados
│   │   ├── auth/
│   │   │   ├── auth_repository.dart             # Interface
│   │   │   ├── auth_repository_types.dart       # Tipos de erro/resposta
│   │   │   ├── supabase_auth_repository.dart    # Implementacao Supabase
│   │   │   └── disabled_auth_repository.dart    # Implementacao sem backend
│   │   ├── course_repository.dart               # Interface
│   │   ├── course_repository_types.dart
│   │   ├── supabase_course_repository.dart      # Implementacao
│   │   ├── exam_repository.dart                 # Interface
│   │   ├── exam_repository_types.dart
│   │   ├── supabase_exam_repository.dart        # Implementacao
│   │   ├── exam_attempt_repository.dart         # Interface
│   │   ├── exam_attempt_repository_types.dart
│   │   ├── supabase_exam_attempt_repository.dart
│   │   ├── question_repository.dart             # Interface
│   │   ├── question_repository_types.dart
│   │   ├── supabase_question_repository.dart
│   │   ├── teacher_repository.dart              # Interface
│   │   ├── supabase_teacher_repository.dart
│   │   ├── gamification_repository.dart         # Interface
│   │   ├── supabase_gamification_repository.dart
│   │   └── supabase_service.dart
│   ├── services/
│   │   ├── auth_service.dart            # Logica de autenticacao
│   │   ├── session_manager.dart         # Gerenciamento de sessao
│   │   ├── gamification_calculator.dart # Calculo de pontos
│   │   └── repositorie/                # Repositorios legados
│   │       ├── exam_repository.dart
│   │       ├── exam_history_repository.dart
│   │       ├── mock_exam_repository.dart
│   │       ├── mock_exam_history_repository.dart
│   │       └── question_repository.dart
│   ├── routes/
│   │   └── app_routes.dart              # Mapa centralizado de rotas
│   ├── widgets/
│   │   └── protected_route.dart         # Wrapper de autenticacao
│   └── ui/
│       ├── theme/
│       │   ├── app_color.dart           # Paleta de cores
│       │   └── string_text.dart         # Estilos de texto
│       ├── components/                  # ~25 componentes reutilizaveis
│       │   ├── avatar_with_medal.dart
│       │   ├── default_accordion.dart
│       │   ├── default_button_back.dart
│       │   ├── default_button_forward.dart
│       │   ├── default_button_arrow_back.dart
│       │   ├── default_button_orange.dart
│       │   ├── default_chekbox.dart
│       │   ├── default_config.dart
│       │   ├── default_create_question.dart
│       │   ├── default_create_question-statement.dart
│       │   ├── default_exam_history_accordion.dart
│       │   ├── default_feedback_dialog.dart
│       │   ├── default_inline_message.dart
│       │   ├── default_input.dart
│       │   ├── default_input_select.dart
│       │   ├── default_Logo.dart
│       │   ├── default_navbar.dart
│       │   ├── default_navbar_teacher.dart
│       │   ├── default_password_input_47.dart
│       │   ├── default_question_navigation.dart
│       │   ├── default_radio_group.dart
│       │   ├── default_radio_question.dart
│       │   ├── default_scoreCard.dart
│       │   ├── default_subject_card.dart
│       │   ├── default_user_data_card.dart
│       │   ├── default_user_profile_card.dart
│       │   ├── feedback_severity.dart
│       │   └── result_question_tile.dart
│       └── preview.dart
├── supabase/migrations/                # 18 arquivos SQL
├── test/                               # Testes unitarios basicos
├── pubspec.yaml
├── CLAUDE.md
└── database_functions.sql
```

### 3.4 Fluxo de Dados Principal

```
[Aluno abre o app]
      │
      ▼
[SplashScreen] ──► SessionManager.initialize()
      │                    │
      ▼                    ▼
[WelcomeScreen]    Sessao ativa?
      │              │         │
      ▼            Sim        Nao
[LoginScreen] ◄────┘         │
      │                      ▼
      ▼              [MainNavigationScreen]
[AuthService.signIn()]       │
      │                 ┌────┼────┬────────┐
      ▼                 ▼    ▼    ▼        ▼
[SessionManager]     Home  Ranking Historico Perfil
      │                │
      ▼                ▼
[Verifica role]   [Seleciona curso]
      │                │
  teacher?             ▼
      │          [QuizConfigScreen]
      ▼                │
[TeacherMainScreen]    ▼
                  [ExamScreen]
                       │
                       ▼
                  [ExamResultScreen]
                  + Gamification save
```

---

## 4. MODELOS DE DADOS (DART)

### 4.1 UserModel (`lib/models/user_model.dart`)
```dart
class UserModel {
  String id;          // UUID do Supabase Auth
  String name;        // first_name
  String email;
  UserRole role;      // student | teacher | admin
  String? phone;
  String? avatarUrl;
  String? bio;
}

enum UserRole { student, teacher, admin }
```

### 4.2 Course (`lib/models/course.dart`)
```dart
class Course {
  String id;
  String courseKey;     // slug ex: 'psicologia'
  String title;
  String? description;
  String? iconKey;
  IconData? iconData;
  bool isActive;
  DateTime createdAt;
}
```

### 4.3 Question (`lib/models/question.dart`)
```dart
class Question {
  String id;
  String enunciation;       // Texto do enunciado
  String idCourse;
  String? difficultyLevel;  // easy | medium | hard
  double points;
  bool isActive;
  String? idTeacher;
  String? idCategory;
  String? idSubject;
  int? questionOrder;
  int? number;
  List<AnswerChoice> answerChoices;
  List<SupportingText> supportingTexts;
}
```

### 4.4 AnswerChoice (`lib/models/answer_choice.dart`)
```dart
class AnswerChoice {
  String id;
  String letter;          // A, B, C, D, E
  String content;         // Texto da alternativa
  bool correctAnswer;
  String idQuestion;
}
```

### 4.5 SupportingText (`lib/models/supporting_text.dart`)
```dart
class SupportingText {
  String id;
  String idQuestion;
  String contentType;   // text | image | code | table
  String content;
  int displayOrder;
}
```

### 4.6 Exam (`lib/models/exam.dart`)
```dart
class Exam {
  String id;
  String? idUser;
  String idCourse;
  String? title;
  String? description;
  int? questionCount;
  int? timeLimitMinutes;
  double? passingScorePercentage;
  bool isCompleted;
  bool showCorrectAnswers;
  bool allowReview;
  int attemptNumber;
  // ... campos de resultado (score, passed, etc.)
}
```

### 4.7 ExamTemplate (`lib/models/exam_template.dart`)
```dart
class ExamTemplate {
  String id;
  String name;
  String? description;
  String idCourse;
  String idTeacher;
  int? timeLimitMinutes;
  int questionCount;
  double passingScorePercentage;
  bool shuffleQuestions;
  bool shuffleChoices;
  bool showCorrectAnswers;
  bool allowReview;
  int? maxAttempts;
  bool isPublished;
  bool isActive;
}
```

### 4.8 GamificationLevel (`lib/models/gamification_level.dart`)
```dart
enum GamificationLevel {
  iniciante(label: 'Iniciante', minPoints: 0, maxPoints: 100),
  explorador(label: 'Explorador', minPoints: 101, maxPoints: 200),
  mestreDoConteudo(label: 'Mestre do Conteudo', minPoints: 201, maxPoints: 300),
  lendario(label: 'Lendario', minPoints: 301, maxPoints: infinity);
}
```

### 4.9 GamificationPoints (`lib/models/gamification_points.dart`)
```dart
class GamificationPoints {
  String id, userId, seasonId, attemptId, examId, courseId;
  String? examTemplateId;
  int questionCount, correctCount, durationSeconds;
  double basePoints, timeBonus, totalPoints, percentageScore;
}

class SavePointsResult {
  double accumulatedPoints, previousPoints, pointsSaved;
  bool didImprove;
}
```

### 4.10 RankingEntry (`lib/models/ranking_entry.dart`)
```dart
class RankingEntry {
  String userId, seasonId, userName;
  String? avatarUrl, courseId, courseName, examTemplateId, templateName;
  double seasonPoints;
  int totalAttempts, rankPosition;
}
```

### 4.11 GamificationSeason (`lib/models/gamification_season.dart`)
```dart
class GamificationSeason {
  String id, name;      // ex: "2026.1"
  DateTime startsAt, endsAt;
  bool isActive;
}
```

---

## 5. CAMADA DE REPOSITORIOS

Os repositorios seguem o padrao **Interface + Implementacao Supabase**, permitindo substituicao por mocks em testes.

### 5.1 Repositorios de Autenticacao

| Arquivo | Descricao |
|---------|-----------|
| `auth_repository.dart` | Interface abstrata com `signUp`, `signIn`, `signOut`, `resetPasswordForEmail`, `updatePassword` |
| `supabase_auth_repository.dart` | Implementacao real usando `Supabase.instance.client.auth` |
| `disabled_auth_repository.dart` | Stub que lanca excecoes (modo offline) |
| `auth_repository_types.dart` | `AuthRepositoryException`, `AuthRepositoryErrorCode`, tipos de resposta |

### 5.2 Repositorios de Dados

| Interface | Implementacao | Responsabilidade |
|-----------|--------------|------------------|
| `CourseRepository` | `SupabaseCourseRepository` | CRUD de cursos, busca de questoes disponiveis |
| `ExamRepository` | `SupabaseExamRepository` | Criar exame, buscar questoes aleatorias, salvar respostas |
| `ExamAttemptRepository` | `SupabaseExamAttemptRepository` | Criar/atualizar tentativas, buscar historico |
| `QuestionRepository` | `SupabaseQuestionRepository` | CRUD de questoes (modulo professor) |
| `TeacherRepository` | `SupabaseTeacherRepository` | RPCs do professor: criar/editar questao, gerar exame de template, stats |
| `GamificationRepository` | `SupabaseGamificationRepository` | Pontos, rankings, seasons, historico |

### 5.3 Injecao de Dependencia

Os repositorios sao registrados no `MultiProvider` do `main.dart`:

```dart
MultiProvider(
  providers: [
    Provider<AuthRepository>.value(value: authRepository),
    Provider<AuthService>.value(value: authService),
    ChangeNotifierProvider<SessionManager>.value(value: sessionManager),
    Provider<CourseRepository?>(create: (_) => SupabaseCourseRepository(...)),
    Provider<TeacherRepository?>(create: (_) => SupabaseTeacherRepository(...)),
    Provider<GamificationRepository?>(create: (_) => SupabaseGamificationRepository(...)),
  ],
)
```

Repositorios que dependem do Supabase sao registrados como **nullable** (`Repository?`). Quando o Supabase nao esta configurado, retornam `null` e a UI trata o caso graciosamente.

---

## 6. CAMADA DE SERVICOS

### 6.1 AuthService (`lib/services/auth_service.dart`)

Orquestra operacoes de autenticacao entre o repositorio e o SessionManager:

| Metodo | Descricao | Retorno |
|--------|-----------|---------|
| `signUp(email, password, name)` | Cria conta e retorna se precisa confirmacao | `SignUpResult` |
| `signIn(email, password)` | Autentica e atualiza SessionManager | `SignInResult` |
| `resetPasswordForEmail(email)` | Envia e-mail de recuperacao | `ResetPasswordResult` |
| `updatePassword(newPassword)` | Altera senha do usuario autenticado | `ResetPasswordResult` |
| `signOut()` | Limpa sessao e redireciona | `void` |

### 6.2 SessionManager (`lib/services/session_manager.dart`)

Gerencia o estado de sessao do usuario com escuta de eventos do Supabase Auth:

| Funcionalidade | Descricao |
|----------------|-----------|
| **Escuta de auth** | Ouve `onAuthStateChange` para reagir a signIn, signOut, tokenRefreshed, passwordRecovery |
| **Fetch de role** | Busca role (student/teacher/admin) na tabela `user` apos autenticacao |
| **Deteccao de erro 401/403** | Metodo `handleSupabaseError` detecta JWT expired e forca signOut |
| **Redirecionamento** | Redireciona para `/login` ao perder sessao, para `/reset_password2` em recovery |

### 6.3 GamificationCalculator (`lib/services/gamification_calculator.dart`)

Classe utilitaria **pura** (sem estado) para calculo de pontos:

```
Pontos Base = acertos × multiplicador
  - Ate 5 questoes: 1.0 pt/acerto
  - 6-10 questoes: 1.25 pt/acerto
  - 11+ questoes: 1.5 pt/acerto

Bonus de Tempo = N questoes (pontos extras)
  Condicoes:
  - Acertou >= 70% das questoes
  - Completou em <= 80% do tempo normal (2min por questao)

Total = Base + Bonus
```

**Mensagens motivacionais:**
| Condicao | Mensagem |
|----------|----------|
| Nao melhorou | "Sua pontuacao anterior foi mantida. Tente superar!" |
| >=90% + bonus | "Incrivel! Performance perfeita!" |
| >=80% + bonus | "Excelente! Voce esta voando!" |
| >=70% | "Bom trabalho! Continue assim!" |
| >=50% | "Bom esforco! Pratique mais para melhorar!" |
| <50% | "Continue tentando! A pratica leva a perfeicao!" |

---

## 7. VIEWMODELS

Todos os ViewModels estendem `ChangeNotifier` e sao consumidos via `Provider`.

### 7.1 ViewModels do Aluno

| ViewModel | Tela(s) | Responsabilidade |
|-----------|---------|------------------|
| `CourseSelectionViewModel` | HomeScreen | Carrega lista de cursos |
| `QuizConfigViewModel` | QuizConfigScreen | Configura quantidade de questoes, inicia quiz |
| `ExamViewModel` | ExamScreen | Gerencia estado da prova (questoes, respostas, navegacao, finalizacao) |
| `ExamHistoryViewModel` | ExamHistoryScreen | Carrega historico de tentativas por curso |
| `ExamDetailViewModel` | ExamDetailScreen | Carrega detalhes de uma tentativa especifica |
| `ProfileViewModel` | ProfileScreen | Carrega/edita dados do usuario |
| `LoginViewModel` | LoginScreen | Gerencia estado do formulario de login |
| `SignUpViewModel` | SignupScreen | Gerencia estado do formulario de cadastro |
| `GamificationViewModel` | RankingScreen, ProfileScreen | Rankings, pontos, niveis, temporadas |

### 7.2 ViewModels do Professor

| ViewModel | Tela(s) | Responsabilidade |
|-----------|---------|------------------|
| `QuestionListViewModel` | TeacherQuestionListScreen | Lista, filtra e gerencia questoes |
| `TeacherDashboardViewModel` | TeacherStatsScreen | Estatisticas de questoes e provas |
| `ExamTemplateViewModel` | TeacherExamTemplatesScreen | CRUD de templates de prova |
| `TeacherExamTemplateViewModel` | Formulario de template | Estado do formulario de criacao/edicao |
| `TeacherGamificationViewModel` | TeacherGamificationScreen | Ranking e stats dos alunos por template |

---

## 8. TELAS E NAVEGACAO

### 8.1 Mapa de Rotas

```dart
// Rotas de Alunos
'/splash'           → SplashScreen
'/welcome'          → WelcomeScreen
'/signup'           → SignupScreen
'/login'            → LoginScreen
'/reset_password'   → ResetPasswordScreen1
'/reset_password2'  → ResetPasswordScreen2
'/main'             → MainNavigationScreen (protegida)
'/profile'          → ProfileScreen (protegida)
'/help'             → HelpScreen (protegida)
'/about'            → AboutScreen (protegida)
'/exam'             → ExamScreen (protegida, recebe args)
'/quiz/config'      → QuizConfigScreenWrapper (protegida, recebe course)
'/exam/result'      → ExamResultScreen (protegida, recebe results)

// Rotas de Professores
'/teacher'                → TeacherMainScreen (protegida)
'/teacher/home'           → TeacherMainScreen (protegida)
'/teacher/create-question'→ TeacherScreenCreateQuestion (protegida)
'/teacher/questions'      → TeacherQuestionListScreen (protegida)
'/teacher/questions/edit'  → TeacherEditQuestionScreen (protegida, recebe questionId)
'/teacher/templates'      → TeacherExamTemplatesScreen (protegida)
'/teacher/stats'          → TeacherStatsScreen (protegida)
```

### 8.2 Navegacao do Aluno

`MainNavigationScreen` usa `IndexedStack` com 4 abas via `CustomNavBar`:

| Indice | Aba | Tela | Icone |
|--------|-----|------|-------|
| 0 | Inicio | HomeScreen (selecao de curso) | home |
| 1 | Ranking | RankingScreen (3 sub-abas) | emoji_events |
| 2 | Historico | ExamHistoryScreen | history |
| 3 | Perfil | ProfileScreen | person |

### 8.3 Navegacao do Professor

`TeacherMainScreen` usa `Row` com side menu lateral (280px) + conteudo:

| Indice | Item do Menu | Tela |
|--------|-------------|------|
| 0 | Montar Provas | TeacherExamTemplatesScreen |
| 1 | Nova Questao (sub-item) | TeacherScreenCreateQuestion |
| 2 | Perfil | TeacherProfileScreen |
| 3 | Listar Questoes (sub-item) | TeacherQuestionListScreen |
| 4 | Dashboard | TeacherStatsScreen |
| 5 | Gamificacao | TeacherGamificationScreen |
| 6 | Materias (sub-item) | TeacherSubjectListScreen |
| 7 | Categorias (sub-item) | TeacherCategoryListScreen |

O menu "Criar Questoes" e um accordion (sanfona) que expande para revelar: Nova Questao, Listar Questoes, Materias, Categorias.

### 8.4 Protecao de Rotas

O widget `ProtectedRoute` verifica autenticacao via `SessionManager`:
- Se autenticado: renderiza a tela filha
- Se nao autenticado: redireciona para a rota de login

---

## 9. COMPONENTES DE UI REUTILIZAVEIS

Todos os componentes ficam em `lib/ui/components/` com prefixo `default_`.

| Componente | Descricao |
|-----------|-----------|
| `default_navbar.dart` | Bottom navigation bar do aluno (4 abas) |
| `default_navbar_teacher.dart` | Navigation bar do professor |
| `default_button_back.dart` | Botao de voltar |
| `default_button_forward.dart` | Botao de avancar |
| `default_button_arrow_back.dart` | Botao seta voltar |
| `default_button_orange.dart` | Botao laranja (acao principal) |
| `default_input.dart` | Campo de texto padrao |
| `default_password_input_47.dart` | Campo de senha com toggle de visibilidade |
| `default_input_select.dart` | Select/dropdown padrao |
| `default_radio_group.dart` | Grupo de radio buttons |
| `default_radio_question.dart` | Radio button para questoes de prova |
| `default_chekbox.dart` | Checkbox padrao |
| `default_accordion.dart` | Componente sanfona |
| `default_config.dart` | Configuracoes visuais padrao |
| `default_Logo.dart` | Logo da instituicao |
| `default_scoreCard.dart` | Card de pontuacao |
| `default_subject_card.dart` | Card de curso/materia |
| `default_user_data_card.dart` | Card de dados do usuario com avatar e medalha |
| `default_user_profile_card.dart` | Card de perfil do usuario |
| `default_create_question.dart` | Formulario de criacao de questao |
| `default_create_question-statement.dart` | Editor de enunciado |
| `default_exam_history_accordion.dart` | Accordion de historico de provas |
| `default_question_navigation.dart` | Navegacao entre questoes (indicador de progresso) |
| `default_feedback_dialog.dart` | Dialog de feedback (sucesso/erro) |
| `default_inline_message.dart` | Mensagem inline |
| `feedback_severity.dart` | Enum de severidade de feedback |
| `result_question_tile.dart` | Tile de questao no resultado (correta/errada) |
| `avatar_with_medal.dart` | Avatar circular com medalha de nivel sobreposta |

---

## 10. SISTEMA DE AUTENTICACAO

### 10.1 Fluxo de Cadastro

```
[SignupScreen]
      │
      ▼
[SignUpViewModel.signUp()]
      │
      ▼
[AuthService.signUp(email, password, name)]
      │
      ▼
[SupabaseAuthRepository.signUp()]
      │
      ├── Cria usuario no Supabase Auth
      ├── Faz upsert na tabela "user" com role='student'
      └── Envia e-mail de confirmacao
      │
      ▼
[Redireciona para LoginScreen com mensagem de confirmacao]
```

### 10.2 Fluxo de Login

```
[LoginScreen]
      │
      ▼
[LoginViewModel.signIn()]
      │
      ▼
[AuthService.signIn(email, password)]
      │
      ▼
[SupabaseAuthRepository.signIn()]
      │
      ├── Autentica via Supabase Auth
      ├── Retorna sessao com JWT
      └── AuthService atualiza SessionManager
      │
      ▼
[SessionManager.setAuthenticatedUser()]
      │
      ├── Busca role na tabela "user" (async)
      └── notifyListeners()
      │
      ▼
[Redireciona baseado no role]
   student → /main
   teacher/admin → /teacher
```

### 10.3 Fluxo de Recuperacao de Senha

```
Etapa 1: [ResetPasswordScreen1]
      │
      ▼
[AuthService.resetPasswordForEmail(email)]
      │
      ▼
[Supabase envia e-mail com link de recuperacao]
      │
      ▼
[Usuario clica no link → Supabase redireciona para o app]
      │
      ▼
[SessionManager detecta AuthChangeEvent.passwordRecovery]
      │
      ▼
Etapa 2: [ResetPasswordScreen2]
      │
      ▼
[AuthService.updatePassword(newPassword)]
```

### 10.4 Tratamento de Sessao Expirada

O `SessionManager` detecta automaticamente erros de autenticacao:
- `JWT expired`, `invalid token`, `invalid jwt`
- Codigos HTTP 401 e 403
- Ao detectar, executa `signOut()` e redireciona para `/login`

---

## 11. SISTEMA DE GAMIFICACAO

### 11.1 Visao Geral

O sistema de gamificacao motiva os alunos atraves de:
- **Pontuacao** por desempenho em provas
- **Niveis** de progressao com medalhas visuais
- **Rankings** competitivos (global, por curso, por prova)
- **Temporadas** semestrais

### 11.2 Niveis de Progressao

| Nivel | Label | Faixa de Pontos | Medalha |
|-------|-------|-----------------|---------|
| 1 | Iniciante | 0 - 100 pts | `medal_iniciante.png` |
| 2 | Explorador | 101 - 200 pts | `medal_explorador.png` |
| 3 | Mestre do Conteudo | 201 - 300 pts | `medal_mestre.png` |
| 4 | Lendario | 301+ pts | `medal_lendario.png` |

### 11.3 Calculo de Pontos

**Pontos Base** = Acertos x Multiplicador

| Questoes na Prova | Pontos por Acerto |
|-------------------|--------------------|
| 1-5 | 1.00 pt |
| 6-10 | 1.25 pts |
| 11+ | 1.50 pts |

**Bonus de Tempo** = N questoes (pontos extras), concedido se:
- Acertou >= 70% das questoes
- Completou em <= 80% do tempo normal (tempo normal = 2 min/questao)

**Exemplo:** Prova de 10 questoes, 8 acertos, completou em 12 min:
- Base = 8 × 1.25 = 10.0 pts
- Tempo normal = 20 min, tempo record = 16 min, completou em 12 min (< 16) ✓
- Acertou 80% (>= 70%) ✓
- Bonus = 10.0 pts
- **Total = 20.0 pts**

### 11.4 Politica "Best Score Only"

O sistema so registra pontos que representem **melhoria** sobre a melhor pontuacao anterior:

```
Tentativa 1: 15 pts → salva 15 pts (acumulado: 15)
Tentativa 2: 12 pts → NAO salva (nao melhorou)
Tentativa 3: 20 pts → salva 5 pts (delta: 20-15) (acumulado: 20)
```

Isso garante que o ranking reflita habilidade, nao volume de tentativas.

### 11.5 Temporadas

- Semestrais: 1o semestre (fev-jul), 2o semestre (ago-dez)
- Nomeadas como "AAAA.S" (ex: "2026.1")
- Criadas automaticamente pela funcao `get_or_create_active_season()`
- Pontos e rankings sao isolados por temporada

### 11.6 Rankings

3 escopos de ranking, todos calculados via views SQL com `RANK() OVER`:

| Escopo | Descricao | View SQL |
|--------|-----------|----------|
| **Global** | Todos os alunos, todos os exames | `ranking_global_view` |
| **Por Curso** | Alunos que fizeram provas de um curso especifico | `ranking_course_view` |
| **Por Prova** | Alunos que fizeram um template de prova especifico | `ranking_template_view` |

### 11.7 Feedback Visual

**Na tela de resultado (`ExamResultScreen`):**
- Card de feedback com mensagem motivacional
- Detalhamento: pontos base + bonus de tempo + total
- Barra de progresso do nivel atual
- Dica de como ganhar bonus se nao foi conquistado
- Animacao de level-up quando o aluno sobe de nivel (elasticOut)

**No perfil (`ProfileScreen`):**
- Card com medalha, nivel, pontos e barra de progresso
- Historico de temporadas com medalha, pontos e posicao

**No ranking (`RankingScreen`):**
- Avatar com medalha (`AvatarWithMedal`)
- Top 3 com cores ouro/prata/bronze
- Posicao do usuario atual fixada no topo se fora do top 50

---

## 12. BANCO DE DADOS SUPABASE

### 12.1 Diagrama Entidade-Relacionamento

```
auth.users (Supabase Auth)
      │ (mesmo UUID)
      ▼
 ┌─────────┐
 │  "user"  │◄──────────────────────────────────────────┐
 │ PK: id   │                                           │
 └───┬──┬───┘                                           │
     │  │                                               │
     │  │  ┌──────────┐     ┌───────────────────┐       │
     │  └──│  course   │◄────│ question_category │       │
     │     │ PK: id    │     │ FK: id_course     │       │
     │     └──┬──┬──┬──┘     │ FK: id_subject    │       │
     │        │  │  │        └───────┬───────────┘       │
     │        │  │  │                │                   │
     │        │  │  ▼                │                   │
     │        │  │ ┌─────────┐      │                   │
     │        │  │ │ subject  │◄─────┘                   │
     │        │  │ │FK:id_crs │                          │
     │        │  │ └────┬─────┘                          │
     │        │  │      │                                │
     │        │  ▼      ▼                                │
     │        │ ┌──────────────┐                         │
     │        │ │   question    │                        │
     │        │ │ FK: id_course │                        │
     │        │ │ FK: id_teacher├────────────────────────┘
     │        │ │ FK: id_categ. │
     │        │ │ FK: id_subj.  │
     │        │ └──┬────────┬──┘
     │        │    │        │
     │        │    ▼        ▼
     │        │ ┌────────┐ ┌────────────────┐
     │        │ │answer  │ │ supportingtext │
     │        │ │choice  │ │ FK: id_question│
     │        │ │FK:idq. │ └────────────────┘
     │        │ └────────┘
     │        │
     │        ▼
     │  ┌──────────────┐     ┌─────────────────────────┐
     │  │exam_template  │────│exam_template_question    │
     │  │FK: id_course  │    │FK: id_exam_template      │
     │  │FK: id_teacher │    │FK: id_question            │
     │  └──────┬───────┘    └──────────────────────────┘
     │         │
     │         │             ┌─────────────────────────┐
     │         └─────────────│exam_template_category    │
     │                       │FK: id_exam_template      │
     │                       │FK: id_category            │
     │                       └──────────────────────────┘
     │
     │  ┌──────────────┐
     ├──│    exam       │
     │  │ FK: id_user   │
     │  │ FK: id_course │
     │  │ FK: id_templ. │
     │  └──────┬───────┘
     │         │
     │         ├── examquestion ──── question
     │         │
     │         ▼
     │  ┌──────────────────────┐
     ├──│ user_exam_attempts    │
     │  │ FK: user_id           │
     │  │ FK: exam_id           │
     │  │ FK: course_id         │
     │  └──────────┬───────────┘
     │             │
     │             ├── user_responses (FK: attempt_id, question_id, answer_choice_id)
     │             │
     │             └── user_gamification_points (FK: user_id, season_id, attempt_id)
     │                          │
     │                 ┌────────┘
     │                 ▼
     │          gamification_season
     │
     └──────────────────────────────────
```

### 12.2 Tabelas Detalhadas

#### Tabela: `public."user"`
Armazena dados dos usuarios. O `id` e o mesmo UUID do Supabase Auth.

| Coluna | Tipo | NOT NULL | Default | Constraints |
|--------|------|----------|---------|-------------|
| id | uuid | Sim | gen_random_uuid() | PRIMARY KEY |
| created_at | timestamp | Sim | NOW() | |
| updated_at | timestamp | Sim | NOW() | |
| email | text | Sim | | UNIQUE (user_email_key) |
| first_name | text | Nao | | |
| surename | text | Nao | | Typo legado (surname) |
| role | text | Sim | 'student' | CHECK ('student','teacher','admin') |
| phone | text | Nao | | |
| avatar_url | text | Nao | | |
| bio | text | Nao | | |

**Indices:** `idx_user_email(email)`, `idx_user_role(role)`

---

#### Tabela: `public.course`
Cursos disponiveis no sistema.

| Coluna | Tipo | NOT NULL | Default | Constraints |
|--------|------|----------|---------|-------------|
| id | uuid | Sim | gen_random_uuid() | PRIMARY KEY |
| created_at | timestamp | Sim | NOW() | |
| updated_at | timestamp | Sim | NOW() | |
| name | text | Sim | | UNIQUE |
| icon | text | Sim | | Legado |
| description | text | Nao | | |
| is_active | boolean | Nao | TRUE | |
| course_key | text | Nao | | UNIQUE (course_course_key_key) |
| title | text | Nao | | Nome moderno |
| icon_key | text | Nao | | Icone moderno |

**Indices:** `idx_course_name(name)`, `idx_course_is_active(is_active)`

**Dados seed:** Psicologia, Direito, Medicina, Engenharia, Administracao

---

#### Tabela: `public.subject`
Materias vinculadas a cursos.

| Coluna | Tipo | NOT NULL | Default | Constraints |
|--------|------|----------|---------|-------------|
| id | uuid | Sim | gen_random_uuid() | PRIMARY KEY |
| name | text | Sim | | |
| description | text | Nao | | |
| id_course | uuid | Sim | | FK → course(id) ON DELETE CASCADE |
| is_active | boolean | Sim | true | |
| created_at | timestamptz | Sim | NOW() | |
| updated_at | timestamptz | Sim | NOW() | |

**Indices:** `idx_subject_course(id_course)`, `idx_subject_active(is_active)`

---

#### Tabela: `public.question_category`
Categorias de questoes.

| Coluna | Tipo | NOT NULL | Default | Constraints |
|--------|------|----------|---------|-------------|
| id | uuid | Sim | gen_random_uuid() | PRIMARY KEY |
| created_at | timestamp | Sim | NOW() | |
| updated_at | timestamp | Sim | NOW() | |
| name | text | Sim | | UNIQUE(name, id_course) |
| description | text | Nao | | |
| id_course | uuid | Sim | | FK → course(id) ON DELETE CASCADE |
| id_subject | uuid | Nao | | FK → subject(id) ON DELETE SET NULL |
| is_active | boolean | Sim | true | |

**Indices:** `idx_question_category_course(id_course)`, `idx_question_category_subject(id_subject)`

---

#### Tabela: `public.question`
Questoes de multipla escolha.

| Coluna | Tipo | NOT NULL | Default | Constraints |
|--------|------|----------|---------|-------------|
| id | uuid | Sim | gen_random_uuid() | PRIMARY KEY |
| created_at | timestamp | Sim | NOW() | |
| updated_at | timestamp | Sim | NOW() | |
| enunciation | text | Sim | | Texto do enunciado |
| id_course | uuid | Sim | | FK → course(id) |
| difficulty_level | text | Nao | | CHECK ('easy','medium','hard') |
| points | decimal(5,2) | Nao | 1.0 | |
| is_active | boolean | Nao | TRUE | |
| id_teacher | uuid | Nao | | FK → "user"(id) ON DELETE SET NULL |
| id_category | uuid | Nao | | FK → question_category(id) ON DELETE SET NULL |
| id_subject | uuid | Nao | | FK → subject(id) ON DELETE SET NULL |
| question_order | integer | Nao | | |
| number | integer | Nao | | Sequencial por curso |

**Indices:** `idx_question_id_course`, `idx_question_is_active`, `idx_question_difficulty`, `idx_question_teacher`, `idx_question_category`, `idx_question_subject`

---

#### Tabela: `public.answerchoice`
Alternativas de resposta.

| Coluna | Tipo | NOT NULL | Default | Constraints |
|--------|------|----------|---------|-------------|
| id | uuid | Sim | gen_random_uuid() | PRIMARY KEY |
| created_at | timestamp | Nao | | |
| upload_at | timestamp | Sim | | Nome legado |
| letter | text | Sim | | A, B, C, D, E |
| content | text | Sim | | Texto da alternativa |
| correctanswer | boolean | Sim | | E a resposta correta? |
| idquestion | uuid | Sim | | FK → question(id) |

**Indices:** `idx_answerchoice_idquestion`, UNIQUE `(idquestion, letter)`, `idx_answerchoice_correctanswer`

---

#### Tabela: `public.supportingtext`
Textos de apoio para questoes.

| Coluna | Tipo | NOT NULL | Default | Constraints |
|--------|------|----------|---------|-------------|
| id | uuid | Sim | gen_random_uuid() | PRIMARY KEY |
| created_at | timestamp | Sim | NOW() | |
| id_question | uuid | Sim | | FK → question(id) ON DELETE CASCADE |
| content_type | text | Sim | | CHECK ('text','image','code','table') |
| content | text | Sim | | |
| display_order | integer | Nao | 1 | |

**Indices:** `idx_supportingtext_id_question`, `idx_supportingtext_display_order(id_question, display_order)`

---

#### Tabela: `public.exam`
Provas realizadas pelos alunos.

| Coluna | Tipo | NOT NULL | Default | Constraints |
|--------|------|----------|---------|-------------|
| id | uuid | Sim | gen_random_uuid() | PRIMARY KEY |
| created_at | timestamp | Sim | NOW() | |
| updated_at | timestamp | Sim | NOW() | |
| date_start | timestamp | Sim | NOW() | |
| date_end | timestamp | Sim | NOW()+30 days | |
| is_completed | boolean | Sim | false | |
| id_user | uuid | Nao | | FK → "user"(id) |
| id_course | uuid | Sim | | FK → course(id) |
| question_count | integer | Nao | | |
| total_score | decimal(5,2) | Nao | | |
| percentage_score | decimal(5,2) | Nao | | |
| title | text | Nao | | |
| description | text | Nao | | |
| total_available_questions | integer | Nao | 0 | |
| time_limit_minutes | integer | Nao | | |
| passing_score_percentage | decimal(5,2) | Nao | 70.0 | |
| is_active | boolean | Nao | TRUE | |
| id_exam_template | uuid | Nao | | FK → exam_template(id) ON DELETE SET NULL |
| show_correct_answers | boolean | Nao | true | |
| allow_review | boolean | Nao | true | |
| attempt_number | integer | Nao | 1 | |
| total_questions | integer | Nao | | |
| correct_answers | integer | Nao | | |
| score | decimal(5,2) | Nao | | |
| passed | boolean | Nao | | |

**Indices:** `idx_exam_id_user`, `idx_exam_id_course`, `idx_exam_is_completed`, `idx_exam_date_end`, `idx_exam_user_course(id_user, id_course)`, `idx_exam_template`

---

#### Tabela: `public.examquestion`
Relacao N:N entre exam e question.

| Coluna | Tipo | NOT NULL | Default | Constraints |
|--------|------|----------|---------|-------------|
| id | uuid | Sim | gen_random_uuid() | PRIMARY KEY |
| created_at | timestamp | Sim | | |
| update_at | timestamp | Sim | | Nome legado |
| id_exam | uuid | Sim | | FK → exam(id) |
| id_question | uuid | Sim | | FK → question(id) |
| question_order | integer | Nao | | |

**Indices:** `idx_examquestion_id_exam`, `idx_examquestion_id_question`, UNIQUE `(id_exam, id_question)`

---

#### Tabela: `public.user_exam_attempts`
Tentativas de prova dos alunos.

| Coluna | Tipo | NOT NULL | Default | Constraints |
|--------|------|----------|---------|-------------|
| id | uuid | Sim | gen_random_uuid() | PRIMARY KEY |
| user_id | uuid | Sim | | FK → "user"(id) ON DELETE CASCADE |
| exam_id | uuid | Sim | | FK → exam(id) ON DELETE CASCADE |
| course_id | uuid | Sim | | FK → course(id) ON DELETE CASCADE |
| question_count | integer | Sim | | |
| started_at | timestamp | Sim | NOW() | |
| completed_at | timestamp | Nao | | |
| duration_seconds | integer | Nao | | |
| total_score | numeric(6,2) | Nao | | |
| percentage_score | numeric(5,2) | Nao | | |
| status | text | Sim | 'in_progress' | 'in_progress' ou 'completed' |
| created_at | timestamp | Sim | NOW() | |
| updated_at | timestamp | Sim | NOW() | |

**Indices:** `idx_user_exam_attempts_user`, `idx_user_exam_attempts_exam`, `idx_user_exam_attempts_course`, `idx_user_exam_attempts_status`

---

#### Tabela: `public.user_responses`
Respostas individuais de cada questao. Originalmente `userresponse`, renomeada na migracao 006.

| Coluna | Tipo | NOT NULL | Default | Constraints |
|--------|------|----------|---------|-------------|
| id | uuid | Sim | gen_random_uuid() | PRIMARY KEY |
| created_at | timestamp | Sim | NOW() | |
| exam_id | uuid | Sim | | FK → exam(id) ON DELETE CASCADE |
| question_id | uuid | Sim | | FK → question(id) ON DELETE CASCADE |
| answer_choice_id | uuid | Nao | | FK → answerchoice(id) ON DELETE SET NULL |
| selected_choice_key | text | Nao | | Letra selecionada |
| is_correct | boolean | Nao | | |
| points_earned | decimal(5,2) | Nao | 0 | |
| time_spent_seconds | integer | Nao | | |
| answered_at | timestamp | Nao | | |
| attempt_id | uuid | Nao | | FK → user_exam_attempts(id) ON DELETE CASCADE |

**Indices:** `idx_user_responses_attempt`, `idx_user_responses_question`, `idx_user_responses_answer_choice`, UNIQUE `(attempt_id, question_id)`

---

#### Tabela: `public.exam_template`
Templates de prova criados por professores.

| Coluna | Tipo | NOT NULL | Default | Constraints |
|--------|------|----------|---------|-------------|
| id | uuid | Sim | gen_random_uuid() | PRIMARY KEY |
| created_at | timestamp | Sim | NOW() | |
| updated_at | timestamp | Sim | NOW() | |
| name | text | Sim | | |
| description | text | Nao | | |
| id_course | uuid | Sim | | FK → course(id) ON DELETE CASCADE |
| id_teacher | uuid | Sim | | FK → "user"(id) ON DELETE CASCADE |
| time_limit_minutes | integer | Nao | | NULL = sem limite |
| question_count | integer | Sim | 10 | |
| passing_score_percentage | decimal(5,2) | Nao | 60.0 | |
| shuffle_questions | boolean | Sim | true | |
| shuffle_choices | boolean | Sim | true | |
| show_correct_answers | boolean | Sim | true | |
| allow_review | boolean | Sim | true | |
| max_attempts | integer | Nao | | NULL = ilimitado |
| is_published | boolean | Sim | false | |
| is_active | boolean | Sim | true | |

**Indices:** `idx_exam_template_course`, `idx_exam_template_teacher`, `idx_exam_template_published`

---

#### Tabela: `public.exam_template_question`
Questoes associadas a um template.

| Coluna | Tipo | NOT NULL | Default | Constraints |
|--------|------|----------|---------|-------------|
| id | uuid | Sim | gen_random_uuid() | PRIMARY KEY |
| created_at | timestamp | Sim | NOW() | |
| id_exam_template | uuid | Sim | | FK → exam_template(id) ON DELETE CASCADE |
| id_question | uuid | Sim | | FK → question(id) ON DELETE CASCADE |
| question_order | integer | Sim | 1 | |
| points_override | decimal(5,2) | Nao | | Sobrescreve pontuacao padrao |

**Constraint:** UNIQUE `(id_exam_template, id_question)`

---

#### Tabela: `public.exam_template_category`
Categorias associadas a um template com contagem de questoes.

| Coluna | Tipo | NOT NULL | Default | Constraints |
|--------|------|----------|---------|-------------|
| id | uuid | Sim | gen_random_uuid() | PRIMARY KEY |
| created_at | timestamp | Sim | NOW() | |
| id_exam_template | uuid | Sim | | FK → exam_template(id) ON DELETE CASCADE |
| id_category | uuid | Sim | | FK → question_category(id) ON DELETE CASCADE |
| question_count | integer | Sim | 5 | Qtd de questoes desta categoria |

**Constraint:** UNIQUE `(id_exam_template, id_category)`

---

#### Tabela: `public.gamification_season`
Temporadas de competicao (semestrais).

| Coluna | Tipo | NOT NULL | Default | Constraints |
|--------|------|----------|---------|-------------|
| id | uuid | Sim | gen_random_uuid() | PRIMARY KEY |
| name | text | Sim | | UNIQUE (gs_name_unique). Ex: "2026.1" |
| starts_at | timestamp | Sim | | |
| ends_at | timestamp | Sim | | |
| is_active | boolean | Sim | false | |
| created_at | timestamp | Sim | NOW() | |

**Dados seed:** Season "2026.1" (01/02/2026 a 31/07/2026, is_active=true)

---

#### Tabela: `public.user_gamification_points`
Pontos de gamificacao por tentativa.

| Coluna | Tipo | NOT NULL | Default | Constraints |
|--------|------|----------|---------|-------------|
| id | uuid | Sim | gen_random_uuid() | PRIMARY KEY |
| user_id | uuid | Sim | | FK → "user"(id) ON DELETE CASCADE |
| season_id | uuid | Sim | | FK → gamification_season(id) ON DELETE CASCADE |
| attempt_id | uuid | Sim | | FK → user_exam_attempts(id) ON DELETE CASCADE, UNIQUE |
| exam_id | uuid | Sim | | |
| course_id | uuid | Sim | | |
| exam_template_id | uuid | Nao | | |
| question_count | integer | Sim | | |
| correct_count | integer | Sim | | |
| percentage_score | numeric(5,2) | Sim | | |
| duration_seconds | integer | Sim | | |
| base_points | numeric(6,2) | Sim | 0 | |
| time_bonus | numeric(6,2) | Sim | 0 | |
| total_points | numeric(6,2) | Sim | 0 | Pode ser apenas o delta (melhoria) |
| created_at | timestamp | Sim | NOW() | |

**Indices:** `idx_ugp_user`, `idx_ugp_season`, `idx_ugp_course`, `idx_ugp_exam`, `idx_ugp_template`, `idx_ugp_user_season(user_id, season_id)`, `idx_ugp_user_exam(user_id, exam_id, season_id)`, `idx_ugp_user_template(user_id, exam_template_id, season_id)`

---

### 12.3 Views

#### `ranking_global_view`
Ranking global por temporada. Agrega pontos de todos os exames.
- Colunas: `user_id`, `season_id`, `user_name`, `avatar_url`, `season_points`, `total_attempts`, `rank_position`
- Usa `RANK() OVER (PARTITION BY season_id ORDER BY SUM(total_points) DESC)`

#### `ranking_course_view`
Ranking por curso e temporada.
- Colunas extras: `course_id`, `course_name`
- Particionado por `(season_id, course_id)`

#### `ranking_template_view`
Ranking por template de prova e temporada.
- Colunas extras: `exam_template_id`, `template_name`
- Particionado por `(season_id, exam_template_id)`

#### `teacher_question_stats`
Estatisticas de questoes por professor e curso.
- Colunas: `id_teacher`, `id_course`, `course_name`, `total_questions`, `active_questions`, `categories_used`, `avg_points`

#### `teacher_exam_stats`
Estatisticas de templates e provas por professor.
- Colunas: `id_teacher`, `id_course`, `course_name`, `total_templates`, `published_templates`, `total_exams_taken`, `avg_score`, `total_passed`

#### `teacher_student_responses`
Respostas detalhadas de alunos nas provas do professor.
- JOIN entre `exam_template`, `exam`, `user_exam_attempts`, `user`

---

### 12.4 Stored Procedures / Funcoes

#### `get_or_create_active_season()`
Retorna a temporada ativa ou cria uma nova baseada no semestre atual.
- Semestre 1: fev-jul | Semestre 2: ago-dez
- Desativa temporadas anteriores automaticamente
- `SECURITY DEFINER`

#### `create_teacher_question(p_teacher_id, p_course_id, p_category_id, p_enunciation, p_difficulty_level, p_points, p_supporting_texts jsonb, p_answer_choices jsonb)`
Cria questao completa atomicamente (questao + textos de apoio + alternativas).
- Valida role do professor
- Atribui numero sequencial por curso
- `SECURITY DEFINER`

#### `update_teacher_question(p_question_id, p_teacher_id, p_subject_id, p_category_id, p_enunciation, p_difficulty_level, p_points, p_supporting_texts jsonb, p_answer_choices jsonb)`
Atualiza questao completa atomicamente.
- UPSERT de alternativas por `(idquestion, letter)`
- `SECURITY DEFINER`

#### `get_teacher_questions(p_teacher_id, p_course_id, p_category_id, p_active_only)`
Retorna questoes de um professor com contagem de alternativas e textos de apoio.
- `SECURITY DEFINER`

#### `generate_exam_from_template(p_template_id, p_user_id)`
Cria um `exam` e popula `examquestion` a partir de um `exam_template`.
- Retorna UUID do exame criado
- `SECURITY DEFINER`

#### `get_teacher_exam_responses(p_teacher_id, p_template_id, p_exam_id)`
Retorna respostas detalhadas dos alunos para analise do professor.
- `SECURITY DEFINER`

---

### 12.5 Row Level Security (RLS)

| Tabela | RLS Ativo | Politicas |
|--------|-----------|-----------|
| question_category | Sim | Teachers/admins: ALL; Public: SELECT onde is_active=true |
| exam_template | Sim | Owner teacher: ALL; Public: SELECT onde is_published=true AND is_active=true |
| exam_template_question | Sim | Apenas teacher dono do template: ALL |
| exam_template_category | Sim | Apenas teacher dono do template: ALL |
| subject | Sim | SELECT: is_active=true; INSERT/UPDATE: authenticated |
| gamification_season | Sim | SELECT: authenticated |
| user_gamification_points | Sim | SELECT: authenticated; INSERT: apenas auth.uid()=user_id |
| Demais tabelas | Nao | Sem RLS configurado |

### 12.6 Observacoes sobre o Schema

**Inconsistencias de nomenclatura (legado vs. moderno):**
- `answerchoice.idquestion` — sem underscore (legado, nunca renomeado)
- `answerchoice.upload_at` — nome diferente do padrao `updated_at`
- `examquestion.update_at` — nunca renomeado para `updated_at`
- `user.surename` — typo de `surname`, preservado para compatibilidade
- `user_responses` foi originalmente `userresponse`, colunas renomeadas na migracao 006

**Extension utilizada:** `pgcrypto` para `gen_random_uuid()`

**Integridade referencial:**
- `ON DELETE CASCADE`: exam_template_question, exam_template_category, user_exam_attempts, user_responses, user_gamification_points, subject, question_category
- `ON DELETE SET NULL`: user_responses.answer_choice_id, question.id_teacher, question.id_category, question.id_subject, exam.id_exam_template

---

## 13. CI/CD E DEPLOY

### 13.1 Pipeline GitHub Actions

Arquivo: `.github/workflows/deploy.yml`

```
Trigger: push em main/develop | PR para main | manual (workflow_dispatch)

Job 1: ANALYZE
  └── flutter analyze (lint)

Job 2: TEST (depende de analyze)
  └── flutter test

Job 3: BUILD & DEPLOY (depende de test, apenas push na main)
  ├── flutter build web --release
  │   --dart-define=SUPABASE_URL=${{ secrets.SUPABASE_URL }}
  │   --dart-define=SUPABASE_ANON_KEY=${{ secrets.SUPABASE_ANON_KEY }}
  ├── git add build/web -f
  ├── git commit -m "chore: build web release [skip ci]"
  └── git push
```

- **Flutter version:** 3.38.5 (stable)
- **Secrets necessarios:** `SUPABASE_URL`, `SUPABASE_ANON_KEY`
- **Hosting:** Vercel (dominio padrao *.vercel.app)

### 13.2 Testes

- Situacao atual: **testes unitarios basicos**
- Framework: `flutter_test` + `mockito`
- Geracao de mocks: `dart run build_runner build`
- Cobertura: `flutter test --coverage`

---

## 14. CONFIGURACAO DE AMBIENTE

### 14.1 Pre-requisitos

- Flutter SDK >=3.1.0 <4.0.0
- Dart SDK (incluido no Flutter)
- Git
- Conta no Supabase (para backend)
- Editor: VS Code ou Android Studio

### 14.2 Setup Local

```bash
# 1. Clonar repositorio
git clone git@github.com:UNICV-TECH/smart_quiz_mvp.git
cd smart_quiz_mvp

# 2. Instalar dependencias
flutter pub get

# 3. Configurar variaveis de ambiente (mobile/desktop)
# Criar arquivo assets/dotenv.env com:
SUPABASE_URL=https://seu-projeto.supabase.co
SUPABASE_ANON_KEY=sua-anon-key-aqui

# 4. Executar
flutter run -d chrome                    # Web
flutter run                              # Device conectado
flutter run --dart-define-from-file=.vscode/dev.json  # Com env vars locais
```

### 14.3 Configuracao de Secrets (CI/CD)

No repositorio GitHub, configurar em Settings > Secrets:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

### 14.4 Migracoes do Banco

As migracoes estao em `supabase/migrations/` e devem ser aplicadas em ordem numerica:

```bash
# Via Supabase CLI
supabase db push

# Ou manualmente no SQL Editor do Dashboard Supabase
# Executar cada arquivo na ordem do nome
```

---

## 15. GUIA DE CONTRIBUICAO

### 15.1 Fluxo de Trabalho Git

```
main ─────────────────────────────────────────►
   \                    /
    develop ───────────────────────────────────►
       \          /         \          /
        feature/xxx         fix/xxx
```

1. Criar branch a partir de `develop` ou `main`
2. Nomear branch: `feature/nome-descritivo` ou `fix/nome-do-bug`
3. Fazer commits pequenos e descritivos
4. Abrir Pull Request para a branch principal
5. Aguardar CI passar (analyze + test)
6. Code review por pelo menos 1 membro da equipe

### 15.2 Padrao de Commits

```
tipo: descricao curta

Exemplos:
feat: add teacher gamification screen
fix: correct score calculation for time bonus
chore: build web release [skip ci]
refactor: extract avatar component
docs: update API documentation
test: add unit tests for gamification calculator
```

### 15.3 Padrao de Codigo

- **Arquitetura:** MVVM — nao misturar logica de negocio nas Views
- **State Management:** Provider + ChangeNotifier — nao usar setState diretamente para estado compartilhado
- **Repositorios:** Sempre criar interface abstrata + implementacao Supabase
- **Modelos:** Usar `fromJson`/`toJson` factories, `copyWith` para imutabilidade
- **Componentes UI:** Prefixar com `default_`, manter em `lib/ui/components/`
- **Rotas:** Registrar em `app_routes.dart`, proteger com `ProtectedRoute`
- **Nomes de arquivo:** snake_case
- **Nomes de classe:** PascalCase
- **Nomes de variavel:** camelCase

### 15.4 Checklist de Seguranca (Pre-Commit)

- [ ] Nenhum arquivo `.env` esta staged
- [ ] Nenhuma API key ou token esta hardcoded
- [ ] Credenciais de banco nao estao expostas
- [ ] `.gitignore` inclui: .env, node_modules/, dist/, .dart_tool/, build/

### 15.5 Como Adicionar uma Nova Feature

1. **Model:** Criar/editar em `lib/models/`
2. **Migration:** Criar SQL em `supabase/migrations/` (nomear: `YYYYMMDDHHMMSS_descricao.sql`)
3. **Repository:** Criar interface + implementacao em `lib/repositories/`
4. **Registrar:** Adicionar Provider no `main.dart`
5. **ViewModel:** Criar em `lib/viewmodels/`
6. **View:** Criar tela em `lib/views/`
7. **Rota:** Registrar em `app_routes.dart`
8. **Testar:** Escrever testes unitarios minimos

---

## 16. MANUAL DO PROFESSOR

### 16.1 Acesso ao Sistema

1. Acesse o aplicativo Smart Quiz
2. Faca login com seu e-mail e senha (cadastrado como `teacher` ou `admin`)
3. O sistema automaticamente redireciona para a **interface do professor**

### 16.2 Tela Principal

Ao acessar, voce vera um **menu lateral** a esquerda com as opcoes:

- **Montar Provas** — Criar e gerenciar templates de prova
- **Criar Questoes** (sanfona que expande):
  - Nova Questao — Formulario de criacao
  - Listar Questoes — Ver e editar questoes existentes
  - Materias — Gerenciar materias do curso
  - Categorias — Gerenciar categorias de questoes
- **Dashboard** — Estatisticas do seu trabalho
- **Gamificacao** — Ver ranking dos alunos nos seus templates
- **Perfil** — Seus dados e opcao de sair

### 16.3 Criar uma Questao

1. Clique em **Criar Questoes > Nova Questao**
2. Selecione o **curso** (Psicologia, Direito, etc.)
3. Selecione a **materia** e **categoria** (ou crie novas)
4. Escolha o **nivel de dificuldade**: Facil, Medio ou Dificil
5. Defina a **pontuacao** (padrao: 1.0)
6. Escreva o **enunciado** da questao
7. (Opcional) Adicione **textos de apoio**: texto, imagem, codigo ou tabela
8. Preencha as **alternativas** (A a E) e marque a **resposta correta**
9. Clique em **Salvar**

### 16.4 Editar uma Questao

1. Va em **Criar Questoes > Listar Questoes**
2. Encontre a questao desejada (pode filtrar por curso e categoria)
3. Clique na questao para editar
4. Modifique os campos desejados
5. Salve as alteracoes

### 16.5 Gerenciar Materias e Categorias

**Materias:**
1. Va em **Criar Questoes > Materias**
2. Crie materias vinculadas ao curso desejado
3. Cada materia pode ter descricao e ser ativada/desativada

**Categorias:**
1. Va em **Criar Questoes > Categorias**
2. Crie categorias vinculadas ao curso (e opcionalmente a uma materia)
3. O nome da categoria deve ser unico dentro do curso

### 16.6 Montar uma Prova (Template)

1. Clique em **Montar Provas**
2. Clique em **Criar Novo Template**
3. Preencha:
   - Nome e descricao
   - Curso
   - Quantidade de questoes
   - Tempo limite (opcional, em minutos)
   - Nota de corte (padrao: 60%)
   - Opcoes: embaralhar questoes, embaralhar alternativas, mostrar gabarito, permitir revisao
   - Maximo de tentativas (opcional)
4. Associe questoes individuais ou categorias com quantidade
5. Salve o template
6. Quando pronto, **publique** o template para que os alunos possam ve-lo

### 16.7 Dashboard

O dashboard mostra:
- **Estatisticas de questoes:** Total criadas, ativas, categorias usadas, media de pontos por curso
- **Estatisticas de provas:** Templates criados, publicados, total de realizacoes, media de nota, total de aprovados

### 16.8 Gamificacao

Na tela de Gamificacao:
1. Selecione um dos seus **templates publicados** no dropdown
2. Visualize:
   - Total de participantes
   - Media de pontos
   - Melhor e pior pontuacao
   - Ranking detalhado dos alunos com avatar, medalha e pontuacao

---

## 17. MANUAL DO ALUNO

### 17.1 Primeiro Acesso

1. Abra o aplicativo Smart Quiz
2. Na tela de boas-vindas, clique em **Cadastrar**
3. Preencha: nome, e-mail e senha
4. Verifique seu e-mail e confirme o cadastro
5. Volte ao app e faca **login**

### 17.2 Tela Principal

Apos o login, voce vera 4 abas na parte inferior:

| Aba | Icone | Descricao |
|-----|-------|-----------|
| **Inicio** | Home | Selecao de curso para iniciar um quiz |
| **Ranking** | Trofeu | Rankings competitivos |
| **Historico** | Relogio | Suas provas anteriores |
| **Perfil** | Pessoa | Seus dados, nivel e medalha |

### 17.3 Iniciar um Quiz

1. Na aba **Inicio**, selecione um **curso** (ex: Psicologia)
2. Na tela de configuracao, escolha a **quantidade de questoes**
3. O sistema mostra quantas questoes estao disponiveis
4. Clique em **Iniciar**
5. Responda cada questao selecionando uma alternativa (A-E)
6. Use os botoes de navegacao para avancar/voltar entre questoes
7. Quando terminar, clique em **Finalizar Prova**

### 17.4 Resultado da Prova

Apos finalizar, voce vera:
- **Resumo:** total de acertos, nota percentual, tempo gasto
- **Pontuacao de gamificacao:**
  - Pontos base (por acertos)
  - Bonus de tempo (se aplicavel)
  - Mensagem motivacional
  - Progresso no nivel atual
- **Se subiu de nivel:** animacao especial com nova medalha
- **Detalhamento:** cada questao com sua resposta e a correta
- Opcao de **refazer** com novas questoes

### 17.5 Historico

Na aba **Historico**:
- Veja todas as provas que voce ja realizou
- Agrupadas por curso
- Clique em uma tentativa para ver detalhes (questoes, respostas, pontuacao)

### 17.6 Rankings

Na aba **Ranking**, existem 3 sub-abas:

**Geral:** Ranking de todos os alunos somando pontos de todos os exames na temporada atual. Se voce nao estiver no top 50, sua posicao aparece fixada no topo.

**Por Curso:** Selecione um curso para ver o ranking especifico.

**Por Prova:** Selecione uma prova (template publicado) para ver o ranking especifico. Templates que voce ja realizou sao marcados com "Participou".

### 17.7 Sistema de Niveis

Seus pontos acumulados determinam seu nivel:

| Medalha | Nivel | Pontos Necessarios |
|---------|-------|--------------------|
| Iniciante | 1 | 0 - 100 pts |
| Explorador | 2 | 101 - 200 pts |
| Mestre do Conteudo | 3 | 201 - 300 pts |
| Lendario | 4 | 301+ pts |

### 17.8 Como Ganhar Mais Pontos

- **Acerte mais questoes:** quanto mais acertos, mais pontos base
- **Faca provas maiores:** provas com 11+ questoes dao 1.5 pt por acerto (vs 1.0 para provas de 5)
- **Seja rapido:** complete a prova em menos de 80% do tempo normal com 70%+ de acertos para ganhar bonus
- **Melhore sua pontuacao:** repetir uma prova so soma pontos se voce superar seu recorde anterior

### 17.9 Perfil

Na aba **Perfil**:
- Veja e edite seu nome
- Veja seu nivel atual com medalha e barra de progresso
- Veja a temporada atual e seus pontos
- Consulte o **historico de temporadas** anteriores com medalha, pontos e posicao
- Acesse **Ajuda** e **Sobre**
- Faca **logout**

### 17.10 Recuperar Senha

1. Na tela de login, clique em **Esqueceu a senha?**
2. Informe seu e-mail
3. Verifique seu e-mail e clique no link recebido
4. O app abrira a tela de nova senha
5. Defina sua nova senha e confirme

---

## 18. ROADMAP

### Planejado

| Feature | Descricao | Prioridade |
|---------|-----------|-----------|
| IA para geracao de questoes | Integracao com LLM (Claude/GPT) para gerar questoes automaticamente a partir de conteudo | Alta |
| Relatorios avancados | Dashboards detalhados de desempenho para alunos e professores com graficos e metricas | Alta |
| Expansao de cursos | Adicionar novos cursos conforme demanda da instituicao | Continuo |

### Melhorias Tecnicas Sugeridas

| Melhoria | Descricao |
|----------|-----------|
| RLS completo | Habilitar Row Level Security em todas as tabelas (user, question, exam, etc.) |
| Padronizacao de schema | Corrigir inconsistencias de nomenclatura legada (answerchoice.idquestion, etc.) |
| Cobertura de testes | Aumentar cobertura com testes de widget e integracao |
| Cache local | Implementar cache offline para questoes e resultados |
| Notificacoes push | Lembretes de estudo e avisos de novas provas |

---

> **Documento gerado em:** Fevereiro 2026
> **Projeto:** Smart Quiz MVP - UniCV Tech
> **Repositorio:** github.com/UNICV-TECH/smart_quiz_mvp
