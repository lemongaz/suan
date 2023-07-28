FROM node:slim
EXPOSE 7860
WORKDIR /app
COPY web-linux /app/
ENV TZ="Asia/Shanghai" \
  NODE_ENV="production"
RUN chmod 775 web-linux

CMD ["./web-linux"]
