SELECT a.pixi_id, a.title, concat(b.first_name, ' ', b.last_name) as buyer, a.seller_id, a.start_date, a.end_date, c.name as category_name,
d.name as site_name, a.site_id, a.status, a.description, w.user_id, w.created_at as want_date
FROM `pxb_production`.`listings` a,
`pxb_production`.`users` b, `pxb_production`.`categories` c, `pxb_production`.`sites` d, 
`pxb_production`.`pixi_wants` w
WHERE a.category_id = c.id
and a.site_id = d.id
and a.pixi_id = w.pixi_id
and w.user_id = b.id
and a.seller_id = 210
and a.status = 'active'
and a.end_date > curdate();