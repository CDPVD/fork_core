WITH CODE_PAIEMENTS as (
    SELECT DISTINCT code_pmnt
    FROM {{ref("stg_paiement_history")}}
),

CATEGORIE as (
    SELECT *
            , LEN(categorie_code) as match_priority
    FROM {{ref("aff_categories_code_paiement")}}
),

MATCHING as (
    SELECT code_pmnt
			, ISNULL(categorie_code, LEFT(code_pmnt,3)) as categorie_code
			, ISNULL(categorie_descr, 'Non catégorisé') as categorie_descr
			, ISNULL(match_priority, 0) as match_priority
    FROM CODE_PAIEMENTS cp
    LEFT JOIN CATEGORIE ON code_pmnt Like (CONCAT(categorie_code, '%'))
),

PRIORITY_MATCHING as (
	SELECT code_pmnt as matched_code
			, MAX(match_priority) as max_match
	FROM MATCHING
	GROUP BY code_pmnt
),

CODE_PMNT_CATEGORISE as (
	SELECT code_pmnt
			, categorie_code
			, categorie_descr
	FROM MATCHING 
	INNER JOIN PRIORITY_MATCHING ON code_pmnt = matched_code AND match_priority = max_match
)


SELECT * FROM CODE_PMNT_CATEGORISE