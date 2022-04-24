@echo off
@REM 项目目录以使本脚本在电脑任意都可以执行，如果直接放在项目根目录下，这里可注释不配置
cd c:/xx/x

: setFeatBranch
cls
set /p featBranch=请输入当前合并的分支名：
if "%featBranch%" == "" goto:setFeatBranch
echo %featBranch%
set /p envBranch=请输入合并的分支，多个分支空格隔开(默认值是dev sit alpha uat)：
echo %featBranch%
if "%envBranch%" == "" set envBranch=dev sit alpha uat
(for %%i in (%envBranch%) do (
  git checkout %%i
  git pull
  git merge %featBranch%
  git push
  echo "end with %%i"
))
