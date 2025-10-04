# Jamie AI Assistant

Guia rápido para acessar e usar a IA exclusiva da Paintflow Renovations na geração de orçamentos.

## 🎥 Treinamento em Vídeo
- Acesse o vídeo introdutório em: https://paintprojcgg.notion.site/Paintflow-AI-101-7c130f820b4743f8a98d6291b0f00b09?pvs=4
- Clique em **Play** para assistir ao passo a passo completo do fluxo de IA.

## 🔐 Acesso ao Jamie AI
1. Abra o link da IA: https://app.flowgpt.com/c/196ejfecp2
2. Faça login com e-mail corporativo e senha ou use **Continue with Google** com `jacobmoura@paintflowrenovations.com`.
3. Ao entrar, selecione a IA "Jamie AI" (assistente exclusivo de orçamentos da Paintflow).
4. Utilize os quadros customizados para enviar suas solicitações de orçamento.

## 🧮 Geração de Orçamento
1. Clique em **Customização de Orçamentos Paintflow Renovations**.
2. Informe os dados abaixo para personalizar o orçamento:
   - Nome do cliente.
   - Tipo de pintura (`interno`, `externo` ou `ambos`).
   - Condição das paredes (`muito boa`, `boa`, `ruim`, `muito ruim`).
   - Custos extras (taxas, fees ou outros ajustes relevantes).
   - Condição da casa (ocupada ou vazia). Se ficar vazia por um período prolongado, sugerir 48 horas.
   - Disponibilidade/agenda para execução do serviço.
   - Soluções adicionais desejadas (não pintamos `stripes`; oferecemos `brick/brick mortar wash` e `wood stains`).
   - Observações complementares que possam impactar o orçamento.
3. Clique em **Enviar** e aguarde o cálculo automático.
4. Revise o orçamento sugerido pela IA.
5. Se estiver tudo correto, utilize **Copiar texto** para enviar o orçamento por e-mail ou pelo CRM.

### Saídas do Jamie AI
- Cronograma sugerido para execução.
- Materiais e insumos recomendados.
- Plano de execução com estimativa de mão de obra.

## 📝 Exemplo de submissão

Use o template abaixo no quadro "Customização de Orçamentos" para alinhar os campos com a API:

```markdown
**Cliente:** Maria Silva
**Projeto:** Pintura interna + externa
**Tipo:** ambos
**Condição das paredes:** boa
**Custos extras:** taxa HOA de 150 USD
**Condição da casa:** ocupada (solicitar janela de 48h)
**Disponibilidade:** próxima semana, terça a quinta
**Serviços adicionais:** brick mortar wash na fachada, wood stains em duas portas
**Observações:** família com crianças pequenas, evitar cheiros fortes
```

A resposta do Jamie AI retorna blocos organizados (resumo, materiais, linha do tempo e próximos passos) que devem ser migrados para o payload `POST /api/estimates` conforme `docs/reference/estimates.md`.

## ✅ Boas Práticas
- Cada orçamento reflete exatamente as informações fornecidas; revise antes de enviar ao cliente.
- Para ajustes solicitados pelo cliente, retorne ao Jamie AI e gere uma nova versão com os dados atualizados.
