#!/bin/bash
set -e
KUBECTL_PATH=/usr/local/bin/kubectl
# 安装依赖
NEED_INSTALL=${needInstall}
# 操作 
OPT_TYPE=${optType}
# 镜像名称
IMAGE_NAME=${imageName}:${imageTag}
# K8s Namespace 名称
NAMESPACE=${namespace}
# JOB 任务名称
JOB_NAME=${JOB_NAME}
# 是否已构建镜像
IS_IMAGE_BUILD=false
# 是否已推送镜像到 Habor 仓库
IS_IMAGE_PUSHED=false

echo "------------------------------------------------------------------------"
. ~/.nvm/nvm-0.39.3/nvm.sh
nvm use 16
rm -rf .nx
if [[ "$NEED_INSTALL" == "true" ]]; then
  npm config set register npm.com
  npm i
fi
echo "构建项目"
nx build resource-admin --skip-nx-cache
nvm use 14
echo "构建 Docker 镜像"
cp deploy/apps/resource-admin/docker/* dist/apps/resource-admin/
cd dist/apps/resource-admin/
docker build -t $IMAGE_NAME .
echo "推送 Docker 镜像..."
docker push $IMAGE_NAME
echo "部署开始"
echo "Namespace: $NAMESPACE"
IFS=',' read -ra envList <<< "$OPT_TYPE"
for env in "${envList[@]}"; do
  if [[ "$env" == "dev" ]]; then
    DEPLOYMENT=fe-cloud-resource-admin-dev-v1
  elif [[ "$env" == "auto" ]]; then
    DEPLOYMENT=fe-cloud-resource-admin-auto-v1
  fi
  
  if [ "$env" == "test"  ]; then
    # 通过helm来更新，后续传入参数执行流水线即可 IMAGE_NAME IMAGE_VERSION optType
    echo "更新 k8s集群 helm 应用..."
  elif [[ "$env" == "dev" ]] || [[ "$env" == "auto" ]]; then
    # 非测试环境直接 kubectl patch 更新
    echo "Deployment: $DEPLOYMENT"
    CONTAINER_NAME=$(kubectl get deployment $DEPLOYMENT -o=jsonpath='{.spec.template.spec.containers[0].name}' -n $NAMESPACE)
    echo "Container Name: $CONTAINER_NAME"
    kubectl patch deployment $DEPLOYMENT -p '{"spec":{"template":{"spec":{"containers":[{"name":"'$(echo $CONTAINER_NAME)'","image":"'$(echo $IMAGE_NAME)'"}]}}}}' -n $NAMESPACE
  fi
done
echo "------------------------------------------------------------------------"
