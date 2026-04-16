WITH BRUTE_REMU_AVEC_JRS_EQUIV as (
SELECT pai.*
    , pai.hrs_remunere / hrs.nb_hres_jrs as equiv_jours
    , categorie as categorie_empl
FROM {{ref("aff_fact_paiements")}} pai
LEFT JOIN {{ref("stg_hrs_calc")}} hrs ON pai.corp_empl = hrs.corp_empl AND pai.stat_eng = hrs.stat_eng
LEFT JOIN {{ref("aff_dim_categorie_emploi")}} cate ON pai.corp_empl = cate.corp_empl
),

AGG as (
SELECT annee
    , categorie_empl
    , SUM(total_mnt_brut) as total_mnt_brut
    , SUM(hrs_remunere) as hrs_remunere
    , SUM(equiv_jours) as jours_remunere_period
    , lieu_jumele
    , nom_lieu_jumele
    , paiement_period
FROM BRUTE_REMU_AVEC_JRS_EQUIV
GROUP BY annee, categorie_empl, lieu_jumele, nom_lieu_jumele, paiement_period
),

NORMALISATION_PAR_JOUR as (
SELECT AGG.*
        , jours_remunere_period / NB_JOURS_PER AS EQUIV_PERSONNE_JOURS
FROM AGG 
LEFT JOIN dashboard_affectation.aff_fact_duree_period_pmnt ON paiement_period = NO_PER AND annee = PER_YEAR
)

SELECT * FROM NORMALISATION_PAR_JOUR