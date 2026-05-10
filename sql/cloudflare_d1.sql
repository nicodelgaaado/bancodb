PRAGMA foreign_keys = OFF;

DROP TABLE IF EXISTS transacciones;
DROP TABLE IF EXISTS prestamos;
DROP TABLE IF EXISTS cuentas;
DROP TABLE IF EXISTS empleados;
DROP TABLE IF EXISTS tipos_cuenta;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS sucursales;

PRAGMA foreign_keys = ON;

CREATE TABLE sucursales (
    id_sucursal integer PRIMARY KEY AUTOINCREMENT,
    nombre text NOT NULL,
    ciudad text NOT NULL,
    direccion text NOT NULL
);

CREATE TABLE empleados (
    id_empleado integer PRIMARY KEY AUTOINCREMENT,
    nombre text NOT NULL,
    cargo text NOT NULL,
    salario numeric NOT NULL CHECK (salario > 0),
    id_sucursal integer NOT NULL REFERENCES sucursales(id_sucursal)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE clientes (
    id_cliente integer PRIMARY KEY AUTOINCREMENT,
    nombre text NOT NULL,
    apellido text NOT NULL,
    telefono text NOT NULL,
    correo text NOT NULL UNIQUE,
    ciudad text NOT NULL
);

CREATE TABLE tipos_cuenta (
    id_tipo integer PRIMARY KEY AUTOINCREMENT,
    descripcion text NOT NULL UNIQUE
);

CREATE TABLE cuentas (
    id_cuenta integer PRIMARY KEY AUTOINCREMENT,
    numero_cuenta text NOT NULL UNIQUE,
    saldo numeric NOT NULL DEFAULT 0 CHECK (saldo >= 0),
    fecha_apertura text NOT NULL,
    estado text NOT NULL CHECK (estado IN ('Activa', 'Bloqueada')),
    id_cliente integer NOT NULL REFERENCES clientes(id_cliente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    id_tipo integer NOT NULL REFERENCES tipos_cuenta(id_tipo)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE transacciones (
    id_transaccion integer PRIMARY KEY AUTOINCREMENT,
    tipo text NOT NULL CHECK (tipo IN ('Deposito', 'Retiro', 'Transferencia')),
    monto numeric NOT NULL CHECK (monto > 0),
    fecha text NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_cuenta integer NOT NULL REFERENCES cuentas(id_cuenta)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE prestamos (
    id_prestamo integer PRIMARY KEY AUTOINCREMENT,
    monto numeric NOT NULL CHECK (monto > 0),
    tasa_interes numeric NOT NULL CHECK (tasa_interes >= 0),
    fecha_inicio text NOT NULL,
    cuotas integer NOT NULL CHECK (cuotas > 0),
    id_cliente integer NOT NULL REFERENCES clientes(id_cliente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE INDEX idx_empleados_id_sucursal ON empleados(id_sucursal);
CREATE INDEX idx_cuentas_id_cliente ON cuentas(id_cliente);
CREATE INDEX idx_cuentas_id_tipo ON cuentas(id_tipo);
CREATE INDEX idx_transacciones_id_cuenta ON transacciones(id_cuenta);
CREATE INDEX idx_prestamos_id_cliente ON prestamos(id_cliente);

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
