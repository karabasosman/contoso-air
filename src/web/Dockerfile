# syntax=docker/dockerfile:1
FROM node:20-alpine AS base
WORKDIR /usr/src/app


# Sadece package dosyalarını kopyala ve bağımlılıkları yükle (cache için)
COPY package*.json ./
RUN npm ci --omit=dev

# Uygulama dosyalarını kopyala
COPY . .

# Portu belirt
EXPOSE 3000

# Production ortamı
ENV NODE_ENV=production

# Non-root user oluştur ve kullan
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Uygulamayı başlat
CMD ["node", "./bin/www"]
