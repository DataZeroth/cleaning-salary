-- ======================================================================== --
--                            LIMPIEZA DE DATOS SQL           
-- ========================================================================= -- 



CREATE DATABASE IF NOT EXISTS clean;


-- ----- Seleccionar la tabla a trabajar
USE clean;

-- ----- Generar una muestra de los datos
SELECT * FROM LIMPIEZA;

-- =========== Store procedure (macro) ================== --

Select * from limpieza; -- se quiere evitar escribirlo repetidamente

-- ----- crear el procedimiento para consultar sin escribir toda la consulta
DELIMITER //
CREATE PROCEDURE limp()
BEGIN
    SELECT * FROM limpieza;
END //
DELIMITER ;
-- ejecutar el procedimiento
CALL limp;

-- ----- Renombrar los nombres de las columnas con caracteres especiales
ALTER TABLE limpieza CHANGE COLUMN `ï»¿Id?empleado` Id_emp varchar(20) null; -- `caracteres especiales` -- 
ALTER TABLE limpieza CHANGE COLUMN `gÃ©nero` Gender varchar(20) null; -- `caracteres especiales` -- 
-- =========== Verificar y remover registros duplicados ================== --

select id_emp, count(*) as cantidad_duplicados
from limpieza
group by id_emp
having count(*) > 1;

-- ----- Contar el número de duplicados con Subquery 

SELECT count(*) AS cantidad_duplicados
FROM (
    select id_emp, count(*) as cantidad_duplicados
    from limpieza
    group by id_emp
    having count(*) > 1
    ) AS subquery;
    
-- ----- Eliminando duplicados

rename table limpieza to conduplicados;

CREATE TEMPORARY TABLE Temp_limpieza as
SELECT DISTINCT * FROM conduplicados;

SELECT count(*) as original from conduplicados;
SELECT count(*) as original from Temp_limpieza;

CREATE TABLE Limpieza AS SELECT * FROM TEMP_LIMPIEZA;

CALL LIMP();

##### ELIMINANDO TABLA CON DUPLICADOS

DROP TABLE conduplicados;

#### CAMBIANDO MAS COLUMNAS

ALTER TABLE limpieza CHANGE COLUMN Apellido Last_Name varchar(50) null;
ALTER TABLE limpieza CHANGE COLUMN Star_date Start_date varchar(50) null;

#### VER TIPOS DE DATOS

DESCRIBE Limpieza;

### LIMPIEZA DE ESPACIOS BLANCOS 

SELECT Name FROM limpieza WHERE LENGTH(name) - LENGTH(TRIM(name)) > 0; 

SELECT Name, trim(Name) as Name
FROM limpieza
WHERE length(name) - length(trim(name)) > 0;

### AHORA APELLIDOS

SELECT Last_Name, trim(Last_Name) as Last_Name
FROM limpieza
WHERE length(Last_Name) - length(trim(Last_Name)) > 0;

### QUE SE ACTUALICE LA TABLA CON LOS NUEVOS NOMBRES

SET sql_safe_updates = 0; 
UPDATE limpieza SET NAME = TRIM(NAME)
WHERE length(name) - length(trim(name)) > 0;

UPDATE limpieza SET Last_Name = TRIM(Last_Name)
WHERE length(Last_Name) - length(trim(Last_Name)) > 0;

-- ------ identificar espacios extra en medio de dos palabras

-- # adicionar a propósito espacios extra
UPDATE limpieza SET area = REPLACE(area, ' ', '       '); 
call limp();

## limpiando

SELECT area FROM Limpieza
WHERE area regexp '\\s{2,}';
 
 ## ELIMINAMOS ESPACIOS
 
 SELECT area, trim(regexp_replace(area, '\\s+',' ')) as ensayo from limpieza;

 
 # ACTUALIZAMOS
 
UPDATE limpieza SET area = trim(regexp_replace(area, '\\s+',' '));

### BUSCAR Y REEMPLAZAR 

SELECT gender ,
CASE
  WHEN gender = "hombre" then "male"
  WHEN gender = "mujer" then "female"
  ELSE "other"
END as gender1
FROM limpieza;

