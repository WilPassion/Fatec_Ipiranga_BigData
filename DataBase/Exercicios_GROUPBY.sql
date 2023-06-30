CREATE TABLE Departamentos (
    id_departamento INTEGER,
    nome TEXT,
    PRIMARY KEY (id_departamento)
);

CREATE TABLE Funcionarios (
    id_funcionario INTEGER,
    nome TEXT,
    salario NUMERIC,
    departamento_id INTEGER,
    PRIMARY KEY (id_funcionario),
    FOREIGN KEY (departamento_id) REFERENCES Departamentos (id_departamento)
);
INSERT INTO Departamentos (id_departamento, nome) VALUES
(1, 'Vendas'),
(2, 'Recursos Humanos'),
(3, 'Financeiro'),-- Inserts adicionais para a tabela Departamentos
(6, 'Logística'),
(7, 'Qualidade'),
(8, 'Atendimento ao Cliente'),
(9, 'Marketing Digital'),
(10, 'Pesquisa e Desenvolvimento');

-- Inserts adicionais para a tabela Funcionarios
INSERT INTO Funcionarios (id_funcionario, nome, salario, departamento_id) VALUES
(6, 'Laura Oliveira', 3200.00, 1),
(7, 'Rafael Costa', 3800.00, 2),
(8, 'Fernanda Santos', 2900.00, 3),
(9, 'Gustavo Lima', 4200.00, 4),
(10, 'Camila Mendes', 3500.00, 1);
(4, 'TI'),
(5, 'Marketing');

-- Inserts para a tabela Funcionarios
INSERT INTO Funcionarios (id_funcionario, nome, salario, departamento_id) VALUES
(1, 'João Silva', 3500.00, 1),
(2, 'Maria Santos', 4000.00, 2),
(3, 'Pedro Almeida', 3000.00, 1),
(4, 'Ana Pereira', 3800.00, 3),
(5, 'Carlos Oliveira', 4200.00, 4);

-- Inserts adicionais para a tabela Departamentos
INSERT INTO Departamentos (id_departamento, nome) VALUES
(6, 'Logística'),
(7, 'Qualidade'),
(8, 'Atendimento ao Cliente'),
(9, 'Marketing Digital'),
(10, 'Pesquisa e Desenvolvimento');

-- Inserts adicionais para a tabela Funcionarios
INSERT INTO Funcionarios (id_funcionario, nome, salario, departamento_id) VALUES
(6, 'Laura Oliveira', 3200.00, 1),
(7, 'Rafael Costa', 3800.00, 2),
(8, 'Fernanda Santos', 2900.00, 3),
(9, 'Gustavo Lima', 4200.00, 4),
(10, 'Camila Mendes', 3500.00, 1);

-- GROUP BY --
-- Escreva uma consulta SQL que retorne o nome de cada departamento 
-- e a soma dos salários de todos os funcionários
--em cada departamento.
SELECT d.nome, SUM(func.salario) AS "Soma salário"
FROM Departamentos d INNER JOIN Funcionarios func 
	ON d.id_departamento = func.departamento_id 
GROUP BY d.nome;

-- Escreva uma consulta SQL que retorne o nome do departamento,
-- o número total de funcionários -> em cada departamento <-, 
-- e a média salarial -> por departamento <-
SELECT d.nome, COUNT(f.id_funcionario) AS "Total de Funcionários",
	AVG(f.salario) AS "Média Salário"
FROM Departamentos d INNER JOIN Funcionarios f
	ON d.id_departamento = f.departamento_id 
GROUP BY d.nome;

-- Escreva uma consulta SQL que retorne o nome do departamento, 
-- o nome do funcionário com o maior salário 'em cada' departamento
-- e o respectivo salário
SELECT d.nome, f.nome AS "Nome Funcionario", f.salario AS Salário
FROM Departamentos d INNER JOIN Funcionarios f ON d.id_departamento = f.departamento_id 
WHERE f.salario = (
				   SELECT MAX(f.salario) 
				   FROM Funcionarios f
	               WHERE d.id_departamento = f.departamento_id 					
);

SELECT * FROM departamentos;
SELECT * FROM funcionarios;