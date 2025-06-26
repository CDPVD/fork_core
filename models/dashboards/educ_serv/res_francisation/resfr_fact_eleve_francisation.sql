{# {{
    config(
        post_hook=[
            core_dashboards_store.create_clustered_index(
                "{{ this }}", ["id_eco", "fiche"], unique=True
            ),
        ]
    )
}} #}

with spi as (
    select 
        fiche
        , id_eco
    from {{ ref('spine') }}
    where seqid = 1
),
franci as (
    select
        spi.fiche,
        spi.id_eco,
        mes.type_mesure,
        des_mes.cf_descr_abreg as description_type_mesure, 
        mes.date_deb_mesure, 
        mes.date_fin_mesure,
        row_number() over (partition by spi.fiche order by spi.id_eco) as anciennete
    from spi 
    inner join {{ ref("i_gpm_e_mesures") }} as mes
		on mes.fiche = spi.fiche AND mes.id_eco = spi.id_eco    
    inner join {{ ref("i_wl_descr") }} as des_mes
        on des_mes.code = mes.type_mesure
        and nom_table = 'type_mesure'
    where type_mesure in ('11', '22', '23', '32', '33', '34')
)
select 
    fiche, 
    id_eco,  
    type_mesure, 
    description_type_mesure, 
    date_deb_mesure, 
    date_fin_mesure,
    anciennete
from franci