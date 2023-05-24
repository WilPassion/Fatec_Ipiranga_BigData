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

--add coluna em funcionario
ALTER TABLE funcionario ADD COLUMN dt_desligamento DATE NOT NULL;
--add constraints de verificação em tabela escala_funcionario
ALTER TABLE escala_funcionario ADD CHECK (funcao IN ('CAIXA', 'GERENTE', 'ATENDENTE'));
ALTER TABLE assento ADD CHECK (tipo_assento IN ('NORMAL', 'PNE', 'LARGO'));

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
INSERT INTO artista VALUES (4, 'Britanica', 'Gilian Anderson', 'F');
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
	
-- horario
SELECT * FROM horario ;
INSERT INTO horario VALUES ( 2, '16:00');
INSERT INTO horario VALUES ( 3, '17:00');
INSERT INTO horario VALUES ( 5, '20:00');
INSERT INTO horario VALUES ( 6, '22:00');

--  assento ;
SELECT * FROM assento ;
SELECT * FROM sala ;
INSERT INTO assento VALUES ( 1, 'A', 'Azul', 'NORMAL', 'DISPONIVEL');
INSERT INTO assento VALUES ( 2, 'A', 'Azul', 'PNE', 'DISPONIVEL');
INSERT INTO assento VALUES ( 3, 'A', 'Azul', 'LARGO', 'DISPONIVEL');
INSERT INTO assento VALUES ( 11, 'C', 'Azul', 'NORMAL', 'DISPONIVEL');
INSERT INTO assento VALUES ( 21, 'C', 'Azul', 'PNE', 'DISPONIVEL') ;
INSERT INTO assento VALUES ( 31, 'C', 'Azul', 'LARGO', 'DISPONIVEL') ;
INSERT INTO assento VALUES ( 5, 'B', 'Azul', 'NORMAL', 'DISPONIVEL') ;
INSERT INTO assento VALUES ( 6, 'B', 'Azul', 'NORMAL', 'DISPONIVEL') ;
INSERT INTO assento VALUES ( 7, 'B', 'Azul', 'NORMAL', 'DISPONIVEL') ;
INSERT INTO assento VALUES ( 1, 'A', 'Vermelha', 'NORMAL', 'DISPONIVEL') ;
INSERT INTO assento VALUES ( 2, 'A', 'Vermelha', 'PNE', 'DISPONIVEL') ;
INSERT INTO assento VALUES ( 3, 'A', 'Vermelha', 'LARGO', 'DISPONIVEL') ;
INSERT INTO assento VALUES ( 11, 'G', 'Vermelha', 'NORMAL', 'DISPONIVEL') ;
INSERT INTO assento VALUES ( 12, 'G', 'Vermelha', 'PNE', 'DISPONIVEL') ;
INSERT INTO assento VALUES ( 13, 'G', 'Vermelha', 'LARGO', 'DISPONIVEL') ;
INSERT INTO assento VALUES ( 10, 'B', 'Vermelha', 'NORMAL', 'DISPONIVEL') ;
INSERT INTO assento VALUES ( 20, 'B', 'Vermelha', 'PNE', 'DISPONIVEL') ;
INSERT INTO assento VALUES ( 30, 'B', 'Vermelha', 'LARGO', 'DISPONIVEL') ;
-- forma de pagamento
SELECT * FROM forma_pgto ;
INSERT INTO forma_pgto VALUES ( 'DIN', 'DINHEIRO', 'ATIVO' ) ;
INSERT INTO forma_pgto VALUES ( 'CCRED', 'CARTAO CREDITO', 'ATIVO' ) ;
INSERT INTO forma_pgto VALUES ( 'PIX', 'PIX' , 'ATIVO' ) ;
-- ingresso
SELECT * FROM ingresso ;
SELECT * FROM sessao_filme ;
INSERT INTO ingresso VALUES ( default , 'MEIA', 25.00,  'DIN', 1, 'A', 'Azul', 23002 ) ;
INSERT INTO ingresso VALUES ( default , 'INTEIRA', 50.00, 'PIX', 2, 'A', 'Azul', 23002) ;
INSERT INTO ingresso VALUES ( default , 'MEIA', 25.00,  'DIN', 1, 'A', 'Vermelha', 23001) ;
INSERT INTO ingresso VALUES ( default , 'INTEIRA', 50.00,  'PIX', 3, 'A', 'Azul', 23002) ;
INSERT INTO ingresso VALUES ( default , 'MEIA', 25.00, 'DIN', 2, 'A', 'Vermelha', 23001) ;
INSERT INTO ingresso VALUES ( default , 'INTEIRA', 50.00, 'PIX', 3, 'A', 'Vermelha', 23001) ;
INSERT INTO ingresso VALUES ( default, 'MEIA', 25.00, 'DIN', 5, 'B', 'Azul', 23002) ;
INSERT INTO ingresso VALUES ( default , 'INTEIRA', 50.00,  'CCRED', 11, 'G', 'Vermelha', 23001) ;

