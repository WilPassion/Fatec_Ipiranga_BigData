/*Filme (Cod_filme(PK), Titulo_Filme, Ano_lancto,Titulo_original, Idioma_Original, Ano_producao, Classifica_Etaria, Estudio,
Duracao, Nacionalidade_Filme, Genero, Situacao_Filme)
Artista (Cod_artista(PK),Nome_artista, Nacionalidade_artista, Sexo_artista)
Sala (Nome_sala(PK), Capacidade,Tipo_Sala, Tipo_Projecao, Tipo_Audio, Dim_tela, Situacao_Sala)
Assento (Num_assento(PK), Fileira(PK), Nome_sala(FK)(PK), Tipo_assento [Normal, PNE etc], Situacao_assento)
Forma_Pagto (Cod_Forma_pgto(PK), Tipo_forma_pgto, Situacao_Forma_pgto)
Horario (Cod_hora(PK), Horario)
Funcionario (Cod_func(PK), Nome_func, sexo_func [M,F], Dt_nascto, Dt_admissao, Salario, Num_CTPS, Situacao_func)

Tabelas de Relacionamento
Sessao (Num_Sessao(PK), Dt_sessao, Tipo_projecao, Idioma, Dubl_Leg, Preco_Ingresso, Publico, cod_filme(FK)NN,
Nome_sala(FK)NN, Cod_hora_exibicao(FK)NN, Situacao_sessao)
Ingresso (Num_ingresso(PK), Tipo_ingresso, Valor_pago, Num_sessao(FK)NN, Num_assento(FK)NN, Fileira(FK)NN,
Nome_sala(FK)NN, Cod_Forma_pgto(FK)NN, Situacao_ingresso)
Escala_Turno (Cod_turno(PK), Nome_turno,Dia_semana,Cod_hora_ini(FK)NN, Cod_hora_term(FK)NN)
Escala_Trabalho (Cod_turno(PK)(FK),Cod_func(PK)(FK),Dt_ini_escala(PK), Dt_term_escala, Funcao)
Elenco_filme (Cod_artista(PK)(FK),Cod_filme(PK)(FK), Tipo_participacao [Ator,Diretor etc.])*/

-- setting date 
SET DATESTYLE TO POSTGRES, DMY;

-- filme table
DROP TABLE IF EXISTS filme CASCADE;
CREATE TABLE filme
(
	Cod_filme INTEGER NOT NULL PRIMARY KEY,
	Titulo_Filme VARCHAR(50) NOT NULL,
	Ano_lancto SMALLINT NOT NULL,
	Titulo_original VARCHAR(50),
	Idioma_Original VARCHAR(50),
	Ano_producao SMALLINT NOT NULL,
	Classifica_Etaria VARCHAR(20) NOT NULL,
	Estudio VARCHAR(30) NOT NULL,
	Duracao SMALLINT NOT NULL,  
	Nacionalidade_Filme VARCHAR(20) NOT NULL, 
	Genero VARCHAR(20) NOT NULL,
	Situacao_Filme CHAR(15)
);

-- sala table
DROP TABLE IF EXISTS sala CASCADE;
CREATE TABLE sala 
(
	Nome_sala CHAR(20) NOT NULL PRIMARY KEY,
	Capacidade SMALLINT NOT NULL,
	Tipo_Sala CHAR(20) NOT NULL,
	Tipo_Projecao CHAR(20) NOT NULL, 
	Tipo_Audio CHAR(20) NOT NULL,
	Dim_tela CHAR(20) NOT NULL, 
	Situacao_Sala CHAR(20) NOT NULL
		CHECK (Situacao_Sala IN ('ATIVA', 'INATIVA', 'MANUTENCAO'))
);

-- sessao table - relations with sala, horario e filme
DROP TABLE IF EXISTS sessao CASCADE;
CREATE TABLE sessao 
(
	Num_sessao SERIAL PRIMARY KEY,
	Dt_sessao DATE NOT NULL,
	Tipo_projecao CHAR(20) NOT NULL,
	Idioma VARCHAR(15) NOT NULL,
	Dubl_Leg VARCHAR(9) NOT NULL
		CHECK (Dubl_Leg IN ('DUBLADO', 'LEGENDADO')),
	Preco_Ingresso NUMERIC(8,2) NOT NULL,
	Publico SMALLINT NOT NULL,
	Situacao_sessao CHAR(15) NOT NULL,
	Cod_filme INTEGER NOT NULL REFERENCES filme (Cod_filme) ON DELETE CASCADE ON UPDATE CASCADE,
	Nome_sala CHAR(20) NOT NULL REFERENCES sala (Nome_sala) ON DELETE CASCADE ON UPDATE CASCADE,
	Cod_hora INTEGER NOT NULL REFERENCES horario (Cod_hora) ON DELETE CASCADE ON UPDATE CASCADE
);

DROP TABLE IF EXISTS assento CASCADE;
CREATE TABLE assento
(
	Num_assento SMALLINT NOT NULL, 
	Fileira CHAR(1) NOT NULL, 
	Tipo_assento VARCHAR(15) NOT NULL CHECK (Tipo_assento IN ('Normal', 'PNE')),
	Situacao_assento CHAR(15) NOT NULL,
	Nome_sala CHAR(15) NOT NULL REFERENCES sala (Nome_sala) ON DELETE CASCADE ON UPDATE CASCADE,		
	PRIMARY KEY (Num_assento, Fileira, Nome_sala)
);

DROP TABLE IF EXISTS horario CASCADE;
CREATE TABLE horario 
(
	Cod_hora SMALLINT NOT NULL PRIMARY KEY,
	horario TIME NOT NULL
);
