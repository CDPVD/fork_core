SELECT DISTINCT lieu_jumele, categorie_lieu_jumele, nom_lieu_jumele FROM {{ref("aff_fact_paiements")}}
WHERE lieu_jumele IS NOT NULL