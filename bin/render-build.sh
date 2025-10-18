set -o errexit
# set -o nounset
# set -o pipefail

# Install dependencies
bundle install

# Build the Rails app
bundle exec rails assets:precompile
bundle exec rails assets:clean

# Run database migrations
bundle exec rails db:migrate

# For local Docker development (uncomment if needed):
# docker build -t infovault .
# docker push infovault