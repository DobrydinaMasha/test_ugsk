CREATE TABLE SUBJECT(
EMPLISN NUMBER NOT NULL PRIMARY KEY,
EMPLNAME VARCHAR2(25),
PREMIUM NUMBER(10,2),
SHAREPRC NUMBER(4,2),
DEPTISN NUMBER
);

--DROP TABLE SUBJECT;

COMMENT ON COLUMN SUBJECT.EMPLISN IS 'Уникальный идентификатор сотрудника/агента';
COMMENT ON COLUMN SUBJECT.EMPLNAME IS 'ФИО сотрудника/агента';
COMMENT ON COLUMN SUBJECT.PREMIUM IS 'Премия по полисам  сотрудника/агента';
COMMENT ON COLUMN SUBJECT.SHAREPRC IS 'Процент комиссии агента. Удерживается из премии по полису.';
COMMENT ON COLUMN SUBJECT.DEPTISN IS 'Идентификатор филиала к которому относится сотрудник/агент';

--truncate table SUBJECT;
INSERT INTO SUBJECT(EMPLISN, EMPLNAME, PREMIUM, SHAREPRC, DEPTISN)
VALUES(1, 'Иванов И.И.', 100.98, 10.9, 1);
INSERT INTO SUBJECT(EMPLISN, EMPLNAME, PREMIUM, SHAREPRC, DEPTISN)
VALUES(2, 'Петров И.И.', 1000.08, 20.9, 1);
INSERT INTO SUBJECT(EMPLISN, EMPLNAME, PREMIUM, SHAREPRC, DEPTISN)
VALUES(3, 'Козлов И.И.', 20000, 60.9, 2);
INSERT INTO SUBJECT(EMPLISN, EMPLNAME, PREMIUM, SHAREPRC, DEPTISN)
VALUES(4, 'Сидоров И.И.', 100000.1, 80.9, 5);
INSERT INTO SUBJECT(EMPLISN, EMPLNAME, PREMIUM, SHAREPRC, DEPTISN)
VALUES(5, 'Безкомиссный', 100000.1, null, 5);
INSERT INTO SUBJECT(EMPLISN, EMPLNAME, PREMIUM, SHAREPRC, DEPTISN)
VALUES(6, 'Безпремий', null, 80.9, 5);
INSERT INTO SUBJECT(EMPLISN, EMPLNAME, PREMIUM, SHAREPRC, DEPTISN)
VALUES(7, 'Безфилиала', 50000, 70, null);

---1.Напишите запрос, который выведет сумму комиссии по каждому сотруднику/агенту (премия * (процент комиссии / 100)), а также вычисляемое поле «Comment». Если для сотрудника/агента процент комиссии больше 50, то в поле “Comment” должно выводиться «Повышенное вознаграждение», иначе «Стандартное вознаграждение».
SELECT
emplisn,
emplname,
nvl(premium * shareprc / 100, 0) as sum_commission,
CASE WHEN nvl(shareprc,0) >50 THEN 'Повышенное вознаграждение'  -- нужен nvl?
    ELSE 'Стандартное вознаграждение' END  as "Comment"
FROM SUBJECT;

---2  Создайте функцию, которая возвращает сумму премии по полисам сотрудника по его идентификатору. Напишите запрос, который выведет всех сотрудников и сумму премии по их полисам, используя созданную функцию.
CREATE OR REPLACE FUNCTION get_premium_subject(EMPLISN_IN NUMBER)
   RETURN NUMBER
   IS PREMIUM_OUT NUMBER(10,2);
   BEGIN
      SELECT PREMIUM
      INTO PREMIUM_OUT
      FROM SUBJECT
      WHERE EMPLISN = EMPLISN_IN;
      RETURN(PREMIUM_OUT);
    END;
/

SELECT
emplisn,
emplname,
get_premium_subject(emplisn) as premium
from SUBJECT;

---3 Создайте процедуру, в которой в цикле (LOOP) всем сотрудникам устанавливается размер комиссии равный 0,5 (50%).
CREATE OR REPLACE PROCEDURE shareprc_to_fifty_percent AS
   BEGIN
     FOR cur IN (SELECT emplisn
                   FROM SUBJECT)
       LOOP
          UPDATE SUBJECT
             SET shareprc = 50
           WHERE emplisn = cur.emplisn;
       END LOOP;
   END;
/

execute shareprc_to_fifty_percent();

--4 Создайте триггер для таблицы SUBJECT, который срабатывает при добавлении или изменении записи в таблице и выводит сообщение об ошибке «Комиссия не может быть меньше нуля!» в случае, если значение поля SHAREPRC в добавляемой/изменяемой строке меньше 0.
CREATE OR REPLACE TRIGGER  SUBJECT_BEFORE_UPDATE
BEFORE INSERT OR UPDATE ON SUBJECT
FOR EACH ROW
BEGIN
   IF (:new.shareprc<0) then
       RAISE_APPLICATION_ERROR( -20001, 'Комиссия не может быть меньше нуля!' );
   END IF;
