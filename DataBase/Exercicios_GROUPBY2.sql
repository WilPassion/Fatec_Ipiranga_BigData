/* Exercicios INNER JOIN, GROUP BY */

CREATE TABLE Funcionarios (
    id_funcionario integer,
    nome text,
    salario numeric,
    departamento_id integer
);

CREATE TABLE Departamentos (
    id_departamento integer,
    nome text
);

CREATE TABLE Projetos (
    id_projeto integer,
    nome text,
    departamento_id integer
);

CREATE TABLE Alocacoes (
    id_alocacao integer,
    id_funcionario integer,
    id_projeto integer,
    data_inicio date,
    data_fim date
);
INSERT INTO Funcionarios (id_funcionario, nome, salario, departamento_id) VALUES
(1, 'João Silva', 5000, 1),
(2, 'Maria Santos', 6000, 1),
(3, 'Pedro Oliveira', 4500, 2),
(4, 'Ana Costa', 5500, 2),
(5, 'Carlos Pereira', 4000, 3),
(6, 'Mariana Rocha', 7000, 3),
(7, 'Lucas Santos', 4800, 1),
(8, 'Sofia Fernandes', 5200, 2),
(9, 'Rodrigo Lima', 5300, 3),
(10, 'Laura Carvalho', 4700, 1);
INSERT INTO Departamentos (id_departamento, nome) VALUES
(1, 'Vendas'),
(2, 'Recursos Humanos'),
(3, 'Financeiro'),-- Inserts adicionais para a tabela Departamentos
(6, 'Logística'),
(7, 'Qualidade'),
(8, 'Atendimento ao Cliente'),
(9, 'Marketing Digital'),
(10, 'Pesquisa e Desenvolvimento');
INSERT INTO Projetos (id_projeto, nome, departamento_id) VALUES
(1, 'Projeto A', 1),
(2, 'Projeto B', 2),
(3, 'Projeto C', 3),
(4, 'Projeto D', 1),
(5, 'Projeto E', 2),
(6, 'Projeto F', 3),
(7, 'Projeto G', 1),
(8, 'Projeto H', 2),
(9, 'Projeto I', 3),
(10, 'Projeto J', 1);
INSERT INTO Alocacoes (id_alocacao, id_funcionario, id_projeto, data_inicio, data_fim) VALUES
(1, 1, 1, '2021-01-01', '2021-06-30'),
(2, 2, 1, '2021-03-01', '2021-09-30'),
(3, 3, 2, '2021-02-01', '2021-07-31'),
(4, 4, 2, '2021-04-01', '2021-10-31'),
(5, 5, 3, '2021-01-01', '2021-06-30'),
(6, 6, 3, '2021-03-01', '2021-09-30'),
(7, 7, 4, '2021-02-01', '2021-07-31'),
(8, 8, 4, '2021-04-01', '2021-10-31'),
(9, 9, 5, '2021-01-01', '2021-06-30'),
(10, 10, 5, '2021-03-01', '2021-09-30');

-- Escreva uma consulta SQL que retorne o nome do projeto, 
-- o nome do departamento responsável por esse projeto 
-- e a contagem de funcionários alocados em cada projeto.
SELECT p.nome AS "Nome_Projeto", d.nome AS "Departamento",
	COUNT(f.id_funcionario) AS "Funcionarios Alocados" 
FROM Departamentos d 
INNER JOIN Funcionarios f ON d.id_departamento = f.departamento_id
INNER JOIN Projetos p ON d.id_departamento = p.departamento_id
GROUP BY p.nome, d.nome
ORDER BY p.nome ASC;


SELECT * FROM Departamentos; 
SELECT * FROM Funcionarios;
SELECT * FROM Alocacoes;
SELECT * FROM Projetos;

