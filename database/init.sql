-- =============================================================================
--  database/init.sql - Khởi tạo dữ liệu cho đề 001: Quản lý phòng Lab
--  MySQL tự chạy file này ở LẦN KHỞI ĐỘNG ĐẦU TIÊN khi được mount vào
--  /docker-entrypoint-initdb.d/  (database và user do biến MYSQL_* tạo sẵn)
-- =============================================================================
SET NAMES utf8mb4;

USE ptit_lab_db;

CREATE TABLE IF NOT EXISTS labs (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    lab_name        VARCHAR(100) NOT NULL,
    building        VARCHAR(50) NOT NULL,
    capacity        INT NOT NULL,
    equipment       VARCHAR(150) NOT NULL,
    status          VARCHAR(30) NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO labs (lab_name, building, capacity, equipment, status) VALUES
    ('DevOps Lab', 'A1', 40, 'Máy chủ Dell R740, Switch Cisco', 'Hoạt động'),
    ('Cloud Lab', 'A1', 35, 'Cụm Proxmox 3 node', 'Hoạt động'),
    ('Network Lab', 'A2', 30, 'Router Cisco 4321', 'Bảo trì'),
    ('AI Lab', 'A3', 25, 'GPU NVIDIA RTX 4090', 'Hoạt động'),
    ('IoT Lab', 'A2', 30, 'Raspberry Pi, Arduino', 'Hoạt động'),
    ('Security Lab', 'A3', 20, 'Firewall FortiGate 60F', 'Tạm đóng'),
    ('Mobile Lab', 'B1', 45, 'MacBook Pro, iPhone 15', 'Hoạt động'),
    ('Data Lab', 'B1', 40, 'Máy trạm HP Z4', 'Hoạt động');
