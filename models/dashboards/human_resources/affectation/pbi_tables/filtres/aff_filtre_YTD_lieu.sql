SELECT DISTINCT lieu_comp.lieu_jumele
                , ISNULL(categorie_lieu_jumele, 'CSS') as categorie_lieu_jumele
                , ISNULL(nom_lieu_jumele, 'CSS') as nom_lieu_jumele
FROM {{ref("aff_report_YTD_comp")}} lieu_comp 
LEFT JOIN {{ref("aff_filtre_lieu_jumele")}} lieu ON lieu_comp.lieu_jumele = lieu.lieu_jumele
WHERE lieu_comp.lieu_jumele IS NOT NULL