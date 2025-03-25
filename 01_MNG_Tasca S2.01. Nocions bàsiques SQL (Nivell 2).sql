-- NIVELL 2
-- Exercici 1: Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes.
-- Mostra la data de cada transacció juntament amb el total de les vendes.
select timestamp, sum(amount)
from transaction
group by timestamp
order by sum(amount) desc
limit 5;

-- Exercici 2: Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.
select country, avg(amount)
from company
join transaction on company.id=transaction.company_id
group by country
order by avg(amount) desc;

-- Exercici 3: En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer competència a la companyia "Non Institute".
-- Per a això, et demanen la llista de totes les transaccions realitzades per empreses que estan situades en el mateix país que aquesta companyia.
-- Mostra el llistat aplicant JOIN i subconsultes.

	-- Pas 1: Conèixer el país de l'empresa Non Institute
	select company_name, country
	from company
	where company_name="Non Institute";

	-- Pas 2:Obtenir el llistat d'empreses de United Kingdom, amb el seu id per poder-les relacionar amb la taula de transaccions
	select id, company_name,country
	from company
	where country="United Kingdom";  -- El nom del país l'obtenim de la Query del Pas 1

-- Pas 3: Fer JOIN de lla taula company amb la que torna la Subquery del Pas 2, on relacionem el id de les empreses
select transaction.id
from transaction
join (select id, company_name                                                           -- Subquery del Pas 2
      from company
      where country="United Kingdom") as UKTable on transaction.company_id=UKTable.id;

-- Mostra el llistat aplicant solament subconsultes.
select transaction.id,company_name,country -- Unió de les dues taules sense fer servir JOIN, simplement combinant-les
from company,transaction
where (company.id=transaction.company_id) and (country="United Kingdom"); -- La primera condició és l'equivalent a l'ON d'una JOIN
