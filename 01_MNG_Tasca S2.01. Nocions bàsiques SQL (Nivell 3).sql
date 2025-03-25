-- NIVELL 3
-- Exercici 1: Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor comprès entre 100 i 200 euros
-- i en alguna d'aquestes dates: 29 d'abril del 2021, 20 de juliol del 2021 i 13 de març del 2022. Ordena els resultats de major a menor quantitat.
	-- Pas 1: Obtenir una taula amb les dades requerides de la taula company
	select id,company_name,phone,email
	from company;

	-- Pas 2: Obtenir una taula amb les dades requerides de la taula transaction
	select company_id,timestamp,amount
	from transaction;

-- Pas 3: Fer JOIN de les taules obtingudes de Pas 1 i Pas 2. Fer el filtres requerits a l'enunciat
select company_name,phone,email,timestamp,amount
from (select id,company_name,phone,email                                     -- Subquery del Pas 1
      from company) as compTable
join (select company_id,timestamp,amount                                     -- Subquery del Pas 2
      from transaction) as transTable on compTable.id=transTable.company_id
where (amount between 100 and 200) and (timestamp like ("%2021-04-29%")) or (timestamp like ("%2021-07-20%")) or (timestamp like ("%2022-03-13%"))
order by amount desc;


-- Exercici 2: Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, 
-- per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses, 
-- però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis si tenen més de 4 transaccions o menys.
-- Pas 1: Obtenir taula amb id de les companyies amb més de 4 transaccions
select company_id, count(id)
from transaction
group by company_id
having count(id)>4
order by count(id) desc;

-- Pas 2: Convertir en taula la Query del Pas 1
create table masCuatro as
select company_id
from (select company_id, count(id) -- Query Pas 1
      from transaction
      group by company_id
      having count(id)>4) as mas4;

-- Pas 3: Afegir nova columna que indiqui que les empreses d'aquesta taula tenen més de 4 transaccionsa la taula creada en el Pas 2
alter table masCuatro add mas4Trans char(2) not null default "SI"; 

-- Pas 4: Obtenir taula amb id de les companyies amb menys de 4 transaccions
select company_id, count(id)
from transaction
group by company_id
having count(id)<4
order by count(id) desc;

-- Pas 5: Convertir en taula la Query del Pas 4
create table menosCuatro as
select company_id
from (select company_id, count(id) -- Query Pas 4
      from transaction
      group by company_id
      having count(id)<4) as menos4;

-- Pas 6: Afegir nova columna que indiqui que les empreses d'aquesta taula tenen menys de 4 transaccionsa la taula creada en el Pas 5
alter table menosCuatro add mas4Trans char(2) not null default "NO"; 

-- Pas 7: Crear una nova taula on agrupar les taules generades anteriorment
create table defTable(
	company_id varchar(20),
    masDe4Transacciones char(2));

-- Pas 7: Unir les taules taules creades
select * from defTable      -- Nova taula 
union
select * from masCuatro     -- Taula creada al Pas 2
union
select * from menosCuatro;  -- Taula creada al Pas 5

-- Pas 8: Fer una JOIN per mostrar el nom de l'empresa
select company_id,company_name,masDe4Transacciones
from company
join (select * from defTable                                                        -- Taula creada al Pas 7
      union
      select * from masCuatro
      union
      select * from menosCuatro) as unionTable on company.id=unionTable.company_id;