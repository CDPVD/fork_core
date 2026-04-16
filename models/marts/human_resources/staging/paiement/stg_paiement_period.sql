SELECT DISTINCT matr
                , no_cheq
                , no_per
                , date_fin_per
FROM {{ref("i_pai_hchq_per_paie")}}