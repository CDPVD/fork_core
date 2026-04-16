WITH SOMME_PERIOD as (
SELECT annee
        , lieu_jumele
        , descr_cat_code_pmnt
        , paiement_period
        , corp_empl
        , SUM(total_mnt_brut) as mnt_total
        , SUM(hrs_remunere) as hres_total
FROM {{ref("aff_fact_paiements")}}
GROUP BY annee, paiement_period, lieu_jumele, descr_cat_code_pmnt, corp_empl
),

PERIODS as (
SELECT DISTINCT annee
                , paiement_period
FROM SOMME_PERIOD
),

CUMULATIF as (
SELECT per.*
        , lieu_jumele
        , descr_cat_code_pmnt
        , sPer.paiement_period as per_in_cummul
        , corp_empl
        , mnt_total
        , hres_total
FROM PERIODS per
LEFT JOIN SOMME_PERIOD sPer ON per.annee = sPer.annee AND per.paiement_period >= sPer.paiement_period
)

SELECT * FROM CUMULATIF
WHERE lieu_jumele IS NOT NULL