FROM node:20-alpine AS builder
WORKDIR /admin-frontend
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build
FROM nginx:alpine AS runner
WORKDIR /usr/share/nginx/html
COPY --from=builder /admin-frontend/dist .
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
