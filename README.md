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
.\run.ps1 -User postgres
```

Si `psql` no esta en el PATH:

```powershell
.\run.ps1 -User postgres -PsqlPath "C:\Program Files\PostgreSQL\18\bin\psql.exe"
```

El script solicitara la contraseña del usuario PostgreSQL durante la ejecucion.
El script recrea la base `bancodb` desde cero. Si ya existe, la elimina y la vuelve a crear.

## Archivos SQL

- `sql/01_create_database.sql`: elimina y crea `bancodb`.
- `sql/02_schema.sql`: crea tablas, claves primarias, claves foraneas, restricciones e indices.
- `sql/03_seed_data.sql`: inserta los registros solicitados en el laboratorio.
- `sql/04_queries.sql`: ejecuta las 19 consultas del enunciado.
- `sql/cloudflare_d1.sql`: version compatible con Cloudflare D1.

## Despliegue en Cloudflare D1

La base remota creada en Cloudflare es:

```text
Nombre: bancodb
Database ID: 21222d8a-44ad-42d5-ba18-68bfffda06ea
Region: ENAM
```

El archivo `wrangler.toml` contiene el binding `DB` hacia esa base. Para volver a cargar el esquema y los datos en D1:

```powershell
npx wrangler d1 execute bancodb --remote --file .\sql\cloudflare_d1.sql
```

Para validar una consulta rapida:

```powershell
npx wrangler d1 execute bancodb --remote --command "SELECT COUNT(*) AS total_clientes FROM clientes;"
```

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
psql --host=localhost --port=5432 --username=postgres --dbname=bancodb --file=.\sql\04_queries.sql
Remove-Item Env:PGPASSWORD
Remove-Item Env:PGCLIENTENCODING
```

Si `psql` no esta en el PATH:

```powershell
chcp 65001 > $null
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$env:PGPASSWORD = "123"
$env:PGCLIENTENCODING = "UTF8"
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" --host=localhost --port=5432 --username=postgres --dbname=bancodb --file=.\sql\04_queries.sql
Remove-Item Env:PGPASSWORD
Remove-Item Env:PGCLIENTENCODING
```

Tambien puedes entrar a la consola interactiva:

```powershell
chcp 65001 > $null
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$env:PGPASSWORD = "123"
$env:PGCLIENTENCODING = "UTF8"
psql --host=localhost --port=5432 --username=postgres --dbname=bancodb
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
SELECT clientes.nombre, clientes.apellido, cuentas.numero_cuenta
FROM clientes
JOIN cuentas ON cuentas.id_cliente = clientes.id_cliente
ORDER BY clientes.id_cliente;

-- 6. Mostrar los clientes y el tipo de cuenta que poseen.
SELECT clientes.nombre, clientes.apellido, tipos_cuenta.descripcion AS tipo_cuenta
FROM clientes
JOIN cuentas ON cuentas.id_cliente = clientes.id_cliente
JOIN tipos_cuenta ON tipos_cuenta.id_tipo = cuentas.id_tipo
ORDER BY clientes.id_cliente;

-- 7. Mostrar los empleados y la sucursal donde trabajan.
SELECT empleados.nombre AS empleado, empleados.cargo, sucursales.nombre AS sucursal, sucursales.ciudad
FROM empleados
JOIN sucursales ON sucursales.id_sucursal = empleados.id_sucursal
ORDER BY sucursales.nombre, empleados.nombre;

-- 8. Mostrar los clientes que tienen prestamos y el valor del prestamo.
SELECT clientes.nombre, clientes.apellido, prestamos.monto AS valor_prestamo
FROM clientes
JOIN prestamos ON prestamos.id_cliente = clientes.id_cliente
ORDER BY clientes.id_cliente;

-- 9. Mostrar todas las transacciones realizadas por cada cliente.
SELECT clientes.nombre, clientes.apellido, cuentas.numero_cuenta, transacciones.tipo, transacciones.monto, transacciones.fecha
FROM clientes
JOIN cuentas ON cuentas.id_cliente = clientes.id_cliente
JOIN transacciones ON transacciones.id_cuenta = cuentas.id_cuenta
ORDER BY clientes.id_cliente, transacciones.id_transaccion;

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
SELECT tipos_cuenta.descripcion AS tipo_cuenta, ROUND(AVG(cuentas.saldo), 2) AS saldo_promedio
FROM tipos_cuenta
JOIN cuentas ON cuentas.id_tipo = tipos_cuenta.id_tipo
GROUP BY tipos_cuenta.descripcion
ORDER BY tipos_cuenta.descripcion;

-- 13. Mostrar cuantos empleados tiene cada sucursal.
SELECT sucursales.nombre AS sucursal, COUNT(empleados.id_empleado) AS total_empleados
FROM sucursales
LEFT JOIN empleados ON empleados.id_sucursal = sucursales.id_sucursal
GROUP BY sucursales.id_sucursal, sucursales.nombre
ORDER BY sucursales.nombre;

-- 14. Mostrar el saldo total agrupado por ciudad.
SELECT clientes.ciudad, SUM(cuentas.saldo) AS saldo_total
FROM clientes
JOIN cuentas ON cuentas.id_cliente = clientes.id_cliente
GROUP BY clientes.ciudad
ORDER BY clientes.ciudad;

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
psql --host=localhost --port=5432 --username=postgres --dbname=bancodb
```

Si `psql` no esta en el PATH:

```powershell
chcp 65001 > $null
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$env:PGPASSWORD = "123"
$env:PGCLIENTENCODING = "UTF8"
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" --host=localhost --port=5432 --username=postgres --dbname=bancodb
```

Dentro de `psql`, ejecuta estos ejemplos:

```sql
-- INNER JOIN
-- Muestra solo clientes que tienen cuenta registrada.
SELECT clientes.id_cliente, clientes.nombre, clientes.apellido, cuentas.numero_cuenta, cuentas.saldo
FROM clientes
INNER JOIN cuentas ON cuentas.id_cliente = clientes.id_cliente
ORDER BY clientes.id_cliente;

-- LEFT JOIN
-- Muestra todos los clientes, tengan o no tengan prestamos.
SELECT clientes.id_cliente, clientes.nombre, clientes.apellido, prestamos.id_prestamo, prestamos.monto
FROM clientes
LEFT JOIN prestamos ON prestamos.id_cliente = clientes.id_cliente
ORDER BY clientes.id_cliente;

-- RIGHT JOIN
-- Muestra todas las sucursales y los empleados relacionados.
SELECT empleados.id_empleado, empleados.nombre AS empleado, sucursales.id_sucursal, sucursales.nombre AS sucursal
FROM empleados
RIGHT JOIN sucursales ON sucursales.id_sucursal = empleados.id_sucursal
ORDER BY sucursales.id_sucursal, empleados.id_empleado;

-- FULL JOIN
-- Muestra todos los clientes y todas las cuentas, exista o no coincidencia.
SELECT clientes.id_cliente, clientes.nombre, clientes.apellido, cuentas.id_cuenta, cuentas.numero_cuenta
FROM clientes
FULL JOIN cuentas ON cuentas.id_cliente = clientes.id_cliente
ORDER BY clientes.id_cliente, cuentas.id_cuenta;

```
