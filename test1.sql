-- SEQUENCE region_seq START WITH 1;

CREATE TABLE region(
id NUMBER /*DEFAULT region_seq.nextval  NOT NULL*/ PRIMARY KEY,
region_name VARCHAR2(256) 
);

CREATE SEQUENCE gorod_seq START WITH 1;

CREATE TABLE gorod(
id NUMBER DEFAULT gorod_seq.nextval  PRIMARY KEY,
city_name VARCHAR2(256),
region_id NUMBER NOT NULL,
naselenie NUMBER,
 CONSTRAINT fk_region
    FOREIGN KEY (region_id)
    REFERENCES region(id)
);


INSERT INTO region(id, region_name) VALUES(1, 'Чувашская Республика');
INSERT INTO region(id, region_name) VALUES(2, 'Республика Татарстан');
INSERT INTO region(id, region_name) VALUES(3, 'Республика Марий Эл');
INSERT INTO region(id, region_name) VALUES(4, 'Нижегородская область');

INSERT INTO gorod(city_name, region_id, naselenie)
VALUES('Чебоксары', 1, 400000);

INSERT INTO gorod(city_name, region_id, naselenie)
VALUES('Йошкар-Ола', 3, 300000);

INSERT INTO gorod(city_name, region_id, naselenie)
VALUES('Казань', 2, 1200000);

INSERT INTO gorod(city_name, region_id, naselenie)
VALUES('Нижний Новгород', 4, 1400000);

INSERT INTO gorod(city_name, region_id, naselenie)
VALUES('Канаш', 1, 58000);

INSERT INTO gorod(city_name, region_id)
VALUES('Новочебоксарск', 1);


SELECT * FROM gorod;

--1
select g.city_name, g.naselenie
from gorod g
join region r on g.region_id = r.id
where r.region_name = 'Чувашская Республика'
order by g.naselenie;

--2. Вывести кол-во городов, хранящихся в таблице gorod, для которых не указана численность населения
select count(*)
from gorod
where naselenie is null;

--3. Выбрать из таблицы gorod город с наибольшим кол-вом населения
--если нужно найти один любой с максимальной численностью
select *
from gorod
where naselenie is not null
order by naselenie desc
FETCH FIRST 1 ROWS ONLY;
--или если все
select *
from gorod g
where naselenie = (select max(naselenie) from gorod);

--4. Удалить из таблицы gorod города с населением меньше 400000
delete  gorod
where naselenie < 400000;

--5. Изменить поле naselenie в таблице gorod, выставив в нем для городов Чувашской Республики значение 200000
update gorod g
set naselenie = 200000
where exists (select 1 from region r where g.region_id = r.id and r.region_name = 'Чувашская Республика');

--6. Отобрать из таблицы gorod все города, начинающиеся на букву К
select *
from gorod
where city_name like 'К%';

--7. Написать запрос, позволяющий определить кол-во городов, которое хранится в таблице gorod для каждого региона, т.е. результат должен быть в виде: название соответствующего региона/кол-во городов, т.е. как на в таблице ниже:
select r.region_name, count(g.id) as count_gorod
from region  r
--если регионы без городов не нужны, то убрать left
left join gorod g on g.region_id = r.id 
group by r.region_name;