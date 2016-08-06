FROM ruby:alpine

RUN apk add --no-cache openssl gcc build-base

EXPOSE 4567
