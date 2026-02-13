Credit Risk Engine & Portfolio Analytics (SQL)
📌 Contexto del Proyecto
Como Economista y Data Scientist, he desarrollado este proyecto para simular un Motor de Decisión Crediticia automatizado. El sistema no solo gestiona la base de datos de una entidad financiera, sino que aplica reglas de negocio para la aprobación de préstamos basadas en indicadores macro y microeconómicos, como el Ratio DTI (Debt-to-Income).

🛠️ Tecnologías Utilizadas
Motor de Base de Datos: MySQL (Workbench)

Lenguaje: SQL (DML, DDL)

Conceptos Avanzados: Stored Procedures, Window Functions, Logic Control (IF/ELSE), Data Normalization.

🚀 Paso a Paso del Desarrollo
1. Modelado de Datos (Arquitectura)
El primer paso fue diseñar una estructura robusta para garantizar la integridad de la información.

Customers: Almacena el perfil socioeconómico del solicitante (ingresos, antigüedad, score).

Concepto clave: Uso de DECIMAL(15,2) para precisión financiera y AUTO_INCREMENT para la gestión eficiente de registros.

2. Motor de Riesgo (Automatización con Stored Procedures)
Desarrollé el procedimiento sp_evaluate_loan_risk para eliminar la subjetividad en la aprobación de créditos.

Lógica Financiera: El código calcula el Ratio DTI. Si un cliente solicita un préstamo cuyo pago (o monto total) excede el 45% de sus ingresos anuales, el sistema lo rechaza automáticamente por riesgo de sobreendeudamiento.

Validación de Ingresos: Se estableció un piso de ingresos de $20,000 para cumplir con las políticas de riesgo de la institución.

3. Analítica de Cartera (Data Science)
Para demostrar mi capacidad como analista de datos, incluí consultas que utilizan Window Functions (OVER, RANK, PERCENT_RANK):

Segmentación: Clasificación de clientes en cuartiles según sus ingresos.

Benchmarking: Comparación de cada cliente contra el ingreso promedio de la cartera para identificar desviaciones y perfiles "Outliers".

📊 Código Principal y Explicación
Creación del Procedimiento de Evaluación
SQL

-- Este bloque permite automatizar la decisión de crédito
DELIMITER //
CREATE PROCEDURE sp_evaluate_loan_risk(IN p_customer_id INT, IN p_requested_amount DECIMAL(15,2))
BEGIN
    -- Cálculo del ratio de deuda sobre ingreso (DTI)
    SET v_dti_ratio = p_requested_amount / NULLIF(v_income, 0);

    -- Regla de decisión económica
    IF (v_dti_ratio > 0.45) THEN
        SET v_result = 'RECHAZADO: Exceso de deuda';
    ...
END //
DELIMITER ;
Análisis Estadístico de Clientes
SQL

-- Uso de funciones de ventana para análisis de mercado interno
SELECT 
    full_name,
    PERCENT_RANK() OVER (ORDER BY annual_income) AS percentil_ingreso,
    annual_income - AVG(annual_income) OVER() AS desviacion_media
FROM Customers;
📈 Conclusiones de Negocio
Eficiencia: La automatización mediante SQL reduce el tiempo de respuesta de aprobación de minutos a milisegundos.

Mitigación de Riesgo: La implementación del límite DTI del 45% protege la salud financiera de la cartera y reduce la probabilidad de default.

Cómo usar este repositorio
Clona el repositorio.

Ejecuta el archivo Credit_Risk_Project.sql en tu instancia de MySQL Workbench.

Prueba el motor con el comando CALL sp_evaluate_loan_risk(ID, MONTO);.
