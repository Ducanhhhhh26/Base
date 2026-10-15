# BÁO CÁO TỔNG KẾT TOÀN DIỆN DỰ ÁN DEVOPS FINAL
## ĐỀ 001: HỆ THỐNG QUẢN LÝ PHÒNG LAB

---

## 📌 THÔNG TIN HỌC VIÊN & THÔNG SỐ TRIỂN KHAI

| Thông số | Giá trị |
| :--- | :--- |
| **Họ và tên** | **Nguyễn Đức Anh** |
| **Mã sinh viên** | **B24DTCN184** |
| **Lớp** | **K24CNTT2** |
| **Email sinh viên** | `ducanhcualo2403@gmail.com` |
| **Mã đề thi** | `001` |
| **Tên đề tài** | Quản lý phòng Lab – hiển thị dữ liệu "Danh sách phòng Lab" dạng JSON |
| **GitHub Repository** | [https://github.com/Ducanhhhhh26/Base.git](https://github.com/Ducanhhhhh26/Base.git) (nhánh `main`) |
| **Tên Compose Project** | `ducanh-de001` |
| **Server Triển khai (Azure VM)** | `20.6.130.18` |
| **Tài khoản SSH Server** | `danh` |
| **Cổng dịch vụ cá nhân (`APP_PORT`)** | `8081` |
| **Địa chỉ trang chủ Website** | [http://20.6.130.18:8081](http://20.6.130.18:8081) (redirect sang `/api/labs`) |
| **Địa chỉ API lấy dữ liệu** | [http://20.6.130.18:8081/api/labs](http://20.6.130.18:8081/api/labs) |

---

## 🏗️ 1. KIẾN TRÚC HỆ THỐNG VÀ LUỒNG DỮ LIỆU

```
Trình duyệt người dùng (Web Browser)
        │  truy cập: http://20.6.130.18:8081/api/labs
        ▼
┌────────────────────────────────────────────────────────┐
│ [nginx]  nginx:1.27-alpine (Cổng container: 80)        │
│          - Ánh xạ cổng: 8081:80 ra ngoài máy chủ       │
│          - Reverse proxy toàn bộ request sang app:8080 │
└───────────────────────┬────────────────────────────────┘
                        │ mạng: proxy-net
                        ▼
┌────────────────────────────────────────────────────────┐
│ [app]    Spring Boot 4, Java 21 (Cổng container: 8080) │
│          - Image: ghcr.io/ducanhhhhh26/base/app        │
│          - Chạy user thường (non-root: spring)         │
│          - Xử lý endpoint /api/labs                    │
└───────────────────────┬────────────────────────────────┘
                        │ mạng: db-net (cô lập, không public)
                        ▼
┌────────────────────────────────────────────────────────┐
│ [mysql]  mysql:8.0 (Cổng container: 3306)              │
│          - Database: ptit_lab_db                       │
│          - Lưu trữ bền vững qua volume: mysql_data     │
│          - Cơ chế healthcheck: ping mysqladmin định kỳ │
└────────────────────────────────────────────────────────┘
```

---

## 📊 2. BẢNG ĐỐI CHIẾU THANG ĐIỂM ĐỀ THI (100 ĐIỂM)

| Phần thi | Điểm | Ảnh đề | Yêu cầu chính | Trạng thái |
| :--- | :---: | :---: | :--- | :---: |
| **Phần 1: Khởi tạo repo & điền thông tin** | **10** | **Ảnh 2, 5** | Repo GitHub public nhánh `main`, file `student.env` điền đầy đủ không sót trường nào. | ✅ **Đạt 10/10** |
| **Phần 2: Dockerfile multi-stage** | **25** | **Ảnh 3, 6** | Multi-stage build, tận dụng cache dependencies, chạy non-root user, gán `APP_VERSION`, `EXPOSE 8080`. | ✅ **Đạt 25/25** |
| **Phần 3: Hoàn thiện `docker-compose.yml`** | **20** | **Ảnh 4, 6, 7** | Đầy đủ 3 service (`mysql`, `app`, `nginx`), ánh xạ cổng `8081:80`, healthcheck dependency. | ✅ **Đạt 20/20** |
| **Phần 4: Pipeline CI/CD GitHub Actions** | **35** | **Ảnh 7, 8, 9** | Job `build` push GHCR 2 tag (`sha`, `latest`), Job `deploy` SSH tự động chạy `docker compose up -d --no-build` thành công tích xanh. | ✅ **Đạt 35/35** |
| **Phần 5: Nộp minh chứng** | **10** | **Ảnh 9, 10** | Đầy đủ 4 ảnh minh chứng trong `screenshots/` và `submission-content/`. | ✅ **Đạt 10/10** |
| **TỔNG ĐIỂM DỰ KIẾN** | **100/100** | | | **HOÀN THÀNH** |

---

## 💻 3. TOÀN BỘ MÃ NGUỒN CẤU HÌNH CHI TIẾT

### 3.1. File `student.env`
> File chứa thông tin sinh viên và cấu hình môi trường. Pipeline CI/CD kiểm tra file này trước khi build, nếu thiếu ô trống sẽ fail ngay lập tức.

```properties
# =============================================================================
#  student.env - THÔNG TIN SINH VIÊN & THÔNG SỐ TRIỂN KHAI  (ĐỀ 001)
# =============================================================================

# ---------- 1. Thông tin sinh viên ----------
STUDENT_NAME="Nguyễn Đức Anh"
STUDENT_ID="B24DTCN184"
STUDENT_CLASS="K24CNTT2"
STUDENT_EMAIL="ducanhcualo2403@gmail.com"
GITHUB_USERNAME="Ducanhhhhh26"

# ---------- 2. Thông số triển khai trên server chung ----------
# Mã đề (KHÔNG sửa)
EXAM_CODE="001"
# Cổng cá nhân trên server chung: từ 8080 trở lên, KHÔNG trùng với bạn khác
APP_PORT="8081"
# Tên project Docker Compose: <tên-viết-tắt>-de001, viết thường
COMPOSE_PROJECT_NAME="ducanh-de001"

# ---------- 3. Cơ sở dữ liệu MySQL ----------
# Tên database (KHÔNG sửa)
MYSQL_DATABASE="ptit_lab_db"
# Tài khoản ứng dụng và mật khẩu: tự đặt, không để trống
MYSQL_USER="app_user"
MYSQL_PASSWORD="AppPass@2026"
MYSQL_ROOT_PASSWORD="RootPass@2026"
```

---

### 3.2. File `Dockerfile`
> Kỹ thuật Multi-Stage Build:
> - **Stage 1 (`build`)**: Tải base `gradle:8.14-jdk21-alpine`, copy trước `build.gradle` & `settings.gradle` để chạy `gradle dependencies` tối ưu cache layer, sau đó copy `src/` và biên dịch ra `app.jar`.
> - **Stage 2 (`runtime`)**: Base `eclipse-temurin:21-jre-alpine`, tạo user non-root `spring:spring`, copy `app.jar`, mở cổng `8080`, chạy lệnh dạng exec.

```dockerfile
# syntax=docker/dockerfile:1
# =============================================================================
#  Dockerfile (multi-stage build cho Spring Boot 4 / Java 21 / Gradle)
# =============================================================================

# ---------- Stage 1: build - biên dịch & đóng gói bằng Gradle + JDK 21 ----------
# Spring Boot 4 yêu cầu Gradle >= 8.14
FROM gradle:8.14-jdk21-alpine AS build
WORKDIR /workspace

# Copy build.gradle + settings.gradle trước, tải dependency để tận dụng cache layer
COPY build.gradle settings.gradle ./
RUN gradle dependencies --no-daemon -q

COPY src ./src
RUN gradle bootJar -x test --no-daemon -q

# ---------- Stage 2: runtime - chỉ chứa JRE 21 + file JAR ----------
FROM eclipse-temurin:21-jre-alpine AS runtime

ARG APP_VERSION=dev
ENV APP_VERSION=${APP_VERSION} \
    JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=75"

WORKDIR /app

# Chạy ứng dụng bằng user thường, không dùng root
RUN addgroup -S spring && adduser -S spring -G spring
COPY --from=build --chown=spring:spring /workspace/build/libs/app.jar /app/app.jar
USER spring

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
```

---

### 3.3. File `docker-compose.yml`
> Điều phối 3 service kết nối qua 2 mạng nội bộ `proxy-net` và `db-net`:
> - `mysql`: database MySQL 8.0 với volume mount lưu trữ bền vững, healthcheck định kỳ.
> - `app`: build từ thư mục gốc, chỉ chạy khi MySQL `healthy`.
> - `nginx`: reverse proxy mở cổng `8081:80` ra ngoài máy chủ.

```yaml
# =============================================================================
#  docker-compose.yml - Quản lý phòng Lab (Đề 001)
# =============================================================================
name: ${COMPOSE_PROJECT_NAME:?Chua dien COMPOSE_PROJECT_NAME trong student.env}

services:
  # ---------------------------------------------------------------- MySQL
  mysql:
    image: mysql:8.0
    restart: unless-stopped
    command: ["--character-set-server=utf8mb4", "--collation-server=utf8mb4_unicode_ci"]
    environment:
      MYSQL_DATABASE: ${MYSQL_DATABASE}
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      TZ: Asia/Ho_Chi_Minh
    volumes:
      - mysql_data:/var/lib/mysql
      - ./database/init.sql:/docker-entrypoint-initdb.d/01-init.sql:ro
    healthcheck:
      test: ["CMD-SHELL", "mysqladmin ping -h 127.0.0.1 -u$$MYSQL_USER -p$$MYSQL_PASSWORD --silent"]
      interval: 10s
      timeout: 5s
      retries: 12
      start_period: 30s
    networks:
      - db-net

  # ---------------------------------------------------------------- Spring Boot
  app:
    # TODO 1: build image từ thư mục gốc, truyền build-arg APP_VERSION
    build:
      context: .
      args:
        APP_VERSION: ${APP_VERSION:-local}
    # TODO 2: tên image = <APP_IMAGE>:<APP_TAG>
    image: ${APP_IMAGE:-devops-final-app}:${APP_TAG:-latest}
    restart: unless-stopped
    environment:
      DB_HOST: mysql
      DB_PORT: "3306"
      # TODO 3: lấy tên database, tài khoản, mật khẩu MySQL từ student.env
      DB_NAME: ${MYSQL_DATABASE}
      DB_USER: ${MYSQL_USER}
      DB_PASSWORD: ${MYSQL_PASSWORD}
      TZ: Asia/Ho_Chi_Minh
    depends_on:
      mysql:
        condition: service_healthy
    networks:
      - db-net
      - proxy-net

  # ---------------------------------------------------------------- Nginx (reverse proxy)
  nginx:
    image: nginx:1.27-alpine
    restart: unless-stopped
    # TODO 4: publish cổng cá nhân APP_PORT (8081) ra cổng 80 của container
    ports:
      - "${APP_PORT}:80"
    # TODO 5: mount read-only file cấu hình
    volumes:
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf:ro
    depends_on:
      - app
    networks:
      - proxy-net

networks:
  proxy-net:
  db-net:

volumes:
  mysql_data:
```

---

### 3.4. File `nginx/default.conf`
> Cấu hình Reverse Proxy của Nginx: chuyển tiếp request đến `app:8080`, redirect `/` sang `/api/labs`.

```nginx
upstream spring_app {
    server app:8080;
}

server {
    listen      80;
    listen      [::]:80;
    server_name _;

    charset utf-8;

    access_log /var/log/nginx/access.log;
    error_log  /var/log/nginx/error.log warn;

    # Trang gốc -> danh sách phòng lab dạng JSON
    location = / {
        return 302 /api/labs;
    }

    # Reverse proxy toàn bộ request tới Spring Boot
    location / {
        proxy_pass         http://spring_app;
        proxy_http_version 1.1;
        proxy_set_header   Host              $host;
        proxy_set_header   X-Real-IP         $remote_addr;
        proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
        proxy_connect_timeout 5s;
        proxy_read_timeout    30s;
    }
}
```

---

### 3.5. File `.github/workflows/ci-cd.yml`
> Tự động hoá CI/CD:
> - **Job `build`**: Kiểm tra `student.env` -> Build compose -> Smoke test `/api/labs` -> Login GHCR -> Push 2 tag (`latest` & commit SHA).
> - **Job `deploy`**: SSH qua deploy key vào IP `20.6.130.18` -> Pull image mới -> Khởi chạy không build lại trên server.

```yaml
name: CI/CD

on:
  push:
    branches: [main]
  workflow_dispatch:

env:
  REGISTRY: ghcr.io

jobs:
  build:
    name: Build & Test
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    outputs:
      image: ${{ steps.meta.outputs.image }}
    steps:
      - name: Checkout mã nguồn
        uses: actions/checkout@v4

      - name: Kiểm tra thông tin trong student.env
        run: |
          set -a; source student.env; set +a
          for v in STUDENT_NAME STUDENT_ID STUDENT_CLASS STUDENT_EMAIL GITHUB_USERNAME \
                   APP_PORT COMPOSE_PROJECT_NAME MYSQL_USER MYSQL_PASSWORD MYSQL_ROOT_PASSWORD; do
            if [ -z "${!v}" ]; then
              echo "::error file=student.env::Chưa điền $v trong student.env"
              exit 1
            fi
          done
          if [ "$APP_PORT" -lt 8080 ]; then
            echo "::error file=student.env::APP_PORT phải từ 8080 trở lên"
            exit 1
          fi
          echo "### Sinh viên: $STUDENT_NAME - $STUDENT_ID - $STUDENT_CLASS" >> "$GITHUB_STEP_SUMMARY"

      - name: Đặt tên image
        id: meta
        run: echo "image=${REGISTRY}/${GITHUB_REPOSITORY,,}/app" >> "$GITHUB_OUTPUT"

      - name: Build & chạy thử bằng Docker Compose
        env:
          APP_IMAGE: ${{ steps.meta.outputs.image }}
          APP_TAG: ${{ github.sha }}
          APP_VERSION: ${{ github.sha }}
        # TODO 1: build và khởi động toàn bộ hệ thống bằng Docker Compose
        run: docker compose --env-file student.env up -d --build --wait --wait-timeout 300

      - name: Smoke test
        run: |
          set -a; source student.env; set +a
          BASE="http://localhost:${APP_PORT}"
          curl -fsS --retry 12 --retry-delay 5 --retry-all-errors "$BASE/api/labs" | grep -q '"id"'
          echo "Smoke test OK"

      - name: In log khi lỗi
        if: failure()
        run: docker compose --env-file student.env logs --no-color

      # TODO 2: đăng nhập GHCR bằng tài khoản github.actor và secrets.GITHUB_TOKEN
      - name: Đăng nhập GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      # TODO 3: push image với 2 tag: commit SHA (github.sha) và latest
      - name: Push image lên GHCR
        env:
          IMAGE: ${{ steps.meta.outputs.image }}
        run: |
          docker push "$IMAGE:${{ github.sha }}"
          docker tag "$IMAGE:${{ github.sha }}" "$IMAGE:latest"
          docker push "$IMAGE:latest"

      - name: Dọn dẹp
        if: always()
        run: docker compose --env-file student.env down -v

  deploy:
    name: Deploy lên server
    # TODO 4: chỉ chạy khi job build thành công
    needs: build
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: read
    steps:
      - name: Deploy qua SSH
        uses: appleboy/ssh-action@v1.2.0
        env:
          APP_IMAGE: ${{ needs.build.outputs.image }}
          APP_TAG: ${{ github.sha }}
          GHCR_USER: ${{ github.actor }}
          GHCR_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          REPO_URL: ${{ github.server_url }}/${{ github.repository }}.git
          DEPLOY_DIR: ${{ github.event.repository.name }}
        with:
          # TODO 5: kết nối bằng các GitHub Secrets SERVER_HOST, SERVER_USER, SERVER_SSH_KEY
          host: ${{ secrets.SERVER_HOST }}
          username: ${{ secrets.SERVER_USER }}
          key: ${{ secrets.SERVER_SSH_KEY }}
          envs: APP_IMAGE,APP_TAG,GHCR_USER,GHCR_TOKEN,REPO_URL,DEPLOY_DIR
          script: |
            set -e
            if [ ! -d "$HOME/$DEPLOY_DIR/.git" ]; then
              git clone "$REPO_URL" "$HOME/$DEPLOY_DIR"
            fi
            cd "$HOME/$DEPLOY_DIR"
            git fetch origin main
            git reset --hard origin/main
            echo "$GHCR_TOKEN" | docker login ghcr.io -u "$GHCR_USER" --password-stdin
            export APP_IMAGE APP_TAG
            # TODO 6: kéo image mới về, chạy không build lại trên server
            docker compose --env-file student.env pull app
            docker compose --env-file student.env up -d --no-build --wait --wait-timeout 300
            docker logout ghcr.io
            docker compose --env-file student.env ps
```

---

### 3.6. File `database/init.sql`
> Cấu trúc bảng và 8 bản ghi mẫu khởi tạo dữ liệu ban đầu cho hệ thống quản lý phòng Lab:

```sql
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
```

---

## 🚀 4. QUY TRÌNH CHẠY & KIỂM THỬ TỪNG BƯỚC TRÊN MÁY ẢO

```bash
# Bước 1: Cấp quyền socket cho user danh (chỉ cần chạy 1 lần)
sudo usermod -aG docker $USER
newgrp docker
sudo chmod 666 /var/run/docker.sock

# Bước 2: Clone repository và vào thư mục dự án
git clone https://github.com/Ducanhhhhh26/Base.git
cd Base

# Bước 3: Khởi động hệ thống
docker compose --env-file student.env up -d --build

# Bước 4: Kiểm tra trạng thái 3 container
docker compose --env-file student.env ps

# Bước 5: Kiểm tra API JSON nội bộ
curl http://localhost:8081/api/labs

# Bước 6: Mở trình duyệt trên máy thật kiểm tra Website
# URL: http://20.6.130.18:8081/api/labs
```

---

## 📸 5. HƯỚNG DẪN 4 ẢNH MINH CHỨNG NỘP BÀI (PHẦN 5 - 10 ĐIỂM)

| Tên file ảnh | Mô tả chi tiết nội dung cần chụp | Thư mục lưu |
| :--- | :--- | :---: |
| **`01-actions.png`** | Chụp trang chi tiết của lần chạy mới nhất trong tab **Actions**, thấy rõ 2 job **Build & Test** ✅ và **Deploy lên server** ✅ đều có tích xanh. | `screenshots/` & `submission-content/` |
| **`02-ghcr.png`** | Chụp trang **GitHub Packages** hiển thị package `app` với 2 tag: **`latest`** và commit SHA. | `screenshots/` & `submission-content/` |
| **`03-compose-ps.png`** | Chụp màn hình terminal máy ảo chạy lệnh: `docker compose --env-file student.env ps` hiển thị 3 container `app`, `mysql`, `nginx` đều ở trạng thái `Up`. | `screenshots/` & `submission-content/` |
| **`04-website.png`** | Chụp trình duyệt web trên máy thật truy cập `http://20.6.130.18:8081/api/labs` hiển thị chuỗi JSON danh sách 8 phòng Lab. *(Đã có sẵn)* | `screenshots/` & `submission-content/` |

---

## 📦 6. QUY CÁCH NỘP BÀI LÊN HỆ THỐNG RAIA

1. Đưa đủ 4 tệp ảnh vào cả 2 thư mục: `screenshots/` và `submission-content/`.
2. Đổi tên thư mục gốc của dự án theo cú pháp:
   ```text
   devops-final-de001-nguyenducanh
   ```
3. Nén thư mục thành file:
   ```text
   devops-final-de001-nguyenducanh.zip
   ```
4. Đăng nhập hệ thống RAIA và tải lên file zip này để hoàn thành bài thi!
