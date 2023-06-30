SET DATESTYLE TO POSTGRES, DMY;
-- tabela Horario
DROP TABLE IF EXISTS horario CASCADE ;
CREATE TABLE horario 
(
	cod_hora SMALLINT PRIMARY KEY,
	horario TIME NOT NULL 
);
-- populando horario
INSERT INTO horario VALUES ( 1, '14:00');
SELECT * FROM horario ;
-- tabela filme
DROP TABLE IF EXISTS filme CASCADE;
CREATE TABLE filme 
(
	cod_filme INTEGER NOT NULL PRIMARY KEY,
	titulo_Filme VARCHAR(50) NOT NULL,
	titulo_original VARCHAR(50) NOT NULL,
	ano_lancto SMALLINT NOT NULL,
	idioma_Original VARCHAR(15),
	ano_producao SMALLINT NOT NULL,
	classifica_Etaria VARCHAR(20) NOT NULL,
	estudio VARCHAR(30) NOT NULL,
	duracao_min SMALLINT,
	nacionalidade_filme VARCHAR(20),
	genero VARCHAR(150) NOT NULL,
	situacao_filme CHAR(15)
);
-- tabela sala
DROP TABLE IF EXISTS sala CASCADE;
CREATE TABLE sala 
(
	nome_sala CHAR(20) NOT NULL PRIMARY KEY,
	capacidade SMALLINT NOT NULL,
	tipo_sala CHAR(20) NOT NULL,
	tipo_projecao CHAR(20) NOT NULL,
	tipo_audio CHAR(20) NOT NULL,
	dim_tela CHAR(20) NOT NULL,
	situacao_sala CHAR(15) NOT NULL
		CHECK ( situacao_sala IN ('ATIVA', 'INATIVA', 'MANUTENCAO')) 
);
--tabela sessao -> relacionada com sala, horario e filme
DROP TABLE IF EXISTS sessao CASCADE;
CREATE TABLE sessao
(
	num_sessao SERIAL NOT NULL PRIMARY KEY,
	dt_sessao DATE NOT NULL,
	tipo_projecao CHAR(20) NOT NULL,
	idioma CHAR(20) NOT NULL,
	dubl_leg CHAR(9) CHECK (dubl_leg IN ('DUBLADO', 'LEGENDADO')),
	preco_ingresso NUMERIC(10,2) NOT NULL,
	publico SMALLINT NOT NULL,
	cod_filme INTEGER NOT NULL, --fk de filme
	nome_sala CHAR(20) NOT NULL, --fk sala
	cod_hora_exibicao SMALLINT NOT NULL, --fk horario
	situacao_sessao CHAR(15) NOT NULL,
	FOREIGN KEY (cod_filme) REFERENCES filme (cod_filme)
		ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (nome_sala) REFERENCES sala (nome_sala)
		ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (cod_hora_exibicao) REFERENCES horario (cod_hora)
);
--tabela artista 
DROP TABLE IF EXISTS artista CASCADE;
CREATE TABLE artista
(
	cod_artista INTEGER NOT NULL PRIMARY KEY,
	nome_artista VARCHAR(50) NOT NULL, 
	nacionalidade_artista CHAR(20) NOT NULL,
	sexo_artista CHAR(1) NOT NULL CHECK (sexo_artista IN ('F', 'M'))
);
-- tabela elenco filme	
DROP TABLE IF EXISTS elenco_filme CASCADE;
CREATE TABLE elenco_filme
(
	cod_artista INTEGER NOT NULL, 
	cod_filme INTEGER NOT NULL,
	tipo_participacao CHAR(20) NOT NULL,
	FOREIGN KEY (cod_artista) REFERENCES artista (cod_artista)
		ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (cod_filme) REFERENCES filme (cod_filme)
		ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY (cod_artista, cod_filme)	
	/*Cod_artista INTEGER NOT NULL REFERENCES artista
	ON DELETE CASCADE ON UPDATE CASCADE ,
	Cod_filme INTEGER NOT NULL REFERENCES filme
	ON DELETE CASCADE ON UPDATE CASCADE ,
	Tipo_participacao CHAR(20) NOT NULL,
	PRIMARY KEY ( cod_artista, cod_filme) ) ;*/
);
ALTER TABLE elenco_filme ADD COLUMN personagem VARCHAR(25); --add coluna personagem
SELECT * FROM elenco_filme;

-- tabela assento
DROP TABLE IF EXISTS assento;
CREATE TABLE assento
(
	num_assento SMALLINT NOT NULL,
	fileira_assento CHAR(1) NOT NULL, 
	nome_sala CHAR(25) NOT NULL,
	tipo_assento CHAR(15) NOT NULL,
	situacao_assento CHAR(15) NOT NULL,
	FOREIGN KEY (nome_sala) REFERENCES sala (nome_sala) 
		ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY (num_assento, fileira_assento, nome_sala)
);
-- tabela Funcionário
DROP TABLE IF EXISTS funcionario CASCADE;
CREATE TABLE funcionario
(
	cod_funcionario INTEGER NOT NULL PRIMARY KEY,
	nome_func VARCHAR(50) NOT NULL,
	sexo_func CHAR(1) NOT NULL CHECK (sexo_func IN ('M', 'F')),
	dt_nascto_func DATE NOT NULL,
	end_func VARCHAR(100) NOT NULL,
	dt_admissao DATE NOT NULL,
	num_ctps INTEGER NOT NULL,
	UNIQUE (num_ctps)
);
-- escala trabalho
DROP TABLE IF EXISTS escala_trabalho CASCADE;
CREATE TABLE escala_trabalho
(
	num_escala INTEGER NOT NULL PRIMARY KEY, 
	dia_semana CHAR(15) NOT NULL, 
	horario_inicio SMALLINT NOT NULL, -- FOREIGN KEY (cod_hora_exibicao) REFERENCES 
	--horario (cod_hora) USADA entre sessao x horário
	horario_termino SMALLINT NOT NULL, -- cod_hora em na table horário é do tipo TYPE
	FOREIGN KEY (horario_inicio) REFERENCES horario ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (horario_termino) REFERENCES horario ON DELETE CASCADE ON UPDATE CASCADE
);
DROP TABLE escala_trabalho CASCADE; --table dropada - *** table recriada sem referenciação à 
--chave primerario da table horário ****

