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

CMD [ "node", "/app/index.js" ]
