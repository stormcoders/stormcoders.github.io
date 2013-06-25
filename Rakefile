desc "Update static html files"
task :update do
  `rm about.html`
  `jekyll build`
  `cp _site/about.html about.html`
end