--table escala funcionario
DROP TABLE IF EXISTS escala_funcionario CASCADE;
CREATE TABLE escala_funcionario
( 
	num_escala INTEGER NOT NULL REFERENCES escala_trabalho ON DELETE CASCADE ON UPDATE CASCADE,
	cod_funcional INTEGER NOT NULL REFERENCES funcionario ON DELETE CASCADE ON UPDATE CASCADE,
	dt_inicio DATE NOT NULL,
	funcao CHAR(15) NOT NULL,
	PRIMARY KEY ( num_escala, cod_funcional, dt_inicio)
);
----table ingresso
DROP TABLE IF EXISTS ingresso CASCADE;
CREATE TABLE ingresso
(
	num_ingresso SERIAL NOT NULL PRIMARY KEY,
	tipo_ingresso CHAR(20) NOT NULL,
	vl_pago NUMERIC(10,2) NOT NULL,
	forma_pgto CHAR(50) NOT NULL,
	num_assento SMALLINT NOT NULL,
	fileira_assento CHAR(1) NOT NULL,
	nome_sala CHAR(25) NOT NULL,
	num_sessao SERIAL NOT NULL REFERENCES sessao (num_sessao) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (num_assento, fileira_assento, nome_sala)
		REFERENCES assento (num_assento, fileira_assento, nome_sala) 
		ON DELETE CASCADE ON UPDATE CASCADE
);
--tabela forma pagamento
DROP TABLE IF EXISTS forma_pgto CASCADE ;
CREATE TABLE forma_pgto
(
	cod_forma_pgto CHAR(5) PRIMARY KEY, 
    tipo_forma_pgto VARCHAR(20),
    situacao_Forma_pgto CHAR(10)
);
--corrigindo table ingresso
ALTER TABLE ingresso ADD COLUMN forma_pagto VARCHAR(20) NOT NULL;
ALTER TABLE ingresso
ADD CONSTRAINT fk_ingresso_pagto
FOREIGN KEY (forma_pagto)
	REFERENCES forma_pagto 
/* 2- Com o comando ALTER TABLE : 
a) Inclua  uma nova coluna em Funcionário : Data de desligamento
b) Crie as seguintes constraints de verificação : 
		Função em Escala-Funcionário : Caixa, Atendente, Gerente
		Tipo em Assento : Normal, PNE (Portador Necessidades Especiais), Largo */

--a)
--add coluna em funcionario
ALTER TABLE funcionario ADD COLUMN dt_desligamento DATE NOT NULL;
--corrigindo -> valor poderá ser nulo 
ALTER TABLE funcionario ALTER COLUMN dt_desligamento TYPE DATE;
ALTER TABLE funcionario ALTER COLUMN dt_desligamento DROP NOT NULL;
--b1)
--add constraints de verificação em tabela escala_funcionario
ALTER TABLE escala_funcionario ADD CHECK (funcao IN ('CAIXA', 'GERENTE', 'ATENDENTE'));
ALTER TABLE assento ADD CHECK (tipo_assento IN ('NORMAL', 'PNE', 'LARGO'));

/**** aula 09/maio - ALTER TABLE , DML (insert, update, delete), 
DQL SElect funções de caractere e data *****/
-- Verificando a estrutura da tabela
--verificando estrutura da tabela
SELECT table_name AS "Tabela", column_name AS "Coluna", 
data_type AS "Tipo de Dado", is_nullable AS "Permite nulo"
FROM information_schema.columns
WHERE table_name = 'filme';

-- ALTER TABLE
-- excluindo uma coluna da tabela
ALTER TABLE sessao DROP COLUMN tipo_sessao;
ALTER TABLE sessao DROP COLUMN tipo_exibicao;
SELECT * FROM sessao;
-- adicionando mais de uma coluna
ALTER TABLE sessao ADD COLUMN tipo_sessao VARCHAR(20);
ALTER TABLE sessao ADD COLUMN tipo_exibicao VARCHAR(20);				 
-- renomeando uma coluna
ALTER TABLE sessao RENAME COLUMN tipo_exibicao TO coluna_para_excluir;
ALTER TABLE sessao DROP COLUMN coluna_para_excluir;
-- renomeando uma tabela
ALTER TABLE sessao RENAME TO sessao_filme;
-- definir um valor padrão para uma coluna
ALTER TABLE sessao_filme RENAME COLUMN valor_ingresso TO preco_ingresso
ALTER TABLE sessao_filme ALTER COLUMN preco_ingresso SET DEFAULT 40.0;
ALTER TABLE sessao_filme ALTER COLUMN dt_sessao SET DEFAULT current_date;
ALTER TABLE sessao_filme ADD CHECK (situacao_sessao IN ( 'AGENDADA', 'CANCELADA', 'CONCLUIDA')) ;
ALTER TABLE sessao_filme ADD CHECK (dt_sessao >= current_date );
-- mudando tamanho ou tipo de dado de uma coluna
ALTER TABLE filme ALTER COLUMN classifica_etaria TYPE CHAR(15) ;
--SELECT data/hora atual
SELECT current_date, current_timestamp, now();

--POP TABLES
-- populando as tabelas
-- artista
SELECT * FROM artista ;
INSERT INTO artista VALUES (1, 'Fernanda Montenegro', 'Brasileira', 'F');
INSERT INTO artista VALUES (2, 'Robert de Niro', 'Norte-Americano', 'M');
INSERT INTO artista VALUES (3, 'Aracy de Almeida', 'Brasileiro', 'M');
INSERT INTO artista VALUES (4, 'Gilian Anderson', 'Britanica', 'F');
--corrigindo linha
DELETE FROM artista
WHERE nome_artista = 'Britanica';
INSERT INTO artista VALUES (4, 'Gilian Anderson', 'Gilian Anderson', 'F');
-- horario, filme, sessao, sala , elenco			
INSERT INTO horario VALUES (4, '18:00');
-- filme 
SELECT * FROM Filme ;
INSERT INTO filme VALUES (1000, 'Central do Brasil', 'Central do Brasil', 1998,
	'Portugues', 1997, 'Livre', 'Arthue Conn', 113, 'Brasil', 'Drama', 'Catalogo');					  
INSERT INTO filme VALUES (1001, 'Cabo do Medo', 'Cape Fear', 1991,
	'Ingles', 1990, '16 anos', 'Tribeca', 128, 'EUA', 'Drama', 'Catalogo');
-- elenco partcipando do filme
SELECT * FROM elenco_filme;
INSERT INTO elenco_filme VALUES (1, 1000, 'Atriz', 'Dora');
INSERT INTO elenco_filme VALUES (2, 1001, 'Ator', 'Max Capy');

-- elenco partcipando do filme
SELECT * FROM elenco_filme;
INSERT INTO elenco_filme VALUES (1, 1000, 'Atriz', 'Dora');
INSERT INTO elenco_filme VALUES (2, 1001, 'Ator', 'Max Capy');

-- sala
SELECT * FROM sala;
INSERT INTO sala VALUES ('Azul', 200, 'Anfiteatro', '3D', 'Dolby Surround',
						 '8mx4m', 'ATIVA');
INSERT INTO sala VALUES ('Vermelha', 145, 'Inclinada', '3D', 'Estereo 3D',
						 '6mx3m', 'ATIVA');
--sessao filme alterando sequência de num_sessao
ALTER SEQUENCE sessao_num_sessao_seq
RESTART WITH 1 INCREMENT BY 1 MINVALUE 1;
INSERT INTO sessao_filme VALUES (default, default, '4D MAX PLUS ULTRA',
	'Portugues', 'DUBLADO', default, 0, 1001, 'Azul', 4, 'AGENDADA', 'REGULAR');