END;

INSERT INTO SUBJECT(EMPLISN, EMPLNAME, PREMIUM, SHAREPRC, DEPTISN)
VALUES(8, 'Иванов', 50000, -70, null);

INSERT INTO SUBJECT(EMPLISN, EMPLNAME, PREMIUM, SHAREPRC, DEPTISN)
VALUES(8, 'Иванов', 50000, null, null);

INSERT INTO SUBJECT(EMPLISN, EMPLNAME, PREMIUM, SHAREPRC, DEPTISN)
VALUES(9, 'Иванов 2', 50000, 70, null);

--5 В базу добавлена еще одна таблица по филиалам (DEPTS). Таблица связана с таблицей SUBJECT по графе DEPTISN. Напишите запрос, который выведет наибольший размер комиссии для каждого филиала.
CREATE TABLE DEPTS(
DEPTISN NUMBER NOT NULL PRIMARY KEY,
DEPTNAME VARCHAR2(25)
);

COMMENT ON COLUMN DEPTS.DEPTISN IS 'Уникальный идентификатор филиала';
COMMENT ON COLUMN DEPTS.DEPTNAME IS 'Наименование филиала';

INSERT INTO DEPTS(DEPTISN, DEPTNAME)
VALUES(1, 'Филиал 1');
INSERT INTO DEPTS(DEPTISN, DEPTNAME)
VALUES(2, 'Филиал 2');
INSERT INTO DEPTS(DEPTISN, DEPTNAME)
VALUES(3, 'Филиал 3');
INSERT INTO DEPTS(DEPTISN, DEPTNAME)
VALUES(4, 'Филиал 4');
INSERT INTO DEPTS(DEPTISN, DEPTNAME)
VALUES(5, 'Филиал 5');

--6 Напишите запрос, который выведет два столбца. В первом столбце выводится название филиала, во второй столбец – все сотрудники филиала через запятую.
select d.DEPTNAME,
       LISTAGG( s.emplname, ',') WITHIN GROUP (ORDER BY  d.DEPTNAME) as emplnames
from DEPTS d
left join SUBJECT s on d.deptisn = s.deptisn
group by d.DEPTNAME;

--7 В базу добавлена еще одна таблица по продуктам (PRODUCTS). В таблице хранится древовидная структура продуктов компании.
--drop table PRODUCTS;

CREATE TABLE PRODUCTS(
PRODISN NUMBER NOT NULL PRIMARY KEY,
PRODNAME VARCHAR2(25),
PARENTPROD NUMBER
--,CONSTRAINT FK_PARENTPROD
--    FOREIGN KEY (PARENTPROD)
--   REFERENCES PRODUCTS(PRODISN)
);

COMMENT ON COLUMN PRODUCTS.PRODISN IS 'Уникальный идентификатор продукта';
COMMENT ON COLUMN PRODUCTS.PRODNAME IS 'Наименование продукта';
COMMENT ON COLUMN PRODUCTS.PARENTPROD IS 'Ссылка на родительский продукт';

INSERT INTO PRODUCTS(PRODISN, PRODNAME, PARENTPROD)
VALUES(1, 'АВТО', 0);
INSERT INTO PRODUCTS(PRODISN, PRODNAME, PARENTPROD)
VALUES(11, 'КАСКО', 1);
INSERT INTO PRODUCTS(PRODISN, PRODNAME, PARENTPROD)
VALUES(12, 'ОСАГО', 1);
INSERT INTO PRODUCTS(PRODISN, PRODNAME, PARENTPROD)
VALUES(13, 'ДГО', 1);
INSERT INTO PRODUCTS(PRODISN, PRODNAME, PARENTPROD)
VALUES(2, 'ИМУЩЕСТВО', 0);
INSERT INTO PRODUCTS(PRODISN, PRODNAME, PARENTPROD)
VALUES(21, 'ЖИЛЬЕ', 2);
INSERT INTO PRODUCTS(PRODISN, PRODNAME, PARENTPROD)
VALUES(221, 'КВАРТИРА', 21);
INSERT INTO PRODUCTS(PRODISN, PRODNAME, PARENTPROD)
VALUES(222, 'ТАУНХАУС', 21);

SELECT level, p.*
FROM products p
START WITH PRODNAME = 'ЖИЛЬЕ'
CONNECT BY PRIOR PRODISN = PARENTPROD;

select
xmlelement("ROW",xmlforest(PRODISN, PRODNAME, PARENTPROD)) xml_products
from products;

--если нужно сгруппировать
select 
xmlagg(
xmlelement("ROW",xmlforest(PRODISN, PRODNAME, PARENTPROD))
).getClobVal() xml_products
from products;