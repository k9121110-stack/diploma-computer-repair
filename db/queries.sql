-- Прецедент: Клиент өзінің жөндеу өтінімдерін телефон нөмірімен көреді.
SELECT rr.id, d.brand, d.model, s.name AS status, rr.received_at
FROM customers c JOIN devices d ON d.customer_id=c.id
JOIN repair_requests rr ON rr.device_id=d.id
JOIN statuses s ON s.id=rr.status_id
WHERE c.phone='+77010000001' ORDER BY rr.received_at DESC;

-- Прецедент: Шебер өзіне тағайындалған белсенді өтінімдерді қарайды.
SELECT rr.id, c.full_name, d.brand, d.model, s.name AS status
FROM repair_requests rr JOIN devices d ON d.id=rr.device_id
JOIN customers c ON c.id=d.customer_id
JOIN statuses s ON s.id=rr.status_id
JOIN technicians t ON t.id=rr.technician_id
WHERE t.id=1 AND s.code NOT IN ('COMPLETED');

-- Прецедент: Әкімші әр мәртебедегі өтінім санын есептейді (GROUP BY).
SELECT s.name AS status, COUNT(rr.id) AS request_count
FROM statuses s LEFT JOIN repair_requests rr ON rr.status_id=s.id
GROUP BY s.id,s.name ORDER BY request_count DESC,s.name;

-- Прецедент: Шебер өтінімге пайдаланылған қосалқы бөлшектердің құнын көреді (JOIN + GROUP BY).
SELECT rr.id, COALESCE(SUM(rp.quantity*rp.unit_price),0) AS parts_total
FROM repair_requests rr LEFT JOIN repair_parts rp ON rp.repair_request_id=rr.id
GROUP BY rr.id ORDER BY rr.id;

-- Прецедент: Шебер бір өтінімнің мәртебе өзгерістер тарихын қарайды.
SELECT h.changed_at, old_s.name AS previous_status, new_s.name AS current_status, h.note
FROM status_history h LEFT JOIN statuses old_s ON old_s.id=h.old_status_id
JOIN statuses new_s ON new_s.id=h.new_status_id
WHERE h.repair_request_id=1 ORDER BY h.changed_at;

-- Прецедент: Қойма қызметкері қоры аз бөлшектерді толықтыруға табады.
SELECT sku,name,stock_quantity FROM parts WHERE stock_quantity<5 ORDER BY stock_quantity;