INSERT INTO sessao_filme VALUES (default, )
-- ** DELETE - TESTES **
DELETE FROM sessao_filme WHERE num_sessao = 1;		
DELETE FROM sessao_filme WHERE num_sessao = 2;
INSERT INTO sessao_filme VALUES (23001, default, '2D',
	'Portugues', 'DUBLADO', default, 0, 1000, 'Vermelha', 1, 'AGENDADA', 'REGULAR');
DELETE FROM sessao_filme WHERE num_sessao = 23001;
--pop sessao_filme
INSERT INTO sessao_filme VALUES (default, default, '4D MAX PLUS ULTRA',
	'Portugues', 'DUBLADO', default, 0, 1001, 'Azul', 4, 'AGENDADA', 'REGULAR');
INSERT INTO sessao_filme VALUES (default, default, '2D',
	'Portugues', 'DUBLADO', default, 0, 1000, 'Vermelha', 1, 'AGENDADA', 'REGULAR');

/* Atividade 07 : Utilizando a linguagem SQL 
1 – Popular as tabelas em verde (criadas na atividade 6) : insira duas linhas em cada tabela */	
-- horario
SELECT * FROM horario ;
INSERT INTO horario VALUES (2, '16:00');
INSERT INTO horario VALUES (3, '17:00');
INSERT INTO horario VALUES (5, '20:00');
INSERT INTO horario VALUES (6, '22:00');

--  assento ;
SELECT * FROM assento ;
SELECT * FROM sala ;
INSERT INTO assento VALUES (1, 'A', 'Azul', 'NORMAL', 'DISPONIVEL');
INSERT INTO assento VALUES (2, 'A', 'Azul', 'PNE', 'DISPONIVEL');
INSERT INTO assento VALUES (3, 'A', 'Azul', 'LARGO', 'DISPONIVEL');
INSERT INTO assento VALUES (11, 'C', 'Azul', 'NORMAL', 'DISPONIVEL');
INSERT INTO assento VALUES (21, 'C', 'Azul', 'PNE', 'DISPONIVEL');
INSERT INTO assento VALUES (31, 'C', 'Azul', 'LARGO', 'DISPONIVEL');
INSERT INTO assento VALUES (5, 'B', 'Azul', 'NORMAL', 'DISPONIVEL');
INSERT INTO assento VALUES (6, 'B', 'Azul', 'NORMAL', 'DISPONIVEL');
INSERT INTO assento VALUES (7, 'B', 'Azul', 'NORMAL', 'DISPONIVEL');
INSERT INTO assento VALUES (1, 'A', 'Vermelha', 'NORMAL', 'DISPONIVEL');
INSERT INTO assento VALUES (2, 'A', 'Vermelha', 'PNE', 'DISPONIVEL');
INSERT INTO assento VALUES (3, 'A', 'Vermelha', 'LARGO', 'DISPONIVEL');
INSERT INTO assento VALUES (11, 'G', 'Vermelha', 'NORMAL', 'DISPONIVEL');
INSERT INTO assento VALUES (12, 'G', 'Vermelha', 'PNE', 'DISPONIVEL');
INSERT INTO assento VALUES (13, 'G', 'Vermelha', 'LARGO', 'DISPONIVEL');
INSERT INTO assento VALUES (10, 'B', 'Vermelha', 'NORMAL', 'DISPONIVEL');
INSERT INTO assento VALUES (20, 'B', 'Vermelha', 'PNE', 'DISPONIVEL');
INSERT INTO assento VALUES (30, 'B', 'Vermelha', 'LARGO', 'DISPONIVEL');

-- forma de pagamento
SELECT * FROM forma_pgto ;
INSERT INTO forma_pgto VALUES ('DIN', 'DINHEIRO', 'ATIVO');
INSERT INTO forma_pgto VALUES ('CCRED', 'CARTAO CREDITO', 'ATIVO');
INSERT INTO forma_pgto VALUES ('PIX', 'PIX' , 'ATIVO');

-- ingresso
SELECT * FROM ingresso;
SELECT * FROM sessao_filme;
SELECT * FROM forma_pgto;
INSERT INTO ingresso VALUES (default , 'MEIA', 25.00,  'DIN', 1, 'A', 'Azul', 2 );
INSERT INTO ingresso VALUES (default , 'INTEIRA', 50.00, 'PIX', 2, 'A', 'Azul', 2);
INSERT INTO ingresso VALUES (default , 'MEIA', 25.00,  'DIN', 1, 'A', 'Vermelha', 1);
INSERT INTO ingresso VALUES (default , 'INTEIRA', 50.00,  'PIX', 3, 'A', 'Azul', 2);
INSERT INTO ingresso VALUES (default , 'MEIA', 25.00, 'DIN', 2, 'A', 'Vermelha', 1);
INSERT INTO ingresso VALUES (default , 'INTEIRA', 50.00, 'PIX', 3, 'A', 'Vermelha', 1);
INSERT INTO ingresso VALUES (default, 'MEIA', 25.00, 'DIN', 5, 'B', 'Azul', 2);
INSERT INTO ingresso VALUES (default , 'INTEIRA', 50.00,  'CCRED', 11, 'G', 'Vermelha', 1);
INSERT INTO ingresso VALUES (default , 'MEIA', 25.00,  'CCRED',  21, 'C', 'Azul', 2);
INSERT INTO ingresso VALUES (default , 'INTEIRA', 50.00, 'PIX', 12, 'G', 'Vermelha', 1);
INSERT INTO ingresso VALUES (default , 'MEIA', 25.00, 'PIX', 6, 'B', 'Azul', 2);
INSERT INTO ingresso VALUES (default , 'INTEIRA', 50.00,  'DIN',13, 'G', 'Vermelha', 1);
INSERT INTO ingresso VALUES (default , 'MEIA', 25.00,  'CCRED',10, 'B', 'Vermelha', 1);
INSERT INTO ingresso VALUES (default , 'INTEIRA', 50.00, 'PIX', 7, 'B', 'Azul', 2);
INSERT INTO ingresso VALUES (default , 'MEIA', 25.00, 'CCRED', 20, 'B', 'Vermelha', 1);
INSERT INTO ingresso VALUES (default , 'INTEIRA', 50.00,  'CCRED',  30, 'B', 'Vermelha', 1);
--corrigindo ingresso
ALTER TABLE ingresso DROP COLUMN forma_pagto;

-- funcionário
SELECT * FROM funcionario;
INSERT INTO funcionario VALUES ( 1000, 'Jose de Arimateia','M', '10/10/1980', 'Rua Amarela, 10', 
current_date - 500, 123456, null);
INSERT INTO funcionario VALUES ( 1001, 'Maria Conceicao dos Santos','F', '15/12/1988', 'Rua Azul, 20', 
current_date - 300, 987654, null);
INSERT INTO funcionario VALUES ( 1002, 'Tereza Baptista Silva','F', '05/02/1978', 'Rua Verde, 30', 
'10/01/2016', 658734, null);
INSERT INTO funcionario VALUES ( 1003, 'Joao de Castro e Souza','M', '10/01/1970', 'Rua Branca, 10', 
current_date - 100, 765432, null);
INSERT INTO funcionario VALUES ( 1004, 'Carla Marinho','F', '05/05/1978', 'Rua Vermelha, 20', 
current_date - 120, 342176, null);
INSERT INTO funcionario VALUES ( 1005, 'Francine Oliver','F', '25/02/1996', 'Rua Verde, 50', 
'10/11/2016', 543734, null);

