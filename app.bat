@echo off
setlocal enabledelayedexpansion
@REM 项目目录以使本脚本在电脑任意都可以执行，如果直接放在项目根目录下，这里可注释不配置
cd C:\Users\Admin\Desktop\project\app

: setFeatBranch
cls
set /p featBranch=请输入功能分支：
if "%featBranch%" == "" goto:setFeatBranch
: setProject
cls
set /p project=请输入项目：
if "%project%" == "" goto:setProject
set /p envBranch=请输入环境分支，多个环境空格隔开(默认为空即不发布到环境)：

set env=""
(for %%i in (%envBranch%) do (
  setlocal EnableDelayedExpansion
  if %%i == dev (
    set env=develop
  )
  if %%i == test (
    set env=testing-cmp
  )
  git checkout !env!
  git pull
  if not %errorlevel% == 0 pause
  git merge %featBranch%
  if not %errorlevel% == 0 pause
  git push
  if not %errorlevel% == 0 pause
  git push -f origin !env!:%%i-%project%
))
git checkout %featBranch%
pause