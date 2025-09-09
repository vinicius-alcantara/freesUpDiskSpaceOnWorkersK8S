# freesUpDiskSpaceOnWorkersK8S

## 📌 Descrição

Este projeto automatiza a **liberação de espaço em disco nos workers de um cluster Kubernetes**, realizando:

- Verificação do uso de disco em cada worker.
- **Drain** e **Uncordon** controlados dos nodes conforme o ambiente e horário.
- Reinicialização do serviço Docker e execução de `docker image prune -af`.
- Comparação do espaço em disco antes e depois da limpeza.
- Envio de notificações por e-mail com sucesso ou falha em cada etapa.

A automação foi projetada para rodar em **ambientes de Produção** e **Desenvolvimento**, aplicando regras diferentes de execução.

---

## 📂 Estrutura do Projeto

```text
freesUpDiskSpaceOnWorkersK8S/
├── script.sh                  # Script principal de automação
└── sendMailCurlFunction.sh    # Funções auxiliares para envio de e-mails
