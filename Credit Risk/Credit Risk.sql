DROP DATABASE IF EXISTS CreditRiskDB;
CREATE DATABASE CreditRiskDB;
USE CreditRiskDB;

-- 1. Tablas
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    annual_income DECIMAL(15, 2) NOT NULL,
    credit_score_internal INT DEFAULT 600
);

-- 2. Procedimiento (El bloque crítico)
DELIMITER //

CREATE PROCEDURE sp_evaluate_loan_risk(
    IN p_customer_id INT, 
    IN p_requested_amount DECIMAL(15,2)
)
BEGIN
    DECLARE v_income DECIMAL(15,2);
    DECLARE v_dti_ratio DECIMAL(5,2);
    DECLARE v_result VARCHAR(100);

    -- Obtener datos
    SELECT annual_income INTO v_income 
    FROM Customers 
    WHERE customer_id = p_customer_id;

    -- Calcular ratio
    SET v_dti_ratio = p_requested_amount / NULLIF(v_income, 0);

    -- Lógica de decisión
    IF (v_dti_ratio > 0.45) THEN
        SET v_result = 'RECHAZADO: DTI alto';
    ELSEIF (v_income < 20000) THEN
        SET v_result = 'RECHAZADO: Ingreso bajo';
    ELSE
        SET v_result = 'APROBADO: Perfil apto';
    END IF;

    -- Resultado
    SELECT p_customer_id AS ID, v_dti_ratio AS DTI, v_result AS Decision;
END //

DELIMITER ;

-- 3. Datos y Pruebas
INSERT INTO Customers (full_name, annual_income) VALUES 
('Juan Economista', 90000.00),
('Pedro Riesgo', 15000.00);

CALL sp_evaluate_loan_risk(1, 20000.00);
CALL sp_evaluate_loan_risk(2, 10000.00);

-- 1. Clasificación estadística de clientes
-- Usamos CASE y Window Functions para ver la posición de cada cliente
SELECT 
    full_name,
    annual_income,
    -- Calculamos el ingreso promedio de toda la base para comparar
    AVG(annual_income) OVER() as promedio_cartera,
    -- Identificamos si el cliente está por encima o debajo de la media
    CASE 
        WHEN annual_income > (AVG(annual_income) OVER()) THEN 'Sobre la media'
        ELSE 'Bajo la media'
    END AS estatus_ingreso
FROM Customers;

-- 2. Creación de una Vista para Reportes (Reporting Layer)
CREATE OR REPLACE VIEW v_risk_summary AS
SELECT 
    COUNT(*) as total_clientes,
    SUM(annual_income) as masa_salarial_total,
    AVG(annual_income) as ingreso_medio
FROM Customers;

-- Consultar la vista
SELECT * FROM v_risk_summary;

-- 1. Insertar más perfiles para probar el motor y las estadísticas
INSERT INTO Customers (full_name, annual_income, credit_score_internal) VALUES 
('Carlos Slim-ish', 250000.00, 850), -- High Net Worth
('Lucía Fernández', 65000.00, 710),   -- Clase Media Consolidada
('Roberto Gómez', 12000.00, 450),    -- Perfil Vulnerable
('Marta Stewart', 95000.00, 780),    -- Perfil Premium
('Esteban Quito', 35000.00, 600),    -- Clase Media Inicial
('Sofía Datos', 55000.00, 680),      -- Científica de Datos Senior
('Jorge Riesgo', 19500.00, 520);     -- Al borde del límite de ingreso

-- 2. Probar el motor con los nuevos perfiles
-- Carlos pide un préstamo grande pero su ingreso es altísimo (Aprobado)
CALL sp_evaluate_loan_risk(3, 80000.00); 

-- Esteban pide un préstamo que lo sobreendeuda (Rechazado por DTI)
CALL sp_evaluate_loan_risk(7, 25000.00);

-- Jorge tiene ingresos justo por debajo del límite de 20k (Rechazado por Ingreso)
CALL sp_evaluate_loan_risk(9, 2000.00);

-- 3. Análisis de Segmentación Pro
-- Aquí comparamos a cada individuo contra su grupo
SELECT 
    full_name,
    annual_income,
    -- Ranking de ingresos de mayor a menor
    RANK() OVER (ORDER BY annual_income DESC) as ranking_ingresos,
    -- Percentil (en qué lugar del 0 al 1 está respecto al resto)
    ROUND(PERCENT_RANK() OVER (ORDER BY annual_income), 2) as percentil_ingreso,
    -- Diferencia respecto al ingreso promedio de la cartera
    annual_income - AVG(annual_income) OVER() as desviacion_de_la_media
FROM Customers;