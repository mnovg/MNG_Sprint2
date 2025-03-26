/************************************************************ NIVEL 1 *****************************************************************************************/

-- 2.1.Llistat dels països que estan fent compres.
select distinct country as 'PAISES QUE REALIZAN COMPRAS'
from company
join transaction on company.id=transaction.company_id
order by country desc;

-- 2.2. Des de quants països es realitzen les compres.
select count(country) as 'Nº PAISES QUE REALIZAN COMPRAS'
from (select distinct country
      from company
      join transaction on company.id=transaction.company_id
      order by country desc) as subQuery1;

-- 2.3. Identifica la companyia amb la mitjana més gran de vendes.
select distinct company.id,company_name,avg(amount) as media                             -- Tabla resumen A (muestra la media de ventas de cada empresa)
from company
join transaction on company.id=transaction.company_id
group by company.id,company_name;

select max(media)                                                                        -- Calculo media máxima
from (select distinct company.id,company_name,avg(amount) as media
	  from company
      join transaction on company.id=transaction.company_id
      group by company.id,company_name) as A;
      
select A.company_name,A.media
from (select distinct company.id,company_name,avg(amount) as media                       -- Datos de la tabla resumen A
	  from company
	  join transaction on company.id=transaction.company_id
	  group by company.id,company_name) as A
where A.media=(select max(media)                                                         -- Comparación con la media máxima
			   from (select distinct company.id,company_name,avg(amount) as media
				     from company
					 join transaction on company.id=transaction.company_id
					 group by company.id,company_name) as A);

-- 3.1. Mostra totes les transaccions realitzades per empreses d'Alemanya.
select distinct company_name,country
from company
join transaction on company.id=transaction.company_id
where country='Germany'; 

-- 3.2. Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.
select avg(amount)                                        -- Valor correspondiente a la media de todos los importes de la tabla transaction
from transaction;

select company_name,avg(amount)                           
from company
join transaction on company.id=transaction.company_id
group by company_name
having avg(amount)>(select avg(amount)                    -- Filtro a través de el valor que devuelve la función de agregación avg, con el
                    from transaction)                     -- valor máximo calculado en la query anterior 
order by avg(Amount) desc;

-- 3.3. Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.
select company_id,count(id) as numTransactions                    -- Tabla resumen B que devuelve el nº de transacciones por id de empresa 
from transaction
group by company_id;

select company_name,B.company_id,B.numTransactions
from company
left join (select company_id,count(id) as numTransactions         -- JOIN que devuelve todas las empresas de la tabla company
           from transaction                                       -- y las comunes en la tabla transaction
           group by company_id) as B on company.id=B.company_id
where B.numTransactions='null';                                   -- Filtro aquellas que no tienen transacciones 



/************************************************************** NIVEL 2 ****************************************************************************************/

-- 2.1.- Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes.
--       Mostra la data de cada transacció juntament amb el total de les vendes.
select cast(timestamp as date) as FECHA, sum(amount) as INGRESOS   -- Convierto el tipo de fecha de timestamp a data par eliminar la hora
from transaction                                                   -- y consulto la suma de ingresos por fecha
group by FECHA                                                     
order by INGRESOS desc  
limit 5;

-- 2.2.- Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.
select country,avg(amount) as 'MEDIA DE VENTAS'
from company
join transaction on company.id=transaction.company_id
group by country
order by 'MEDIA DE VENTAS';

-- 2.3.- En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer competència a la companyia "Non Institute".
-- Per a això, et demanen la llista de totes les transaccions realitzades per empreses que estan situades en el mateix país que aquesta companyia.

-- 2.3.1.- Mostra el llistat aplicant JOIN i subconsultes.
select distinct country                                               -- Query para obtener el país al que pertenece la empresa Non Institute
from company
join transaction on company.id=transaction.company_id
where company_name='Non Institute';

select transaction.id,company_name,country
from company
join transaction on company.id=transaction.company_id
where country=(select distinct country                                 -- Filtro del país de la empresa Non Institute
               from company
               join transaction on company.id=transaction.company_id
               where company_name='Non Institute');

-- 2.3.2.- Mostra el llistat aplicant solament subconsultes.
select country                                     -- Devuelve el país al que pertenece la empresa Non Institute
from company
where company_name='Non Institute';

select distinct transaction.id,country,company_name      
from company,transaction                                                             -- UNION entre ambas tablas 
where (company.id=transaction.company_id) and (country=(select country
													   from company
													   where company_name='Non Institute'));



/************************************************************** NIVEL 3 ****************************************************************************************/

-- 3.1.- Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor comprès entre 100 i 200 euros
-- i en alguna d'aquestes dates: 29 d'abril del 2021, 20 de juliol del 2021 i 13 de març del 2022. Ordena els resultats de major a menor quantitat.

select company_name,phone,country,cast(timestamp as date),amount
from company
join transaction on company.id=transaction.company_id
where (amount between 100 and 200) and (timestamp like ('%2021-04-29%') or timestamp like ('%2021-07-20%') or timestamp like ('%2022-03-13%'))
order by amount desc;

-- 3.2.- Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi,
-- per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses, 
-- però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis si tenen més de 4 transaccions o menys.

select company_name, count(transaction.id) as 'NUMERO DE TRANSACCIONES'         -- Tabla resumen de empresas con más de 4 transacciones (QueryMasCuatro)
from company
join transaction on company.id=transaction.company_id
group by company_name
having count(transaction.id)>4
order by count(transaction.id) desc;

select company_name, count(transaction.id) as 'NUMERO DE TRANSACCIONES'         -- Tabla resumen de empresas con 4 o menos transacciones (QueryMenosCuatro)
from company
join transaction on company.id=transaction.company_id
group by company_name
having count(transaction.id)<=4
order by count(transaction.id) desc;

-- Conversión de las consultas anteriores en tablas
create table masCuatro as
select company_name
from (select company_name, count(transaction.id) as 'NUMERO DE TRANSACCIONES'          -- QueryMasCuatro
	  from company
	  join transaction on company.id=transaction.company_id
	  group by company_name
	  having count(transaction.id)>4
	  order by count(transaction.id) desc) as QueryMasCuatro;

create table menosCuatro as
select company_name
from (select company_name, count(transaction.id) as 'NUMERO DE TRANSACCIONES'          -- QueryMenosCuatro
	  from company
	  join transaction on company.id=transaction.company_id
	  group by company_name
	  having count(transaction.id)<=4
	  order by count(transaction.id) desc) as QueryMenosCuatro;

-- Añadir una nueva columna a las nuevas tablas creadas
alter table masCuatro add MAS_DE_CUATRO_TRANSACCIONES char(2) not null default "SI";   -- No puede adoptar el valor NULL y por defecto es SI

alter table menosCuatro add MAS_DE_CUATRO_TRANSACCIONES char(2) not null default "NO"; -- No puede adoptar el valor NULL y por defecto es NO

-- Crear una nueva tabla en la que unir las dos nuevas creadas con la nueva columna añadida
create table defTable(
	company_id varchar(20),
    MAS_DE_CUATRO_TRANSACCIONES char(2));

select *
from defTable
union
select *
from masCuatro
union
select *
from menosCuatro;