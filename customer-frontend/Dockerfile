FROM node:25 as builder
WORKDIR /customer-frontend

COPY package.json package-lock.json ./
RUN npm install  --frozen-lockfile
COPY . .

RUN npm run build

From nginx:alpine AS runner 

WORKDIR /usr/share/nginx/html

COPY --from=builder /customer-frontend/dist .
EXPOSE 3000

CMD ["nginx", "-g", "daemon off;"]