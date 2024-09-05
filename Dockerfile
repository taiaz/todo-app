# Giai đoạn 1: Xây dựng ứng dụng React
FROM node:16-alpine as build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Giai đoạn 2: Thiết lập Nginx để phục vụ các tệp tĩnh
FROM nginx:alpine
# Sao chép các tệp tĩnh từ giai đoạn xây dựng
COPY --from=build /app/build /usr/share/nginx/html
# Cài đặt file cấu hình Nginx (nếu có)
COPY nginx.conf /etc/nginx/nginx.conf
# Mặc định Nginx chạy trên cổng 80
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]