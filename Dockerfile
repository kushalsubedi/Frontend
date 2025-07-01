# -------- Stage 1: Base build, only deps --------
FROM node:18-alpine AS base

WORKDIR /app

COPY package*.json ./
COPY yarn.lock ./

RUN yarn install --frozen-lockfile


# -------- Stage 2: Dist build, create dist folder --------
FROM node:18-alpine AS builder

WORKDIR /app

COPY --from=base /app/node_modules ./node_modules
COPY . .

RUN yarn build


# -------- Stage 3: Production (use dist folder from above build) --------
FROM nginx:stable-alpine3.21-perl AS production

RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
ENTRYPOINT ["nginx", "-g", "daemon off;"]

