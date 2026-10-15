# HƯỚNG DẪN TRIỂN KHAI VÀ ĐÁNH DẤU TỪNG PHẦN THEO ĐỀ BÀI (ĐỀ 001 - QUẢN LÝ PHÒNG LAB)

> **Dự án**: Hệ thống quản lý phòng Lab - DevOps Final  
> **Sinh viên**: Nguyễn Đức Anh | **Mã SV**: B24DTCN184 | **Lớp**: K24CNTT2  
> **Cổng truy cập cá nhân**: `8081` | **Compose Project**: `ducanh-de001`  
> **GitHub Repository**: [https://github.com/Ducanhhhhh26/Base.git](https://github.com/Ducanhhhhh26/Base.git)  

---

## 📌 BẢNG ĐỐI CHIẾU CÁC PHẦN ĐỀ BÀI VÀ THANG ĐIỂM (100 ĐIỂM)

| Phần trong đề thi | Thang điểm | Ảnh đề bài | Tệp tin & Lệnh thực hiện tương ứng |
| :--- | :---: | :---: | :--- |
| **Phần 1: Khởi tạo repo & điền thông tin** | **10 điểm** | **Ảnh 2, Ảnh 5** | - Tạo Git repo public, nhánh `main`<br>- File `student.env` đã điền đủ thông tin |
| **Phần 2: Dockerfile multi-stage cho backend** | **25 điểm** | **Ảnh 3, Ảnh 6** | - File `Dockerfile` (Stage 1 Gradle build cache, Stage 2 JRE 21 non-root `spring`) |
| **Phần 3: Hoàn thiện `docker-compose.yml`** | **20 điểm** | **Ảnh 4, Ảnh 6, Ảnh 7** | - File `docker-compose.yml` (TODO 1–5: app, mysql, nginx, port `8081:80`)<br>- Chạy `docker compose --env-file student.env up -d --build` |
| **Phần 4: Pipeline CI/CD GitHub Actions** | **35 điểm** | **Ảnh 7, Ảnh 8, Ảnh 9** | - Mục 4.1: Tạo SSH key & 3 Secrets (`SERVER_HOST`, `SERVER_USER`, `SERVER_SSH_KEY`)<br>- Mục 4.2: File `.github/workflows/ci-cd.yml`<br>- Mục 4.3: Push lên `main`, kích hoạt pipeline tự động build & deploy |
| **Phần 5: Nộp minh chứng** | **10 điểm** | **Ảnh 9, Ảnh 10** | - 4 ảnh chụp minh chứng lưu vào `screenshots/`<br>- Copy vào `submission-content/` để nộp |

---

## 🛠️ CHI TIẾT TỪNG PHẦN THEO ĐỀ BÀI VÀ CÁC BƯỚC THỰC HIỆN

---

### [PHẦN 1 - 10 ĐIỂM] KHỞI TẠO REPOSITORY & ĐIỀN THÔNG TIN SINH VIÊN
*(Đối chiếu: **Ảnh 2, Ảnh 5** trong đề thi)*

- **Yêu cầu đề bài**:
  1. Tạo repository GitHub public, đưa toàn bộ mã nguồn lên nhánh `main`.
  2. Điền đầy đủ file `student.env`: thông tin cá nhân, `APP_PORT` cá nhân (>= 8080), `COMPOSE_PROJECT_NAME` theo dạng `<tên-viết-tắt>-de001` (viết thường), tài khoản/mật khẩu MySQL. Giữ nguyên `EXAM_CODE="001"` và `MYSQL_DATABASE="ptit_lab_db"`.
- **Trạng thái đã hoàn thành trong code**:
  - Repo GitHub: `https://github.com/Ducanhhhhh26/Base.git` (nhánh `main`).
  - File `student.env` đã điền:
    - `STUDENT_NAME="Nguyễn Đức Anh"`
    - `STUDENT_ID="B24DTCN184"`
    - `STUDENT_CLASS="K24CNTT2"`
    - `STUDENT_EMAIL="ducanhcualo2403@gmail.com"`
    - `GITHUB_USERNAME="Ducanhhhhh26"`
    - `APP_PORT="8081"`
    - `COMPOSE_PROJECT_NAME="ducanh-de001"`
    - `MYSQL_DATABASE="ptit_lab_db"`, `MYSQL_USER="app_user"`, `MYSQL_PASSWORD="AppPass@2026"`, `MYSQL_ROOT_PASSWORD="RootPass@2026"`.

---

### [PHẦN 2 - 25 ĐIỂM] DOCKERFILE MULTI-STAGE CHO BACKEND
*(Đối chiếu: **Ảnh 3, Ảnh 6** trong đề thi)*

- **Yêu cầu đề bài**:
  - **Stage 1 (build)**: Base image `gradle:8.14-jdk21-alpine AS build`. Copy `build.gradle` và `settings.gradle` trước để chạy `gradle dependencies` nhằm tận dụng cache layer; sau đó mới copy thư mục `src/` và build file jar bằng lệnh `gradle bootJar -x test`.
  - **Stage 2 (runtime)**: Base image chỉ có JRE 21 (`eclipse-temurin:21-jre-alpine`). Copy file `app.jar` từ stage build. Chạy bằng user thường (non-root `spring`). Nhận `ARG APP_VERSION` gán vào `ENV APP_VERSION`. Mở cổng `EXPOSE 8080`, ENTRYPOINT dạng exec `["java", "-jar", "/app/app.jar"]`.
- **Trạng thái đã hoàn thành trong code**:
  - Đã cấu hình chuẩn 100% đúng cấu trúc trong file `Dockerfile`.

---

### [PHẦN 3 - 20 ĐIỂM] HOÀN THIỆN `docker-compose.yml` & CHẠY THỬ TRÊN MÁY ẢO
*(Đối chiếu: **Ảnh 4, Ảnh 6, Ảnh 7** trong đề thi)*

- **Yêu cầu đề bài**:
  - Service `mysql`: Đã có sẵn mạng `db-net`, volume `mysql_data`, healthcheck ping và mount file `database/init.sql`. KHÔNG public cổng MySQL ra ngoài máy chủ.
  - Service `app`:
    - **TODO 1**: Build từ thư mục gốc, build-arg `APP_VERSION: ${APP_VERSION:-local}`.
    - **TODO 2**: Image `${APP_IMAGE:-devops-final-app}:${APP_TAG:-latest}`.
    - **TODO 3**: Biến môi trường database đọc từ `student.env` (`${MYSQL_DATABASE}`, `${MYSQL_USER}`, `${MYSQL_PASSWORD}`).
    - `depends_on: mysql: condition: service_healthy`.
  - Service `nginx`:
    - **TODO 4**: Publish cổng cá nhân `${APP_PORT}:80` (cổng 8081 map ra 80 của container).
    - **TODO 5**: Mount cấu hình `./nginx/default.conf:/etc/nginx/conf.d/default.conf:ro`.

#### ▶ Hướng dẫn thao tác chạy trên máy ảo (VM):

1. **Chuẩn bị quyền Docker (chỉ cần chạy 1 lần trên máy ảo)**:
   ```bash
   sudo usermod -aG docker $USER
   newgrp docker
   ```
   *(Nếu cần, chạy thêm `sudo chmod 666 /var/run/docker.sock`)*.

2. **Clone mã nguồn về máy ảo**:
   ```bash
   git clone https://github.com/Ducanhhhhh26/Base.git
   cd Base
   ```
   *(Phải `cd Base` để vào thư mục chứa `student.env`)*.

3. **Chạy lệnh khởi động theo đúng đề bài (Ảnh 7)**:
   ```bash
   docker compose --env-file student.env up -d --build
   ```

4. **Kiểm tra trạng thái các container (Ảnh 7, Ảnh 10)**:
   ```bash
   docker compose --env-file student.env ps
   ```
   - Cả 3 container `mysql` (healthy), `app`, `nginx` đều ở trạng thái `Up`.
   - 📸 **Lấy ảnh minh chứng**: Chụp màn hình kết quả này lưu thành `screenshots/03-compose-ps.png`.

5. **Kiểm tra API dữ liệu (Ảnh 7, Ảnh 10)**:
   ```bash
   curl http://localhost:8081/api/labs
   ```
   - Trả về JSON 8 phòng Lab.
   - Mở trình duyệt trên máy thật: truy cập `http://<IP_MÁY_ẢO>:8081` hiển thị danh sách phòng lab.
   - 📸 **Lấy ảnh minh chứng**: Chụp ảnh màn hình trình duyệt lưu thành `screenshots/04-website.png`.

---

### [PHẦN 4 - 35 ĐIỂM] PIPELINE CI/CD VỚI GITHUB ACTIONS
*(Đối chiếu: **Ảnh 7, Ảnh 8, Ảnh 9** trong đề thi)*

- **Yêu cầu đề bài**:
  - **4.1. Chuẩn bị kết nối server (Ảnh 7)**:
    - Tạo khóa SSH: `ssh-keygen -t ed25519 -f deploy_key -N ""`
    - Đưa public key vào `~/.ssh/authorized_keys` trên máy ảo/server.
    - Cấu hình 3 GitHub Secrets: `SERVER_HOST`, `SERVER_USER`, `SERVER_SSH_KEY`.
  - **4.2. Hoàn thiện `.github/workflows/ci-cd.yml` (Ảnh 8, Ảnh 9)**:
    - **TODO 1**: Build và khởi động bằng `docker compose --env-file student.env up -d --build --wait --wait-timeout 300`.
    - **TODO 2**: Đăng nhập GHCR bằng `github.actor` và `secrets.GITHUB_TOKEN`.
    - **TODO 3**: Push image lên GHCR với 2 tag: commit SHA (`${{ github.sha }}`) và `latest`.
    - **TODO 4**: Job `deploy` chỉ chạy khi job `build` thành công (`needs: build`).
    - **TODO 5 / TODO 6**: Kết nối SSH bằng các secret `SERVER_HOST`, `SERVER_USER`, `SERVER_SSH_KEY`.
    - **TODO 6 / TODO 7**: Trên server pull image mới của service `app` và chạy `docker compose --env-file student.env up -d --no-build --wait --wait-timeout 300` (KHÔNG build trên server).
  - **4.3. Chạy pipeline & kiểm tra (Ảnh 9)**:
    - Push lên `main`: Tab Actions trên GitHub hiển thị cả 2 job `build` và `deploy` thành công tích xanh.
    - Mở `http://<IP_máy_chủ>:8081`: hiển thị danh sách phòng lab.

#### ▶ Các bước thiết lập trên GitHub:
1. Vào repo GitHub `https://github.com/Ducanhhhhh26/Base` -> **Settings** -> **Secrets and variables** -> **Actions**:
   - Thêm `SERVER_HOST`: IP máy ảo.
   - Thêm `SERVER_USER`: `danh`
   - Thêm `SERVER_SSH_KEY`: Nội dung file `deploy_key` (private key).
2. Vào **Settings** -> **Actions** -> **General** -> cuộn xuống **Workflow permissions** -> chọn **Read and write permissions** -> bấm **Save**.
3. Khi push code lên `main`, vào tab **Actions** theo dõi pipeline chạy thành công.
   - 📸 **Lấy ảnh minh chứng**: Chụp màn hình tab Actions thành công lưu thành `screenshots/01-actions.png`.
   - 📸 **Lấy ảnh minh chứng**: Chụp màn hình GitHub Packages (GHCR) với 2 tag lưu thành `screenshots/02-ghcr.png`.

---

### [PHẦN 5 - 10 ĐIỂM] NỘP ẢNH MINH CHỨNG
*(Đối chiếu: **Ảnh 4, Ảnh 9, Ảnh 10** trong đề thi)*

Bổ sung đầy đủ 4 ảnh minh chứng vào thư mục `screenshots/`:

| Tên file ảnh | Nội dung theo yêu cầu đề bài | Nguồn lấy ảnh |
| :--- | :--- | :--- |
| `01-actions.png` | Tab Actions: run trên `main` thành công cả `build` và `deploy`. | Chụp tab Actions trên GitHub repo. |
| `02-ghcr.png` | Package image trên GHCR với 2 tag: commit SHA và `latest`. | Chụp trang GitHub Packages của tài khoản / repo. |
| `03-compose-ps.png` | Kết quả lệnh `docker compose --env-file student.env ps` trên server. | Chụp cửa sổ terminal máy ảo hiển thị 3 container `Up`. |
| `04-website.png` | Browser hiển thị danh sách phòng lab dạng JSON. | Chụp trình duyệt web truy cập `http://<IP_MÁY_ẢO>:8081`. |

> 📦 **Quy trình nộp bài cuối cùng (Ảnh 4)**:  
> Copy cả 4 file ảnh từ thư mục `screenshots/` sang thư mục `submission-content/`.  
> Sau đó nén hoặc dùng SFTP kéo thư mục dự án về máy tính và nộp lên hệ thống thi RAIA.
