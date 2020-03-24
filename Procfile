platform: cd ./platform && bundle exec rails server --port 3001
emails: cd ./emails && bundle exec rails server --port 3002
assets: cd ./assets && bundle exec rails server --port 3003

emails_subscriber: cd ./emails && bundle exec rake feature_channel:subscribe --trace
platform_subscriber: cd ./platform && bundle exec rake feature_channel:subscribe --trace
