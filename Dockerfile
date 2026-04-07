# syntax=docker/dockerfile:1
# Stage 1: Build Flutter Web
FROM debian:bullseye-slim AS build

# Installation des dépendances minimales pour Flutter
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    libglu1-mesa \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Fixer la version de Flutter pour la stabilité (équivalent à stable)
RUN git clone https://github.com/flutter/flutter.git -b stable /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Activer le Web et pré-télécharger les outils
ENV PUB_CACHE=/root/.pub-cache
ENV FLUTTER_NO_AUDIT=true
RUN flutter config --enable-web && flutter doctor

WORKDIR /app

# Copier seulement le nécessaire pour les dépendances
COPY pubspec.* ./

# 🚀 NETTOYAGE : On retire temporairement le cache pour "purger" les erreurs de Matrix4 et config
RUN flutter pub get

COPY . .

# Créer un .env vide à la racine pour éviter les erreurs de compilation (flutter_dotenv)
RUN touch .env

ARG API_URL
ARG SUPABASE_URL
ARG SUPABASE_ANON_KEY
ARG SUPABASE_BUCKET
ARG APP_NAME
ARG APP_VERSION

# 🚀 NETTOYAGE : On compile "à froid" pour reconstruire les liens
RUN flutter build web --release \
    --base-href / \
    --dart-define=API_URL=${API_URL} \
    --dart-define=SUPABASE_URL=${SUPABASE_URL} \
    --dart-define=SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY} \
    --dart-define=SUPABASE_BUCKET=${SUPABASE_BUCKET} \
    --dart-define=APP_NAME=${APP_NAME} \
    --dart-define=APP_VERSION=${APP_VERSION}

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Install gettext for envsubst (needed to inject $PORT at runtime)
RUN apk add --no-cache gettext

# Copy Flutter build output to Nginx html folder
COPY --from=build /app/build/web /usr/share/nginx/html

# Use custom Nginx config template
COPY nginx.conf /etc/nginx/conf.d/default.conf.template

EXPOSE 8080

# Versions et Cache (Détonateurs)
ARG CACHE_VERSION
ARG APP_VERSION
ENV CACHE_VERSION=${CACHE_VERSION}
ENV APP_VERSION=${APP_VERSION}

# At runtime, replace placeholders in Nginx config AND index.html
CMD sh -c "envsubst '\$PORT \$CACHE_VERSION' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf && \
           envsubst '\$APP_VERSION' < /usr/share/nginx/html/index.html > /usr/share/nginx/html/index.tmp && \
           mv /usr/share/nginx/html/index.tmp /usr/share/nginx/html/index.html && \
           nginx -g 'daemon off;'"