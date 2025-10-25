-- SEÇÃO 1: LIMPEZA DO AMBIENTE
--
--
DROP TABLE IF EXISTS db_loja.pedido_itens, db_loja.pedido_cabecalho, db_loja.produtos, db_loja.categorias_produtos, db_loja.clientes CASCADE;
DROP SCHEMA IF EXISTS db_loja;


--
-- SEÇÃO 2: CRIAÇÃO DO SCHEMA
--
-- Um schema é como uma pasta dentro do banco de dados, usado para organizar as tabelas e outros objetos.
-- Isso evita conflitos de nomes e melhora a organização.
--
CREATE SCHEMA IF NOT EXISTS db_loja;

--
-- SEÇÃO 3: ESTRUTURA DAS TABELAS (CREATE TABLE)
--
-- Aqui definimos a estrutura de cada tabela, suas colunas, tipos de dados e restrições.
--

-- Tabela: categorias_produtos
-- Armazena as categorias às quais os produtos podem pertencer.
CREATE TABLE db_loja.categorias_produto (
    id INTEGER PRIMARY KEY,                 -- Chave primária: identificador único da categoria.
    nome VARCHAR(100) NOT NULL UNIQUE,      -- Nome da categoria, não pode ser nulo e deve ser único.
    descricao TEXT                          -- Descrição opcional da categoria.
);

-- Tabela: produtos
-- Contém todos os produtos da loja.
CREATE TABLE db_loja.produto (
    id INTEGER PRIMARY KEY,                 -- Chave primária: identificador único do produto.
    nome VARCHAR(255) NOT NULL,             -- Nome do produto, não pode ser nulo.
    descricao TEXT,                         -- Descrição detalhada do produto.
    preco NUMERIC(10, 2) NOT NULL,          -- Preço do produto com precisão de 2 casas decimais.
    estoque INT NOT NULL DEFAULT 0,         -- Quantidade em estoque, com valor padrão 0.
    id_categoria INT,                       -- Chave estrangeira que se conecta à tabela 'categorias_produtos'.
    data_criacao TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,     -- Registra o momento exato da criação do produto. Preenchido automaticamente no INSERT.
    data_atualizacao TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Registra a última modificação do produto. Será atualizado automaticamente pelo Trigger.
   CONSTRAINT fk_categoria                 -- Nome da restrição.
        FOREIGN KEY(id_categoria)           -- Coluna nesta tabela.
        REFERENCES db_loja.categorias_produto(id) -- Tabela e coluna referenciadas.
);

-- Tabela: clientes
-- Armazena os dados dos clientes cadastrados.
CREATE TABLE db_loja.cliente (
    id INTEGER PRIMARY KEY,                 -- Chave primária: identificador único do cliente.
    nome VARCHAR(150) NOT NULL,             -- Nome do cliente.
    email VARCHAR(255) UNIQUE NOT NULL,     -- Email do cliente, deve ser único.
    telefone VARCHAR(20),                   -- Telefone de contato.
    data_cadastro TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP, -- Data de cadastro, preenchida automaticamente.
    is_date BOOLEAN DEFAULT FALSE NOT NULL -- Marcação se o registro foi excluído.
);

-- Tabela: pedido_cabecalho
-- Armazena as informações gerais de cada pedido.
CREATE TABLE db_loja.pedido_cabecalho (
    id INTEGER PRIMARY KEY,                 -- Chave primária: identificador único do pedido.
    id_cliente INT NOT NULL,                -- Chave estrangeira para a tabela 'clientes'.
    data_pedido TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP, -- Data em que o pedido foi realizado.
    valor_total NUMERIC(10, 2) NOT NULL,    -- Valor total do pedido.
    CONSTRAINT fk_cliente
        FOREIGN KEY(id_cliente)
        REFERENCES db_loja.cliente(id)
);

-- Tabela: pedido_itens
-- Detalha os produtos contidos em cada pedido. Uma linha para cada produto em um pedido.
CREATE TABLE db_loja.pedido_itens (
    id INTEGER PRIMARY KEY,                 -- Chave primária: identificador único do item do pedido.
    id_pedido INT NOT NULL,                 -- Chave estrangeira para 'pedido_cabecalho'.
    id_produto INT NOT NULL,                -- Chave estrangeira para 'produtos'.
    quantidade INT NOT NULL,                -- Quantidade comprada do produto.
    preco_unitario NUMERIC(10, 2) NOT NULL, -- Preço do produto no momento da compra.
    CONSTRAINT fk_pedido
        FOREIGN KEY(id_pedido)
        REFERENCES db_loja.pedido_cabecalho(id),
    CONSTRAINT fk_produto
        FOREIGN KEY(id_produto)
        REFERENCES db_loja.produto(id)
);


