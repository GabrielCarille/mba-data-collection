# Ambiente de Desenvolvimento com PySpark, PostgreSQL e MinIO

Este repositório fornece um ambiente de desenvolvimento pré-configurado para projetos de dados que utilizam **PySpark**, **Pandas**, **PostgreSQL** e **MinIO** (armazenamento de objetos S3).

O objetivo principal é padronizar e acelerar a configuração do ambiente de trabalho através do uso de **Dev Containers** e **GitHub Codespaces**, fornecendo um stack completo e pronto para uso em minutos.

## Sobre o Ambiente e a Tecnologia

Este é um template de ambiente de desenvolvimento baseado na especificação **Dev Containers** e projetado para ser executado na plataforma **GitHub Codespaces**. Ele automatiza a criação de um ambiente de desenvolvimento conteinerizado que já inclui todas as ferramentas e dependências necessárias.

### O que é um Dev Container?

Um Dev Container (ou Contêiner de Desenvolvimento) é um ambiente de desenvolvimento completo que roda dentro de um contêiner Docker. Trata-se de um padrão de código aberto que permite definir todos os componentes de um ambiente como código.

*   **Como funciona?** Através de um arquivo de configuração (`.devcontainer/devcontainer.json`) e um `docker-compose.yml`, você especifica tudo o que o projeto precisa: os serviços (app, banco de dados, S3), o sistema operacional base, versões de linguagens (Python, etc.), ferramentas, extensões do editor (VS Code) e configurações.
*   **Qual o benefício?** Ele resolve o clássico problema do "mas na minha máquina funciona". Como o ambiente é definido em código, qualquer pessoa que abrir o projeto terá um ambiente idêntico, consistente e reproduzível, garantindo que o código se comporte da mesma forma para todos.

### O que é o GitHub Codespaces?

O GitHub Codespaces é um produto da GitHub que oferece ambientes de desenvolvimento completos na nuvem. Pense nele como "Dev Containers como um Serviço".

*   **Como funciona?** O Codespaces lê a configuração do Dev Container (`.devcontainer/`) diretamente do seu repositório. Em seguida, ele utiliza essa configuração para construir e hospedar o seu ambiente em uma máquina virtual poderosa na nuvem. Você acessa este ambiente completo através do seu navegador, sem precisar instalar nada localmente.
*   **Qual o benefício?** Ele combina o poder da padronização dos Dev Containers com a flexibilidade da nuvem. Você pode programar de qualquer dispositivo, ter acesso a recursos computacionais robustos sob demanda e começar a trabalhar em um projeto novo em questão de minutos, com o ambiente já 100% configurado.

### Tecnologias Inclusas

O ambiente provisionado inclui os seguintes serviços e ferramentas:

*   **Python 3.11**: Linguagem de programação base.
*   **Apache Spark (via PySpark)**: Plataforma para processamento de dados em larga escala.
*   **Pandas**: Biblioteca para manipulação e análise de dados.
*   **PostgreSQL 15**: Banco de dados relacional de código aberto, rodando como um serviço separado.
*   **MinIO**: Um serviço de armazenamento de objetos de alta performance compatível com a API do Amazon S3. Ideal para armazenar "data lakes", arquivos brutos, backups, etc.
*   **Docker**: Plataforma de containerização que gerencia todos os serviços.
*   **GitHub Codespaces**: Plataforma de nuvem que hospeda e executa o ambiente.

### Principais Vantagens

*   **Stack Completo**: Ambiente pronto com processamento (PySpark), banco de dados (PostgreSQL) e armazenamento de objetos (MinIO).
*   **Inicialização Rápida**: O ambiente fica pronto para uso em poucos minutos, eliminando a necessidade de instalações e configurações manuais.
*   **Consistência**: Garante que todos os usuários operem com a mesma configuração de software e dependências, prevenindo problemas de compatibilidade.
*   **Isolamento**: As ferramentas e bibliotecas são executadas dentro de containers, não interferindo com a configuração da máquina local do usuário.
*   **Portabilidade**: O ambiente pode ser acessado de qualquer dispositivo com um navegador web.

## Guia de Utilização

Para utilizar este ambiente, siga os passos abaixo.

### Passo 1: Criar um "Fork" do Repositório

É recomendado criar uma cópia pessoal deste repositório na sua conta do GitHub. Um "fork" permite que você modifique o código livremente.

1.  Clique no botão "**Fork**" no canto superior direito desta página.
2.  Na tela seguinte, confirme a criação do fork clicando em "**Create fork**".

### Passo 2: Iniciar o GitHub Codespace

O Codespace irá construir e iniciar o ambiente de desenvolvimento.

1.  Na página do seu fork, clique no botão verde `< > Code`.
2.  Selecione a aba "**Codespaces**".
3.  Clique em "**Create codespace on main**".

O processo de inicialização pode levar alguns minutos, especialmente no primeiro uso. Ao final, uma nova aba será aberta com uma instância do VS Code funcional em seu navegador.

### Passo 3: Verificação do Ambiente

Para confirmar que todos os serviços estão operacionais e se comunicando, execute os scripts de teste localizados na raiz do projeto.

Abra o terminal integrado no VS Code (geralmente na parte inferior da tela) e execute os seguintes comandos:

*   **Teste do Pandas**:
    ```bash
    python teste_pandas.py
    ```
    (A saída esperada é a impressão de DataFrames com dados de produtos).
*   **Teste de Conexão com o PostgreSQL**:
    ```bash
    python teste_postgres.py
    ```
    (A saída esperada é uma mensagem de sucesso com a versão do PostgreSQL).