-- escala trabalho
SELECT * FROM escala_trabalho;
INSERT INTO escala_trabalho VALUES (1, 'Segunda-Feira', 1, 5);
INSERT INTO escala_trabalho VALUES (2, 'Segunda-Feira', 4, 6);
INSERT INTO escala_trabalho VALUES (3, 'Terca-Feira', 1, 5);
INSERT INTO escala_trabalho VALUES (4, 'Terca-Feira', 4, 6);
INSERT INTO escala_trabalho VALUES (5, 'Quarta-Feira', 1, 5);
INSERT INTO escala_trabalho VALUES (6, 'Quarta-Feira', 4, 6);

-- escala de atendimento
SELECT * FROM escala_funcionario;
SELECT * FROM horario;
INSERT INTO escala_funcionario VALUES (1, 1001, current_date - 21, 'CAIXA'); 
INSERT INTO escala_funcionario VALUES (1, 1002, current_date - 21,'ATENDENTE');
INSERT INTO escala_funcionario VALUES (3, 1001, current_date - 21,'ATENDENTE');
INSERT INTO escala_funcionario VALUES (3, 1002, current_date - 21,'GERENTE');
INSERT INTO escala_funcionario VALUES (3, 1003, current_date - 21,'CAIXA');
INSERT INTO escala_funcionario VALUES (2, 1001, current_date - 14,'CAIXA');
INSERT INTO escala_funcionario VALUES (2, 1002, current_date - 14,'GERENTE');
INSERT INTO escala_funcionario VALUES (4, 1001, current_date - 7,'ATENDENTE');
INSERT INTO escala_funcionario VALUES (4, 1002, current_date - 7,'GERENTE');
INSERT INTO escala_funcionario VALUES (4, 1003, current_date - 7,'CAIXA');
INSERT INTO escala_funcionario VALUES (5, 1001, current_date ,'CAIXA');
INSERT INTO escala_funcionario VALUES (5, 1002, current_date ,'ATENDENTE');
INSERT INTO escala_funcionario VALUES (6, 1001, current_date + 7, 'ATENDENTE');
INSERT INTO escala_funcionario VALUES (6, 1002, current_date + 7,'ATENDENTE');
INSERT INTO escala_funcionario VALUES (6, 1003, current_date + 7,'ATENDENTE');

/* 2 – Após popular as tabelas em verde,  transforme as colunas Nacionalidade em Artista e Filme
em uma tabela auxiliar com Código e Nome do País, por exemplo :
código 01, nome Brasil. Estabeleça o relacionamento e atualize os dados nas tabelas de origem */

DROP TABLE IF EXISTS nacionalidade CASCADE;
CREATE TABLE nacionalidade 
( 
	cod_pais SMALLINT PRIMARY KEY,
	nome_pais CHAR(25) NOT NULL 
);

INSERT INTO nacionalidade VALUES (1 , 'BRASIL');
INSERT INTO nacionalidade VALUES (2 , 'ESTADOS UNIDOS DA AMERICA');
INSERT INTO nacionalidade VALUES (3, 'INGLATERRA');
INSERT INTO nacionalidade VALUES (4, 'AUSTRALIA');
INSERT INTO nacionalidade VALUES (5, 'ARGENTINA');
--RESOLVENDO FILME
--add cod_nacionalidade (cod_pais) em filme
ALTER TABLE filme ADD COLUMN cod_nacionalidade SMALLINT;
--reconfigurando valores BRASIL E EUA em nacionalidade filme para cod_nacionalidade
UPDATE filme
SET cod_nacionalidade = 1
WHERE UPPER (nacionalidade_filme) LIKE '%BRASIL%';
UPDATE filme 
SET cod_nacionalidade = 2
WHERE (nacionalidade_filme) LIKE '%EUA%';
--declarando fk filme x nacionalidade
ALTER TABLE filme ADD CONSTRAINT fk_nacionalidadefilme FOREIGN KEY (cod_nacionalidade)
REFERENCES nacionalidade (cod_pais);
--excluir coluna nacionalidade em filme
ALTER TABLE filme DROP COLUMN nacionalidade_filme;
--definir como NOT NULL
ALTER TABLE filme ALTER COLUMN cod_nacionalidade SET NOT NULL;
--reconfigurando valores BRASIL E EUA em nacionalidade filme para cod_nacionalidade
--RESOLVENDO ARTISTA
--add cod_nacionalidade em Artista
ALTER TABLE artista ADD COLUMN cod_nacionalidade SMALLINT;
--reconfigurando valores BRASILEIRA/AMERICANO/BRITANICA em nacionalidade Artista para cod_nacionalidade
UPDATE artista
SET cod_nacionalidade = 1
WHERE UPPER (nacionalidade_artista) LIKE '%BRASIL%';
UPDATE artista
SET cod_nacionalidade = 2
WHERE UPPER (nacionalidade_artista) LIKE '%AMERICANO%';
UPDATE artista
SET cod_nacionalidade = 3
WHERE UPPER(nacionalidade_artista) LIKE '%BRITAN%'; 
--declarando fk artista(cod_nacionalidade) x nacionalidade(cod_pais)
ALTER TABLE artista ADD CONSTRAINT fk_nacionalidadeartista FOREIGN KEY (cod_nacionalidade)
REFERENCES nacionalidade (cod_pais);
--excluindo nacionalidade_artista em artista
ALTER TABLE artista DROP COLUMN nacionalidade_artista;
--definir cod_nacionalidade como NOT NULL
ALTER TABLE artista ALTER COLUMN cod_nacionalidade SET NOT NULL;

/********************************
SQL DQL - SELECTS  
*********************************/
-- Sintaxe do SELECT 
-- SELECT coluna1, coluna2,...., colunaN
-- FROM tabela1, tabela2,...., tabelaN
-- WHERE condicao1, ... condicaoN;

--Consultas com funções caracter 
SELECT * FROM filme;
--Discriminando as colunas
SELECT titulo_filme
FROM filme
WHERE genero = 'Drama';

SELECT f.titulo_filme, f.genero
FROM filme f;

-- Discriminando as colunas dando apelido para as colunas -> Alias
SELECT titulo_filme AS Titulo, genero, estudio, duracao_min AS "Duração em Minutos"
FROM filme
WHERE genero = 'Drama';

-- Usando funções de formatação de caracter - UPPER, LOWER , INITCAP
SELECT UPPER(titulo_filme) AS Maiusculo, LOWER(genero) AS Minusculo, 
INITCAP(estudio) AS "Primeiro em Maisculo restante em minusculo",
duracao_min AS "Duracao em minutos"
FROM filme
WHERE UPPER (genero) = 'DRAMA';

