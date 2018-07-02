select record_date, offer_id, offer_year, season_id, version_no, offer_product_id, category_id, sub_category_id,
offer_product_desc
from dt_cm_results

where offer_product_id = '641864'

order by offer_year, offer_id, version_no