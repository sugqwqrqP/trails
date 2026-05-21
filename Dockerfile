# syntax=docker/dockerfile:1
FROM ruby:3.1.6-slim

ENV LANG=C.UTF-8 \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3

WORKDIR /app

# Rails + sqlite3 のビルドに必要なもの
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      build-essential \
      git \
      libsqlite3-dev \
      sqlite3 \
      nodejs \
      npm \
    && rm -rf /var/lib/apt/lists/*

# Bundler
RUN gem install bundler -v 2.3.27

# 先にGemfileだけコピーしてbundle installをキャッシュさせる
COPY Gemfile Gemfile.lock ./
RUN bundle install

# アプリ本体
COPY . .

EXPOSE 3000

# コンテナ起動時にDB準備してRails起動
CMD ["bash", "-lc", "bin/rails db:prepare && bin/rails s -b 0.0.0.0 -p 3000"]