-- Operador de concatenação : concatena as strings tirando o espaço entre elas
-- Filme foi lancado em ano tal , é do genero tal e produzido por estudio tal e
-- demanda tantos minutos de paciência // para filmes com mais de 120 min
SELECT titulo_filme||' foi lançado em '||TO_CHAR(ano_lancto,'9999')||
', e do genero'||genero||', produzido pelo estudio'||estudio||
' e demanda'||TO_CHAR(duracao_min, '9999')||' minutos de paciencia'
AS "Dados do Filme"
FROM filme;

---- operador LIKE - busca não exata

INSERT INTO filme VALUES (1002, 'Bye Bye Brasil', 'Bye Bye Brasil', 1980,
	'Portugues', 1979, '16 anos', 'Gaumont', 105 , 'Comedia', 'Catalogo', 1);	
	
-- todos os filmes com brasil no titulo
SELECT titulo_filme
FROM filme
WHERE UPPER (titulo_filme) LIKE '%BRASIL%';
-- Brazil ou Brasil - _ é a máscara para um caracter
SELECT * 
FROM filme
WHERE UPPER (titulo_filme) LIKE '%BRA_IL%';
-- encontrar todos os funcionarios de nome João 
SELECT * 
FROM funcionario
WHERE UPPER (nome_func) LIKE '%JO_O%';
-- exemplo de Initcap
SELECT INITCAP ('bolinha'), INITCAP('TRIANGULO');
--WHERE com AND e OR
SELECT titulo_filme, ano_lancto, ano_producao
FROM filme
WHERE UPPER (titulo_filme) LIKE '%BRASIL%'
AND ano_lancto > 1990;
--OR
SELECT titulo_filme, ano_lancto, ano_producao
FROM filme
WHERE UPPER (titulo_filme) LIKE '%BRASIL%'
OR ano_lancto > 1990;
--OR e AND
SELECT titulo_filme, ano_lancto, ano_producao
FROM filme
WHERE UPPER (titulo_filme) LIKE '%BRASIL%'
OR ano_lancto > 1990 AND genero != 'Drama';

-- Funções de data
-- Data e hora atuais: 
-- current_date, current_timestamp, localtimestamp, now(), time()
SELECT current_date AS "Hora Atual",
	   current_timestamp AS "Data e Hora Atual com local zone",
	   localtimestamp AS "Idem current_timestamp sem local zone",
	   now() AS "Idem current_timestamp";
--Função EXTRACT, extrai um pedaço da data Ano ou mês, hora, minuto, semana
SELECT EXTRACT (YEAR FROM current_date) AS "Ano",
	   EXTRACT (MONTH FROM current_date) AS "Mês",
	   EXTRACT (HOUR FROM current_timestamp) AS "Hora",
	   EXTRACT (SECOND FROM current_timestamp) AS "Segundos",
	   EXTRACT (WEEK FROM current_date) AS "Dias da Semana";
SELECT EXTRACT (YEAR FROM TO_DATE('10/02/1991', 'DD/MM/YYYY'));

--calculo da idade dos funcionarios
SELECT nome_func AS "Funcionario",
	   TRUNC((current_date - dt_nascto_func)/365.25) AS Idade
FROM funcionario
ORDER BY Idade ASC;
--Intervalo entre datas OPERADOR INTERVAL
SELECT current_date - INTERVAL '1' MONTH;
SELECT current_date + INTERVAL '10' YEAR;
SELECT current_date + INTERVAL '28' DAY;	 
--Funcionarios que admitidos há mais de um ano e meio
SELECT nome_func, dt_admissao, 
FROM funcionario
WHERE dt_admissao < current_date - INTERVAL '1' YEAR - INTERVAL '6' MONTH;


--Funcionarios com mais de 22 anos admitidos no  ano passado
SELECT nome_func, dt_nascto_func,
	TRUNC((current_date - dt_nascto_func)/365.25) AS Idade, dt_admissao
FROM funcionario
WHERE TRUNC((current_date - dt_nascto_func)/365.25) > 22
AND EXTRACT(YEAR FROM dt_admissao) = EXTRACT(YEAR FROM current_date - INTERVAL '1' YEAR);

/****** Junção - JOIN 
SELECTS envolvendo mais de uma tabela ****/

--Nacionalidade dos artistas
SELECT * FROM artista; --4 artistas
SELECT * FROM nacionalidade; -- 5 nacionalidades

SELECT a.nome_artista, n.nome_pais
FROM nacionalidade n, artista a
WHERE n.cod_pais = a.cod_nacionalidade; -- Junção no WHERE

--sintaxe INNER JOIN
SELECT a.nome_artista, n.nome_pais
FROM nacionalidade n INNER JOIN artista a
	ON (n.cod_pais = a.cod_nacionalidade); --colunas junção

--três tabelas - Mostrar o elenco dos filmes (artista, elenco filme, filme)
SELECT a.nome_artista,  f.titulo_filme, ef.tipo_participacao, 
	   ef.personagem
FROM filme f INNER JOIN elenco_filme ef -- FILME > ELENCO_FILME
ON (f.cod_filme = ef.cod_filme)
             INNER JOIN artista a  -- ELENCO_FILME > ARTISTA 	
ON (a.cod_artista = ef.cod_artista); 

--três tabelas - Mostrar o elenco dos filmes em que o título contenha Brasil e e o ano lançamento > 19
SELECT a.nome_artista,  f.titulo_filme, ef.tipo_participacao, 
	   ef.personagem	   
FROM filme f INNER JOIN elenco_filme ef
ON (f.cod_filme = ef.cod_filme)
             INNER JOIN artista a
ON (a.cod_artista = ef.cod_artista)
WHERE UPPER (f.titulo_filme) LIKE '%BRASIL%'
AND f.ano_lancto > 1980;
-- quatro tabelas incluindo a nacionalidade filme > elenco_filme > artista > nacionalidade
SELECT f.titulo_filme, f.genero, f.ano_lancto, n.nome_pais, 
a.nome_artista, ef.personagem
FROM filme f INNER JOIN elenco_filme ef 
ON (f.cod_filme = ef.cod_filme) 
	         INNER JOIN artista a
ON (a.cod_artista = ef.cod_artista)
			 INNER JOIN nacionalidade n
ON (f.cod_nacionalidade = ef.cod_nacionalidade)
WHERE UPPER (f.titulo_filme) LIKE '%BRASIL%'
AND f.ano_lancto > 1980;


SELECT f.titulo_filme, f.genero, f.ano_lancto, n.nome_pais, 
a.nome_artista, ef.personagem
FROM filme f JOIN elenco_filme ef 
ON ( f.cod_filme = ef.cod_filme  )  -- junção filme x elenco
             JOIN artista a
ON ( a.cod_artista = ef.cod_artista)   -- juncao elenco x artista
             JOIN nacionalidade n
