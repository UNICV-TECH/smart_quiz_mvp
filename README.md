# 🚀 Projeto SmarQuiz

![Status](https://img.shields.io/badge/status-em%20desenvolvimento-yellow)
![Frontend](https://img.shields.io/badge/tecnologia-Flutter-blue)
![Backend](https://img.shields.io/badge/tecnologia-.Flutter-blue)
![Banco](https://img.shields.io/badge/banco-Supabase-green)
![License](https://img.shields.io/badge/license-MIT-lightgrey)
---

## 📖 Descrição do Projeto
O **Smart Quiz** é um Projeto de Ensino do **UniCV** que busca conectar os alunos ao aprendizado e trazer experiências reais de desenvolvimento de tecnologia. A iniciativa envolve acadêmicos e professores em um processo colaborativo, transformando teoria em prática e promovendo inovação. O aplicativo desenvolvido pelo projeto na edição 2025/26 é uma ferramenta de preparação para avaliações acadêmicas e profissionais, como o ENADE, Prova Diagnóstica, Exame da Ordem entre outras. Ele reúne **quizzes interativos**, questões reais e simuladas, feedback imediato e recursos de gamificação que tornam o estudo mais dinâmico e estratégico, ajudando o aluno a identificar pontos de melhoria e acompanhar sua evolução. Mais do que um braço de desenvolvimento de tecnologia, **o Smart QUiz representa a integração entre educação e tecnologia**, gerando impacto direto no desempenho acadêmico e contribuindo para a qualidade do ensino da instituição.

---

## 🔗 Links Importantes
- **Protótipo (Figma / Canva / outro)**: [Acessar protótipo](https://www.figma.com/design/GidS299VRzBeauUL8XFqjD/UniCV-Tech---Vers%C3%A3o-Principal?node-id=82-26&p=f&t=gxetva9GrY8AXUmv-0)
- **Taiga**: [Acessar Lean Inception](https://tree.taiga.io/)
- **Documentação Completa**: na pasta [`documentacao`](Documentacao/)
- **Vercel**: [Acessar projeto](https://smart-quiz-mvp.vercel.app/)

---

## 🗂 Estrutura do Repositório
```text
ProjetosSmartQuiz/
│
├─ Documentacao/             # Documentação
├─ Lib                       # Dart/ Flutter     

```

## ⚙ Funcionalidades Principais
| ID    | Funcionalidade           | Descrição                                                   |
|-------|--------------------------|-------------------------------------------------------------|
| RF01  | Autenticação             | Login e registro via Supabase Auth                          |
| RF02  | Listagem de Cursos       | Visualizar todos os cursos                                  |
| RF03  | Controle de Usuários     | Permissões de Admin e Funcionário                           |
| RF04  | Integração com Supabase  | Autenticação, storage e sincronização                       |
| RF05  | Simulados                | Criação das provas, por quantidades de questões             |
| RF06  | Usuário                  | Alterações de nome e senha                                  |
---

## 🛠 Tecnologias Utilizadas
- **Frontend:** Flutter/ Dart  
- **Banco de Dados:** SQL Server / Supabase  
- **Autenticação:** Supabase Auth  
- **Ferramentas Auxiliares:**  Git, BRMW, 

---

⚠️ Pré-requisitos

- Flutter >= 3.35.6

---

## 🚀 Instalação de Dependências

### 🔹 Frontend (Flutter)
Dentro da raiz do projeto do frontend execute o passo:

```
./npm install
```

---

## 💻 Como Rodar o Projeto

### Frontend
```bash
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter Local Dev",
      "request": "launch",
      "type": "dart",
      "deviceId": "chrome",
      "args": [
        "--dart-define-from-file=.vscode/dev.json",
      ]
    }
  ]
}
cd SMART_QUIZ_MVP
F5
```
---

## 📂 Documentação
Toda a documentação está na pasta documentacao, incluindo:
- Requisitos funcionais e não funcionais
- Diagramas (fluxogramas, organogramas, etc.)
- Detalhes de arquitetura
