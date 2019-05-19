FROM alpine:latest

RUN apk add nodejs

ARG    build_maint="DEF_MAINT"
ARG    build_branch="DEF_BRANCH"
ARG    build_commit="DEF_COMMIT"

LABEL branch=$build_branch \
      commit=$build_commit \
      maintaner=$build_maint

WORKDIR /app
COPY testcase-pybash/ /app

RUN ln -sf /dev/stdout /var/log/js.log

CMD [ "node", "/app/index.js" ]
