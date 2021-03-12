create database faculdade

CREATE TABLE Curso
(
	nome_curso varchar(20) NOT NULL,
	CONSTRAINT pkcurso PRIMARY KEY(nome_curso) 
);

CREATE TABLE Aluno
(
	ra int NOT NULL,
	nome_aluno varchar(50) NOT NULL,
	end_logradouro varchar(20),
	end_numero varchar(10) NOT NULL,
	end_bairro varchar(20),
	end_cep char(8) NOT NULL,
	end_localidade varchar(20),
	end_uf varchar(2),
	nome_curso varchar(20) NOT NULL,
	
	CONSTRAINT fkAlunoNome_curso FOREIGN KEY (nome_curso) REFERENCES Curso(nome_curso),
	CONSTRAINT pkAlunoRA PRIMARY KEY(ra) 
);
CREATE TABLE FoneAluno
(
	ra int NOT NULL,
	numero char(11) NOT NULL,
	tipo varchar(20) NOT NULL,

	CONSTRAINT fkFoneAlunoRa FOREIGN KEY(ra) REFERENCES Aluno(ra),
	CONSTRAINT pkFoneAlunoRaNumero PRIMARY KEY(ra,numero)
);

CREATE TABLE Disciplina
(	
	nome_disciplina varchar(20) NOT NULL,
	qtd_aula int NOT NULL,
	nome_curso varchar(20) NOT NULL,

	CONSTRAINT fkDisciplinaNomeCurso FOREIGN KEY(nome_curso) REFERENCES Curso(nome_curso),
	CONSTRAINT pkDisciplinaNomeDisciplina PRIMARY KEY(nome_disciplina)
);

CREATE TABLE Possui
(
	ra int NOT NULL,
	nome_disciplina varchar(20)NOT NULL,
	semestre int NOT NULL,
	falta int ,
	situacao varchar(20),
	ano int NOT NULL,
	nota_b1 decimal(4,2),
	nota_b2 decimal(4,2),
	sub decimal(4,2),

	CONSTRAINT fkPossuiRa FOREIGN KEY(ra) REFERENCES Aluno(ra),
	CONSTRAINT fkPossuiNomeDisciplina FOREIGN KEY(nome_disciplina) REFERENCES Disciplina(nome_disciplina),
	CONSTRAINT pkPossuiRaNomeDisciplina PRIMARY KEY(ra,nome_disciplina,semestre)
);
drop TRIGGER TatualizaSituacao
CREATE TRIGGER TatualizaSituacao
ON Possui 
AFTER Insert , Update
AS 
begin
	DECLARE 
		@SUB decimal(4,2),
		@NOME varchar(20),
		@RA int,
		@SEMESTRE int,
		@NOTA1 decimal(4,2) ,
		@NOTA2 decimal(4,2),
		@MEDIA decimal(4,2),
		@FALTA decimal(4,2),
		@TOTAL decimal(4,2),
		@PORCENTAGEM decimal(4,2)
	select @RA = ra, @NOME = nome_disciplina,@SEMESTRE = semestre ,@FAlTA = falta,@NOTA1 = nota_b1 , @NOTA2 = nota_b2, @SUB = sub
	from INSERTED
	
	if @NOTA1 > @NOTA2
	Update Possui
	set nota_b2 = 
	(case
		when @SUB is NULL  then nota_b2
		else(@SUB)
	end 
	) 
	if @NOTA1< @NOTA2
	Update Possui
	set nota_b1 = 
	(case
		when @SUB is NULL  then nota_b1
		else(@SUB)
	end 
	)
	set @MEDIA=(@NOTA1+@NOTA2)/2

	Select @TOTAL = qtd_aula from Disciplina where nome_disciplina = @NOME
	set @PORCENTAGEM = (@FALTA/@TOTAL)

	Update Possui 
	set situacao = 
	(case
		when @PORCENTAGEM > 0.250 then 'Reprovado por falta' 
		when @MEDIA > 6.00 then 'Aprovado'
		when @MEDIA < 5.99 then  'Reprovado por nota' 
		when @PORCENTAGEM < 0.250 then 'Aprovado'
		
	end 
	) 
	where ra = @RA and nome_disciplina = @NOME  and semestre = @SEMESTRE
end;

insert into Possui(ra,nome_disciplina,ano,semestre,falta,nota_b1,nota_b2)
values(1,'Redes de Comput',2020,1,0,9,8)

--serve para inserir depois da inserção
update Possui
set sub = 6
where ra = 2 AND semestre = 1 AND nome_disciplina = 'Programacao linear'

update Possui
set falta = 10
where ra = 1 AND semestre = 1 AND nome_disciplina = 'Redes de Comput'

update Possui
set nota_b1 = 6
where ra = 1 AND nome_disciplina = 'Estrutura de Dados'

insert into Curso
values('ADS')

insert into Aluno
values(2,'Luiz Sena','rua Sebastião','20','centro','15000852','Matão','sp','ADS')

insert into FoneAluno
values(2,'1633846633','Fixo')

insert into Disciplina
values('Matematica Discreta',30,'ADS')


/*a)Quais são alunos de uma determinada disciplina ministrada no ano de 2020, com suas notas. Você definirá a disciplina.*/
Select l.nome_aluno, p.nota_b1,p.nota_b2
from Aluno l ,Disciplina d  join Possui p
ON d.nome_disciplina = 'Estrutura de Dados' AND d.nome_disciplina = p.nome_disciplina
where l.ra = p.ra and p.ano = 2020

/*b)Quais  são  as  notas  de  um  aluno  em  todas  as  disciplinas  por  ele cursadas  no  2º.  Semestre  de  2019.  
(“BOLETIM  COM  AS INFORMAÇÕES  DAS  DISCIPLINAS  CURSADAS”).  Você  definirá  o aluno.*/
select l.nome_aluno,p.semestre,c.nome_disciplina,p.nota_b1, p.nota_b2, Cast((p.nota_b1 + p.nota_b2)/2 as decimal(4,2)) as media 
from Aluno l,Disciplina c  join Possui p 
ON p.semestre = 2  AND p.nome_disciplina = c.nome_disciplina
WHERE l.nome_aluno = 'Isabela' and p.ano = 2019 and p.ra = l.ra

/*C)Quais são os alunos reprovados por nota (média inferior a seis) no ano de 2020 e,
o nome das disciplinas e as médias.Você definirá o curso.*/
select l.nome_aluno,c.nome_disciplina,Cast((p.nota_b1 + p.nota_b2)/2 as decimal(4,2)) as media
from Aluno l ,Disciplina c join Possui p
on p.situacao = 'Reprovado por nota' and p.nome_disciplina = c.nome_disciplina
where c.nome_curso = 'ADS' and p.ano = 2020  and p.ra = l.ra

/*d)Tabela que aparece o nome e telefone dos alunos matriculados em alguma disciplina na facudade.*/
SELECT DISTINCT l.nome_aluno,t.numero
FROM Possui p join FoneAluno t ON t.ra = p.ra
join  Disciplina c on c.nome_disciplina = p.nome_disciplina
join  Aluno l ON p.ra = l.ra 

 