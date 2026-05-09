\set ON_ERROR_STOP on
SET client_encoding = 'UTF8';

INSERT INTO sucursales(nombre, ciudad, direccion)
VALUES
('Sucursal Centro', 'Bogotá', 'Cra 10 #20-30'),
('Sucursal Norte', 'Medellín', 'Calle 50 #40-20'),
('Sucursal Sur', 'Cali', 'Av 5 Norte #12-10');

INSERT INTO empleados(nombre, cargo, salario, id_sucursal)
VALUES
('Carlos Pérez', 'Gerente', 8500000, 1),
('Ana Torres', 'Asesor', 3500000, 1),
('Luis Gómez', 'Cajero', 2800000, 2),
('Martha Díaz', 'Asesor', 4200000, 3);

INSERT INTO clientes(nombre, apellido, telefono, correo, ciudad)
VALUES
('Juan', 'Rodríguez', '3001112233', 'juan@gmail.com', 'Bogotá'),
('María', 'López', '3004445566', 'maria@gmail.com', 'Cali'),
('Pedro', 'Martínez', '3019998877', 'pedro@gmail.com', 'Medellín'),
('Laura', 'García', '3025556677', 'laura@gmail.com', 'Pasto'),
('Camila', 'Fernández', '3048887766', 'camila@gmail.com', 'Bogotá');

INSERT INTO tipos_cuenta(descripcion)
VALUES
('Ahorros'),
('Corriente');

INSERT INTO cuentas
(numero_cuenta, saldo, fecha_apertura, estado, id_cliente, id_tipo)
VALUES
('20001', 5000000, '2024-01-10', 'Activa', 1, 1),
('20002', 1200000, '2024-02-11', 'Activa', 2, 2),
('20003', 9500000, '2024-03-15', 'Activa', 3, 1),
('20004', 850000, '2024-03-20', 'Bloqueada', 4, 2),
('20005', 15000000, '2024-04-05', 'Activa', 5, 1);

INSERT INTO transacciones(tipo, monto, id_cuenta)
VALUES
('Deposito', 500000, 1),
('Retiro', 200000, 1),
('Transferencia', 1000000, 2),
('Deposito', 800000, 3),
('Retiro', 350000, 4),
('Deposito', 1500000, 5);

INSERT INTO prestamos(monto, tasa_interes, fecha_inicio, cuotas, id_cliente)
VALUES
(10000000, 12.5, '2024-01-15', 24, 1),
(5000000, 10.2, '2024-02-20', 12, 2),
(15000000, 15.0, '2024-03-10', 36, 3);