--
-- SEÇÃO 4: AUTOMAÇÃO DE TIMESTAMP (FUNÇÃO E TRIGGER)
--
-- Esta seção cria a lógica para atualizar automaticamente o campo 'data_atualizacao' na tabela 'produtos'.
--

-- 4.1. FUNÇÃO DO TRIGGER:
-- Esta função define a AÇÃO que o trigger irá executar.
-- Sua única responsabilidade é atualizar o campo 'data_atualizacao' para o horário atual (NOW()).
CREATE OR REPLACE FUNCTION db_loja.atualizar_data_atualizacao_trigger()
RETURNS TRIGGER AS $$
BEGIN
   -- A variável especial 'NEW' representa a linha que está sendo inserida ou atualizada.
   -- Aqui, estamos modificando o valor do campo 'data_atualizacao' dessa linha.
   NEW.data_atualizacao = NOW();
   
   -- Retorna a linha modificada para que a operação de UPDATE possa continuar normalmente.
   RETURN NEW;
END;
$$ LANGUAGE plpgsql; -- Define a linguagem da função como PL/pgSQL, padrão do PostgreSQL.

-- 4.2. CRIAÇÃO DO TRIGGER (GATILHO):
-- Este é o "gatilho" que efetivamente monitora a tabela 'produtos'.
CREATE TRIGGER trigger_produtos_atualizacao
BEFORE UPDATE ON db_loja.produto              -- Dispara ANTES de qualquer comando UPDATE na tabela 'produtos'.
FOR EACH ROW                                   -- A ação será executada para cada linha individual que for atualizada.
EXECUTE FUNCTION db_loja.atualizar_data_atualizacao_trigger(); -- Executa a função que criamos acima.


--
-- SEÇÃO 5: INSERÇÃO DE DADOS DE EXEMPLO (INSERT)
--
-- Agora que a estrutura está pronta, populamos as tabelas com dados de exemplo.
--

-- Inserindo dados na tabela de categorias
INSERT INTO db_loja.categorias_produto (id, nome, descricao) values
(1, 'Eletrônicos', 'Dispositivos eletrônicos e acessórios.'),
(2, 'Livros', 'Livros de diversos gêneros e autores.'),
(3, 'Roupas', 'Vestuário masculino, feminino e infantil.'),
(4, 'Casa e Cozinha', 'Utensílios e decoração para o lar.'),
(5, 'Esportes e Lazer', 'Artigos para práticas esportivas e atividades ao ar livre.'),
(6, 'Brinquedos e Jogos', 'Brinquedos para todas as idades e jogos de tabuleiro.'),
(7, 'Saúde e Bem-estar', 'Vitaminas, suplementos e equipamentos de cuidado pessoal.'),
(8, 'Ferramentas', 'Ferramentas manuais e elétricas para reparos.'),
(9, 'Automotivo', 'Acessórios e peças para veículos.'),
(10, 'Jardinagem', 'Ferramentas e suprimentos para jardinagem.');

