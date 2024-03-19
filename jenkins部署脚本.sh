#!/bin/bash
KUBECTL_PATH=/usr/local/bin/kubectl
# 安装依赖
NEED_INSTALL=${needInstall}
# 操作
PROJECT=${project}
# JOB 任务名称
JOB_NAME=${JOB_NAME}
# K8s Namespace 名称
NAMESPACE=${namespace}
# 是否已构建镜像
IS_IMAGE_BUILD=false
# 是否已推送镜像到 Habor 仓库
IS_IMAGE_PUSHED=false

echo "------------------------------------------------------------------------"
if [[ "$NEED_INSTALL" == "true" ]]; then
  echo "安装依赖"
  lerna bootstrap
fi
IFS=',' read -ra projectList <<< "$PROJECT"  
for project in "${projectList[@]}"; do
  echo "构建项目"
  cd ./packages/${project}
  npm run build:test
  echo "构建 Docker 镜像"
  cd ./dist
  cp ../deploy/docker/* .
  # 镜像名称
  IMAGE_NAME=${imageName}-${project}:${imageTag}
  docker build -t $IMAGE_NAME .
  echo "推送 Docker 镜像"
  docker push $IMAGE_NAME
  echo "部署开始"
  echo "Namespace: $NAMESPACE"
  DEPLOYMENT=${project}-v1
  echo "Deployment: $DEPLOYMENT"
  CONTAINER_NAME=$(kubectl get deployment $DEPLOYMENT -o=jsonpath='{.spec.template.spec.containers[0].name}' -n $NAMESPACE)
  echo "Container Name: $CONTAINER_NAME"
  kubectl patch deployment $DEPLOYMENT -p '{"spec":{"template":{"spec":{"containers":[{"name":"'$(echo $CONTAINER_NAME)'","image":"'$(echo $IMAGE_NAME)'"}]}}}}' -n $NAMESPACE
  cd ../../../
done
echo "------------------------------------------------------------------------"
