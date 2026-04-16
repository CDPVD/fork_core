WITH STATS_POP as (
    SELECT  Annee
            , eco
            , COUNT(FICHE) as NB_ELE
            , SUM(IIF(population IN ('Primaire régulier','Secondaire régulier'), 1, 0)) as NB_ELE_REG
            , SUM(IIF(population IN ('Primaire adapté','Secondaire adapté'), 1, 0)) as NB_ELE_ADAPT
            , SUM(IIF(population = 'Prescolaire', 1, 0)) as NB_ELE_PRE_SCO
            , SUM(IIF(plan_interv_ehdaa = 'Avec', 1, 0)) as NB_ELE_PI
            , COUNT(DISTINCT grp_rep) as nb_grp_scolaire
            , COUNT(DISTINCT IIF(grp_rep LIKE '8%' OR grp_rep LIKE '9%', grp_rep, NULL)) as nb_grp_adapt
            , COUNT(difficulte) as nb_ele_difficulte
    FROM {{ref("fact_yearly_student")}}
    GROUP BY annee, eco
),

STATS_POP_ET_RATIO as (
    SELECT STATS_POP.*
            , CONVERT(float, NB_ELE_ADAPT) / NB_ELE as ratio_ele_adapt
            , CONVERT(float, NB_ELE_PRE_SCO) / NB_ELE as ratio_ele_presco
            , CONVERT(float, NB_ELE_PI) / NB_ELE as ratio_ele_pi
            , CONVERT(float, nb_ele_difficulte) / NB_ELE as ratio_ele_difficulte
            , CONVERT(float, nb_grp_adapt) / nb_grp_scolaire as ratio_grp_adapt
            , COALESCE(lieu_jumele, eco) as lieu_jumele
    FROM STATS_POP
    LEFT JOIN {{ref("eff_mapping_fgj_paie")}} ON eco = ecole_gpi
)

SELECT * FROM STATS_POP_ET_RATIO