## ACTUALIZAMOS 
UPDATE limpieza SET gender = 
CASE
  WHEN gender = "hombre" then "male"
  WHEN gender = "mujer" then "female"
  ELSE "other"
END;

CALL limp();

## CAMBIANDO LA COLUMNA TYPE (BOLEANA) POR TEXT PARA PODER REEMPLAZAR

DESCRIBE limpieza;

ALTER TABLE limpieza MODIFY COLUMN type  TEXT;

### REEMPLAZANDO

SELECT type,
CASE
   WHEN type = 1 then "Remote"
   WHEN type = 0 then "Hybrid"
   ELSE "Other"
END as ejemplo
FROM limpieza;

### ACTUALIZAMOS

UPDATE limpieza SET type =
CASE
   WHEN type = 1 then "Remote"
   WHEN type = 0 then "Hybrid"
   ELSE "Other"
END;

CALL limp();

-- ===========  Ajustar formato números ================== -- 
call limp();

### EDITANDO PARA CAMBIAR EL SALARY

SELECT salary, CAST(TRIM(REPLACE(REPLACE(salary, "$", ""), ",", "")) AS DECIMAL(15,2)) FROM limpieza;

### ACTUALIZAMOS

UPDATE limpieza SET salary = CAST(TRIM(REPLACE(REPLACE(salary, '$', ''), ',', '')) AS DECIMAL(15, 2));

## CAMBIANDO TEXTO DE SALARY A NUM 

ALTER TABLE limpieza MODIFY COLUMN salary int null;

DESCRIBE limpieza;

## TRABAJANDO CON FECHAS

SELECT birth_date from limpieza;

SELECT birth_date, case
      WHEN birth_date LIKE "%/%" THEN          date_format(str_to_date(birth_date, "%m/%d/%y"), "%Y-%m-%d")
      WHEN birth_date LIKE "%-%" THEN          date_format(str_to_date(birth_date, "%m-%d-%y"), "%Y-%m-%d")
	  ELSE NULL
END AS new_birth_date
FROM limpieza;

UPDATE limpieza
SET birth_date = CASE
	WHEN birth_date LIKE '%/%' THEN date_format(str_to_date(birth_date, '%m/%d/%Y'),'%Y-%m-%d')
    WHEN birth_date LIKE '%-%' THEN date_format(str_to_date(birth_date, '%m-%d-%Y'),'%Y-%m-%d')
    ELSE NULL
END;

## CAMBIANDO EL TIPO DE COLUMNA DE FECHA

ALTER TABLE limpieza MODIFY COLUMN birth_date DATE;
DESCRIBE limpieza; ## VERIFICAMOS

## AHORA PARA start_date

SELECT start_date FROM limpieza;

SELECT start_date, CASE
	 WHEN start_date LIKE '%/%' THEN date_format(str_to_date(start_date, '%m/%d/%Y'),'%Y-%m-%d')
     WHEN start_date LIKE '%-%' THEN date_format(str_to_date(start_date, '%m-%d-%Y'),'%Y-%m-%d')
    ELSE NULL
END AS new_start_date
FROM limpieza;

- ----- Actualizar la tabla
UPDATE limpieza
SET start_date = CASE
	WHEN start_date LIKE '%/%' THEN date_format(str_to_date(start_date, '%m/%d/%Y'),'%Y-%m-%d')
    WHEN start_date LIKE '%-%' THEN date_format(str_to_date(start_date, '%m-%d-%Y'),'%Y-%m-%d')
    ELSE NULL
END;

-- Cambiar el tipo de dato de la columna 
ALTER TABLE limpieza MODIFY COLUMN start_date DATE;
DESCRIBE limpieza;

-- ===========  Explorando funciones de fecha  ================== --

-- usaremos finish_date para explorar
SELECT finish_date FROM limpieza;
CALL limp();