-- Inserindo dados na tabela de produtos
-- Note que não precisamos informar 'data_criacao' e 'data_atualizacao', pois elas são preenchidas automaticamente.
INSERT INTO db_loja.produto (id, nome, descricao, preco, estoque, id_categoria) VALUES
(1, 'Smartphone X', 'Smartphone de última geração com 128GB.', 2999.90, 50, 1),
(2, 'Notebook Pro', 'Notebook com processador i7, 16GB RAM.', 7499.50, 30, 1),
(3, 'O Senhor dos Anéis', 'Edição de colecionador da trilogia.', 199.99, 100, 2),
(4, 'Camiseta Básica', 'Camiseta de algodão na cor preta.', 79.90, 200, 3),
(5, 'Panela de Pressão Elétrica', 'Capacidade de 6 litros, multifuncional.', 399.90, 80, 4),
(6, 'Bicicleta Aro 29', 'Mountain bike com 21 marchas.', 1499.00, 40, 5),
(7, 'Lego Classic', 'Caixa grande com 790 peças.', 249.90, 150, 6),
(8, 'Kit Halteres 10kg', 'Par de halteres emborrachados.', 179.90, 90, 7),
(9, 'Furadeira de Impacto', 'Potência de 750W, com maleta.', 299.00, 60, 8),
(10, 'Aspirador de Pó Robô', 'Mapeia a casa e retorna para a base.', 1899.00, 25, 4),
(11, 'Fones de Ouvido Bluetooth', 'Com cancelamento de ruído.', 499.50, 120, 1),
(12, 'A Sutil Arte de Ligar o F*da-se', 'Livro de autoajuda de Mark Manson.', 34.90, 300, 2),
(13, 'Jaqueta Corta-vento', 'Ideal para corridas e atividades ao ar livre.', 189.90, 110, 3),
(14, 'Kit de Jardinagem 3 Peças', 'Pá, ancinho e garfo de mão.', 49.90, 250, 10),
(15, 'Pneu Aro 15', 'Pneu para carros de passeio.', 350.00, 100, 9),
(16, 'Barraca de Camping 4 Pessoas', 'Impermeável e fácil de montar.', 450.00, 35, 5),
(17, 'Jogo de Tabuleiro War', 'Clássico jogo de estratégia.', 129.90, 80, 6),
(18, 'Vitamina C 1000mg', 'Frasco com 60 comprimidos.', 29.90, 400, 7),
(19, 'Jogo de Chaves de Fenda', 'Com 6 peças de diferentes tamanhos.', 89.90, 150, 8),
(20, 'Calça Jeans Slim', 'Jeans com elastano para maior conforto.', 149.90, 180, 3);

-- Inserindo dados na tabela de clientes
INSERT INTO db_loja.cliente (id, nome, email, telefone) VALUES
(1, 'João Silva', 'joao.silva@example.com', '(21) 98765-4321'),
(2, 'Maria Oliveira', 'maria.oliveira@example.com', '(11) 91234-5678'),
(3, 'Carlos Pereira', 'carlos.p@example.com', '(31) 99999-8888'),
(4, 'Ana Costa', 'ana.costa@example.com', '(41) 98888-7777'),
(5, 'Pedro Souza', 'pedro.souza@example.com', '(51) 97777-6666'),
(6, 'Juliana Santos', 'juliana.s@example.com', '(61) 96666-5555'),
(7, 'Lucas Lima', 'lucas.lima@example.com', '(71) 95555-4444'),
(8, 'Fernanda Almeida', 'fernanda.a@example.com', '(81) 94444-3333'),
(9, 'Ricardo Rocha', 'ricardo.r@example.com', '(91) 93333-2222'),
(10, 'Camila Gomes', 'camila.g@example.com', '(27) 92222-1111'),
(11, 'Bruno Martins', 'bruno.m@example.com', '(48) 91111-0000'),
(12, 'Patrícia Ribeiro', 'patricia.r@example.com', '(85) 90000-9999');


--
-- SEÇÃO 6: SIMULAÇÃO DE PEDIDOS
--
-- Inserindo dados de pedidos (cabeçalho e itens) para simular o funcionamento da loja.
--

-- Pedidos 1-10
INSERT INTO db_loja.pedido_cabecalho (id, id_cliente, valor_total, data_pedido) VALUES
(1, 1, 3159.70, '2025-09-01 10:30:00'), (2, 2, 199.99, '2025-09-02 14:00:00'), (3, 3, 7499.50, '2025-09-03 11:00:00'),
(4, 4, 449.80, '2025-09-04 09:15:00'), (5, 5, 1499.00, '2025-09-05 18:00:00'), (6, 6, 379.80, '2025-09-06 13:45:00'),
(7, 7, 239.70, '2025-09-07 16:20:00'), (8, 8, 299.00, '2025-09-08 10:00:00'), (9, 9, 1899.00, '2025-09-09 19:00:00'),
(10, 10, 534.40, '2025-09-10 12:30:00');

