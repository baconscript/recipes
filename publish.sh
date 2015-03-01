git checkout master

gulp

git checkout gh-pages

git checkout master .gitignore
git checkout master CNAME
cp -r build/. .
rm -r build
git add -A
git commit

git push origin gh-pages
git checkout master
git push origin master
