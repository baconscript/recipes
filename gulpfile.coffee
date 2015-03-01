gulp = require 'gulp'
rho = require 'gulp-rho'
frontMatter = require 'gulp-front-matter'
through = require 'through2'
_ = require 'lodash'
gulpEjs = require 'gulp-ejs'
ejs = require 'ejs'
watch = require 'gulp-watch'
moment = require 'moment'
fs = require 'fs'
markdown = require 'gulp-markdown'
marked = require 'marked'

recipes = []

zpad = (n) -> if n < 10 then '0'+n else n

gulp.task 'default', ['index','recipes','assets'], ->

gulp.task 'recipes', ->
  gulp.src './recipes/*.md'
    .pipe frontMatter()
    .pipe through.obj (file, enc, done) ->
        slug = file.path.match(/\/([^/]+)$/)[1].replace(/\.md$/,'')
        date = new Date file.frontMatter.date
        year = date.getFullYear()
        month = zpad date.getMonth()+1
        day = zpad date.getDate()
        frontMatter = file.frontMatter
        frontMatter.image ?= 'sq.png'
        frontMatter.dateString = moment(frontMatter.date).format('MMMM Do, YYYY')
        frontMatter.intro = marked frontMatter.intro
        recipes.push _.merge _.clone(file.frontMatter),
          slug: slug
        @push file
        done()
    .pipe markdown()
    .pipe through.obj (file, enc, done) ->
        contents = file.contents.toString()
        fs.readFile './layouts/recipe.html', (err, postTemplate) =>
            contents = contents.replace /\{([^}]+)\}(\[([^\]]*)\])?/g, (whole, name, $2, item) ->
              "<span class='recipe-item' data-which='#{item or name}'>#{name}</span>"
            contents = ejs.render postTemplate.toString(),
                _.merge _.clone(file.frontMatter),
                    content: contents
            file.contents = new Buffer contents
            @push file
            done()
    .pipe gulp.dest 'build'

gulp.task 'index', ['recipes'], (files) ->
  gulp.src('./layouts/index.html')
    .pipe(gulpEjs
      recipes: recipes
      moment: moment
    ).pipe(gulp.dest('./build'))

gulp.task 'assets', ->
    gulp.src './assets/**'
        .pipe gulp.dest './build'
