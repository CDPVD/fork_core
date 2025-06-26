

with perim as (
	select 
        fr.fiche
		, fr.id_eco
		, annee
        , anciennete
    from {{ ref("resfr_fact_eleve_francisation") }} as fr
    inner join {{ ref("dim_mapper_schools") }} as map_sch
        on fr.id_eco = map_sch.id_eco
    where annee = {{ core_dashboards_store.get_current_year() }} 

), res as (
    select 
		perim.fiche
		, perim.id_eco
		, res.annee
        , res.code_matiere
		, res.no_comp
		, res.etape
        , res.res_comp_etape
		, resb.res_comp
    from perim 
	left join {{ ref("fact_resultat_etape_competence") }} as res
		on res.fiche = perim.fiche 
		and res.annee
			between {{ core_dashboards_store.get_current_year() - 4 }}
			and {{ core_dashboards_store.get_current_year() }}
	left join {{ ref("fact_resultat_bilan_competence") }} as resb
		on res.fiche = resb.fiche 
		and res.id_eco = resb.id_eco
		and res.code_matiere = resb.code_matiere 
		and res.no_comp = resb.no_comp
		and res.groupe_matiere = resb.groupe_matiere 		
	inner join {{ ref("resfr_dim_matieres_prim") }} as mat
		on res.code_matiere = mat.code_matiere 
	where 
		res.etat != 0
        and etape in ('1', '2', '3')
		and res.no_comp = FLOOR(res.no_comp)
		and ISNUMERIC(res.groupe_matiere) = 1		
), pivot_tab as(
	select 
		fiche
		,id_eco
		,annee
		,code_matiere
		,no_comp
		,res_comp
		,MAX(res_etape_1) as res_etape_1
		,MAX(res_etape_2) as res_etape_2			
		,MAX(res_etape_3) as res_etape_3
	from
	(
		select 
			fiche
			,id_eco
			,annee
			,code_matiere
			,no_comp
			,res_comp
			,case when etape = 1 then res_comp_etape end as res_etape_1
			,case when etape = 2 then res_comp_etape end as res_etape_2			
			,case when etape = 3 then res_comp_etape end as res_etape_3
		from res
		) as src_table
	group by 
		fiche
		,id_eco
		,annee
		,code_matiere
		,no_comp
		,res_comp

), res_y as(
	select 
		fiche
		,id_eco
		,annee
		,null as code_matiere
		,null as no_comp
		,null as res_comp
		,null as res_etape_1
		,null as res_etape_2			
		,null as res_etape_3
	from perim
	where annee = {{ core_dashboards_store.get_current_year() }}

),merg as (
        select *
        from pivot_tab
        union
        select *
        from res_y
), surrkey as (
	select 
		{{
			dbt_utils.generate_surrogate_key(
				[
					"fiche",
					"id_eco",
					"annee",
					"code_matiere",
					"no_comp",
				]
			)
		}} as primary_key,
		*	
	from merg
)
    
{# select
	perim.fiche
	, el_y.annee
	, el_y.eco		
	, el.nom_prenom_fiche
	, el_y.age_30_sept
	, el_y.niveau_scolaire
	, el_y.plan_interv_ehdaa
	, hist.type_mesure
	, perim.anciennete
	, hist.type_mesure_lag1
	, hist.type_mesure_lag2
	, pt.code_matiere
	, mat.description_abreg as matiere
	, pt.no_comp
	, comp.description_abreg as competence
	, pt.res_comp
	, res_etape_1
	, res_etape_2			
	, res_etape_3	
from perim 
inner join
    {{ ref("fact_yearly_student") }} as el_y
    on perim.fiche = el_y.fiche
    and perim.id_eco = el_y.id_eco
inner join
    {{ ref("dim_eleve") }} as el
    on perim.fiche = el.fiche
left join hist 
	on hist.fiche = perim.fiche and hist.id_eco = perim.id_eco
left join pivot_tab as pt
	on pt.fiche = perim.fiche and pt.id_eco = perim.id_eco
left join {{ ref("stg_descr_mat") }} as mat
	on mat.id_eco = pt.id_eco and mat.mat = pt.code_matiere
left join {{ ref("stg_descr_comp") }} as comp
	on comp.mat = pt.code_matiere and cast(comp.obj_01 as varchar) = cast(pt.no_comp as varchar) #} 
select 
	*
from surrkey 