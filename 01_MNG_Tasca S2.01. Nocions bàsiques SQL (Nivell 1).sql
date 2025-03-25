-- NIVELL 1
-- Exercici 2: Utilitzant JOIN realitzaràs les següents consultes:


-- Exercici 2.1: Llistat dels països que estan fent compres. 
select distinct country                                 -- Amb la comanda DISTINC ens assegurem de no mostrar valors duplicats al camp seleccionat
from company
join transaction on company.id=transaction.company_id   -- Relacionem la PK de la taula company amb la FK de la taula transaction
order by country asc;                                   -- Ordenem els països alfabèticament


-- Exercici 2.2: Des de quants països es realitzen les compres.
select count(country)
from (select distinct country                                  -- Fem servir com a subquery la query del exercici 2.1
	  from company
	  join transaction on company.id=transaction.company_id
      order by country asc) as countryTable;                   -- Posem nom a la nova taula que torna la subquery


-- Exercici 2.3: Identifica la companyia amb la mitjana més gran de vendes.
	-- Pas 1: Obtenir una taula resum de les vendes per company_id (total € y la mitja de € per venda). summaryVendes
	select company_id,count(id),sum(amount),avg(amount) as mitjaVendes
	from transaction
	group by company_id
	order by avg(amount) desc;

	-- Pas 2: Obtenir de manera dinàmica la major mitja de vendes. maxMitja
	select max(mitjaVendes)
	from (select company_id,count(id),sum(amount),avg(amount) as mitjaVendes
		  from transaction
		  group by company_id
		  order by avg(amount) desc) as summaryVendes;

-- Pas 3: Filtrar per el valor maxMitja que torna la subquery anterior
select company_name, summaryVendes.mitjaVendes as mitjaMaxVendes
from company
join (select company_id,count(id),sum(amount),avg(amount) as mitjaVendes                                         -- Subquery Pas 1
      from transaction
      group by company_id
      order by avg(amount) desc) as summaryVendes on company.id=summaryVendes.company_id
      where summaryVendes.mitjaVendes=(select max(mitjaVendes)                                                   -- Subquery Pas 2
                                       from (select company_id,count(id),sum(amount),avg(amount) as mitjaVendes
                                             from transaction
                                             group by company_id
                                             order by avg(amount) desc) as summaryVendes);


-- Exercici 3: Utilitzant JOIN realitzaràs les següents consultes:


-- Exercici 3.1: Mostra totes les transaccions realitzades per empreses d'Alemanya.
select transaction.id,country
from transaction
join company on transaction.company_id=company.id  -- Fem la JOIN per poder relacionar comandes amb països
where country="Germany";                           -- Filtre de country

-- Exercici 3.2: Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.
	-- Pas 1: Calcular la mitjana de totes les transaccions.
	select avg(amount)
	from transaction;

	-- Pas 2: Obtenir una taula amb els company_id i cadascún dels amount de cada transacció realitzada. amountTable
	select company_id, amount
	from transaction
	order by amount desc;

-- Pas 3: Realitzar el filtre
select company_name, amount
from company
join (select company_id, amount                                                  -- JOIN amb la Subquery Pas 2 per relacionar els amount amb els noms de les empreses
      from transaction
      order by amount desc) as amountTable on company.id=amountTable.company_id
where amount>(select avg(amount)                                                 -- Subquery Pas 1
              from transaction)
order by amount asc;                                                             -- Comprobació que es mostren els amounts per sobre del calculat al Pas 1

-- Exercici 3.3: Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.
-- Pas 1: Obtenir una taula que relacioni el nom de les empreses amb el nombre de transaccions realitzades
select company.company_name, count(transaction.id) as transaccionsTotal
from company
join transaction on company.id=transaction.company_id
group by company.company_name
having transaccionsTotal="null"  -- Filtrar aquelles empreses que en el seu camp de transaccions hi hagi un NULL
order by count(transaction.id) asc;