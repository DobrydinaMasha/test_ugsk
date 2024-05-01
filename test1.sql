-- SEQUENCE region_seq START WITH 1;

CREATE TABLE REGION
(
    ID          NUMBER /*DEFAULT region_seq.nextval  NOT NULL*/ PRIMARY KEY,
    REGION_NAME VARCHAR2(256)
);

CREATE SEQUENCE GOROD_SEQ START WITH 1;

CREATE TABLE GOROD
(
    ID        NUMBER DEFAULT GOROD_SEQ.NEXTVAL PRIMARY KEY,
    CITY_NAME VARCHAR2(256),
    REGION_ID NUMBER NOT NULL,
    NASELENIE NUMBER,
    CONSTRAINT FK_REGION
        FOREIGN KEY (REGION_ID)
            REFERENCES REGION (ID)
);


INSERT INTO REGION(ID, REGION_NAME)
VALUES (1, 'Чувашская Республика');
INSERT INTO REGION(ID, REGION_NAME)
VALUES (2, 'Республика Татарстан');
INSERT INTO REGION(ID, REGION_NAME)
VALUES (3, 'Республика Марий Эл');
INSERT INTO REGION(ID, REGION_NAME)
VALUES (4, 'Нижегородская область');

INSERT INTO GOROD(CITY_NAME, REGION_ID, NASELENIE)
VALUES ('Чебоксары', 1, 400000);

INSERT INTO GOROD(CITY_NAME, REGION_ID, NASELENIE)
VALUES ('Йошкар-Ола', 3, 300000);

INSERT INTO GOROD(CITY_NAME, REGION_ID, NASELENIE)
VALUES ('Казань', 2, 1200000);

INSERT INTO GOROD(CITY_NAME, REGION_ID, NASELENIE)
VALUES ('Нижний Новгород', 4, 1400000);

INSERT INTO GOROD(CITY_NAME, REGION_ID, NASELENIE)
VALUES ('Канаш', 1, 58000);

INSERT INTO GOROD(CITY_NAME, REGION_ID)
VALUES ('Новочебоксарск', 1);


SELECT *
FROM GOROD;

--1
SELECT G.CITY_NAME, G.NASELENIE
FROM GOROD G
         JOIN REGION R ON G.REGION_ID = R.ID
WHERE R.REGION_NAME = 'Чувашская Республика'
ORDER BY G.NASELENIE;

--2. Вывести кол-во городов, хранящихся в таблице gorod, для которых не указана численность населения
SELECT COUNT(*)
FROM GOROD
WHERE NASELENIE IS NULL;

--3. Выбрать из таблицы gorod город с наибольшим кол-вом населения
--если нужно найти один любой с максимальной численностью
SELECT *
FROM GOROD
WHERE NASELENIE IS NOT NULL
ORDER BY NASELENIE DESC
    FETCH FIRST 1 ROWS ONLY;
--или если все
SELECT *
FROM GOROD G
WHERE NASELENIE = (SELECT MAX(NASELENIE) FROM GOROD);

--4. Удалить из таблицы gorod города с населением меньше 400000
DELETE GOROD
WHERE NASELENIE < 400000;

--5. Изменить поле naselenie в таблице gorod, выставив в нем для городов Чувашской Республики значение 200000
UPDATE GOROD G
SET NASELENIE = 200000
WHERE EXISTS (SELECT 1 FROM REGION R WHERE G.REGION_ID = R.ID AND R.REGION_NAME = 'Чувашская Республика');

--6. Отобрать из таблицы gorod все города, начинающиеся на букву К
SELECT *
FROM GOROD
WHERE CITY_NAME LIKE 'К%';

--7. Написать запрос, позволяющий определить кол-во городов, которое хранится в таблице gorod для каждого региона, т.е. результат должен быть в виде: название соответствующего региона/кол-во городов, т.е. как на в таблице ниже:
SELECT R.REGION_NAME, COUNT(G.ID) AS COUNT_GOROD
FROM REGION R
--если регионы без городов не нужны, то убрать left
         LEFT JOIN GOROD G ON G.REGION_ID = R.ID
GROUP BY R.REGION_NAME;