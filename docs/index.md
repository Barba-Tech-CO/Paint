# PaintPro Documentation Index

## 🎯 Objetivo
Centralizar o material AI-ready da API PaintPro, destacando fluxos críticos (autenticação, contatos, orçamentos e extração de materiais) e mostrando como navegar entre módulos, referências e coleções de teste.

## 🌳 Estrutura das Pastas
- `AUTH_MODULE.MD`, `CONTATOS_MODULE.MD`, `ORCAMENTOS_MODULE.MD`, `EXTRACAO_PDF_MODULE.MD` — visão de domínio e decisões por módulo.
- `reference/` — contratos de API (REST) prontos para IA e humanos.
- `collections/api-postman.json` — collection Postman para execução manual/automática.
- `database-schema.md` — diagrama lógico do banco.
- `reference/jamie-ai.md` — fluxo assistido pela Jamie AI para geração de orçamentos one-shot.

## 🔗 Navegação Rápida
- Autenticação (Credentials): `docs/AUTH_MODULE.MD`
- Contatos: `docs/CONTATOS_MODULE.MD` · `docs/reference/ghl-contacts.md`
- Orçamentos: `docs/ORCAMENTOS_MODULE.MD` · `docs/reference/estimates.md`
- Materiais (PDF → IA): `docs/EXTRACAO_PDF_MODULE.MD` · `docs/reference/materials.md`
- Saúde e usuários gerais: `docs/reference/health.md`, `docs/reference/users.md`

## 🤖 Como manter AI-ready
1. Atualize este índice sempre que criar novos artefatos.
2. Padronize títulos, subtítulos e links cruzados (conforme `docs/doc-ai-ready-jacob-moura.pdf`).
3. Inclua exemplos de payload, respostas e prompts para assistentes (Jamie AI).
4. Sincronize mudanças de contrato com `paint_pro_api/response.json` e com a collection Postman.

## ✅ Checklist de Atualização
- [ ] Endpoint novo documentado em `reference/`
- [ ] Fluxo explicado no módulo correspondente
- [ ] Exemplos revisados (payload, cURL ou prompt)
- [ ] Postman e `response.json` alinhados
- [ ] Links cruzados inseridos/atualizados neste índice
