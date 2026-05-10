# Laboratorio Final Bases de Datos - BancoDB

Paquete reproducible para crear la base de datos relacional `bancodb` en PostgreSQL.

## Requisitos

- PostgreSQL instalado y en ejecucion.
- Cliente `psql` disponible en el PATH o instalado en una ruta comun de Windows.
- Un usuario administrador de PostgreSQL, por defecto `postgres`.

## Configuracion opcional para ver tildes en SQL Shell

Si usas SQL Shell / `psql` en la consola clasica de Windows y las tildes se ven incorrectas, copia el archivo:

```text
config\psqlrc.conf
```

En esta ruta de tu usuario:

```text
%APPDATA%\postgresql\psqlrc.conf
```

Ese archivo aplica automaticamente:

```sql
\! chcp 1252
\encoding WIN1252
```

Con esto no necesitas escribir esos comandos cada vez que abras `psql`.

## Ejecucion rapida en PowerShell

Desde esta carpeta:

```powershell
.\run.ps1 -User postgres -Password 123
```

Si `psql` no esta en el PATH:

```powershell
.\run.ps1 -User postgres -Password 123 -PsqlPath "C:\Program Files\PostgreSQL\18\bin\psql.exe"
```

El script recrea la base `bancodb` desde cero. Si ya existe, la elimina y la vuelve a crear.

## Archivos SQL

- `sql/01_create_database.sql`: elimina y crea `bancodb`.
- `sql/02_schema.sql`: crea tablas, claves primarias, claves foraneas, restricciones e indices.
- `sql/03_seed_data.sql`: inserta los registros solicitados en el laboratorio.
- `sql/04_queries.sql`: ejecuta las 19 consultas del enunciado.

## Validacion incluida

`run.ps1` valida que se hayan cargado:

- 3 sucursales
- 4 empleados
- 5 clientes
- 2 tipos de cuenta
- 5 cuentas
- 6 transacciones
- 3 prestamos

Despues ejecuta las 19 consultas solicitadas.

## Comandos para ejecutar las consultas del laboratorio

Para ejecutar todas las consultas del PDF desde PowerShell:

```powershell
chcp 65001 > $null
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$env:PGPASSWORD = "123"
$env:PGCLIENTENCODING = "UTF8"
psql -h localhost -p 5432 -U postgres -d bancodb -f .\sql\04_queries.sql
Remove-Item Env:PGPASSWORD
Remove-Item Env:PGCLIENTENCODING
```

Si `psql` no esta en el PATH:

```powershell
chcp 65001 > $null
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$env:PGPASSWORD = "123"
$env:PGCLIENTENCODING = "UTF8"
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" -h localhost -p 5432 -U postgres -d bancodb -f .\sql\04_queries.sql
Remove-Item Env:PGPASSWORD
Remove-Item Env:PGCLIENTENCODING
```

Tambien puedes entrar a la consola interactiva:

```powershell
chcp 65001 > $null
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$env:PGPASSWORD = "123"
$env:PGCLIENTENCODING = "UTF8"
psql -h localhost -p 5432 -U postgres -d bancodb
```

Dentro de `psql`, ejecuta estas consultas:

