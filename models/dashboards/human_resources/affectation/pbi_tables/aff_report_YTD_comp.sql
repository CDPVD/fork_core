WITH SOURCE as (
    SELECT annee
        , paiement_period
        , sum(total_mnt_brut) as mnt_total
        , sum(hrs_remunere) as hrs_total
        , ISNULL(lieu_jumele, 'CSS') as lieu_jumele
        , ISNULL(categorie, 'TOUS') as categorie
    FROM {{ref("aff_fact_paiements")}} pai
    left join {{ref("aff_dim_categorie_emploi")}} cat on pai.corp_empl = cat.corp_empl
    GROUP BY annee, paiement_period, CUBE(lieu_jumele, categorie)
),

OTHER_YEARS as (
    SELECT *
            , annee as annee_comp
    FROM SOURCE
    WHERE annee < {{get_current_year()}}
),

COMP_YEARS as (
    SELECT DISTINCT annee_comp
    FROM OTHER_YEARS
),

YTD_CURRENT_YEAR as (
    SELECT *
    FROM SOURCE cur
    WHERE cur.annee = {{get_current_year()}}
),

CURRENT_YEAR_COMP as (
    SELECT cur.*
            , annee_comp
    FROM YTD_CURRENT_YEAR cur
    CROSS JOIN COMP_YEARS
),

UNION_YEARS as (
    SELECT * FROM OTHER_YEARS
    UNION ALL
    SELECT * FROM CURRENT_YEAR_COMP
)

SELECT * FROM UNION_YEARS