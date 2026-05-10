\set ON_ERROR_STOP on
\encoding UTF8

\echo '1. Clientes ordenados por ciudad'
SELECT nombre, apellido, ciudad
FROM clientes
ORDER BY ciudad, apellido, nombre;

\echo '2. Cuentas cuyo saldo sea superior a 5 millones'
SELECT id_cuenta, numero_cuenta, saldo, estado
FROM cuentas
WHERE saldo > 5000000
ORDER BY saldo DESC;

\echo '3. Total de clientes registrados'
SELECT COUNT(*) AS total_clientes
FROM clientes;

\echo '4. Salario promedio de los empleados'
SELECT ROUND(AVG(salario), 2) AS salario_promedio
FROM empleados;

\echo '5. Clientes junto con su numero de cuenta'
SELECT c.nombre, c.apellido, cu.numero_cuenta
FROM clientes c
JOIN cuentas cu ON cu.id_cliente = c.id_cliente
ORDER BY c.id_cliente;

\echo '6. Clientes y tipo de cuenta que poseen'
SELECT c.nombre, c.apellido, tc.descripcion AS tipo_cuenta
FROM clientes c
JOIN cuentas cu ON cu.id_cliente = c.id_cliente
JOIN tipos_cuenta tc ON tc.id_tipo = cu.id_tipo
ORDER BY c.id_cliente;

\echo '7. Empleados y sucursal donde trabajan'
SELECT e.nombre AS empleado, e.cargo, s.nombre AS sucursal, s.ciudad
FROM empleados e
JOIN sucursales s ON s.id_sucursal = e.id_sucursal
ORDER BY s.nombre, e.nombre;

\echo '8. Clientes que tienen prestamos y valor del prestamo'
SELECT c.nombre, c.apellido, p.monto AS valor_prestamo
FROM clientes c
JOIN prestamos p ON p.id_cliente = c.id_cliente
ORDER BY c.id_cliente;

\echo '9. Transacciones realizadas por cada cliente'
SELECT c.nombre, c.apellido, cu.numero_cuenta, t.tipo, t.monto, t.fecha
FROM clientes c
JOIN cuentas cu ON cu.id_cliente = c.id_cliente
JOIN transacciones t ON t.id_cuenta = cu.id_cuenta
ORDER BY c.id_cliente, t.id_transaccion;

\echo '10. Cantidad de clientes por ciudad'
SELECT ciudad, COUNT(*) AS total_clientes
FROM clientes
GROUP BY ciudad
ORDER BY ciudad;

\echo '11. Monto total agrupado por tipo de transaccion'
SELECT tipo, SUM(monto) AS monto_total
FROM transacciones
GROUP BY tipo
ORDER BY tipo;

\echo '12. Saldo promedio por tipo de cuenta'
SELECT tc.descripcion AS tipo_cuenta, ROUND(AVG(cu.saldo), 2) AS saldo_promedio
FROM tipos_cuenta tc
JOIN cuentas cu ON cu.id_tipo = tc.id_tipo
GROUP BY tc.descripcion
ORDER BY tc.descripcion;

\echo '13. Cantidad de empleados por sucursal'
SELECT s.nombre AS sucursal, COUNT(e.id_empleado) AS total_empleados
FROM sucursales s
LEFT JOIN empleados e ON e.id_sucursal = s.id_sucursal
GROUP BY s.id_sucursal, s.nombre
ORDER BY s.nombre;

\echo '14. Saldo total agrupado por ciudad'
SELECT c.ciudad, SUM(cu.saldo) AS saldo_total
FROM clientes c
JOIN cuentas cu ON cu.id_cliente = c.id_cliente
GROUP BY c.ciudad
ORDER BY c.ciudad;

\echo '15. Clientes que poseen prestamos'
SELECT nombre, apellido
FROM clientes
WHERE id_cliente IN (SELECT id_cliente FROM prestamos)
ORDER BY id_cliente;

\echo '16. Cuentas cuyo saldo es superior al promedio general'
SELECT numero_cuenta, saldo
FROM cuentas
WHERE saldo > (SELECT AVG(saldo) FROM cuentas)
ORDER BY saldo DESC;

\echo '17. Empleado con el salario mas alto'
SELECT nombre, cargo, salario
FROM empleados
WHERE salario = (SELECT MAX(salario) FROM empleados);

\echo '18. Clientes que no poseen prestamos'
SELECT nombre, apellido
FROM clientes
WHERE id_cliente NOT IN (SELECT id_cliente FROM prestamos)
ORDER BY id_cliente;

\echo '19. Cuenta con el menor saldo'
SELECT numero_cuenta, saldo, estado
FROM cuentas
WHERE saldo = (SELECT MIN(saldo) FROM cuentas);
