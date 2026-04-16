WITH HISTORIQUE as (
    SELECT *
    FROM {{ref("stg_paiement_history")}}
    WHERE ANNEE >= {{get_current_year()}} - 4
),

INFO_SUPPL as (
    SELECT hist.*
            , nom_lieu_jumele
            , categorie_lieu_jumele
            , corp.descr as descr_corp_empl
            , ccp.categorie_code
            , ccp.categorie_descr as descr_cat_code_pmnt
    FROM HISTORIQUE hist
    LEFT JOIN {{ref("dim_mapper_lieu_jumele")}} cat on hist.lieu_jumele = cat.lieu_jumele
    LEFT JOIN {{ref("i_pai_tab_corp_empl")}} corp ON hist.corp_empl = corp.corp_empl
    LEFT JOIN {{ref("aff_dim_categorie_code_paiements")}} ccp on hist.code_pmnt = ccp.code_pmnt

)

SELECT * FROM INFO_SUPPL
WHERE lieu_jumele IS NOT NULL