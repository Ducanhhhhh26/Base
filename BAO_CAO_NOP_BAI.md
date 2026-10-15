# BÁO CÁO BÀI THI DEVOPS FINAL - ĐỀ 001: QUẢN LÝ PHÒNG LAB

---

## 1. THÔNG TIN SINH VIÊN & THÔNG SỐ TRIỂN KHAI

- **Họ và tên**: Nguyễn Đức Anh
- **Mã sinh viên**: B24DTCN184
- **Lớp**: K24CNTT2
- **Email**: ducanhcualo2403@gmail.com
- **Mã đề thi**: 001
- **Đề tài**: Quản lý phòng Lab – hiển thị dữ liệu "Danh sách phòng Lab" dạng JSON
- **GitHub Repository**: [https://github.com/Ducanhhhhh26/Base.git](https://github.com/Ducanhhhhh26/Base.git) (nhánh `main`)
- **Tên Docker Compose Project**: `ducanh-de001`
- **Địa chỉ máy chủ (Server IP)**: `20.6.130.18`
- **Tài khoản SSH triển khai**: `danh`
- **Cổng truy cập ứng dụng (APP_PORT)**: `8081`
- **Đường dẫn truy cập Website**: [http://20.6.130.18:8081](http://20.6.130.18:8081)
- **Đường dẫn API lấy dữ liệu**: [http://20.6.130.18:8081/api/labs](http://20.6.130.18:8081/api/labs)

---

## 2. TỔNG QUAN KIẾN TRÚC & CÁC THÀNH PHẦN HOÀN THÀNH

```
Trình duyệt ── http://20.6.130.18:8081
    ▼
[nginx]  nginx:1.27-alpine        Cổng 8081:80, reverse proxy GET /* → app:8080
    ▼
[app]    Spring Boot 4 (JRE 21)   Cổng 8080, GET /api/labs → mysql:3306
    ▼
[mysql]  mysql:8.0                volume mysql_data, mạng db-net (cô lập an toàn)
```

### Các nội dung đã hoàn thành:
1. **Phần 1 - Khởi tạo repository & điền thông tin (10 điểm)**:
   - Repository public trên GitHub nhánh `main`.
   - File `student.env` đã khai báo đầy đủ các biến môi trường cấu hình ứng dụng và kết nối cơ sở dữ liệu.
2. **Phần 2 - Dockerfile multi-stage cho backend (25 điểm)**:
   - Stage `build`: Sử dụng `gradle:8.14-jdk21-alpine`, tối ưu hóa layer caching với `build.gradle` & `settings.gradle`.
   - Stage `runtime`: Sử dụng `eclipse-temurin:21-jre-alpine`, chạy dưới quyền user non-root `spring:spring`, mở cổng `EXPOSE 8080`.
3. **Phần 3 - Hoàn thiện docker-compose.yml (20 điểm)**:
   - Điền đầy đủ TODO 1–5 cho các service `app`, `nginx` và `mysql`.
   - Cấu hình healthcheck cho MySQL và dependency `condition: service_healthy` cho service app.
   - Kiểm tra thành công trên máy ảo: cả 3 container đều hoạt động (`Up`).
4. **Phần 4 - Pipeline CI/CD với GitHub Actions (35 điểm)**:
   - Cấu hình SSH ed25519 deploy key và 3 GitHub Secrets: `SERVER_HOST`, `SERVER_USER`, `SERVER_SSH_KEY`.
   - File `.github/workflows/ci-cd.yml` hoàn thiện đầy đủ TODO 1–6.
   - Job `build`: Build image, kiểm tra cấu hình, chạy smoke test và đẩy image lên GitHub Container Registry (`ghcr.io/ducanhhhhh26/base/app`) với 2 tag `latest` và commit SHA.
   - Job `deploy`: SSH vào máy chủ `20.6.130.18`, pull image mới nhất và khởi động hệ thống tự động không cần build lại trên server.
   - Pipeline trên nhánh `main` đạt kết quả xanh (Success) cả 2 job.
5. **Phần 5 - Minh chứng quá trình thực hiện (10 điểm)**:
   - Đầy đủ các hình ảnh minh chứng trong thư mục `screenshots/` và `submission-content/`.

---

## 3. DANH SÁCH ẢNH MINH CHỨNG (PHẦN 5)

| STT | Tên tệp minh chứng | Nội dung minh chứng |
| :---: | :--- | :--- |
| 1 | `01-actions.png` | Tab GitHub Actions trên nhánh `main` hoàn thành thành công cả 2 job **Build & Test** và **Deploy lên server**. |
| 2 | `02-ghcr.png` | GitHub Packages (GHCR) hiển thị image package của dự án với đầy đủ 2 tag: **`latest`** và **`<commit-SHA>`**. |
| 3 | `03-compose-ps.png` | Terminal trên máy ảo chạy lệnh `docker compose --env-file student.env ps` hiển thị 3 container `app`, `mysql`, `nginx` đều `Up`. |
| 4 | `04-website.png` | Trình duyệt Web truy cập `http://20.6.130.18:8081/api/labs` trả về đầy đủ danh sách 8 phòng Lab dạng JSON từ database MySQL. |