-- # "ensayos" hacer consultas de como quedarían los datos si queremos ensayar diversos cambios.
SELECT finish_date, str_to_date(finish_date, '%Y-%m-%d %H:%i:%s') AS fecha FROM limpieza; 
SELECT finish_date, date_format(str_to_date(finish_date, '%Y-%m-%d %H:%i:%s'), '%Y-%m-%d') AS fecha FROM limpieza; 
SELECT finish_date, str_to_date(finish_date, '%Y-%m-%d') AS fd FROM limpieza; 
SELECT  finish_date, str_to_date(finish_date, '%H:%i:%s') AS hour_stamp FROM limpieza;
SELECT  finish_date, date_format(finish_date, '%H:%i:%s') AS hour_stamp FROM limpieza; 

-- # Diviendo los elementos de la hora
SELECT finish_date,
    date_format(finish_date, '%H') AS hora, # SI QUEREMOS SOLO HORAS Y ASI LAS DE ABAJO
    date_format(finish_date, '%i') AS minutos,
    date_format(finish_date, '%s') AS segundos,
    date_format(finish_date, '%H:%i:%s') AS hour_stamp
FROM limpieza;

-- ===========  Actualizaciones de fecha en la tabla  ================== --

-- ----- Copia de seguridad de la columna finish_date
call limp();
ALTER TABLE limpieza ADD COLUMN date_backup TEXT; -- Agregar columna respaldo
UPDATE limpieza SET date_backup = finish_date; -- Copiar los datos de finish_date a a la columna respaldo

-- # Actualizar la fecha a marca de tiempo: (TIMESTAMP ; DATETIME)
 Select finish_date, str_to_date(finish_date, '%Y-%m-%d %H:%i:%s UTC')  as formato from limpieza; -- (UTC)

UPDATE limpieza
	SET finish_date = str_to_date(finish_date, '%Y-%m-%d %H:%i:%s UTC') 
	WHERE finish_date <> ''; 
    
call limp();

-- --------- Dividir la finish_date en fecha y hora

 -- # Crear las columnas que albergarán los nuevos datos 
ALTER TABLE limpieza
	ADD COLUMN fecha DATE,
	ADD COLUMN hora TIME;
    
-- # actualizar los valores de dichas columnas
UPDATE limpieza
SET fecha = DATE(finish_date),
    hora = TIME(finish_date)
WHERE finish_date IS NOT NULL AND finish_date <> '';

 -- # Valores en blanco a nulos
UPDATE limpieza SET finish_date = NULL WHERE finish_date = '';

-- # Actualizar la propiedad
ALTER TABLE limpieza MODIFY COLUMN finish_date DATETIME;

-- # Revisar los datos
SELECT * FROM limpieza; 
CALL limp();
DESCRIBE limpieza;

-- ========= Cálculos con fechas ====== -- 

-- # Agregar columna para albergar la edad
ALTER TABLE limpieza ADD COLUMN age INT;
call limp();

SELECT name,birth_date, start_date, TIMESTAMPDIFF(YEAR, birth_date, start_date) AS edad_de_ingreso
FROM limpieza;


-- # Actualizar los datos en la columna edad
UPDATE limpieza
SET age = timestampdiff(YEAR, birth_date, CURDATE()); 

call limp;

-- ============ creando columnas adicionales ================= -- 

select CONCAT(SUBSTRING_INDEX(Name, ' ', 1),'_', SUBSTRING(Last_name, 1, 4), '.',SUBSTRING(Type, 1, 1), '@consulting.com') as email from limpieza;
-- correo: primer nombre, _ , dos letras del apellido, @consulting.com
-- SUBSTRING_INDEX(cadena, delimitador, ocurrencia) 

ALTER TABLE limpieza
ADD COLUMN email VARCHAR(100);

UPDATE limpieza 
SET email = CONCAT(SUBSTRING_INDEX(Name, ' ', 1),'_', SUBSTRING(Last_name, 1, 4), '.',SUBSTRING(Type, 1, 1), '@consulting.com'); 

CALL limp();

-- ============ creando y exportando mi set de datos definitivo ================= -- 

SELECT * FROM limpieza
WHERE finish_date <= CURDATE() OR finish_date IS NULL
ORDER BY area, Name;

SELECT area, COUNT(*) AS cantidad_empleados FROM limpieza
GROUP BY area
ORDER BY cantidad_empleados DESC;
      