```sql
-- 1. Mostrar el nombre, apellido y ciudad de los clientes ordenados por ciudad.
SELECT nombre, apellido, ciudad
FROM clientes
ORDER BY ciudad, apellido, nombre;

-- 2. Mostrar las cuentas cuyo saldo sea superior a 5 millones.
SELECT id_cuenta, numero_cuenta, saldo, estado
FROM cuentas
WHERE saldo > 5000000
ORDER BY saldo DESC;

-- 3. Mostrar el total de clientes registrados.
SELECT COUNT(*) AS total_clientes
FROM clientes;

-- 4. Mostrar el salario promedio de los empleados.
SELECT ROUND(AVG(salario), 2) AS salario_promedio
FROM empleados;

-- 5. Mostrar los clientes junto con su numero de cuenta.
SELECT c.nombre, c.apellido, cu.numero_cuenta
FROM clientes c
JOIN cuentas cu ON cu.id_cliente = c.id_cliente
ORDER BY c.id_cliente;

-- 6. Mostrar los clientes y el tipo de cuenta que poseen.
SELECT c.nombre, c.apellido, tc.descripcion AS tipo_cuenta
FROM clientes c
JOIN cuentas cu ON cu.id_cliente = c.id_cliente
JOIN tipos_cuenta tc ON tc.id_tipo = cu.id_tipo
ORDER BY c.id_cliente;

-- 7. Mostrar los empleados y la sucursal donde trabajan.
SELECT e.nombre AS empleado, e.cargo, s.nombre AS sucursal, s.ciudad
FROM empleados e
JOIN sucursales s ON s.id_sucursal = e.id_sucursal
ORDER BY s.nombre, e.nombre;

-- 8. Mostrar los clientes que tienen prestamos y el valor del prestamo.
SELECT c.nombre, c.apellido, p.monto AS valor_prestamo
FROM clientes c
JOIN prestamos p ON p.id_cliente = c.id_cliente
ORDER BY c.id_cliente;

-- 9. Mostrar todas las transacciones realizadas por cada cliente.
SELECT c.nombre, c.apellido, cu.numero_cuenta, t.tipo, t.monto, t.fecha
FROM clientes c
JOIN cuentas cu ON cu.id_cliente = c.id_cliente
JOIN transacciones t ON t.id_cuenta = cu.id_cuenta
ORDER BY c.id_cliente, t.id_transaccion;

-- 10. Mostrar cuantos clientes existen por ciudad.
SELECT ciudad, COUNT(*) AS total_clientes
FROM clientes
GROUP BY ciudad
ORDER BY ciudad;

-- 11. Mostrar el monto total agrupado por tipo de transaccion.
SELECT tipo, SUM(monto) AS monto_total
FROM transacciones
GROUP BY tipo
ORDER BY tipo;

-- 12. Mostrar el saldo promedio por tipo de cuenta.
SELECT tc.descripcion AS tipo_cuenta, ROUND(AVG(cu.saldo), 2) AS saldo_promedio
FROM tipos_cuenta tc
JOIN cuentas cu ON cu.id_tipo = tc.id_tipo
GROUP BY tc.descripcion
ORDER BY tc.descripcion;

-- 13. Mostrar cuantos empleados tiene cada sucursal.
SELECT s.nombre AS sucursal, COUNT(e.id_empleado) AS total_empleados
FROM sucursales s
LEFT JOIN empleados e ON e.id_sucursal = s.id_sucursal
GROUP BY s.id_sucursal, s.nombre
ORDER BY s.nombre;

-- 14. Mostrar el saldo total agrupado por ciudad.
SELECT c.ciudad, SUM(cu.saldo) AS saldo_total
FROM clientes c
JOIN cuentas cu ON cu.id_cliente = c.id_cliente
GROUP BY c.ciudad
ORDER BY c.ciudad;

-- 15. Mostrar los clientes que poseen prestamos.
SELECT nombre, apellido
FROM clientes
WHERE id_cliente IN (SELECT id_cliente FROM prestamos)
ORDER BY id_cliente;

-- 16. Mostrar las cuentas cuyo saldo es superior al promedio general.
SELECT numero_cuenta, saldo
FROM cuentas
WHERE saldo > (SELECT AVG(saldo) FROM cuentas)
ORDER BY saldo DESC;

-- 17. Mostrar el empleado con el salario mas alto.
SELECT nombre, cargo, salario
FROM empleados
WHERE salario = (SELECT MAX(salario) FROM empleados);

-- 18. Mostrar los clientes que no poseen prestamos.
SELECT nombre, apellido
FROM clientes
WHERE id_cliente NOT IN (SELECT id_cliente FROM prestamos)
ORDER BY id_cliente;

-- 19. Mostrar la cuenta con el menor saldo.
SELECT numero_cuenta, saldo, estado
FROM cuentas
WHERE saldo = (SELECT MIN(saldo) FROM cuentas);
```

## Comandos para practicar todos los tipos de JOIN

Primero entra a la base de datos:

```powershell
chcp 65001 > $null
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$env:PGPASSWORD = "123"
$env:PGCLIENTENCODING = "UTF8"
psql -h localhost -p 5432 -U postgres -d bancodb
```

Si `psql` no esta en el PATH:

```powershell
chcp 65001 > $null
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$env:PGPASSWORD = "123"
$env:PGCLIENTENCODING = "UTF8"
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" -h localhost -p 5432 -U postgres -d bancodb
```

Dentro de `psql`, ejecuta estos ejemplos:

```sql
-- INNER JOIN
-- Muestra solo clientes que tienen cuenta registrada.
SELECT c.id_cliente, c.nombre, c.apellido, cu.numero_cuenta, cu.saldo
FROM clientes c
INNER JOIN cuentas cu ON cu.id_cliente = c.id_cliente
ORDER BY c.id_cliente;

-- LEFT JOIN
-- Muestra todos los clientes, tengan o no tengan prestamos.
SELECT c.id_cliente, c.nombre, c.apellido, p.id_prestamo, p.monto
FROM clientes c
LEFT JOIN prestamos p ON p.id_cliente = c.id_cliente
ORDER BY c.id_cliente;

-- RIGHT JOIN
-- Muestra todas las sucursales y los empleados relacionados.
SELECT e.id_empleado, e.nombre AS empleado, s.id_sucursal, s.nombre AS sucursal
FROM empleados e
RIGHT JOIN sucursales s ON s.id_sucursal = e.id_sucursal
ORDER BY s.id_sucursal, e.id_empleado;

-- FULL JOIN
-- Muestra todos los clientes y todas las cuentas, exista o no coincidencia.
SELECT c.id_cliente, c.nombre, c.apellido, cu.id_cuenta, cu.numero_cuenta
FROM clientes c
FULL JOIN cuentas cu ON cu.id_cliente = c.id_cliente
ORDER BY c.id_cliente, cu.id_cuenta;

```
