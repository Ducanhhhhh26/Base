# HƯỚNG DẪN TRIỂN KHAI VÀ KIỂM THỬ DỰ ÁN (ĐỀ 001 - QUẢN LÝ PHÒNG LAB)

> **Dự án**: Hệ thống quản lý phòng Lab - DevOps Final  
> **Sinh viên**: Nguyễn Đức Anh  
> **Mã sinh viên**: B24DTCN184  
> **Lớp**: K24CNTT2  
> **Cổng truy cập cá nhân**: `8081`  
> **Tên Project Compose**: `ducanh-de001`  
> **GitHub Repository**: [https://github.com/Ducanhhhhh26/Base.git](https://github.com/Ducanhhhhh26/Base.git)  

---

## MỤC LỤC
1. [Kiến trúc hệ thống](#1-kiến-trúc-hệ-thống)
2. [Chi tiết các file đã hoàn thiện theo đề thi](#2-chi-tiết-các-file-đã-hoàn-thiện-theo-đề-thi)
3. [Hướng dẫn chạy và kiểm thử trên máy ảo (VM)](#3-hướng-dẫn-chạy-và-kiểm-thử-trên-máy-ảo-vm)
4. [Hướng dẫn cấu hình SSH và GitHub Actions (CI/CD Deploy)](#4-hướng-dẫn-cấu-hình-ssh-và-github-actions-cicd-deploy)
5. [Hướng dẫn chụp và nộp ảnh minh chứng (Phần 5)](#5-hướng-dẫn-chụp-và-nộp-ảnh-minh-chứng-phần-5)
6. [Các lệnh hữu ích và xử lý sự cố thường gặp](#6-các-lệnh-hữu-ích-và-xử-lý-sự-cố-thường-gặp)

---

## 1. Kiến trúc hệ thống

```
Trình duyệt ── http://<IP_máy_chủ hoặc IP_VM>:8081
    ▼
[nginx]  nginx:1.27-alpine        Cổng 8081:80, GET /*  → app:8080 (Reverse proxy)
    ▼
[app]    Spring Boot 4 (JRE 21)   Cổng 8080, GET /api/labs → mysql:3306
    ▼
[mysql]  mysql:8.0                volume mysql_data, mạng db-net (KHÔNG public cổng ra ngoài)
```

- **Mạng `proxy-net`**: Kết nối giữa `nginx` và `app`.
- **Mạng `db-net`**: Kết nối giữa `app` và `mysql` (cô lập an toàn).
- **Volume `mysql_data`**: Lưu trữ dữ liệu bền vững của cơ sở dữ liệu `ptit_lab_db`.

---

## 2. Chi tiết các file đã hoàn thiện theo đề thi

### 2.1. File `student.env`
Đã điền đầy đủ thông tin:
- `STUDENT_NAME="Nguyễn Đức Anh"`
- `STUDENT_ID="B24DTCN184"`
- `STUDENT_CLASS="K24CNTT2"`
- `STUDENT_EMAIL="ducanhcualo2403@gmail.com"`
- `GITHUB_USERNAME="Ducanhhhhh26"`
- `EXAM_CODE="001"` (Giữ nguyên theo đề)
- `APP_PORT="8081"` (Cổng cá nhân >= 8080)
- `COMPOSE_PROJECT_NAME="ducanh-de001"` (Định dạng `<tên-viết-tắt>-de001`)
- `MYSQL_DATABASE="ptit_lab_db"` (Giữ nguyên theo đề)
- `MYSQL_USER="app_user"`
- `MYSQL_PASSWORD="AppPass@2026"`
- `MYSQL_ROOT_PASSWORD="RootPass@2026"`

### 2.2. File `Dockerfile` (Multi-stage build)
- **Stage 1 (`build`)**: Sử dụng base image `gradle:8.14-jdk21-alpine AS build`. Copy `build.gradle` và `settings.gradle` trước để chạy `gradle dependencies --no-daemon -q` tối ưu hóa cache layer của Docker. Sau đó copy `src/` và đóng gói với `gradle bootJar -x test --no-daemon -q`.
- **Stage 2 (`runtime`)**: Sử dụng base image siêu nhẹ `eclipse-temurin:21-jre-alpine AS runtime`. Thiết lập user thường `spring` (non-root) để nâng cao bảo mật. Copy file `app.jar` đã build từ stage 1. Nhận `ARG APP_VERSION` truyền vào `ENV APP_VERSION`. Khai báo `EXPOSE 8080` và khởi chạy qua `ENTRYPOINT ["java", "-jar", "/app/app.jar"]`.

### 2.3. File `docker-compose.yml`
- **TODO 1**: Khai báo `build.context: .` và truyền `args: APP_VERSION: ${APP_VERSION:-local}`.
- **TODO 2**: Đặt tên image dạng `${APP_IMAGE:-devops-final-app}:${APP_TAG:-latest}`.
- **TODO 3**: Đọc thông số cơ sở dữ liệu từ biến môi trường `student.env`: `${MYSQL_DATABASE}`, `${MYSQL_USER}`, `${MYSQL_PASSWORD}`.
- **TODO 4**: Ánh xạ cổng `${APP_PORT}:80` cho service `nginx`.
- **TODO 5**: Mount cấu hình Nginx `./nginx/default.conf:/etc/nginx/conf.d/default.conf:ro`.
- Cấu hình cơ chế `healthcheck` cho MySQL và `depends_on: mysql: condition: service_healthy` cho app.

### 2.4. File `.github/workflows/ci-cd.yml`
- Đã điền đầy đủ các TODO 1 đến 6:
  - **TODO 1**: Khởi động kiểm thử container: `docker compose --env-file student.env up -d --build --wait --wait-timeout 300`
  - **TODO 2**: Đăng nhập GitHub Container Registry (`ghcr.io`) với `docker/login-action@v3`.
  - **TODO 3**: Push image lên GHCR với 2 tags: commit SHA (`${{ github.sha }}`) và `latest`.
  - **TODO 4**: Khai báo `needs: build` cho job `deploy`.
  - **TODO 5**: Kết nối SSH tới server với các GitHub Secrets: `SERVER_HOST`, `SERVER_USER`, `SERVER_SSH_KEY`.
  - **TODO 6**: Script deploy: pull image mới và chạy `docker compose --env-file student.env up -d --no-build --wait --wait-timeout 300`.

---

## 3. Hướng dẫn chạy và kiểm thử trên máy ảo (VM)

### Bước 1: Chuẩn bị môi trường trên máy ảo (Ubuntu/Debian)
Đăng nhập vào máy ảo (qua SSH hoặc trực tiếp terminal máy ảo), đảm bảo máy ảo đã cài Docker và Docker Compose:

```bash
# Cập nhật package index
sudo apt update

# Cài đặt Docker và Docker Compose plugin
sudo apt install -y docker.io docker-compose-v2 curl git

# Đảm bảo dịch vụ docker đang chạy
sudo systemctl enable --now docker

# Thêm user hiện tại vào nhóm docker (để chạy lệnh không cần sudo)
sudo usermod -aG docker $USER

# Áp dụng nhóm mới (hoặc đăng xuất rồi đăng nhập lại)
newgrp docker
```

Kiểm tra:
```bash
docker --version
docker compose version
```

---

### Bước 2: Đưa mã nguồn lên máy ảo

**Cách 1: Clone trực tiếp từ GitHub** (Khuyên dùng sau khi bạn đã push code lên GitHub):
```bash
cd ~
git clone https://github.com/Ducanhhhhh26/Base.git devops-final-app-de001
cd devops-final-app-de001
```

**Cách 2: Sử dụng SCP/SFTP để copy từ máy Windows sang máy ảo**:
Từ máy Windows (PowerShell):
```powershell
scp -r "C:\Users\OS\Downloads\devops-final-app-de001\devops-final-app-de001" username@<IP_MÁY_ẢO>:~/devops-final-app-de001
```

---

### Bước 3: Chạy ứng dụng bằng Docker Compose trên máy ảo

Tại thư mục dự án trên máy ảo, chạy lệnh:

```bash
# Build image và khởi động các container
docker compose --env-file student.env up -d --build
```

> **Lưu ý**: Lần đầu tiên build, Gradle sẽ tải các dependencies và MySQL cần khoảng 20 - 30 giây để khởi tạo database lần đầu từ file `database/init.sql`.

---

### Bước 4: Kiểm tra trạng thái các container

Chạy lệnh:
```bash
docker compose --env-file student.env ps
```

**Kết quả mong đợi**:
Cả 3 container đều có trạng thái `Up` (hoặc `running`):
- `ducanh-de001-mysql-1`: `Up ... (healthy)`
- `ducanh-de001-app-1`: `Up ...`
- `ducanh-de001-nginx-1`: `Up ... 0.0.0.0:8081->80/tcp`

*(Chụp lại màn hình này để dùng cho ảnh minh chứng `03-compose-ps.png`)*.

---

### Bước 5: Kiểm tra API và Website

#### 1. Kiểm tra bằng `curl` ngay trên máy ảo:
```bash
curl http://localhost:8081/api/labs
```

**Kết quả mong đợi**:
Trả về chuỗi JSON chứa danh sách 8 phòng Lab có định dạng như sau:
```json
[
  {"id":1,"labName":"DevOps Lab","building":"A1","capacity":40,"equipment":"Máy chủ Dell R740, Switch Cisco","status":"Hoạt động","createdAt":"..."},
  {"id":2,"labName":"Cloud Lab","building":"A1","capacity":35,"equipment":"Cụm Proxmox 3 node","status":"Hoạt động","createdAt":"..."},
  ...
]
```

Kiểm tra chuyển hướng từ trang chủ `/`:
```bash
curl -I http://localhost:8081/
# Kết quả trả về: HTTP/1.1 302 Moved Temporarily và Location: /api/labs
```

#### 2. Kiểm tra từ trình duyệt trên máy thật (Windows):
- Xem IP của máy ảo: chạy lệnh `ip a` hoặc `hostname -I` trên máy ảo (Ví dụ: `192.168.1.50`).
- Mở trình duyệt Web trên Windows, truy cập địa chỉ:
  ```
  http://<IP_MÁY_ẢO>:8081/api/labs
  ```
  hoặc
  ```
  http://<IP_MÁY_ẢO>:8081
  ```
- Trình duyệt sẽ hiển thị toàn bộ danh sách phòng lab dạng JSON.  
*(Chụp ảnh toàn màn hình trình duyệt có thanh địa chỉ URL để làm minh chứng `04-website.png`)*.

---

### Bước 6: Dừng hệ thống khi muốn tắt hoặc reset dữ liệu

```bash
# Dừng các container
docker compose --env-file student.env down

# Hoặc dừng và xoá toàn bộ volume dữ liệu để reset lại database từ đầu
docker compose --env-file student.env down -v
```

---

## 4. Hướng dẫn cấu hình SSH và GitHub Actions (CI/CD Deploy)

Để pipeline GitHub Actions tự động build, test và deploy lên máy ảo / server:

### Bước 4.1: Tạo cặp khóa SSH Deploy Key
Bạn có thể tạo ngay trên máy ảo hoặc máy local:
```bash
ssh-keygen -t ed25519 -f deploy_key -N ""
```
Lệnh trên sẽ tạo ra 2 file:
- `deploy_key`: Khóa bí mật (Private key).
- `deploy_key.pub`: Khóa công khai (Public key).

Thêm khóa công khai vào danh sách khóa được phép trên máy ảo:
```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
cat deploy_key.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

### Bước 4.2: Cấu hình 3 Secrets trên GitHub Repository
1. Truy cập vào GitHub repo: `https://github.com/Ducanhhhhh26/Base`
2. Chọn **Settings** -> **Secrets and variables** -> **Actions** -> bấm **New repository secret**.
3. Tạo 3 secret sau:
   - `SERVER_HOST`: Địa chỉ IP của máy ảo / server (Lưu ý: IP này cần truy cập được từ internet, hoặc nếu dùng server trường/lab thì là IP public của server).
   - `SERVER_USER`: Tên tài khoản SSH trên server (ví dụ: `ubuntu` hoặc tên user của bạn).
   - `SERVER_SSH_KEY`: Copy toàn bộ nội dung trong file private key `deploy_key` (bao gồm cả dòng `-----BEGIN OPENSSH PRIVATE KEY-----` và `-----END OPENSSH PRIVATE KEY-----`).

### Bước 4.3: Cấu hình quyền cho GitHub Packages (GHCR)
Để job `build` có quyền push Docker Image lên GitHub Container Registry:
1. Trong repo GitHub, vào **Settings** -> **Actions** -> **General**.
2. Cuộn xuống phần **Workflow permissions**, chọn **Read and write permissions**.
3. Bấm **Save**.

### Bước 4.4: Kích hoạt Pipeline
Chỉ cần thực hiện lệnh `git push origin main`, GitHub Actions sẽ tự động chạy:
1. `Build & Test`: Kiểm tra `student.env` -> Build Compose -> Smoke test endpoint `/api/labs` -> Đăng nhập & Push image lên GHCR (`ghcr.io/ducanhhhhh26/base/app:latest` và `:commit-sha`).
2. `Deploy lên server`: Kết nối SSH vào server -> Git pull / clone -> Đăng nhập GHCR -> Pull image -> Khởi động lại hệ thống bằng Docker Compose mà không cần biên dịch lại trên server.

---

## 5. Hướng dẫn chụp và nộp ảnh minh chứng (Phần 5)

Theo yêu cầu đề thi, cần chuẩn bị 4 ảnh chụp minh chứng lưu vào thư mục `screenshots/`:

| Tên tệp ảnh | Nội dung cần chụp | Cách chụp |
|-------------|-------------------|-----------|
| `01-actions.png` | Tab **Actions** trên GitHub hiển thị pipeline chạy trên nhánh `main` thành công tích xanh cả 2 jobs **build** và **deploy**. | Vào GitHub -> tab **Actions** -> mở lần chạy mới nhất -> chụp màn hình hiển thị cả 2 node xanh. |
| `02-ghcr.png` | Trang GitHub Packages (GHCR) hiển thị image package của repo với 2 tags: `latest` và `<commit-SHA>`. | Vào trang Profile GitHub -> mục **Packages** (hoặc trong repo mục Packages) -> chụp chi tiết package image với 2 tag. |
| `03-compose-ps.png` | Terminal trên server / máy ảo chạy lệnh: `docker compose --env-file student.env ps` hiển thị 3 container đang chạy bình thường. | Chụp cửa sổ terminal hiển thị lệnh và bảng kết quả status các container. |
| `04-website.png` | Trình duyệt Web truy cập `http://<IP_máy_chủ>:8081` hiển thị danh sách phòng lab dạng JSON. | Mở trình duyệt, truy cập URL, chụp rõ thanh URL và nội dung JSON. |

> **Quy trình nộp bài theo đề**:
> Sau khi có đủ 4 ảnh minh chứng trong `screenshots/`, bạn copy cả 4 file ảnh này vào thư mục `submission-content/`. Sau đó nén hoặc dùng SFTP kéo thư mục dự án về máy nộp lên hệ thống RAIA.

---

## 6. Các lệnh hữu ích và xử lý sự cố thường gặp

### 1. Xem logs các container khi gặp lỗi:
```bash
# Xem log toàn bộ hệ thống
docker compose --env-file student.env logs -f

# Xem log riêng backend Spring Boot
docker compose --env-file student.env logs -f app

# Xem log MySQL
docker compose --env-file student.env logs -f mysql

# Xem log Nginx
docker compose --env-file student.env logs -f nginx
```

### 2. Sửa lỗi trùng cổng (Port already allocated):
Nếu cổng `8081` bị ứng dụng khác chiếm dụng, bạn chỉ cần sửa biến `APP_PORT` trong file `student.env` (ví dụ đổi thành `8082` hoặc `8085`), sau đó chạy lại:
```bash
docker compose --env-file student.env up -d
```

### 3. Kiểm tra kết nối trực tiếp vào MySQL container:
```bash
docker compose --env-file student.env exec mysql mysql -uapp_user -pAppPass@2026 ptit_lab_db -e "SELECT * FROM labs;"
```
