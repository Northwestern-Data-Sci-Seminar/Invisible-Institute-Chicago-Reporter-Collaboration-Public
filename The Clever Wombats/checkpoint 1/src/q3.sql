select o.id, o.allegation_count, oh1.num_trans, o.*
from data_officer o
join (
    select officer_id, count(*) as num_trans
    from data_officerhistory
    group by  officer_id
    ) oh1
on oh1.officer_id = o.id
order by num_trans desc;