ON ( f.cod_nacionalidade = n.cod_pais )	-- juncao filme x nacionalidade		 
WHERE UPPER(f.titulo_filme) LIKE '%BRASIL%' 
AND f.ano_lancto > 1980 ; 

/*Atividade 08 - Utilizando a instrução SELECT da linguagem SQL responda às seguintes consultas :
1– Mostrar os dados dos filmes do gênero Aventura no formato: ‘Guerra nas Estrelas 
foi lançado em 1977 com classificação etária LIVRE’ */
SELECT titulo_filme || ' foi lancado em ' || ano_lancto ||
' com classificacao etaria ' || (classifica_etaria) 
AS "Dados do Filme"
FROM filme
WHERE UPPER (genero) LIKE '%DRAMA%' 

/*SELECT RTRIM ('Good morning!     '),
	   LTRIM ('        Good morning!'),
	   TRIM  ('        Good morning!'); */
	   
/* 2- Mostrar o título original, estúdio e ano de lançamento dos filmes 
que tem ‘GUERRA’ ou ‘BATALHA’ no título e duram mais de 140 minutos */
SELECT titulo_original, estudio, ano_lancto
FROM filme
WHERE UPPER (titulo_filme)LIKE '%GUERRA%' OR UPPER (titulo_filme)LIKE '%BATALHA%'
AND (duracao_min >= 140); 

/* 3– Mostrar os dados dos funcionários mulheres 
admitidas há mais de um ano e idade superior a 22 anos:
Nome Funcionário-Idade */
SELECT nome_func, TRUNC((current_date - dt_nascto_func)/365.25) AS Idade
FROM funcionario
WHERE TRUNC(current_date - dt_nascto_func) > 22
AND sexo_func = 'F'
AND TRUNC (current_date - dt_admissao) > 1;

/* 4- Mostrar as sessões de cinema exibidas em salas 
com capacidade superior a 100 lugares: 
Número da Sessão – Data Sessão – Nome Sala – Capacidade */
SELECT ss.num_sessao, ss.dt_sessao, sa.nome_sala, sa.capacidade
FROM sessao_filme ss, sala sa
WHERE ss.nome_sala = sa.nome_sala
AND sa.capacidade > 100;
--com INNER JOIN
SELECT ss.num_sessao, ss.dt_sessao, sa.nome_sala, sa.capacidade
FROM sessao_filme ss INNER JOIN sala sa
	ON (ss.nome_sala = sa.nome_sala)
WHERE sa.capacidade > 100;

/* 5- Mostrar os ingressos que foram vendidos para sessões de hoje
do filme ‘Guerra nas estrelas’
Formato: Número Ingresso - Tipo Ingresso - Valor Pago - Número da Sessão
Tipo sessão - Título Original Filme – Duração Filme */
SELECT i.num_ingresso, i.tipo_ingresso, i.vl_pago, tss.num_sessao,
tss.tipo_sessao, f.titulo_original, f.duracao_min
FROM filme f, ingresso i, sessao_filme tss
WHERE i.num_sessao = tss.num_sessao
AND tss.cod_filme = f.cod_filme
AND TO_CHAR(current_date, 'DD/MM/YYYY') = TO_CHAR(dt_sessao, 'DD/MM/YYYY')
AND UPPER (f.titulo_original) LIKE '%GUERRA NAS ESTRELAS%';

/* TESTES DATAS 

CREATE TABLE teste_datas ( hoje DATE, agora TIMESTAMP) ;
INSERT INTO teste_datas VALUES (current_date, current_timestamp) ;
SELECT * FROM teste_datas ;

SELECT * FROM teste_datas WHERE agora = current_timestamp ;
SELECT hoje, agora, TO_CHAR(agora, 'DD/MM/YY') AS Agora_Hoje
FROM teste_datas
WHERE hoje = current_date 
AND TO_CHAR(agora, 'DD/MM/YY') = TO_CHAR(current_timestamp,'DD/MM/YY' );
-- usando EXTRACT
SELECT hoje, agora
FROM teste_datas
WHERE EXTRACT(DAY FROM agora) = EXTRACT(DAY FROM current_timestamp)
AND EXTRACT(MONTH FROM agora) = EXTRACT(MONTH FROM current_timestamp)
AND EXTRACT(YEAR FROM agora) = EXTRACT(YEAR FROM current_timestamp) ;
*/

/* 6- Repetir a consulta 5 acima, usando duas sintaxes para o JOIN e
adicionando os seguintes critérios: 
--> para salas com capacidade inferior a 100 lugares
e filmes com mais de 100 minutos de duração, que não sejam LIVRES no formato
Número Ingresso - Tipo Ingresso - Valor Pago-Número da Sessão - Tipo sessão - 
Título Original Filme – Duração Filme - Classificação Etária - Nome Sala-Capacidade */
SELECT i.num_ingresso, i.tipo_ingresso, i.vl_pago, tss.num_sessao,
tss.tipo_sessao, f.titulo_original, f.duracao_min
FROM filme f INNER JOIN sessao_filme tss
	ON (tss.cod_filme = f.cod_filme)
			 INNER JOIN ingresso i
	ON (i.num_sessao = tss.num_sessao)
WHERE duracao_min > 100
AND UPPER (f.classifica_etaria) NOT LIKE '%LIVRE%';

/* 7- Mostrar os ingressos de meia-entrada vendidos este mês para todos os filmes que tem 
a participação no elenco do ator ’George Clooney’ (ou algum outro que tenha cadastrado) no formato:
Número Ingresso - Tipo Ingresso - Assento completo - Valor Pago - Data da Sessão-Horário -
Título Original Filme – Duração Filme - Tipo Participação */
SELECT TO_CHAR(ss.dt_sessao, 'MON/YY') AS Mes_Atual,
i.num_ingresso, i.tipo_ingresso, a.nome_sala||'-'||a.fileira_assento||'-'||a.num_assento AS Assento,
i.vl_pago, ss.dt_sessao, h.horario, f.titulo_original, f.duracao_min, ef.tipo_participacao
FROM ingresso i INNER JOIN assento a 
   ON (i.nome_sala = a.nome_sala 
	   AND i.fileira.assento = a.fileira.assento 
	   AND i.num_assento = a.num_assento)
JOIN sessao_filme ss ON (ss.num_sessao = i.num_sessao)
JOIN horario h ON (h.cod_hora = ss.cod_hora_exibicao)
JOIN filme f ON (ss.cod_filme = f.cod_filme)
JOIN elenco_filme ef ON (f.cod_filme = ef.cod_filme)
JOIN artista art ON (art.cod_artista = ef.cod_artista)
WHERE UPPER(art.nome_artista) LIKE '%FERNANDA%'
AND TO_CHAR(ss.dt_sessao, 'MM/YY') =  TO_CHAR(current_date, 'MM/YY');

SELECT * FROM sessao_filme; -- sessao filme (cod_hora_exibicao) x horario (cod_hora)
SELECT * FROM ingresso; -- ingresso x sala - nome_sala ------ ingresso x sessao_filme - num_sessao
SELECT * FROM sala; -- sala x ingresso - num_assento
SELECT * FROM elenco_filme; -- elenco_filme x filme - cod_fime
SELECT * FROM horario; -- 