INSERT INTO db_loja.pedido_itens (id, id_pedido, id_produto, quantidade, preco_unitario) VALUES
(1, 1, 1, 1, 2999.90), (2, 1, 4, 2, 79.90), (3, 2, 3, 1, 199.99), (4, 3, 2, 1, 7499.50), (5, 4, 5, 1, 399.90),
(6, 4, 14, 1, 49.90), (7, 5, 6, 1, 1499.00), (8, 6, 7, 1, 249.90), (9, 6, 17, 1, 129.90), (10, 7, 8, 1, 179.90),
(11, 7, 18, 2, 29.90), (12, 8, 9, 1, 299.00), (13, 9, 10, 1, 1899.00), (14, 10, 11, 1, 499.50), (15, 10, 12, 1, 34.90);

-- Pedidos 11-20
INSERT INTO db_loja.pedido_cabecalho (id, id_cliente, valor_total, data_pedido) VALUES
(11, 11, 339.80, '2025-09-11 15:00:00'), (12, 12, 1400.00, '2025-09-12 17:00:00'), (13, 1, 450.00, '2025-09-13 08:00:00'),
(14, 2, 89.90, '2025-09-14 14:20:00'), (15, 3, 309.70, '2025-09-15 16:50:00'), (16, 5, 209.80, '2025-09-15 17:00:00'),
(17, 7, 79.90, '2025-09-16 09:00:00'), (18, 9, 199.99, '2025-09-16 11:30:00'), (19, 11, 34.90, '2025-09-17 14:00:00'),
(20, 12, 59.80, '2025-09-17 15:10:00');

INSERT INTO db_loja.pedido_itens (id, id_pedido, id_produto, quantidade, preco_unitario) VALUES
(16, 11, 13, 1, 189.90), (17, 11, 20, 1, 149.90), (18, 12, 15, 4, 350.00), (19, 13, 16, 1, 450.00), (20, 14, 19, 1, 89.90),
(21, 15, 4, 2, 79.90), (22, 15, 20, 1, 149.90), (23, 16, 17, 1, 129.90), (24, 16, 14, 1, 49.90), (25, 16, 18, 1, 29.90),
(26, 17, 4, 1, 79.90), (27, 18, 3, 1, 199.99), (28, 19, 12, 1, 34.90), (29, 20, 18, 2, 29.90);

-- Pedidos 21-30
INSERT INTO db_loja.pedido_cabecalho (id, id_cliente, valor_total, data_pedido) VALUES
(21, 1, 499.50, '2025-09-17 18:00:00'), (22, 4, 179.90, '2025-09-18 10:00:00'), (23, 6, 299.00, '2025-09-18 11:00:00'),
(24, 8, 399.90, '2025-09-18 14:30:00'), (25, 10, 149.90, '2025-09-18 16:00:00'), (26, 2, 2999.90, '2025-09-19 09:45:00'),
(27, 3, 189.90, '2025-09-19 10:15:00'), (28, 5, 89.90, '2025-09-19 13:00:00'), (29, 7, 700.00, '2025-09-20 11:00:00'),
(30, 9, 249.90, '2025-09-20 14:00:00');

INSERT INTO db_loja.pedido_itens (id, id_pedido, id_produto, quantidade, preco_unitario) VALUES
(30, 21, 11, 1, 499.50), (31, 22, 8, 1, 179.90), (32, 23, 9, 1, 299.00), (33, 24, 5, 1, 399.90), (34, 25, 20, 1, 149.90),
(35, 26, 1, 1, 2999.90), (36, 27, 13, 1, 189.90), (37, 28, 19, 1, 89.90), (38, 29, 15, 2, 350.00), (39, 30, 7, 1, 249.90);

-- Pedidos 31-40
INSERT INTO db_loja.pedido_cabecalho (id, id_cliente, valor_total, data_pedido) VALUES
(31, 12, 129.90, '2025-09-20 15:30:00'), (32, 11, 450.00, '2025-09-20 17:00:00'), (33, 1, 69.80, '2025-09-21 10:00:00'),
(34, 4, 359.80, '2025-09-21 11:30:00'), (35, 6, 79.90, '2025-09-21 12:00:00'), (36, 8, 1499.00, '2025-09-21 14:00:00'),
(37, 10, 399.90, '2025-09-21 16:30:00'), (38, 2, 299.00, '2025-09-22 09:00:00'), (39, 3, 1899.00, '2025-09-22 10:00:00'),
(40, 5, 199.99, '2025-09-22 11:00:00');

