@echo off
@REM ��ĿĿ¼��ʹ���ű��ڵ������ⶼ����ִ�У����ֱ�ӷ�����Ŀ��Ŀ¼�£������ע�Ͳ�����
cd c:/xx/x

: setFeatBranch
cls
set /p featBranch=�����뵱ǰ�ϲ��ķ�֧����
if "%featBranch%" == "" goto:setFeatBranch
echo %featBranch%
set /p envBranch=������ϲ��ķ�֧�������֧�ո����(Ĭ��ֵ��dev sit alpha uat)��
echo %featBranch%
if "%envBranch%" == "" set envBranch=dev sit alpha uat
(for %%i in (%envBranch%) do (
  git checkout %%i
  git pull
  git merge %featBranch%
  git push
  echo "end with %%i"
))
