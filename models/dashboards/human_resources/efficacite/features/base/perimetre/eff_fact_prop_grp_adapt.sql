{#
Dashboards Store - Helping students, one dashboard at a time.
Copyright (C) 2023  Sciance Inc.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
#}
with
    source as (
        select
            y_stud.fiche,
            y_stud.annee,
            coalesce(brdg.lieu_jumele, 'Lieu jumelé non configuré') as lieu_jumele,
            grp_rep
        from {{ ref("fact_yearly_student") }} y_stud
        join {{ ref("i_gpm_t_eco") }} as eco on y_stud.id_eco = eco.id_eco
        join {{ ref("eff_mapping_fgj_paie") }} as brdg on eco.eco = brdg.ecole_gpi
        join
            {{ ref("eff_reporting_configuration") }} as config
            on brdg.lieu_jumele = config.lieu_jumele
            and config.is_school_comparable = 1
        where
            y_stud.annee
            between {{ core_dashboards_store.get_current_year() - 4 }}
            and {{ core_dashboards_store.get_current_year() - 1 }}
    ),

    agg_class_adapt as (
        select annee
		    , lieu_jumele
		    , COUNT(DISTINCT IIF(grp_rep like '8%' OR grp_rep like '9%',grp_rep, null)) as nb_grp_adapt
		    , COUNT(DISTINCT grp_rep) as nb_grp
		from source
		group by annee, lieu_jumele
    ),

    prop_class_adapt as (
        select 
            lieu_jumele
            , annee
            , CONVERT(float, nb_grp_adapt)/nb_grp as prop_classes_adapt
        from agg_class_adapt
    )


    select
        annee,
        lieu_jumele,
        prop_classes_adapt
    from prop_class_adapt