INSERT INTO ingresso VALUES ( default , 'MEIA', 25.00,  'CCRED',  21, 'C', 'Azul', 23002) ;
INSERT INTO ingresso VALUES ( default , 'INTEIRA', 50.00, 'PIX', 12, 'G', 'Vermelha', 23001) ;
INSERT INTO ingresso VALUES ( default , 'MEIA', 25.00, 'PIX', 6, 'B', 'Azul', 23002) ;
INSERT INTO ingresso VALUES ( default , 'INTEIRA', 50.00,  'DIN',13, 'G', 'Vermelha', 23001) ;
INSERT INTO ingresso VALUES ( default , 'MEIA', 25.00,  'CCRED',10, 'B', 'Vermelha', 23001) ;
INSERT INTO ingresso VALUES ( default , 'INTEIRA', 50.00, 'PIX', 7, 'B', 'Azul', 23002) ;
INSERT INTO ingresso VALUES ( default , 'MEIA', 25.00, 'CCRED', 20, 'B', 'Vermelha', 23001) ;
INSERT INTO ingresso VALUES ( default , 'INTEIRA', 50.00,  'CCRED',  30, 'B', 'Vermelha', 23001) ;

-- funcionário
SELECT * FROM Funcionario ;
INSERT INTO funcionario VALUES ( 1000, 'Jose de Arimateia','M', '10/10/1980', 'Rua Amarela, 10', 
current_date - 500, 123456, null) ;
INSERT INTO funcionario VALUES ( 1001, 'Maria Conceicao dos Santos','F', '15/12/1988', 'Rua Azul, 20', 
current_date - 300, 987654, null) ;
INSERT INTO funcionario VALUES ( 1002, 'Tereza Baptista Silva','F', '05/02/1978', 'Rua Verde, 30', 
'10/01/2016', 658734, null) ;
INSERT INTO funcionario VALUES ( 1003, 'Joao de Castro e Souza','M', '10/01/1970', 'Rua Branca, 10', 
current_date - 100, 765432, null) ;
INSERT INTO funcionario VALUES ( 1004, 'Carla Marinho','F', '05/05/1978', 'Rua Vermelha, 20', 
current_date - 120, 342176, null) ;
INSERT INTO funcionario VALUES ( 1005, 'Francine Oliver','F', '25/02/1996', 'Rua Verde, 50', 
'10/11/2016', 543734, null) ;

-- escala trabalho
SELECT * FROM escala_trabalho ;
INSERT INTO escala_trabalho VALUES ( 1,  'Segunda-Feira', 1, 5 ) ;
INSERT INTO escala_trabalho VALUES ( 2,  'Segunda-Feira', 4, 6 ) ;
INSERT INTO escala_trabalho VALUES ( 3,  'Terca-Feira', 1, 5 ) ;
INSERT INTO escala_trabalho VALUES ( 4,  'Terca-Feira', 4, 6 ) ;
INSERT INTO escala_trabalho VALUES ( 5,  'Quarta-Feira', 1, 5 ) ;
INSERT INTO escala_trabalho VALUES ( 6,  'Quarta-Feira', 4, 6 ) ;

-- escala de atendimento
SELECT *  FROM escala_funcionario ;
INSERT INTO escala_funcionario VALUES ( 1, 1001, current_date - 21, 'Caixa') ; -- ***** REVISAR current_date - 21 ******
INSERT INTO escala_funcionario VALUES ( 1, 1002, current_date - 21,'Atendente') ;
INSERT INTO escala_funcionario VALUES ( 3, 1001, current_date - 21,'Atendente') ;
INSERT INTO escala_funcionario VALUES ( 3, 1002, current_date - 21,'Atendente') ;
INSERT INTO escala_funcionario VALUES ( 3, 1003, current_date - 21,'Caixa') ;
INSERT INTO escala_funcionario VALUES ( 2, 1001, current_date - 14,'Caixa') ;
INSERT INTO escala_funcionario VALUES ( 2, 1002, current_date - 14,'Atendente') ;
INSERT INTO escala_funcionario VALUES ( 4, 1001, current_date - 7,'Atendente') ;
INSERT INTO escala_funcionario VALUES ( 4, 1002, current_date - 7,'Atendente') ;
INSERT INTO escala_funcionario VALUES ( 4, 1003, current_date - 7,'Caixa') ;
INSERT INTO escala_funcionario VALUES ( 5, 1001, current_date ,'Caixa') ;
INSERT INTO escala_funcionario VALUES ( 5, 1002, current_date ,'Atendente') ;
INSERT INTO escala_funcionario VALUES ( 6, 1001, current_date + 7, 'Atendente') ;
INSERT INTO escala_funcionario VALUES ( 6, 1002, current_date + 7,'Atendente') ;
INSERT INTO escala_funcionario VALUES ( 6, 1003, current_date + 7,'Atendente') ;
	
SELECT * FROM sessao_horario;
SELECT * FROM horario;