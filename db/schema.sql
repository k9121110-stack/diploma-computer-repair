-- Компьютер жөндеу өтінімдері жүйесінің дерекқоры (SQLite)
PRAGMA foreign_keys = ON;

CREATE TABLE customers (
  id INTEGER PRIMARY KEY,
  full_name TEXT NOT NULL,
  phone TEXT NOT NULL UNIQUE CHECK (length(phone) BETWEEN 10 AND 20),
  email TEXT UNIQUE,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE technicians (
  id INTEGER PRIMARY KEY,
  full_name TEXT NOT NULL,
  phone TEXT NOT NULL UNIQUE,
  email TEXT UNIQUE,
  is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0,1))
);

CREATE TABLE statuses (
  id INTEGER PRIMARY KEY,
  code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL UNIQUE
);

CREATE TABLE devices (
  id INTEGER PRIMARY KEY,
  customer_id INTEGER NOT NULL REFERENCES customers(id),
  device_type TEXT NOT NULL,
  brand TEXT NOT NULL,
  model TEXT NOT NULL,
  serial_number TEXT UNIQUE,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE repair_requests (
  id INTEGER PRIMARY KEY,
  device_id INTEGER NOT NULL REFERENCES devices(id),
  technician_id INTEGER REFERENCES technicians(id),
  status_id INTEGER NOT NULL REFERENCES statuses(id),
  issue_description TEXT NOT NULL CHECK (length(trim(issue_description)) > 0),
  received_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  estimated_cost NUMERIC CHECK (estimated_cost IS NULL OR estimated_cost >= 0),
  completed_at TEXT
);

CREATE TABLE parts (
  id INTEGER PRIMARY KEY,
  sku TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  unit_price NUMERIC NOT NULL CHECK (unit_price >= 0),
  stock_quantity INTEGER NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0)
);

CREATE TABLE repair_parts (
  repair_request_id INTEGER NOT NULL REFERENCES repair_requests(id) ON DELETE CASCADE,
  part_id INTEGER NOT NULL REFERENCES parts(id),
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  unit_price NUMERIC NOT NULL CHECK (unit_price >= 0),
  PRIMARY KEY (repair_request_id, part_id)
);

CREATE TABLE status_history (
  id INTEGER PRIMARY KEY,
  repair_request_id INTEGER NOT NULL REFERENCES repair_requests(id) ON DELETE CASCADE,
  old_status_id INTEGER REFERENCES statuses(id),
  new_status_id INTEGER NOT NULL REFERENCES statuses(id),
  changed_by INTEGER REFERENCES technicians(id),
  changed_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  note TEXT
);

CREATE TABLE notifications (
  id INTEGER PRIMARY KEY,
  repair_request_id INTEGER NOT NULL REFERENCES repair_requests(id) ON DELETE CASCADE,
  recipient_customer_id INTEGER NOT NULL REFERENCES customers(id),
  channel TEXT NOT NULL CHECK (channel IN ('EMAIL','SMS')),
  message TEXT NOT NULL,
  sent_at TEXT,
  delivery_status TEXT NOT NULL CHECK (delivery_status IN ('QUEUED','SENT','FAILED'))
);

INSERT INTO customers (id,full_name,phone,email) VALUES
 (1,'Айдана Сәрсенова','+77010000001','aidana@example.kz'),
 (2,'Нұрлан Әлиев','+77010000002','nurlan@example.kz'),
 (3,'Дана Омарова','+77010000003','dana@example.kz'),
 (4,'Әлихан Мұрат','+77010000004','alikhan@example.kz'),
 (5,'Мадина Қасым','+77010000005','madina@example.kz');

INSERT INTO technicians (id,full_name,phone,email,is_active) VALUES
 (1,'Ержан Бек','+77020000001','yerzhan@example.kz',1),
 (2,'Самат Нұр','+77020000002','samat@example.kz',1),
 (3,'Арман Жол','+77020000003','arman@example.kz',1),
 (4,'Ләззат Ермек','+77020000004','lazzat@example.kz',1),
 (5,'Мирас Дәулет','+77020000005','miras@example.kz',0);