*   **Teste de Conexão com o MinIO (S3)**:
    ```bash
    python teste_minio.py
    ```
    (A saída esperada é uma mensagem de sucesso indicando conexão, criação de um bucket e upload de um arquivo de teste).

A execução bem-sucedida de todos os scripts confirma que o ambiente está configurado corretamente.

### Banco de Dados de Exemplo (`db_loja`)

Este repositório inclui um script SQL (`script-ddl-dbloja.sql`) que cria e popula um banco de dados de e-commerce completo para fins de demonstração.

O script cria o schema `db_loja` e as seguintes tabelas:

*   `categorias_produto`
*   `produto`
*   `cliente`
*   `pedido_cabecalho`
*   `pedido_itens`

Ele também insere centenas de registros de exemplo (produtos, clientes, pedidos), permitindo que você comece a testar consultas e jobs de PySpark imediatamente.

Veja a seção "**Conectando ao Banco de Dados PostgreSQL**" abaixo para instruções sobre como executar este script.

## Salvando e Enviando Alterações para o GitHub (Fluxo Básico do Git)

Após modificar ou criar arquivos, você precisa salvar seu progresso no GitHub. Este é o ciclo padrão que você usará repetidamente.

### Passo 1: Verificar o Status das Alterações

Veja o que você modificou.

```bash
git status
```

### Passo 2: Adicionar as Alterações para "Empacotamento"

Adicione os arquivos que você deseja salvar ao "pacote" (Staging Area).

```bash
# Para adicionar TODOS os arquivos modificados e novos
git add .
```

### Passo 3: Criar um "Pacote" de Salvamento (Commit)

Crie um ponto na história do projeto com as alterações que você adicionou. É crucial escrever uma mensagem clara que descreva o que você fez.

```bash
git commit -m "Sua mensagem descritiva aqui"
```

### Passo 4: Enviar as Alterações para o GitHub

Envie o seu "pacote" (commit) para o seu repositório remoto no GitHub.

```bash
git push origin main
```

## Gerenciamento dos Serviços

### Renomeando um Codespace

Por padrão, o GitHub gera nomes aleatórios para os Codespaces. É uma boa prática renomeá-los para algo mais descritivo.

1.  Acesse a sua lista de Codespaces em: `github.com/codespaces`.
2.  Encontre o Codespace, clique no menu de três pontos (`...`) e selecione "**Rename**".

### Conectando ao Banco de Dados PostgreSQL

Você pode interagir diretamente com o banco de dados PostgreSQL de dentro do VS Code, graças a uma extensão que já vem pré-instalada.

1.  **Conectar ao Banco de Dados**:
    1.  Na barra de atividades do lado esquerdo do VS Code, clique no ícone que parece um cilindro (**PostgreSQL**).
    2.  No painel da extensão, clique no ícone `+` para adicionar uma nova conexão.
    3.  Preencha os detalhes da conexão com as exatas credenciais definidas no arquivo `.devcontainer/docker-compose.yml`:
        *   **Host**: `db` (Este é o nome do serviço do Postgres no Docker Compose. Não use `localhost`).
        *   **User**: `myuser`
        *   **Password**: `mypassword`
        *   **Port**: `5432`
        *   **Database**: `mydb`
    4.  Clique no botão "**Connect**".
2.  **Executar o Script de Carga** (`db_loja`):
    1.  Após a conexão ser bem-sucedida, abra o arquivo `script-ddl-dbloja.sql` no editor.
    2.  Clique com o botão direito em qualquer lugar dentro do editor de texto do script.
    3.  Selecione a opção "**Execute Query**" (ou similar) para executar o script inteiro.
    4.  Após a execução, clique com o botão direito na sua conexão `db` no painel da extensão e escolha "**Refresh**".
    5.  Você agora poderá expandir o banco `mydb` e verá o novo schema `db_loja` com todas as tabelas e dados populados.

### Acessando o Console Web do MinIO

O serviço MinIO inclui um console web para você gerenciar visualmente seus buckets e arquivos (objetos), similar ao console do Amazon S3.

O Codespaces encaminha automaticamente as portas do MinIO (9000 para a API, 9001 para o console web).

1.  No VS Code, vá para a aba "**Portas**" (Ports) no painel inferior (ao lado de "Terminal", "Problemas", etc.).
2.  Você verá uma lista de portas encaminhadas. Encontre a porta `9001` (`minio`).
3.  Clique no ícone de "**Globo**" (Abrir no Navegador) ao lado da porta `9001`.
4.  Uma nova aba do navegador será aberta com a tela de login do MinIO.
5.  Use as credenciais definidas no `docker-compose.yml`:
    *   **Access Key**: `minioadmin`
    *   **Secret Key**: `minioadmin`

Ao logar, você verá o bucket `mybucket` (criado pelo Docker Compose) e o `meu-bucket-teste` (criado pelo script `teste_minio.py`), que contém o arquivo `teste.txt`.

## Próximos Passos

Com o ambiente funcional, você pode:

*   Modificar os scripts (`teste_pandas.py`, `teste_postgres.py`, etc.) para testar novas lógicas.
*   Criar notebooks Jupyter (a extensão Python já dá suporte) para exploração de dados.
*   Desenvolver jobs de PySpark que leem dados do MinIO, processam e gravam resultados no PostgreSQL.
*   Desenvolver jobs que leem dados do PostgreSQL, processam e salvam backups ou datasets tratados no MinIO.

