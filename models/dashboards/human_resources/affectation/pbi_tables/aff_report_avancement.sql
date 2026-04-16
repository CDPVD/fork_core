WITH SOURCE as (
    SELECT  annee
        , total_mnt_brut as mnt_total
        , hrs_remunere as hrs_total
        , lieu_jumele
        , categorie
  FROM {{ref("aff_fact_paiements")}} pai
  left join {{ref("aff_dim_categorie_emploi")}} cat on pai.corp_empl = cat.corp_empl
  WHERE categorie is not null AND lieu_jumele is not null
),

TOTAUX as (
SELECT  annee
      , sum(mnt_total) as mnt_total
      , sum(hrs_total) as hrs_total
      , ISNULL(lieu_jumele, 'CSS') as lieu_jumele
      , ISNULL(categorie, 'TOUS') as categorie
  FROM SOURCE
  group by annee, CUBE( lieu_jumele, categorie)
),

TOTAUX_ANNEE_COURANTE as (
    SELECT *
    FROM TOTAUX
    WHERE annee = {{get_current_year()}}
),

TOTAUX_ANTERIEUR as (
    SELECT *
    FROM TOTAUX
    WHERE annee != {{get_current_year()}}
),

AVANCEMENT as (
    SELECT tac.*
            , ant.annee as annee_ant
            , ant.mnt_total as mnt_total_ant
            , ant.hrs_total as hrs_total_ant
            , CASE
                WHEN ant.mnt_total IS NULL OR ant.mnt_total = 0 THEN NULL
                ELSE tac.mnt_total / ant.mnt_total
              END as ratio_avancement_mnt
            , CASE
                WHEN ant.hrs_total IS NULL OR ant.hrs_total = 0 THEN NULL
                ELSE tac.hrs_total / ant.hrs_total
              END as ratio_avancement_hrs
    FROM TOTAUX_ANNEE_COURANTE tac
    LEFT JOIN TOTAUX_ANTERIEUR ant ON tac.lieu_jumele = ant.lieu_jumele AND tac.categorie = ant.categorie
)

SELECT * FROM AVANCEMENT