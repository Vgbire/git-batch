@echo off
setlocal enabledelayedexpansion
@REM ��ĿĿ¼��ʹ���ű��ڵ������ⶼ����ִ�У����ֱ�ӷ�����Ŀ��Ŀ¼�£������ע�Ͳ�����
cd C:\Users\Admin\Desktop\project\app

: setFeatBranch
cls
set /p featBranch=�����빦�ܷ�֧��
if "%featBranch%" == "" goto:setFeatBranch
: setProject
cls
set /p project=��������Ŀ��
if "%project%" == "" goto:setProject
set /p envBranch=�����뻷����֧����������ո����(Ĭ��Ϊ�ռ�������������)��

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