echo "Install dependencies"
cd $WORKSPACE
bundle install --path vendor/cache

echo "Run App/Framework Unit Tests"
rake test:msdkui_unit
rake test:demo_app_unit