/******************************* 690
Aula 23/maio - Funções de Grupo 
********************************/
-- Funções de Grupo COUNT, MAX, MIN, SUM, AVG

-- Quantas linhas tem uma tabela
SELECT * FROM elenco_filme;
SELECT COUNT (*) FROM elenco_filme; 
UPDATE elenco_filme SET personagem = null WHERE cod_filme = 1000;
SELECT (personagem) FROM elenco_filme;

-- MAX, MIN, AVG, SUM, COUNT
SELECT MAX(i.vl_pago) AS Maior,
	   MIN(i.vl_pago) AS Menor,
	   AVG(i.vl_pago) AS Media,
	   SUM(i.vl_pago) AS Soma,
	   COUNT (*) AS "Total ingressos vendidos"
FROM ingresso i;
--Mostrar Total, Média e Qtos ingressos por sessao
SELECT i.num_sessao AS Sessao, SUM(i.vl_pago) AS "Valor Pago",
       AVG(i.vl_pago) AS Media, COUNT (*) AS "Total ingressos por sessao" 
FROM ingresso i
GROUP BY i.num_sessao;
-- Mostrar Total, Média e Qtos ingressos por sessao e tipo de ingresso
SELECT i.num_sessao AS Sessao,
       i.tipo_ingresso AS "Tipo Ingresso",
	   SUM(i.vl_pago) AS Soma,
	   AVG(i.vl_pago) AS Media,
	   COUNT (*) AS "Quantidade de Ingresso"
FROM ingresso i
GROUP BY i.num_sessao, i.tipo_ingresso
--Incluir o filme
--ENCONTRAR AS CONEXÕES! 
SELECT f.titulo_filme AS Sessão,
	   f.titulo_filme AS "Título Filme",
	   SUM(i.vl_pago) AS Soma,
	   AVG(i.vl_pago) AS Média,
	   COUNT (*) AS "Quantidade de Ingresso"
FROM filme f, ingresso i, sessao_filme ss 
WHERE i.num_sessao = ss.num_sessao
AND ss.cod_filme = f.cod_filme
GROUP BY f.titulo_filme, i.tipo_ingresso;
--Desde que o valor total seja maior que 150
SELECT f.titulo_filme AS Sessão,
	   f.titulo_filme AS "Título Filme",
	   SUM(i.vl_pago) AS Soma,
	   AVG(i.vl_pago) AS Média,
	   COUNT (*) AS "Quantidade de Ingresso"
FROM filme f, ingresso i, sessao_filme ss 
WHERE i.num_sessao = ss.num_sessao
AND ss.cod_filme = f.cod_filme
GROUP BY f.titulo_filme, i.tipo_ingresso
--AND LOWER(ss.nome_sala) NOT LIKE '%azul%'
HAVING SUM (i.vl_pago) > 150
ORDER BY Sessão DESC;
--
/***** Subconsultas / Subquery ****/
--Dados dos ingressos de maio valores
SELECT i.* -- consulta externa 
FROM ingresso i
WHERE i.vl_pago = -- consulta interna ou subconsulta
            ( SELECT MAX(i.vl_pago) FROM ingresso i);
--			
SELECT sa.*
FROM sala sa
ORDER BY sa.capacidade DESC
LIMIT 3;
--Sessões com quantidade de ingressos maior que a média
SELECT i.num_sessao, COUNT(*) AS Contagem
FROM ingresso i
GROUP BY i.num_sessao
HAVING COUNT(*) >
				 1.1* (SELECT AVG(Contagem) FROM -- media ingresso
					  (SELECT COUNT(*) AS Contagem
					  FROM ingresso i
					  GROUP BY i.num_sessao) Media);

/*********** Aula 30/maio - Junção Externa + Group BY ****/
-- 26 - Mostrar o titulo do filme, sala de exibição, ano de exibição,
-- com o total arrecadado, 
-- somente para filmes que não são do gênero Romance e 
-- que tenham arrecadado mais de 1000					  
SELECT f.titulo_filme, ss.nome_sala AS Sala, 
EXTRACT(YEAR FROM ss.dt_sessao) AS Ano_Exibicao,
SUM(i.vl_pago) AS "Total Arrecadado", COUNT(i.num_ingresso) AS "Qtos Ingressos"
FROM filme f JOIN sessao_filme ss ON ( f.cod_filme = ss.cod_filme)
             JOIN ingresso i ON (ss.num_sessao = i.num_sessao)
WHERE UPPER(f.genero) NOT LIKE '%ROMAN%'
GROUP BY f.titulo_filme, ss.nome_sala, EXTRACT(YEAR FROM ss.dt_sessao)
HAVING SUM(i.vl_pago) > 250 ;

-- 27 -  Subconsulta - dados do funcionario mais novo
SELECT f.*, ROUND(((current_date - f.dt_nascto_func)/365.25),1) AS Menor_Idade
FROM funcionario f 
WHERE TRUNC((current_date - f.dt_nascto_func)/365.25) = 
( SELECT MIN(TRUNC((current_date - f.dt_nascto_func)/365.25)) AS Idade
FROM funcionario f )
UNION
( SELECT f.*, ROUND(((current_date - f.dt_nascto_func)/365.25),1) AS Maior_Idade
FROM funcionario f 
WHERE TRUNC((current_date - f.dt_nascto_func)/365.25) = 
( SELECT MAX(TRUNC((current_date - f.dt_nascto_func)/365.25)) AS Idade
FROM funcionario f )) ;

-- 28 - Subconsulta - dados dos filme mais antigo 
SELECT f.titulo_filme, f.ano_producao AS "Mais Antigo" 
FROM Filme f
WHERE f.ano_producao = ( SELECT MIN(ano_producao) FROM filme)  ;

-- mostrando os dois
SELECT f.titulo_filme||'-'||f.ano_producao AS "Mais Antigo" ,
   ( SELECT f.titulo_filme||'-'||f.ano_producao AS Mais_Recente 
     FROM Filme f
     WHERE f.ano_producao = ( SELECT MAX(ano_producao) FROM filme))
FROM Filme f
WHERE f.ano_producao = ( SELECT MIN(ano_producao) FROM filme)  ;

-- 29 - Mostrar todos os atores que trabalharam junto com Fabio Junior
-- bye bye brasil 1002
SELECT * FROM artista ;
INSERT INTO artista VALUES ( 5, 'Jose Wilker', 'M', 1) ;
INSERT INTO artista VALUES ( 6, 'Bete Faria', 'F', 1) ;	
INSERT INTO artista VALUES ( 7, 'Fabio Junior', 'M', 1) ;	
-- elenco participando do filme
SELECT * FROM elenco_filme ;
INSERT INTO elenco_filme VALUES ( 5, 1002, 'Ator', 'Lorde Cigano');
INSERT INTO elenco_filme VALUES ( 6, 1002, 'Atriz', 'Salome');
INSERT INTO elenco_filme VALUES ( 7, 1002, 'Ator', 'Ciço');

