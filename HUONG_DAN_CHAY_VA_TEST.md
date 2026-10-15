# HƯỚNG DẪN TRIỂN KHAI VÀ KIỂM THỬ DỰ ÁN (ĐỀ 001 - QUẢN LÝ PHÒNG LAB)

> **Dự án**: Hệ thống quản lý phòng Lab - DevOps Final  
> **Sinh viên**: Nguyễn Đức Anh  
> **Mã sinh viên**: B24DTCN184  
> **Lớp**: K24CNTT2  
> **Cổng truy cập cá nhân**: `8081`  
> **Tên Project Compose**: `ducanh-de001`  
> **GitHub Repository**: [https://github.com/Ducanhhhhh26/Base.git](https://github.com/Ducanhhhhh26/Base.git)  

---

## ⚠️ LƯU Ý SỬA LỖI: `couldn't find env file: /home/danh/student.env`
Lỗi này xảy ra do bạn đang đứng ở thư mục gốc `/home/danh` (`~`) mà **chưa chuyển vào thư mục code (`cd Base`)**.  
Hãy làm đúng theo quy trình từng bước từ đầu dưới đây!

---

## MỤC LỤC
1. [Quy trình chạy lại từ đầu trên máy ảo (VM) - TỪNG BƯỚC](#1-quy-trình-chạy-lại-từ-đầu-trên-máy-ảo-vm---từng-bước)
2. [Kiểm tra API và Website](#2-kiểm-tra-api-và-website)
3. [Cấu hình SSH và GitHub Actions (CI/CD Deploy)](#3-cấu-hình-ssh-và-github-actions-cicd-deploy)
4. [Hướng dẫn chụp 4 ảnh minh chứng nộp bài (Phần 5 - 10 điểm)](#4-hướng-dẫn-chụp-4-ảnh-minh-chứng-nộp-bài-phần-5---10-điểm)
5. [Các lệnh hữu ích và xử lý sự cố](#5-các-lệnh-hữu-ích-và-xử-lý-sự-cố)

---

## 1. Quy trình chạy lại từ đầu trên máy ảo (VM) - TỪNG BƯỚC

Mở terminal máy ảo hoặc SSH vào máy ảo (bạn sẽ thấy prompt dạng `danh@Server:~$`).

### Bước 1: Dọn dẹp thư mục cũ (nếu có) để làm mới hoàn toàn
Chạy lệnh sau tại `danh@Server:~$`:
```bash
rm -rf Base devops-final-app-de001
```

---

### Bước 2: Clone repository mới nhất từ GitHub
```bash
git clone https://github.com/Ducanhhhhh26/Base.git
```

---

### Bước 3: BẮT BUỘC - Chuyển vào thư mục dự án `Base`
> 🔴 **CỰC KỲ QUAN TRỌNG**: Bạn phải gõ lệnh `cd Base` thì Docker mới nhìn thấy file `student.env` và `docker-compose.yml`.

```bash
cd Base
```
*Lúc này terminal sẽ hiển thị prompt:* `danh@Server:~/Base$`

---

### Bước 4: Kiểm tra danh sách file trong thư mục
```bash
ls -la
```
**Kết quả mong đợi**: Bạn sẽ thấy danh sách các file:
- `student.env`
- `docker-compose.yml`
- `Dockerfile`
- `build.gradle`
- `nginx/`
- `database/`
- `src/`

---

### Bước 5: Build và khởi động toàn bộ hệ thống
Chạy lệnh:
```bash
docker compose --env-file student.env up -d --build
```

> **Giải thích**:  
> - Docker sẽ tải base image `gradle:8.14-jdk21-alpine`, build mã nguồn Spring Boot ra file `app.jar`.  
> - Sau đó tạo container `app` (chạy JRE 21 với user non-root `spring`), container `mysql:8.0` và container `nginx:1.27-alpine`.  
> - Quá trình build lần đầu có thể mất từ 1 - 2 phút để tải dependencies, hãy kiên nhẫn chờ đến khi có thông báo `Started` cho cả 3 container.

---

### Bước 6: Kiểm tra trạng thái các container
```bash
docker compose --env-file student.env ps
```

**Kết quả mong đợi**: Cả 3 container đều có trạng thái `Up`:
- `ducanh-de001-mysql-1`: `Up (healthy)`
- `ducanh-de001-app-1`: `Up`
- `ducanh-de001-nginx-1`: `Up ... 0.0.0.0:8081->80/tcp`

📸 **CHỤP ẢNH MINH CHỨNG 3**:  
Chụp toàn bộ cửa sổ terminal hiển thị lệnh `docker compose --env-file student.env ps` và bảng trạng thái 3 container để lưu thành:  
`screenshots/03-compose-ps.png`

---

## 2. Kiểm tra API và Website

### 2.1. Kiểm tra trực tiếp trên máy ảo bằng `curl`

1. **Kiểm tra API lấy danh sách phòng Lab**:
   ```bash
   curl http://localhost:8081/api/labs
   ```
   **Kết quả trả về**: Chuỗi JSON gồm 8 phòng lab:
   ```json
   [{"id":1,"labName":"DevOps Lab","building":"A1","capacity":40,"equipment":"Máy chủ Dell R740, Switch Cisco","status":"Hoạt động",...}, ...]
   ```

2. **Kiểm tra redirect từ trang chủ `/`**:
   ```bash
   curl -I http://localhost:8081/
   ```
   **Kết quả trả về**: `HTTP/1.1 302 Moved Temporarily` và `Location: /api/labs`.

---

### 2.2. Kiểm tra trên trình duyệt từ máy tính thật (Windows)

1. Xem địa chỉ IP của máy ảo:
   ```bash
   hostname -I
   # hoặc
   ip a
   ```
   *(Ví dụ IP máy ảo là `192.168.1.50` hoặc IP public nếu dùng Cloud/Server trường)*.

2. Mở trình duyệt Web trên Windows (Chrome / Edge), nhập địa chỉ:
   ```
   http://<IP_MÁY_ẢO>:8081
   ```
   hoặc:
   ```
   http://<IP_MÁY_ẢO>:8081/api/labs
   ```

3. Màn hình trình duyệt sẽ hiển thị toàn bộ JSON dữ liệu các phòng lab.

📸 **CHỤP ẢNH MINH CHỨNG 4**:  
Chụp ảnh toàn màn hình trình duyệt hiển thị rõ thanh địa chỉ URL `http://<IP_MÁY_ẢO>:8081` và dữ liệu JSON để lưu thành:  
`screenshots/04-website.png`

---

## 3. Cấu hình SSH và GitHub Actions (CI/CD Deploy)

Pipeline CI/CD nằm ở file `.github/workflows/ci-cd.yml` sẽ tự động:
1. `build`: Build test, smoke test, đóng gói và push Docker Image lên GitHub Container Registry (`ghcr.io`).
2. `deploy`: SSH vào máy ảo/server, pull image mới về và chạy mà không build lại trên server.

### Bước 3.1: Tạo khóa SSH Deploy Key trên máy ảo
Trên máy ảo, chạy:
```bash
# Tạo cặp khóa SSH (ấn Enter nếu được hỏi)
ssh-keygen -t ed25519 -f deploy_key -N ""

# Thêm khóa công khai vào danh sách authorized_keys
mkdir -p ~/.ssh
chmod 700 ~/.ssh
cat deploy_key.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# In nội dung private key ra màn hình để copy
cat deploy_key
```

### Bước 3.2: Thêm 3 Secrets vào GitHub Repository
1. Mở repository trên trình duyệt: [https://github.com/Ducanhhhhh26/Base](https://github.com/Ducanhhhhh26/Base)
2. Chọn **Settings** -> **Secrets and variables** -> **Actions** -> bấm **New repository secret**.
3. Thêm lần lượt 3 secret:
   - `SERVER_HOST`: Địa chỉ IP của máy ảo / server (IP có thể SSH được).
   - `SERVER_USER`: `danh` (tài khoản SSH trên máy ảo).
   - `SERVER_SSH_KEY`: Copy toàn bộ nội dung hiển thị từ lệnh `cat deploy_key` ở trên (từ `-----BEGIN OPENSSH PRIVATE KEY-----` đến `-----END OPENSSH PRIVATE KEY-----`).

### Bước 3.3: Bật quyền ghi cho GitHub Packages (GHCR)
1. Trong repo, vào **Settings** -> **Actions** -> **General**.
2. Cuộn xuống mục **Workflow permissions**.
3. Chọn **Read and write permissions**.
4. Bấm **Save**.

### Bước 3.4: Chạy Pipeline
Mỗi khi có commit push lên nhánh `main`:
1. Vào tab **Actions** trên GitHub để theo dõi 2 job `build` và `deploy`.
2. Khi cả 2 job hiện tích xanh ✅:

📸 **CHỤP ẢNH MINH CHỨNG 1**:  
Chụp màn hình tab Actions hiển thị lần chạy thành công cả 2 jobs `build` và `deploy` để lưu thành:  
`screenshots/01-actions.png`

📸 **CHỤP ẢNH MINH CHỨNG 2**:  
Vào mục **Packages** trên GitHub (trang profile hoặc repo), xem package image `app` có hiển thị 2 tag `latest` và commit SHA. Chụp màn hình để lưu thành:  
`screenshots/02-ghcr.png`

---

## 4. Hướng dẫn chụp 4 ảnh minh chứng nộp bài (Phần 5 - 10 điểm)

| File ảnh minh chứng | Mô tả nội dung cần chụp |
|---------------------|--------------------------|
| `screenshots/01-actions.png` | Tab GitHub Actions: run trên nhánh `main` thành công tích xanh cả `build` và `deploy`. |
| `screenshots/02-ghcr.png` | GitHub Packages (GHCR): package image có đầy đủ 2 tag `latest` và commit SHA. |
| `screenshots/03-compose-ps.png` | Terminal máy ảo chạy lệnh: `docker compose --env-file student.env ps` với 3 container Up. |
| `screenshots/04-website.png` | Trình duyệt Web truy cập `http://<IP_MÁY_CHỦ>:8081` hiển thị danh sách phòng lab dạng JSON. |

> **Quy trình nộp bài cuối cùng**:  
> Sau khi có đủ 4 ảnh trên, bạn copy cả 4 file ảnh này vào thư mục `submission-content/` để nộp bài lên hệ thống RAIA theo đúng yêu cầu đề thi.

---

## 5. Các lệnh hữu ích và xử lý sự cố

### 1. Dừng các container:
```bash
docker compose --env-file student.env down
```

### 2. Dừng và xoá dữ liệu database để reset lại:
```bash
docker compose --env-file student.env down -v
```

### 3. Xem log khi cần debug lỗi:
```bash
# Xem log toàn bộ hệ thống
docker compose --env-file student.env logs -f

# Xem log riêng backend Spring Boot
docker compose --env-file student.env logs -f app

# Xem log Nginx
docker compose --env-file student.env logs -f nginx
```

### 4. Nếu bị lỗi cổng `8081` đã bị chiếm dụng:
Mở file `student.env` bằng lệnh:
```bash
nano student.env
```
Đổi giá trị `APP_PORT="8081"` thành `APP_PORT="8082"` hoặc `8085`. Sau đó chạy lại:
```bash
docker compose --env-file student.env up -d
```