INSERT INTO statuses (id,code,name) VALUES
 (1,'NEW','Жаңа'),(2,'DIAGNOSIS','Диагностика'),(3,'REPAIR','Жөндеуде'),
 (4,'READY','Дайын'),(5,'COMPLETED','Аяқталды');

INSERT INTO devices (id,customer_id,device_type,brand,model,serial_number) VALUES
 (1,1,'Ноутбук','Lenovo','IdeaPad 5','SN-LEN-001'),
 (2,2,'Ноутбук','HP','Pavilion 15','SN-HP-002'),
 (3,3,'Компьютер','Dell','OptiPlex 7090','SN-DELL-003'),
 (4,4,'Ноутбук','ASUS','VivoBook 16','SN-ASUS-004'),
 (5,5,'Принтер','Canon','PIXMA G3411','SN-CAN-005');

INSERT INTO repair_requests (id,device_id,technician_id,status_id,issue_description,received_at,estimated_cost,completed_at) VALUES
 (1,1,1,2,'Қуат қосылмайды','2026-11-20 09:00:00',12000,NULL),
 (2,2,2,3,'Экранда жолақтар пайда болды','2026-11-21 10:30:00',18000,NULL),
 (3,3,3,4,'Желдеткіш қатты шу шығарады','2026-11-22 11:15:00',9000,NULL),
 (4,4,4,5,'Пернетақтадағы бірнеше батырма істемейді','2026-11-23 12:00:00',7000,'2026-11-25 16:00:00'),
 (5,5,1,1,'Қағазды тартпайды','2026-11-24 13:45:00',NULL,NULL);

INSERT INTO parts (id,sku,name,unit_price,stock_quantity) VALUES
 (1,'BAT-001','Ноутбук батареясы',18000,8),
 (2,'SSD-256','SSD 256 GB',14000,12),
 (3,'FAN-001','Салқындатқыш желдеткіш',6500,4),
 (4,'KEY-015','Пернетақта модулі',9000,7),
 (5,'ROL-003','Қағаз тарту ролигі',3500,2);

INSERT INTO repair_parts (repair_request_id,part_id,quantity,unit_price) VALUES
 (1,1,1,18000),(2,2,1,14000),(3,3,1,6500),(4,4,1,9000),(5,5,1,3500);

INSERT INTO status_history (id,repair_request_id,old_status_id,new_status_id,changed_by,changed_at,note) VALUES
 (1,1,NULL,1,1,'2026-11-20 09:00:00','Өтінім қабылданды'),
 (2,1,1,2,1,'2026-11-20 10:00:00','Диагностика басталды'),
 (3,2,NULL,1,2,'2026-11-21 10:30:00','Өтінім қабылданды'),
 (4,3,2,4,3,'2026-11-24 15:00:00','Құрылғы жөндеуден кейін дайын'),
 (5,4,4,5,4,'2026-11-25 16:00:00','Клиентке берілді');

INSERT INTO notifications (id,repair_request_id,recipient_customer_id,channel,message,sent_at,delivery_status) VALUES
 (1,1,1,'SMS','Өтінім FP-001 қабылданды','2026-11-20 09:01:00','SENT'),
 (2,2,2,'EMAIL','Өтінім FP-002 диагностикада','2026-11-21 12:00:00','SENT'),
 (3,3,3,'SMS','Құрылғыңызды алуға болады','2026-11-24 15:02:00','SENT'),
 (4,4,4,'EMAIL','Жөндеу аяқталды','2026-11-25 16:01:00','SENT'),
 (5,5,5,'SMS','Өтінім FP-005 тіркелді','2026-11-24 13:46:00','QUEUED');