SELECT f.titulo_filme, a.nome_artista
FROM elenco_filme ef JOIN artista a
    ON ( ef.cod_artista = a.cod_artista)
	                 JOIN filme f
    ON ( ef.cod_filme = f.cod_filme)
WHERE UPPER(ef.tipo_participacao) LIKE '%AT%'
AND f.cod_filme IN (
-- descobrir os filmes que o Fabio Jr trabalhou
SELECT ef.cod_filme
FROM elenco_filme ef JOIN artista a
    ON ( ef.cod_artista = a.cod_artista)
WHERE UPPER(a.nome_artista) LIKE '%FABIO%'
AND UPPER(ef.tipo_participacao) LIKE '%AT%' ) 
AND UPPER(a.nome_artista) NOT LIKE '%FABIO%' ;

/***************************************
  JUNÇÃO EXTERNA - OUTER JOIN
****************************************/
-- Relembrando a junção interna
--30 ) Filmes que já tiveram sessão
SELECT * FROM filme ;
SELECT f.titulo_filme, f.cod_filme AS "Tá no Filme", ss.cod_filme AS "Tá na Sessão"
FROM filme f INNER JOIN sessao_filme ss
      ON ( f.cod_filme = ss.cod_filme ) ;

-- 31 - Filmes que não tiveram sessão
-- Usando junção externa - OUTER JOIN
SELECT f.titulo_filme, f.cod_filme AS "Tá no Filme", 
                       ss.cod_filme AS "NÃO tem Sessão"
FROM filme f LEFT OUTER JOIN sessao_filme ss
      ON ( f.cod_filme = ss.cod_filme ) 
WHERE ss.cod_filme  IS NULL ;
-- right join
SELECT f.titulo_filme, f.cod_filme AS "Tá no Filme", 
                       ss.cod_filme AS "NÃO tem Sessão"
FROM filme f RIGHT OUTER JOIN sessao_filme ss
      ON ( f.cod_filme = ss.cod_filme )
WHERE f.cod_filme IS NULL ;
-- mudando filme de lado
SELECT f.titulo_filme, f.cod_filme AS "Tá no Filme", 
                       ss.cod_filme AS "NÃO tem Sessão"
FROM sessao_filme ss RIGHT JOIN filme f
      ON ( f.cod_filme = ss.cod_filme )
WHERE ss.cod_filme IS NULL ;
-- full, combina todo com todo mundo
SELECT f.titulo_filme, f.cod_filme AS "Tá no Filme", 
                       ss.cod_filme AS "NÃO tem Sessão"
FROM sessao_filme ss FULL JOIN filme f
      ON ( f.cod_filme = ss.cod_filme ) ;
--32 - De outra forma -- usando NOT IN
SELECT f.* FROM filme f WHERE f.cod_filme IN (
SELECT f.cod_filme FROM filme f -- todos os filmes
WHERE f.cod_filme NOT IN (
SELECT DISTINCT ss.cod_filme FROM sessao_filme ss ) ) ; -- filmes com sessao

--33-  usando operador diferença
SELECT f.cod_filme FROM filme f -- todos os filmes
EXCEPT
SELECT DISTINCT ss.cod_filme FROM sessao_filme ss ;

-- 34 - Mostrar os dados dos assentos nunca ocupados em sessões
INSERT INTO assento VALUES ( 5, 'C', 'Azul', 'NORMAL', 'DISPONIVEL') ;
INSERT INTO assento VALUES ( 10, 'H', 'Vermelha', 'NORMAL', 'DISPONIVEL') ;
-- assentos que não tiveram ingressos vendidos
SELECT * FROM assento ;
SELECT a.num_assento, a.fileira_assento, a.nome_sala, i.num_assento AS Ingresso
FROM assento a LEFT OUTER JOIN ingresso i
ON ( a.num_assento = i.num_assento AND a.fileira_assento = i.fileira_assento
	 AND a.nome_sala = i.nome_sala)
WHERE i.num_assento IS NULL ;
-- 35 - usando NOT IN
SELECT a.num_assento, a.fileira_assento, a.nome_sala
FROM assento a
WHERE a.num_assento||'-'||a.fileira_assento||'-'||a.nome_sala
NOT IN ( SELECT i.num_assento||'-'||i.fileira_assento||'-'||i.nome_sala
FROM ingresso i ) ;
-- 36 - usando minus
SELECT a.num_assento, a.fileira_assento, a.nome_sala
FROM assento a
EXCEPT
( SELECT i.num_assento, i.fileira_assento, i.nome_sala
FROM ingresso i ) ;

--37 ) Mostrar o nome das salas que nunca exibiram filmes de Drama
INSERT INTO sala VALUES ('Amarela', 230, 'Inclinada', '3D', 'Estereo 3D',
						 '9mx5m', 'ATIVA') ;	
SELECT sa.nome_sala, drama.Sala_Drama
FROM sala sa LEFT OUTER JOIN 
(
SELECT ss.nome_sala AS Sala_Drama
FROM filme f JOIN sessao_filme ss ON ( f.cod_filme = ss.cod_filme)
WHERE UPPER(f.genero) LIKE '%DRAMA%' ) AS drama
ON ( sa.nome_sala = drama.Sala_Drama )
WHERE drama.Sala_Drama IS NULL ;

-- 38 - usando diferença
SELECT sa.nome_sala FROM sala sa -- todas as salas
EXCEPT
( SELECT ss.nome_sala AS Sala_Drama
FROM filme f JOIN sessao_filme ss ON ( f.cod_filme = ss.cod_filme)
WHERE UPPER(f.genero) LIKE '%DRAMA%') ;   -- salas que exibiram Drama

-- 39 -  CASE -- na classificacao etaria aparecer um texto explicando
SELECT * FROM sessao_filme 
SELECT * FROM filme ;
UPDATE filme SET classifica_etaria = '18 anos' WHERE cod_filme = 1002;
SELECT f.titulo_filme, f.genero, f.classifica_etaria,
CASE f.classifica_etaria
     WHEN 'Livre' THEN 'Liberado para todas as idades'
	 WHEN '16 anos' THEN 'Não permitido para menores de 16 anos'
	 ELSE 'Somente para adultos'
END AS "Classificacao Etaria"
FROM filme f;

-- 40 - Funcionario que foi mais vezes escalado como caixa
SELECT * FROM escala_funcionario;

SELECT func.* FROM funcionario func
WHERE func.cod_funcional = 
( SELECT ef.cod_funcional
       FROM escala_funcionario ef
       WHERE ef.funcao = 'Caixa'
       GROUP BY ef.cod_funcional, ef.funcao
HAVING COUNT(*) = (
                  SELECT MAX(Qtas_escalacoes) FROM 
                         (SELECT COUNT(*) Qtas_escalacoes
                           FROM escala_funcionario ef
                            WHERE ef.funcao = 'Caixa'
                           GROUP BY ef.cod_funcional, ef.funcao) escalacoes ));