INSERT INTO db_loja.pedido_itens (id, id_pedido, id_produto, quantidade, preco_unitario) VALUES
(40, 31, 17, 1, 129.90), (41, 32, 16, 1, 450.00), (42, 33, 12, 2, 34.90), (43, 34, 8, 2, 179.90), (44, 35, 4, 1, 79.90),
(45, 36, 6, 1, 1499.00), (46, 37, 5, 1, 399.90), (47, 38, 9, 1, 299.00), (48, 39, 10, 1, 1899.00), (49, 40, 3, 1, 199.99);

-- Pedidos 41-50
INSERT INTO db_loja.pedido_cabecalho (id, id_cliente, valor_total, data_pedido) VALUES
(41, 7, 7499.50, '2025-09-22 12:00:00'), (42, 9, 499.50, '2025-09-22 14:00:00'), (43, 11, 29.90, '2025-09-22 15:00:00'),
(44, 12, 49.90, '2025-09-22 16:00:00'), (45, 1, 149.90, '2025-09-22 17:00:00'), (46, 4, 189.90, '2025-09-23 09:30:00'),
(47, 6, 89.90, '2025-09-23 10:00:00'), (48, 8, 1050.00, '2025-09-23 11:00:00'), (49, 10, 249.90, '2025-09-23 12:00:00'),
(50, 2, 129.90, '2025-09-23 14:00:00');

INSERT INTO db_loja.pedido_itens (id, id_pedido, id_produto, quantidade, preco_unitario) VALUES
(50, 41, 2, 1, 7499.50), (51, 42, 11, 1, 499.50), (52, 43, 18, 1, 29.90), (53, 44, 14, 1, 49.90), (54, 45, 20, 1, 149.90),
(55, 46, 13, 1, 189.90), (56, 47, 19, 1, 89.90), (57, 48, 15, 3, 350.00), (58, 49, 7, 1, 249.90), (59, 50, 17, 1, 129.90);

-- Pedidos 51-60
INSERT INTO db_loja.pedido_cabecalho (id, id_cliente, valor_total, data_pedido) VALUES
(51, 3, 450.00, '2025-09-23 15:00:00'), (52, 5, 34.90, '2025-09-23 16:00:00'), (53, 7, 159.80, '2025-09-23 17:00:00'),
(54, 9, 179.90, '2025-09-23 18:00:00'), (55, 11, 299.00, '2025-09-23 19:00:00'), (56, 1, 399.90, '2025-09-23 20:00:00'),
(57, 4, 1499.00, '2025-09-23 21:00:00'), (58, 6, 199.99, '2025-09-24 09:00:00'), (59, 8, 7499.50, '2025-09-24 10:00:00'),
(60, 10, 1899.00, '2025-09-24 11:00:00');

INSERT INTO db_loja.pedido_itens (id, id_pedido, id_produto, quantidade, preco_unitario) VALUES
(60, 51, 16, 1, 450.00), (61, 52, 12, 1, 34.90), (62, 53, 4, 2, 79.90), (63, 54, 8, 1, 179.90), (64, 55, 9, 1, 299.00),
(65, 56, 5, 1, 399.90), (66, 57, 6, 1, 1499.00), (67, 58, 3, 1, 199.99), (68, 59, 2, 1, 7499.50), (69, 60, 10, 1, 1899.00);

-- Pedidos 61-70
INSERT INTO db_loja.pedido_cabecalho (id, id_cliente, valor_total, data_pedido) VALUES
(61, 2, 2999.90, '2025-09-24 12:00:00'), (62, 3, 499.50, '2025-09-24 13:00:00'), (63, 5, 59.80, '2025-09-24 14:00:00'),
(64, 7, 149.90, '2025-09-24 15:00:00'), (65, 9, 189.90, '2025-09-24 16:00:00'), (66, 11, 89.90, '2025-09-24 17:00:00'),
(67, 12, 350.00, '2025-09-24 18:00:00'), (68, 1, 249.90, '2025-09-24 19:00:00'), (69, 4, 129.90, '2025-09-24 20:00:00'),
(70, 6, 450.00, '2025-09-24 21:00:00');

INSERT INTO db_loja.pedido_itens (id, id_pedido, id_produto, quantidade, preco_unitario) VALUES
(70, 61, 1, 1, 2999.90), (71, 62, 11, 1, 499.50), (72, 63, 18, 2, 29.90), (73, 64, 20, 1, 149.90), (74, 65, 13, 1, 189.90),
(75, 66, 19, 1, 89.90), (76, 67, 15, 1, 350.00), (77, 68, 7, 1, 249.90), (78, 69, 17, 1, 129.90), (79, 70, 16, 1, 450.00);

