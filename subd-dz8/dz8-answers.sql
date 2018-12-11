--скрипт для тестирования триггера reservation_BEFORE_INSERT
-- для комнаты id=1 новый резерв не конфликтует с существующими резервами, успешная операция вставки;
-- повторная вставка этого резерва будет неуспешная
insert into booking.reservation(room_id, client_id, start_date, end_date, adults_count, children_count, price, paid)
values 
	(1, 3, '2018-05-13', '2018-05-14', 2, 0, 36000, true)
;


--скрипт для тестирования триггера reservation_BEFORE_INSERT
-- для комнаты id=1 новый резерв конфликтует с существующими резервами, неуспешная операция вставки
insert into booking.reservation(room_id, client_id, start_date, end_date, adults_count, children_count, price, paid)
values 
	(1, 3, '2018-05-05', '2018-05-12', 2, 0, 36000, true)
;