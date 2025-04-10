CREATE DATABASE SPRINT2;

USE SPRINT2;

/************************************************************ NIVEL 1 *****************************************************************************************/

-- 2.1.Llistat dels països que estan fent compres (utilitzant JOIN):
select distinct country as paisesCompradores
from company
join transaction on company.id=transaction.company_id
order by country desc;

-- 2.2. Des de quants països es realitzen les compres (utilitzant JOIN):
select count(distinct country) AS numPaisesCompradores
from company
join transaction on company.id=transaction.company_id;

-- 2.3. Identifica la companyia amb la mitjana més gran de vendes (utilitzant JOIN):
select company_name,round(avg(amount),2) as mediaVentas
from transaction
join company on transaction.company_id=company.id
group by company_name
order by avg(amount) desc
limit 1;


-- 3.1. Mostra totes les transaccions realitzades per empreses d'Alemanya (sense utilitzar JOIN).
select id                                      -- Sacar todos los id de empresas cuyo país es Alemania 
from company
where country='Germany';

select *
from transaction
where company_id in (select id                  -- Filtrar incluyendo la query anterior.
                     from company
                     where country='Germany');

-- 3.2. Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions (sense utilitzar JOIN).
select avg(amount)                           -- calculo de la media total de amount de todas las transacciones
from transaction;

select company_id
from transaction                             -- id de empresas con amount superior a la media total 
where amount>(select avg(amount)
              from transaction);

select company_name
from company
where id in (select company_id
             from transaction 
             where amount>(select avg(amount)
                           from transaction));
                           

-- 3.3. Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses (sense utilitzar JOIN).
select company_id                       -- Listado de empresas que si han realizado transacciones
from transaction
group by company_id
having count(id)!=0;

select company_name
from company
where id not in (select company_id      -- filtro mediante el cual obtengo las empresas que no han realizado transacciones
                 from transaction
                 group by company_id
                 having count(id)!=0);







/************************************************************** NIVEL 2 ****************************************************************************************/

-- 2.1.- Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes.
--       Mostra la data de cada transacció juntament amb el total de les vendes.
select date(timestamp) as FECHA, sum(amount) as INGRESOS           -- Convierto el tipo de fecha de timestamp a data par eliminar la hora
from transaction                                                   -- y consulto la suma de ingresos por fecha
group by FECHA                                                     
order by INGRESOS desc  
limit 5;

select date(timestamp) as FECHA, sum(amount) as INGRESOS   -- Convierto el tipo de fecha de timestamp a data par eliminar la hora
from transaction                                           -- y consulto la suma de ingresos por fecha
group by FECHA                                                     
order by INGRESOS desc  
limit 5;

-- 2.2.- Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.
select country,avg(amount) as avgAmount
from company
join transaction on company.id=transaction.company_id
group by country
order by avgAmount desc;

-- 2.3.- En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer competència a la companyia "Non Institute".
-- Per a això, et demanen la llista de totes les transaccions realitzades per empreses que estan situades en el mateix país que aquesta companyia.

-- 2.3.1.- Mostra el llistat aplicant JOIN i subconsultes.
select distinct country                                               -- Query para obtener el país al que pertenece la empresa Non Institute
from company
where company_name='Non Institute';

select transaction.id,company_name,country
from company
join transaction on company.id=transaction.company_id
where country=(select distinct country                                                -- Filtro del país de la empresa Non Institute
               from company
               where company_name='Non Institute') and company_name!='Non Institute'; -- No devuelvo las de la empresa Non Institute



-- 2.3.2.- Mostra el llistat aplicant solament subconsultes.
select country                                     -- Devuelve el país al que pertenece la empresa Non Institute
from company
where company_name='Non Institute';

select id                                          -- Devuelve los id de empresas ubicadas enel mism país que Nopn Institute
from company
where country=(select country
			   from company
			   where company_name='Non Institute');

select *
from transaction
where company_id in (select id                     -- Filtro los id de empresas con el mismo id que las de la consulta anterior
                     from company
					 where country=(select country
									from company
									where company_name='Non Institute') and company_name!='Non Institute'); 

/************************************************************** NIVEL 3 ****************************************************************************************/

-- 3.1.- Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor comprès entre 100 i 200 euros
-- i en alguna d'aquestes dates: 29 d'abril del 2021, 20 de juliol del 2021 i 13 de març del 2022. Ordena els resultats de major a menor quantitat.

select company_name,phone,country,date(timestamp),amount
from company
join transaction on company.id=transaction.company_id
where (amount between 100 and 200) and (date(timestamp) in ('2021-04-29','2021-07-20','2022-03-13'))
order by amount desc;

-- 3.2.- Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi,
-- per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses, 
-- però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis si tenen més de 4 transaccions o menys.

select company_name, count(amount) as 'numTransacciones',
case 
    when count(amount)>4 then 'Mas de 4 transacciones'
    when count(amount)<4 then 'Menos de 4 transacciones'
    else '4 transacciones'
end as 'notaTransacciones'
from company
join transaction on company.id=transaction.company_id
group by company_name
order by company_name asc;