-- Pedidos 71-80
INSERT INTO db_loja.pedido_cabecalho (id, id_cliente, valor_total, data_pedido) VALUES
(71, 8, 34.90, '2025-09-25 09:00:00'), (72, 10, 79.90, '2025-09-25 10:00:00'), (73, 2, 179.90, '2025-09-25 11:00:00'),
(74, 3, 299.00, '2025-09-25 12:00:00'), (75, 5, 399.90, '2025-09-25 13:00:00'), (76, 7, 1499.00, '2025-09-25 14:00:00'),
(77, 9, 199.99, '2025-09-25 15:00:00'), (78, 11, 7499.50, '2025-09-25 16:00:00'), (79, 12, 1899.00, '2025-09-25 17:00:00'),
(80, 1, 2999.90, '2025-09-25 18:00:00');

INSERT INTO db_loja.pedido_itens (id, id_pedido, id_produto, quantidade, preco_unitario) VALUES
(80, 71, 12, 1, 34.90), (81, 72, 4, 1, 79.90), (82, 73, 8, 1, 179.90), (83, 74, 9, 1, 299.00), (84, 75, 5, 1, 399.90),
(85, 76, 6, 1, 1499.00), (86, 77, 3, 1, 199.99), (87, 78, 2, 1, 7499.50), (88, 79, 10, 1, 1899.00), (89, 80, 1, 1, 2999.90);

-- Pedidos 81-90
INSERT INTO db_loja.pedido_cabecalho (id, id_cliente, valor_total, data_pedido) VALUES
(81, 4, 499.50, '2025-09-25 19:00:00'), (82, 6, 29.90, '2025-09-25 20:00:00'), (83, 8, 149.90, '2025-09-25 21:00:00'),
(84, 10, 189.90, '2025-09-26 09:00:00'), (85, 2, 89.90, '2025-09-26 10:00:00'), (86, 3, 350.00, '2025-09-26 11:00:00'),
(87, 5, 249.90, '2025-09-26 12:00:00'), (88, 7, 129.90, '2025-09-26 13:00:00'), (89, 9, 450.00, '2025-09-26 14:00:00'),
(90, 11, 34.90, '2025-09-26 15:00:00');

INSERT INTO db_loja.pedido_itens (id, id_pedido, id_produto, quantidade, preco_unitario) VALUES
(90, 81, 11, 1, 499.50), (91, 82, 18, 1, 29.90), (92, 83, 20, 1, 149.90), (93, 84, 13, 1, 189.90), (94, 85, 19, 1, 89.90),
(95, 86, 15, 1, 350.00), (96, 87, 7, 1, 249.90), (97, 88, 17, 1, 129.90), (98, 89, 16, 1, 450.00), (99, 90, 12, 1, 34.90);

-- Pedidos 91-100
INSERT INTO db_loja.pedido_cabecalho (id, id_cliente, valor_total, data_pedido) VALUES
(91, 12, 79.90, '2025-09-26 16:00:00'), (92, 1, 179.90, '2025-09-26 17:00:00'), (93, 4, 299.00, '2025-09-26 18:00:00'),
(94, 6, 399.90, '2025-09-26 19:00:00'), (95, 8, 1499.00, '2025-09-26 20:00:00'), (96, 10, 199.99, '2025-09-26 21:00:00'),
(97, 2, 7499.50, '2025-09-27 09:00:00'), (98, 3, 1899.00, '2025-09-27 10:00:00'), (99, 5, 2999.90, '2025-09-27 11:00:00'),
(100, 7, 534.40, '2025-09-27 12:00:00');

INSERT INTO db_loja.pedido_itens (id, id_pedido, id_produto, quantidade, preco_unitario) VALUES
(100, 91, 4, 1, 79.90), (101, 92, 8, 1, 179.90), (102, 93, 9, 1, 299.00), (103, 94, 5, 1, 399.90), (104, 95, 6, 1, 1499.00),
(105, 96, 3, 1, 199.99), (106, 97, 2, 1, 7499.50), (107, 98, 10, 1, 1899.00), (108, 99, 1, 1, 299.90), (109, 100, 11, 1, 499.50),
(110, 100, 12, 1, 34.90);
