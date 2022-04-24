cd C:\\xx\x

git checkout dev
git pull
git merge $1
git push
echo "end with dev"

git checkout sit
git pull
git merge $1
git push
echo "end with sit"

git checkout alpha
git pull
git merge $1
git push
echo "end with alpha"

git checkout uat
git pull
git merge $1
git push
echo "end with uat"