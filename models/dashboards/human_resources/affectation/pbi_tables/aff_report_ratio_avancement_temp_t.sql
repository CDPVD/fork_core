WITH SOURCE as (
    SELECT  annee
        , mnt_total
        , hres_total
        , paiement_period
        , lieu_jumele
        , categorie
    FROM {{ref("aff_report_cumulatif_par_period")}} pai
    left join {{ref("aff_dim_categorie_emploi")}} cat on pai.corp_empl = cat.corp_empl
    WHERE categorie is not null AND lieu_jumele is not null
),

TOTAUX as (
SELECT  annee
    , paiement_period
    , sum(mnt_total) as mnt_total
    , sum(hres_total) as hres_total
    , ISNULL(lieu_jumele, 'CSS') as lieu_jumele
    , ISNULL(categorie, 'TOUS') as categorie
  FROM SOURCE
  group by annee, paiement_period, CUBE( lieu_jumele, categorie)
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
            , ant.hres_total as hrs_total_ant
            , CASE
                WHEN ant.mnt_total IS NULL OR ant.mnt_total = 0 THEN NULL
                ELSE tac.mnt_total / ant.mnt_total
              END as ratio_avancement_mnt
            , CASE
                WHEN ant.hres_total IS NULL OR ant.hres_total = 0 THEN NULL
                ELSE tac.hres_total / ant.hres_total
              END as ratio_avancement_hrs
            , CASE
                WHEN tac.hres_total IS NULL OR tac.hres_total = 0 THEN NULL
                ELSE tac.mnt_total / tac.hres_total
              END as montant_hres_courant
            , CASE
                WHEN ant.hres_total IS NULL OR ant.hres_total = 0 THEN NULL
                ELSE ant.mnt_total / ant.hres_total
              END as montant_hres_ant
    FROM TOTAUX_ANNEE_COURANTE tac
    LEFT JOIN TOTAUX_ANTERIEUR ant ON tac.lieu_jumele = ant.lieu_jumele AND tac.categorie = ant.categorie AND tac.paiement_period = ant.paiement_period
),

PERIODE_COURANTE as (
    SELECT MAX(paiement_period) as per_courante
    FROM TOTAUX_ANNEE_COURANTE
),

AVANCEMENT_COUTS_HORAIRE as (
    SELECT *
            , CASE
                WHEN montant_hres_ant IS NULL OR montant_hres_ant = 0 THEN NULL
                ELSE montant_hres_courant / montant_hres_ant
              END as ratio_montant_hres
            , IIF(paiement_period = (SELECT per_courante FROM PERIODE_COURANTE),1,0) as IND_PERIODE_COURANTE
    FROM AVANCEMENT
)

SELECT * FROM AVANCEMENT_COUTS_HORAIRE