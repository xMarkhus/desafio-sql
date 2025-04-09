CREATE DATABASE loja_virtual;

CREATE TABLE produtos (
	id_produto INT PRIMARY KEY,
    nome_produto VARCHAR(100),
    descricao TEXT,
    preco DECIMAL(10,2),
    estoque INT,
    categoria VARCHAR(50)
);

CREATE TABLE clientes (
	id_cliente INT PRIMARY KEY,
    nome_cliente VARCHAR(100),
    email VARCHAR(140),
    endereco VARCHAR(250)
);

CREATE TABLE pedidos (
	id_pedido INT PRIMARY KEY,
    id_cliente INT,
    data_pedido DATE,
    status VARCHAR(50),
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

CREATE TABLE itens_pedido (
	id_item INT PRIMARY KEY,
    id_pedido INT,
    id_produto INT,
    quantidade INT,
    preco_unitario DECIMAL(10,2),
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido),
    FOREIGN KEY (id_produto) REFERENCES produtos(id_produto)
);

LOAD DATA INFILE '/var/lib/mysql-files/produtos.csv'
INTO TABLE produtos
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id_produto, nome_produto, descricao, preco, estoque, categoria);

LOAD DATA INFILE '/var/lib/mysql-files/clientes.csv'
INTO TABLE clientes
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id_cliente, nome_cliente, email, endereco);

LOAD DATA INFILE '/var/lib/mysql-files/pedidos.csv'
INTO TABLE pedidos
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id_pedido, id_cliente, data_pedido, status);

LOAD DATA INFILE '/var/lib/mysql-files/itens_pedidos.csv'
INTO TABLE itens_pedido
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id_item, id_pedido, id_produto, quantidade, preco_unitario);

-- 1. Liste o nome e a descrição de todos os produtos da categoria "Smartphones" 
-- com preço superior a R$ 1000, 
-- ordenados pelo nome do produto
SELECT nome_produto, categoria
FROM produtos 
WHERE categoria = 'Smartphones'
	AND preco > 1000
ORDER BY nome_produto;

-- 2. Calcule o valor total de compras por cliente, 
-- mostrando o nome do cliente e o valor total, 
-- ordenado pelo valor total em ordem decrescente.
SELECT
	nome_cliente,
    SUM(ip.quantidade * ip.preco_unitario) AS valor_total
FROM clientes c
JOIN
	pedidos p ON c.id_cliente = p.id_cliente
JOIN
	itens_pedido ip ON ip.id_pedido = p.id_pedido
GROUP BY
	c.nome_cliente
ORDER BY
	valor_total DESC;

-- 3. Encontre os 5 produtos mais vendidos, 
-- mostrando o nome do produto e a quantidade total vendida, 
-- ordenados pela quantidade em ordem decrescente.
SELECT
	pro.nome_produto,
    SUM(ip.quantidade) AS total_vendido
FROM 
	itens_pedido ip
JOIN
	produtos pro ON ip.id_pedido = pro.id_produto
GROUP BY
	pro.nome_produto
ORDER BY
	total_vendido DESC
LIMIT 5;

-- 4. Liste os clientes que possuem pedidos com status "Em processamento", 
-- mostrando o nome do cliente 
-- e o número do pedido.
SELECT
	c.nome_cliente,
    p.id_pedido
FROM
	clientes c
JOIN
	pedidos p ON c.id_cliente = p.id_cliente
WHERE
	p.status = 'Em processamento';

-- 5. Calcule a receita total da loja por mês, 
-- mostrando o mês e a receita total, 
-- ordenados pelo mês.
SELECT
	DATE_FORMAT(p.data_pedido, '%Y-%m') AS mes,
    SUM(ip.quantidade * ip.preco_unitario) AS receita_total
FROM
	pedidos p
JOIN
	itens_pedido ip ON p.id_pedido = ip.id_pedido
GROUP BY
	mes
ORDER BY
	mes;

-- Uma abordagem eficiente para melhorar as consultas
-- quando o banco começar a crescer, é a criação de indíces.
-- Os índices melhoram significativamente a otimização de consultas.
-- Poderíamos criar os seguintes índices:

-- Tabela produos
CREATE INDEX idx_produtos_categoria_preco_nome
	ON produtos (categoria, preco, nome_produto);

-- Tabela pedidos
CREATE INDEX idx_pedidos_id_cliente
	ON pedidos (id_cliente);
    
CREATE INDEX idx_pedidos_status
	ON pedidos (status);

CREATE INDEX idx_pedidos_data_pedido
	ON pedidos (data_pedido);
    
-- Tabela itens_pedido
CREATE INDEX idx_itens_pedido_id_pedido
	ON itens_pedido (id_pedido);
    
CREATE INDEX idx_itens_pedido_id_produto
	ON itens_pedido (id_produto);
 