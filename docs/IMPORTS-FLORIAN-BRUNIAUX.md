# Ce que `claude-forge` peut reprendre de Florian Bruniaux

Inventaire de ce que la bibliothèque `forge` (rôles, cycles, schémas, skills lus par agent-engine) peut tirer
des plugins publiés par Florian Bruniaux : ce qui peut être **repris tel quel** (traduit), ce qui doit être
**adapté**, et ce qui est **écarté**. Rien de ce document n'est encore appliqué.

| | |
|---|---|
| Source | [FlorianBruniaux/claude-code-plugins](https://github.com/FlorianBruniaux/claude-code-plugins), commit `d48146a` (2026-09-01) |
| Licence | MIT — « Copyright (c) 2026 Florian Bruniaux » |
| Lu le | 2026-10-13 : les 14 agents, les skills `tdd-workflow`, `security-checklist`, `smart-explore`, `ast-grep-patterns`, `design-patterns`, `plan-pipeline`, `cyber-defense-team`, et les hooks de `security-suite` |
| Référence côté moteur | `D:\Projet\agentic-os\Foundation\briques\agent-engine\docs\ARCHITECTURE-AGENTIQUE.md` (sections 2, 5, 7) et `agents-profils-skills.md` (section 5) |

## Sommaire

1. [Légende et contraintes de forge](#1-légende-et-contraintes-de-forge)
2. [Mention de l'auteur et de la licence](#2-mention-de-lauteur-et-de-la-licence)
3. [Rôles existants à enrichir](#3-rôles-existants-à-enrichir)
4. [Nouveaux rôles](#4-nouveaux-rôles)
5. [Premières skills](#5-premières-skills)
6. [Cycles](#6-cycles)
7. [Pour le moteur, pas pour forge](#7-pour-le-moteur-pas-pour-forge)
8. [Écarté](#8-écarté)
9. [Ordre de mise en œuvre proposé](#9-ordre-de-mise-en-œuvre-proposé)

---

## 1. Légende et contraintes de forge

| Marque | Sens |
|---|---|
| **Tel quel** | Le passage est traduit fidèlement en français et repris. La mention MIT est **obligatoire** ([section 2](#2-mention-de-lauteur-et-de-la-licence)). |
| **Adapté** | L'idée est reprise mais réécrite pour forge : format, livrable, vérification par le programme. Si le texte reste proche de l'original, mentionner aussi l'auteur. |
| **Écarté** | Hors sujet pour un moteur qui vérifie lui-même, ou propre à une stack (TypeScript, Next.js…). |

Toute reprise doit respecter les règles de forge (`claude/BIBLIOTHEQUE-AGENT-ENGINE.md`), qui diffèrent de
celles de Florian :

| Chez Florian | Dans forge |
|---|---|
| En-tête avec `model:` et `tools:` | En-tête **limité** à `name` et `description`. Les outils sont fixés par le **nœud du cycle** (`outils: lecture`), le modèle par la configuration. |
| Livrable en Markdown libre (« 🔴 Blockers… ») | Livrable en **YAML** conforme à un **schéma** (`plan`, `verdict`), validé par le programme. |
| L'agent conclut (« APPROVE », « Stands ») | **Le programme décide.** Un verdict peut renvoyer au travail, jamais conclure seul. |
| Exemples en TypeScript / Jest / Next.js | Les consignes restent **indépendantes du langage** ; le savoir propre à une stack va dans une skill ou dans les règles du projet. |
| « Commit frequently », « Run tests » | C'est le **programme** qui lance les vérifications ; l'agent ne gère pas git. |

---

## 2. Mention de l'auteur et de la licence

La licence MIT exige que la notice de copyright et le texte de la licence accompagnent toute copie ou
« portion substantielle », traductions comprises.

Un rôle ne peut pas porter cette notice dans son en-tête (seuls `name` et `description` sont acceptés), et tout
le texte d'un rôle est envoyé au modèle. Proposition :

1. Créer **`claude/THIRD-PARTY-NOTICES.md`** dans le plugin, qui contient :
   - la liste des fichiers de forge dérivés de Florian Bruniaux, avec le fichier d'origine de chacun ;
   - le texte complet de la licence MIT avec « Copyright (c) 2026 Florian Bruniaux ».
2. Dans un **skill**, ajouter en fin de `SKILL.md` une ligne « Adapté de … (MIT) — voir THIRD-PARTY-NOTICES.md » :
   le contenu d'un skill n'est chargé qu'à la demande, la ligne coûte peu.
3. Mettre à jour `THIRD-PARTY-NOTICES.md` à chaque reprise ou retrait.

Modèle d'entrée :

```markdown
| Fichier forge | Origine (claude-code-plugins, commit d48146a) | Nature |
|---|---|---|
| roles/challenger.md | plugins/pr-workflow/agents/plan-challenger.md | traduction adaptée |
```

---

## 3. Rôles existants à enrichir

### 3.1 `architect` ← `planner`, `planning-coordinator`

| Marque | Quoi | Origine |
|---|---|---|
| **Tel quel** | « Ne suppose rien : vérifie chaque chemin et chaque signature (Glob, Grep, Read) avant de l'inscrire dans le plan. » | `planner.md`, Anti-patterns |
| **Tel quel** | « Ne planifie pas trop : arrête-toi au niveau de détail dont l'implémenteur a besoin. » | `planner.md`, Anti-patterns |
| **Tel quel** | Règles de taille d'une étape : trop petite (« ajouter un champ »), trop grosse (« tout le système d'authentification »), juste (« le service de génération de jetons, avec ses tests »). | `planning-coordinator.md`, Step 3 |
| **Tel quel** | Contrôles avant de rendre le plan : chaque exigence de la tâche a au moins une étape ; aucune étape ne s'appuie sur un fichier qu'une étape précédente n'a pas créé ; pas de dépendance circulaire. | `planning-coordinator.md`, Step 5 |
| **Adapté** | **Risques** et **questions ouvertes** : ajouter au schéma `plan` deux champs facultatifs, `risques` et `questions_ouvertes`. Si `questions_ouvertes` n'est pas vide, le cycle peut faire une **pause pour l'utilisateur** (prévue au palier 2). | `planner.md`, Output Format |
| **Adapté** | **Lier chaque étape à ses tests** : ajouter `etapes[].tests` (des indices dans `tests_prevus`). La règle « chaque étape doit pouvoir être prouvée par un test » existe dans le rôle mais n'est pas vérifiée ; avec ce champ, le **programme** peut la vérifier. | idée tirée de `planning-coordinator.md` (marqueurs `[TDD]`, « Acceptance ») |
| **Écarté** | ADR, PRD, `PATTERNS.md`, couches « Layer 1/2 », synthèse de rapports multi-agents (relève du palier 3), justification du choix de modèle. | |

### 3.2 `tester` ← `test-writer`, skill `tdd-workflow`

| Marque | Quoi | Origine |
|---|---|---|
| **Tel quel** | Philosophie en 4 points : les tests documentent le comportement ; tester le comportement, pas l'implémentation ; un concept par test ; structure Arrange-Act-Assert. | `test-writer.md`, Testing Philosophy |
| **Tel quel** | Plan de test par catégories : cas nominal ; cas limites (entrée vide, valeurs maximales et minimales) ; gestion d'erreurs (entrée invalide, panne réseau, délai dépassé). | `test-writer.md`, Create Test Plan |
| **Tel quel** | Bonnes pratiques : noms descriptifs, pas de dépendance entre tests, isoler les dépendances externes, ne pas tester les méthodes privées. | `test-writer.md`, Best Practices |
| **Adapté** | Le plan de test reste interne à l'agent : le livrable `rouge` est vérifié par le programme (nouveaux tests rouges, anciens verts), pas par un document. | |
| **Écarté** | Gabarits Jest/Vitest, « < 100 ms par test unitaire », tests d'intégration avec base de données. | |

### 3.3 `reviewer` ← `code-reviewer`, `architecture-reviewer`

| Marque | Quoi | Origine |
|---|---|---|
| **Tel quel** | **Règles anti-hallucination** : vérifier avant d'affirmer ; compter les occurrences d'un motif avec Grep avant de le dire « établi » (> 10 : établi, 3 à 10 : émergent, < 3 : non établi) ; marquer l'incertain (« à vérifier »). | `code-reviewer.md`, Anti-Hallucination Rules |
| **Tel quel** | Grille de relecture : exactitude, sécurité, performance, maintenabilité, tests. | `code-reviewer.md`, Review Checklist |
| **Tel quel** | « Justifie toujours la gravité » : une remarque dit pourquoi elle est bloquante. | `code-reviewer.md`, Severity Justification |
| **Adapté** | **Gravité dans le verdict** : ajouter au schéma `verdict` un champ facultatif `remarques[].gravite` (`bloquant`, `amelioration`, `optionnel`). Règle vérifiable par le programme : un `refuse` contient au moins une remarque `bloquant` ; une acceptation peut porter des remarques non bloquantes, transmises sans renvoyer le travail. | `code-reviewer.md`, Severity Classification (🔴/🟡/🟢) |
| **Adapté** | « Lis le fichier entier, pas seulement les lignes du diff » — à concilier avec la lecture progressive ([5.3](#53-lecture-progressive--smart-explore)) : lire en entier les fichiers **du diff**, explorer les autres par structure. | `code-reviewer.md`, Verification Protocol |
| **Écarté** | Format Markdown à émojis, section « Positives », table de chargement de contexte propre à Next.js/Prisma, intégrations (SE-CoVe, boucle auto-fix). | |

---

## 4. Nouveaux rôles

### 4.1 `challenger` ← `plan-challenger` — **le plus intéressant**

Un relecteur **du plan**, en lecture seule, placé entre `architect` et `tester` : il attaque le plan avant
qu'une ligne de code soit écrite.

| Marque | Quoi | Origine |
|---|---|---|
| **Tel quel** | Les **5 dimensions d'attaque** et leur question décisive : hypothèses (« et si elle était fausse ? »), cas manquants (« et si c'est vide, nul, concurrent, à grande échelle ? »), sécurité (« comment un attaquant l'exploite-t-il ? »), architecture (« peut-on revenir en arrière dans 6 mois sans tout réécrire ? »), complexité (« problème réel ou hypothétique ? »). | `plan-challenger.md`, Challenge Dimensions |
| **Tel quel** | Règles d'une bonne objection : citer la partie du plan visée ; décrire la panne concrètement ; dire ce qui devrait changer ; chercher la preuve dans le code avant d'affirmer. | `plan-challenger.md`, Step 2 |
| **Tel quel** | **L'étape de réfutation** : pour chaque objection, essayer de la contredire (le plan la traite-t-il ailleurs ? un motif existant la couvre-t-il ? le scénario est-il possible ?) ; ne garder que celles qui résistent. | `plan-challenger.md`, Step 3 |
| **Tel quel** | Échelle de gravité : bloquant (perte de données, faille, réécriture sous 3 mois) / à traiter ou risque accepté / détail. | `plan-challenger.md`, Severity Classification |
| **Adapté** | Livrable : un **verdict** YAML. Mais le schéma `verdict` exige que chaque remarque cite un fichier **du diff**, et un plan n'a pas de diff. Il faut donc soit un schéma **`verdict-plan`** dont chaque remarque cite une **étape** du plan (`etape: 2`), soit un nouveau type de livrable côté moteur. **Décision à prendre dans agent-engine.** | |
| **Écarté** | Statistiques citées (« +52,8 % », « +80 % ») : non vérifiées. Section « What's Solid », émojis. | |

### 4.2 `reviewer-securite` ← `security-auditor`, skill `security-checklist`

| Marque | Quoi | Origine |
|---|---|---|
| **Tel quel** | La **liste OWASP Top 10** (A01 à A10) et ses points de contrôle. | `security-auditor.md` |
| **Adapté** | Les points « facturation/abonnement » de A04 (Stripe, Paddle) ne valent que pour un projet qui facture : les déplacer dans la skill, pas dans le rôle. | `security-auditor.md`, A04 |
| **Adapté** | Livrable : `verdict`, un second nœud de relecture après `reviewer` dans un cycle « sensible » ([6.2](#62-variante-sensible)). | |
| **Écarté** | Exemples JavaScript (`innerHTML`, `process.env`). | |

### 4.3 `refactor` ← `refactoring-specialist` — facultatif

| Marque | Quoi | Origine |
|---|---|---|
| **Tel quel** | « Préserver le comportement : aucun changement fonctionnel pendant un refactoring » ; « ne jamais refactorer sans tests » ; « un petit changement à la fois ». | `refactoring-specialist.md`, Safety Rules et Process |
| **Adapté** | Livrable `fichiers` : le programme vérifie déjà que les tests existants restent intacts et verts. Un refactoring pur peut exiger **aucun nouveau test** et **le même résultat de tests** : règle à vérifier côté moteur. | |
| **Écarté** | « Commit frequently », « Keep refactoring PRs separate » : git est géré hors de l'agent. | |

### 4.4 `reviewer-architecture` ← `architecture-reviewer` — plus tard

Les **7 dimensions** (couplage, cohésion, réversibilité, montée en charge, sécurité, testabilité, conventions)
peuvent être reprises **telles quelles**. À créer seulement si `reviewer` devient trop chargé ; sinon, les
intégrer à sa grille.

---

## 5. Premières skills

La bibliothèque n'a encore aucune skill ([agents-profils-skills.md, 5.1](../../Foundation/briques/agent-engine/docs/agents-profils-skills.md)).
Rappel du principe 2.6 : une skill **aide**, seul un test **garantit**.

### 5.1 `tdd` ← `tdd-workflow`

- **Tel quel.** Une traduction française existe déjà : `D:\Projet\_quarantaine-dotfiles-2026-10-13\skills\tdd-workflow\SKILL.md` (l'ancienne copie retirée de dotfiles). La relire, ajouter la mention MIT.
- Utilisée par : `tester`, `coder`.

### 5.2 `checklist-securite` ← `security-checklist`

- **Tel quel.** Traduction existante : `D:\Projet\_quarantaine-dotfiles-2026-10-13\skills\security-checklist\SKILL.md`.
- **Adapté** : y ajouter les points « facturation » retirés du rôle ([4.2](#42-reviewer-securite--security-auditor-skill-security-checklist)).
- Utilisée par : `reviewer-securite`, `challenger`.

### 5.3 Lecture progressive ← `smart-explore`

- **Tel quel** : seulement l'**approche A** (« structure d'abord, lecture ciblée ensuite, jamais un fichier de bout en bout pour explorer »), sans outil à installer.
- **Écarté** : approches B (tree-sitter) et C (serveur MCP), qui demandent des installations.
- Intérêt : réduit les tokens lus par `architect`, `challenger` et `reviewer`.

### 5.4 Audit défensif ← section « Defensive Code Audit » de `code-reviewer`

- **Adapté** : les 4 familles (exceptions avalées, valeurs de repli qui masquent une absence, nuls non vérifiés, erreurs asynchrones ignorées) sont universelles ; les exemples sont en JavaScript. Une skill par stack (.NET, Python…) avec ses propres exemples.

### 5.5 Écartées pour l'instant

| Skill | Raison |
|---|---|
| `ast-grep-patterns` | Demande l'outil `ast-grep` installé ; exemples centrés JS/TS. Une copie traduite est en quarantaine si besoin plus tard. |
| `design-patterns` | 566 lignes centrées TypeScript (React, Angular, NestJS), dépend d'un serveur MCP `grepai`. À réécrire pour .NET si utile. |
| `cyber-defense-team` | Analyse de journaux serveur : autre domaine. |

---

## 6. Cycles

### 6.1 `developpement` avec contestation du plan

```text
conception (architect) → contestation (challenger) → tests (tester) → code (coder) → relecture (reviewer)
            ▲                     │ refuse                              ▲                  │ refuse
            └─────────────────────┘                                     └──────────────────┘
```

**Adapté** de l'enchaînement `planner` → `plan-challenger` → implémentation décrit par Florian. Dépend du
schéma `verdict-plan` ([4.1](#41-challenger--plan-challenger--le-plus-intéressant)).

### 6.2 Variante « sensible »

`relecture (reviewer)` → `relecture-securite (reviewer-securite)` → fin. Pour l'authentification, les paiements,
les données personnelles.

### 6.3 Pipeline de planification complet — plus tard

`plan-ceo-review` → `plan-eng-review` → `plan-start` → `plan-validate` → `plan-execute` (skill `plan-pipeline`) :
un enchaînement à portes de validation humaine. **Écarté pour le palier 2** ; une référence pour le palier 3
(orchestrateur).

---

## 7. Pour le moteur, pas pour forge

Ces idées relèvent du **programme** agent-engine (principe 2.1), pas d'un rôle.

| Idée | Origine | Ce que le moteur ferait |
|---|---|---|
| **Commandes interdites** | hook `dangerous-actions-blocker.sh` | Refuser, avant exécution, les commandes de l'agent qui correspondent à une liste : `rm -rf /`, `rm -rf ~`, `mkfs`, `dd if=`, `chmod -R 777 /`, `DROP DATABASE`, `DROP TABLE`, `git push --force` vers `main`/`master`, `npm publish`… La **liste** peut être une donnée de forge (`garde-fous/commandes-interdites.yaml`), le **contrôle** reste dans le moteur (hook `PreToolUse` déclaré dans le code via le Claude Agent SDK). |
| **Fichiers sensibles** | même hook | Interdire la lecture ou l'écriture de `.env*`, `id_rsa`, `id_ed25519`, `credentials.json`, `secrets.y*ml`… Complète le principe 2.5. |
| **Boucle qui tourne à vide** | agent `loop-monitor` | Détecter de façon **déterministe**, sans modèle : N appels d'outil identiques d'affilée, aucun progrès depuis X minutes, consommation anormale. Arrêter le nœud en échec. |
| **Limite de débit de l'API** | hook `velocity-governor.sh` | Attendre la remise à zéro au lieu d'échouer quand la limite de l'API approche. |
| **Modèle par nœud** | champ `model:` des agents (opus pour planifier et relire, sonnet pour coder, haiku pour surveiller) | Un champ facultatif `modele` par nœud de cycle. Le rôle reste sans modèle. |

---

## 8. Écarté

| Élément | Raison |
|---|---|
| Tous les **hooks** de session (`learning-capture`, `session-logger`, `auto-rename-session`, `auto-checkpoint`, `tts-selective`…) | Pensés pour un humain dans Claude Code ; le moteur ne charge pas les réglages de la machine (`setting_sources=[]`) et a ses propres comptes rendus. |
| Les **commandes slash** (`/pr`, `/commit`, `/ship`…) | Déclenchées par un humain ; le moteur exécute des cycles. |
| `output-evaluator` | Un juge LLM qui donne « APPROVE » par seuils de scores : contraire au principe « un avis ne conclut jamais seul ». |
| `security-patcher` | Applique des correctifs après validation humaine : relève d'un cycle à part, plus tard. |
| `adr-writer` | Utile pour documenter, hors du cycle de développement. À reconsidérer pour un cycle « documentation ». |
| `integration-reviewer` | Utile quand un plan touche des services (ports, variables d'environnement) ; à reconsidérer plus tard. |
| `report-template`, `loop-monitor` en tant qu'agent | Le premier est un gabarit de rapport ; le second est repris comme **mécanisme du moteur** ([section 7](#7-pour-le-moteur-pas-pour-forge)). |

---

## 9. Ordre de mise en œuvre proposé

Le critère de tri : une **consigne** (texte d'un rôle, contenu d'un skill) est lue par le modèle, dans un
format déjà fixé ; un **contrat** (schéma, cycle, type de livrable) est ce que le **programme** vérifie, et
c'est agent-engine qui le définit.

- Une consigne peut entrer dans forge **maintenant** : le moteur lit déjà les rôles, et un skill suit le
  format standard de Claude.
- Un contrat entre dans forge **en même temps** que le moteur sait le vérifier : l'écrire avant, c'est écrire
  une règle que personne n'applique, à refaire quand le format sera fixé.

### 9.1 Maintenant — consignes, sans dépendance

| # | Action | Section |
|---|---|---|
| 1 | Créer `claude/THIRD-PARTY-NOTICES.md` | [2](#2-mention-de-lauteur-et-de-la-licence) |
| 2 | Enrichir `architect`, `tester`, `reviewer` avec les passages **tels quels**. Trancher en écrivant `reviewer` : lire en entier les fichiers du diff, explorer les autres par structure | [3.1 à 3.3](#3-rôles-existants-à-enrichir) |
| 3 | Skills `tdd` et `checklist-securite`, depuis les traductions en quarantaine | [5.1](#51-tdd--tdd-workflow), [5.2](#52-checklist-securite--security-checklist) |
| 4 | Rôle `reviewer-securite` : consignes et schéma `verdict` **existant** | [4.2](#42-reviewer-securite--security-auditor-skill-security-checklist) |
| 5 | Skills « lecture progressive » et « audit défensif », si utiles | [5.3](#53-lecture-progressive--smart-explore), [5.4](#54-audit-défensif--section--defensive-code-audit--de-code-reviewer) |

### 9.2 Après le palier 2 d'agent-engine — contrats

| Action | Attend, côté agent-engine | Section |
|---|---|---|
| Rôle `challenger` et cycle « développement avec contestation » | Le format du verdict sur un plan (`verdict-plan` ou nouveau livrable) | [4.1](#41-challenger--plan-challenger--le-plus-intéressant), [6.1](#61-developpement-avec-contestation-du-plan) |
| Champs `plan.risques`, `plan.questions_ouvertes`, `plan.etapes[].tests`, `verdict.remarques[].gravite` | Les vérifications de ces champs, conçues en même temps que le schéma | [3.1](#31-architect--planner-planning-coordinator), [3.3](#33-reviewer--code-reviewer-architecture-reviewer) |
| Variante de cycle « sensible » | Le format des cycles, encore proposé (v0) | [6.2](#62-variante-sensible) |
| Rôle `refactor` | La règle « aucun nouveau test, même résultat de tests » | [4.3](#43-refactor--refactoring-specialist--facultatif) |
| Rôle `reviewer-architecture` | Rien de technique : à décider si `reviewer` devient trop chargé | [4.4](#44-reviewer-architecture--architecture-reviewer--plus-tard) |

### 9.3 Hors de forge

Les idées de la [section 7](#7-pour-le-moteur-pas-pour-forge) (commandes interdites, fichiers sensibles,
boucle à vide, limite de débit, modèle par nœud) relèvent du code d'agent-engine. Seule la **liste** des
commandes interdites pourrait, plus tard, devenir une donnée de forge.

Chaque modification de forge se termine par une montée de `version` dans `claude/.claude-plugin/plugin.json`
et une réinstallation (`install.ps1`).
