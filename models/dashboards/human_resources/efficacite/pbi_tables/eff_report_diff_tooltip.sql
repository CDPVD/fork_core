with info_pi as (
    select
        lieu_jumele
        , annee
        , count(fiche) as nb_totaux_eleve
        , sum(is_pi) as nb_pi
    from {{ ref("eff_fact_eleve_fgj") }}
    group by lieu_jumele, annee
),

prop_pi as (
    select
        lieu_jumele
        , annee
        , (nb_pi * 1.0) / (nb_totaux_eleve * 1.0) as prop_pi
    from info_pi
),

prop_classes_adapt as (
    select annee
        , lieu_jumele
        , prop_classes_adapt
    from {{ref("eff_fact_prop_grp_adapt")}}
),

diff_tooltip_info as (
    select {{ dbt_utils.generate_surrogate_key(["pi.annee", "pi.lieu_jumele"]) }}
            as filter_key
            , pi.annee
            , pi.lieu_jumele
            , prop_pi
            , prop_classes_adapt
    from prop_pi pi
    left join prop_classes_adapt ada ON pi.annee = ada.annee AND pi.lieu_jumele = ada.lieu_jumele
)

select * from diff_tooltip_info
