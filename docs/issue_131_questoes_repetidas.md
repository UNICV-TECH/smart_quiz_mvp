# Issue #131 — Web Alunos: Questões Repetidas

**Status:** Documentado para implementação futura
**Data da análise:** 2026-03-24
**Reportado por:** Débora Rosada De Oliveira (17/03/2026)
**Severidade:** Important | **Tipo:** Bug

## Descrição do Bug

Ao fazer várias provas (simulados) da mesma disciplina, o aluno vê "a mesma questão" repetidamente, prova após prova. Isso acontece não apenas dentro de um curso, mas entre cursos diferentes.

## Causa Raiz Identificada

O shuffle (embaralhamento) funciona corretamente — exames diferentes recebem questões diferentes (confirmado via dados do Supabase). O problema real é que **múltiplas questões no banco compartilham o mesmo texto de apoio (supporting text)**, seguindo o formato ENADE onde um texto base gera várias questões.

No app, cada questão aparece sozinha. O aluno vê o **mesmo bloco de texto** em provas diferentes e percebe como "a mesma questão", mesmo sendo perguntas e alternativas tecnicamente diferentes.

### Dados Concretos (Administração — 43 questões ativas)

| Problema                           | Quantidade               | Impacto                                |
| ---------------------------------- | ------------------------ | -------------------------------------- |
| Grupos de texto de apoio duplicado | 13 grupos (~26 questões) | 60% das questões compartilham texto    |
| Questões com enunciado vazio       | 14 questões              | Texto de apoio é a ÚNICA parte visível |
| Questões sem texto de apoio        | 5 questões               | Aparecem praticamente em branco        |
| Questões de teste ("teste", "rh")  | 3 questões               | Poluem o banco de questões             |

### Exemplos de Texto Compartilhado

| Texto de apoio                         | Questões que compartilham                      |
| -------------------------------------- | ---------------------------------------------- |
| "economia inclusiva" (Instituto Ethos) | 3 questões: `5a8b8239`, `748ce630`, `ba78b549` |
| "liderança situacional"                | 2 questões: `8d28ac0a`, `9a15d936`             |
| "dimensão ética empresarial"           | 2 questões: `bf767b36`, `f6afe126`             |
| "BPM - gestão de processos"            | 2 questões: `22f53417`, `a5f6d773`             |
| "comunicação corporativa"              | 2 questões: `c3d712ff`, `ffbd9826`             |

### Verificação com Dados Reais (Murilo)

Análise de 4 exames consecutivos de Administração:

- **Dentro do mesmo exame:** 2 questões com o MESMO texto de apoio foram selecionadas juntas
- **Entre exames:** O exam de 10 questões (`ff4158b5`) teve 5 textos já vistos em exames anteriores (50% de repetição visual)
- **O shuffle funcionou:** As questões (IDs) eram diferentes, mas os textos de apoio eram idênticos

## Solução Proposta

### Abordagem: Agrupamento por Texto de Apoio

Ao selecionar questões para um simulado, agrupar questões pelo hash do conteúdo do supporting text e selecionar no máximo 1 questão por grupo.

### Arquivo Principal

`lib/viewmodels/exam_view_model.dart` — método `_loadQuestions()` (linhas 147-158)

### Lógica Proposta

```dart
// 1. Buscar todas as questões do curso
final allQuestions = await _dataSource.fetchQuestions(...);

// 2. Buscar agrupamento por texto de apoio
final textGroups = await _dataSource.fetchSupportingTextGroups(
    allQuestions.map((q) => q['id'] as String).toList());

// 3. Agrupar questões pelo hash do texto de apoio
final groups = <String, List<Map<String, dynamic>>>{};
for (final q in allQuestions) {
    final groupKey = textGroups[q['id']] ?? q['id'];
    groups.putIfAbsent(groupKey, () => []).add(q);
}

// 4. Embaralhar os grupos e selecionar 1 questão por grupo
final groupList = groups.values.toList()..shuffle();
final selected = <Map<String, dynamic>>[];
for (final group in groupList) {
    if (selected.length >= questionCount) break;
    group.shuffle();
    selected.add(group.first);
}

// 5. Se não houver grupos suficientes, complementar com questões extras
if (selected.length < questionCount) {
    for (final group in groupList) {
        for (final q in group.skip(1)) {
            if (selected.length >= questionCount) break;
            if (!selected.any((s) => s['id'] == q['id'])) {
                selected.add(q);
            }
        }
        if (selected.length >= questionCount) break;
    }
}

questionsData = selected;
```

### Novo Método na Interface

```dart
// Em ExamRemoteDataSource (~linha 550)
Future<Map<String, String>> fetchSupportingTextGroups(List<String> questionIds);
```

### Implementação

```dart
// Em SupabaseExamDataSource
@override
Future<Map<String, String>> fetchSupportingTextGroups(
    List<String> questionIds) async {
  if (questionIds.isEmpty) return {};

  final response = await _client
      .from('supportingtext')
      .select('id_question, content')
      .inFilter('id_question', questionIds)
      .order('display_order');

  final result = <String, String>{};
  for (final row in response) {
    final qId = row['id_question'] as String;
    final content = (row['content'] as String? ?? '').trim();
    if (content.isNotEmpty && !result.containsKey(qId)) {
      result[qId] = content.substring(0, content.length.clamp(0, 200)).hashCode.toString();
    }
  }
  return result;
}
```

### Arquivos a Modificar

| Arquivo                               | Mudança                                                                      |
| ------------------------------------- | ---------------------------------------------------------------------------- |
| `lib/viewmodels/exam_view_model.dart` | Adicionar método na interface + implementação + atualizar `_loadQuestions()` |
| `test/retake_exam_flow_test.dart`     | Adicionar método fake                                                        |

### Também Remover a Guarda do Shuffle

Linha 154: remover `if (allQuestionsData.length > questionCount)` — sempre embaralhar.

## Ações Complementares de Dados

Além da correção no código, considerar:

1. **Limpar questões de teste:** Remover ou desativar `9825ddd6` ("teste"), `0c418f02` ("testes 1,0"), `425827b0` ("rh")
2. **Preencher enunciados vazios:** 14 questões de Administração (e 61 no total) têm enunciado vazio
3. **Revisar questões sem texto de apoio:** 5 questões de Administração não têm supporting text

## Verificação

1. `flutter analyze` — sem erros
2. `flutter test` — todos os testes passando
3. Fazer 3 simulados seguidos de 5 questões e verificar que os textos de apoio são diferentes
4. O retake (Refazer prova) deve continuar carregando as mesmas questões
5. Edge case: se o aluno pedir mais questões do que existem grupos de texto, complementar com questões extras
