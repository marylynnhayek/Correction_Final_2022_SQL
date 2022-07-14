-- Correction de l'examen final printemps 2022:

create table Etudiant(
  NumE int NOT NULL,
  NomE varchar(50),
  DOB date,
  CodeGenre varchar(1),
  primary key(NumE)
);

create table Enseignant(
  NumEns int NOT NULL,
  NomEns varchar(50),
  Grade varchar(50),
  Ancien varhcahr(1),
  primary key(NumEns)
);

create table Matiere(
  Numat int NOT NULL,
  Nomat varchar(50),
  Coeff int,
  NumEns int,
  primary key(Numat),
  foreign key(NumEns) references Enseignant(NumEns)
);

create table Note(
 NumE int NOT NULL,
 Numat int NOT NULL,
 Note int,
 primary key(NumE,Numat),
 Foreign key(NumE) references Etudiant(NumE),
 Foreign key(Numat) references Matiere(Numat)
);

-- Insertion de données:
insert into Enseignant values(100,'Georges','PROF','Y');
insert into Enseignant values(101,'Jad','MCF','N');
insert into Enseignant values(102,'Najat','AST','Y');

insert into matiere values(1000,'Maths',4,100);
insert into matiere values(1001,'Sciences',3,100);
insert into matiere values(1002,'Languages',2,101);
insert into matiere values(1003,'Programming',4,102);
insert into matiere values(1004,'Database',4,102);

insert into Etudiant values(1,'Jean','1998-02-15','1');
insert into Etudiant values(2,'Marie','1998-06-18','2');
insert into Etudiant values(3,'Sami','1995-05-19','1');
insert into Etudiant values(4,'Rabih','1999-01-01','1');

insert into note values(1,1000,50);
insert into note values(1,1003,80);
insert into note values(1,1004,70);
insert into note values(2,1002,50);
insert into note values(2,1000,80);

-- Queries:

-- 1. Afficher que était l'age moyen des gracons et des filles au premier Janvier 2000.
select CodeGenre, avg(datediff(year,'2000-01-01',DOB))
from Etudiant
group by CodeGenre;

-- Ou bien:
select CodeGenre, Year('2000-01-01')-Year(DOB)
from Etudiant
group by CodeGenre;

-- 2. Afficher le nom et le grade des enseignants de base de données:
select NomEns, grade
from Enseignant E, Matiere M
where E.NumEns=M.NumEns and Nomat='Database';

-- 3. Afficher les noms et numéros des étudiants qui n'ont pas de notes en Maths.
select NomE, NumE
from Etudiant E
where NumE not in(select NumE from Note N, Matiere M
where N.Numat=M.Numat and Nomat='Maths');

-- 4. Afficher le nom et le coefficient des matières qui sont ensiegnées par des maitres de conférences ou des assistant:
select Nomat, Coeff
from Matiere M, Enseignant En
where M.NumEns=En.NumEns and Grade IN('MCF','AST');

-- Methode 2:
select Nomat, Coeff
from Matiere M, Enseignant En
where M.NumEns=En.NumEns and (Grade='MCF'OR Grade='AST');

-- A noter que IN() donne les choix sous la forme OR et non pas AND.

-- 5. Afficher pour chaque étudiant (nom et numéro) et par ordre alphabétique, la moyenne qu'il a obtenue dans chaque matière:
select NomE, E.NumE, sum(Note*Coeff)/sum(Coeff)
from Etudiant E, Note N, Matiere M
where E.NumE=N.NumE and N.Numat=M.Numat
group by E.NumE,NomE
order by NomE asc;

-- 6. Afficher le nom, l'age et le sexe des étudiants qui ont eu une note d'informatique supérieure a la moyenne générale de la classe:
select NomE AS "Nom De L'étudiant", Year(getdate())-Year(DOB) AS "Age", CodeGenre AS "Sexe De L'étudiant"
from Etudiant E, Note N, Matiere M
where E.NumE=N.NumE and N.Numat=M.Numat and Nomat='Programming' and Note>(select avg(Note) from Note N, Matiere M where N.Numat=M.Numat and Nomat='Programming');

-- 7. Afficher pour chaque étudiant (nom et numéro) qui a une note dans chacune des matières, la moyenne obtenue au diplome:
select NomE, E.NumE, avg(Note)
from Etudiant E, Note N
where E.NumE=N.NumE 
group by NomE,E.NumE
having count(Numat)=5;

-- On pourrait appliquer la formule de calcul de la moyenne donnée par 
-- le prof, donc dans ce cas une jointure entre les 3 tables Note,
-- Matières et Etudiants est obligatoire car on utilise des attributs 
-- Comme le coeff. 

-- 8. Afficher le nom, le grade et l'ancienneté des enseignants qui enseignent dans plus d'une matière:
select NomEns as "Nom de l'enseignant", Grade, Ancien, count(Numat)
from Enseignant E, Matiere M
where E.NumEns=M.NumEns 
group by E.NumEns, Grade, Ancien
having count(Numat)>1;

-- Dans mon cas je préfère faire un count des numéros des enseignants et non pas celui des matières.

-- Méthode 2: A éviter l'ambiguité:
select NomEns as "Nom de l'enseignant", Grade, Ancien, count(M.NumEns)
from Enseignant E, Matiere M
where E.NumEns=M.NumEns 
group by E.NumEns, Grade, Ancien
having count(M.NumEns)>1;


