namespace :macgap do
  task :build do
    `sips -s format icns macgap/application.png --out macgap/application.icns`
    `macgap --name Hermes ./macgap`
    `zip -r Hermes.zip Hermes.app`
  end
end