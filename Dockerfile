FROM node:slim
EXPOSE 7860
WORKDIR /app
COPY web-linx /app/
ENV TZ="Asia/Shanghai" \
  NODE_ENV="production"
RUN chmod 775 web-linx
# Health check
HEALTHCHECK --interval=2m --timeout=30s \
  CMD wget --no-verbose --tries=1 --spider http://localhost:7860/health || exit 1
CMD ["./web-linx"]
