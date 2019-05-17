FROM alpine:latest
ARG build_logpath="js.log" 
ARG    build_maint="DEF_MAINT"
ARG    build_branch="DEF_BRANCH"
ARG    build_commit="DEF_COMMIT"
ENV logpath=$build_logpath \
    maint=$build_maint \
    branch=$buidl_branch \
    build_commit=$build_commit
WORKDIR /app
ADD $logpath /app/js.log
COPY testcase-pybash/ /app
RUN apk add nodejs 
CMD [ "node", "/app/index.js",">","js.log" ]
