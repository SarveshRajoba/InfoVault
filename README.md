# InfoVault

**InfoVault** is a collaborative study notes and AI-powered question generation platform built with Ruby on Rails. It lets you organize your study material into subjects, chapters, and paragraphs, then automatically generates questions and answers from your notes using Google Gemini AI — helping you study smarter and collaborate with others.

---

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Prerequisites](#prerequisites)
- [Getting Started (Local Development)](#getting-started-local-development)
  - [1. Clone the Repository](#1-clone-the-repository)
  - [2. Install Dependencies](#2-install-dependencies)
  - [3. Configure the Database](#3-configure-the-database)
  - [4. Set Up Environment Variables](#4-set-up-environment-variables)
  - [5. Set Up and Seed the Database](#5-set-up-and-seed-the-database)
  - [6. Start the Development Server](#6-start-the-development-server)
- [Running Tests](#running-tests)
- [Project Structure](#project-structure)
- [Deployment](#deployment)
  - [Render.com](#rendercom)
  - [Docker](#docker)
- [Environment Variables Reference](#environment-variables-reference)
- [Contributing](#contributing)
- [License](#license)

---

## Features

- 📚 **Study Material Organization** — Structure your notes into Subjects → Chapters → Paragraphs with rich-text formatting.
- 🤖 **AI-Powered Q&A Generation** — Automatically generate concise questions and answers from your paragraphs using the [Google Gemini API](https://ai.google.dev/).
- 🤝 **Collaboration** — Share subjects with other users, granting `read_only` or `edit` access.
- 🔐 **JWT Authentication** — Secure signup/login with bcrypt password hashing and HTTP-only cookie token storage.
- 🔍 **Search** — Search paragraphs by title with case-insensitive matching.
- ⚡ **Real-time Updates** — Hotwire (Turbo + Stimulus) for a smooth, SPA-like experience without a separate frontend build step.
- 🎛️ **Background Jobs** — Question generation runs asynchronously via Solid Queue so the UI stays responsive.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Language | Ruby 3.4.2 |
| Framework | Rails 8.0.1 |
| Database | PostgreSQL |
| Frontend | Hotwire (Turbo + Stimulus), JavaScript ESM, Propshaft |
| Authentication | JWT + bcrypt |
| AI Integration | Google Gemini API (`gemini-2.0-flash`) |
| Background Jobs | Solid Queue |
| Testing | RSpec, FactoryBot, Capybara, SimpleCov |
| Code Quality | RuboCop (rails-omakase), Brakeman |
| Web Server | Puma (dev) / Thruster + Puma (production) |
| Deployment | Render.com, Docker, Kamal |

---

## Prerequisites

Make sure you have the following installed before you begin:

- **Ruby 3.4.2** — use [rbenv](https://github.com/rbenv/rbenv) or [RVM](https://rvm.io/) for version management
- **Bundler** — `gem install bundler`
- **PostgreSQL** — running locally (e.g. `brew install postgresql` on macOS, `apt install postgresql` on Ubuntu)
- **Git**
- **A Google Gemini API key** — [get one here](https://aistudio.google.com/app/apikey) (required for AI question generation)

---

## Getting Started (Local Development)

### 1. Clone the Repository

```bash
git clone https://github.com/SarveshRajoba/InfoVault.git
cd InfoVault
```

### 2. Install Dependencies

```bash
bundle install
```

### 3. Configure the Database

Open `config/database.yml` and update the `development` section with your local PostgreSQL credentials:

```yaml
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: InfoVault_development
  host: localhost
  username: your_postgres_username
  password: your_postgres_password
```

> **Tip:** Alternatively, you can set the `DATABASE_URL` environment variable and the `database.yml` default will pick it up automatically.

### 4. Set Up Environment Variables

Create a `.env` file in the project root:

```bash
cp .env.example .env   # if an example file exists, otherwise create it manually
```

Add the following to your `.env`:

```env
GEMINI_API_KEY=your_google_gemini_api_key
```

> **Note:** The `.env` file is loaded by `dotenv-rails` in development/test. Never commit this file to version control.

### 5. Set Up and Seed the Database

```bash
bin/rails db:create
bin/rails db:migrate
```

Alternatively, use the all-in-one setup script (handles gem installs and database setup):

```bash
./bin/setup
```

### 6. Start the Development Server

```bash
bin/dev
```

The application will be available at **[http://localhost:3000](http://localhost:3000)**.

---

## Running Tests

InfoVault uses **RSpec** as the test framework.

```bash
# Run the full test suite
bundle exec rspec

# Run only model tests
bundle exec rspec spec/models/

# Run only integration/request tests
bundle exec rspec spec/requests/

# Run a single test file
bundle exec rspec spec/models/user_spec.rb

# Run tests with code coverage (SimpleCov)
bundle exec rspec --format progress
```

Test coverage reports are generated in the `coverage/` directory when running with SimpleCov.

---

## Project Structure

```
InfoVault/
├── app/
│   ├── controllers/          # Request handlers (auth, subjects, chapters, paragraphs, questions, answers)
│   ├── models/               # ActiveRecord models (User, Subject, Chapter, Paragraph, Question, Answer, Collaboration)
│   ├── services/             # Business logic
│   │   ├── gemini_service.rb     # Google Gemini API integration
│   │   └── groq_service.rb       # Alternative AI provider
│   ├── jobs/
│   │   └── GenerateQuestionsJob.rb  # Async AI question generation
│   ├── views/                # ERB templates
│   ├── javascript/           # Stimulus JS controllers
│   └── assets/               # Stylesheets and images
├── config/
│   ├── routes.rb             # REST API routes
│   ├── database.yml          # Database configuration
│   └── puma.rb               # Puma server settings
├── db/
│   ├── migrate/              # Database migrations
│   └── schema.rb             # Current schema snapshot
├── spec/
│   ├── models/               # Unit tests for models
│   ├── requests/             # Integration tests
│   └── factories/            # FactoryBot test data factories
├── bin/
│   ├── setup                 # Bootstrap development environment
│   ├── dev                   # Start dev server
│   └── render-build.sh       # Render.com build script
├── Dockerfile                # Production Docker image
├── render.yaml               # Render.com deployment config
└── Gemfile                   # Ruby dependencies
```

---

## Deployment

### Render.com

The project includes a `render.yaml` for one-click deployment to [Render.com](https://render.com).

1. Fork this repository.
2. Create a new Render account or log in.
3. Click **New → Blueprint** and connect your forked repository.
4. Render will automatically detect `render.yaml` and provision:
   - A **PostgreSQL** database (free tier)
   - A **web service** running the Rails app
5. Add the following **environment variables** in the Render dashboard (under your service → Environment):
   - `RAILS_MASTER_KEY` — contents of `config/master.key`
   - `GEMINI_API_KEY` — your Google Gemini API key
6. Trigger a manual deploy or push a commit to kick off the build.

The build command (`./bin/render-build.sh`) will run `bundle install`, precompile assets, and run migrations automatically.

### Docker

Build and run the production Docker image locally:

```bash
# Build the image
docker build -t infovault .

# Run the container
docker run -d -p 80:80 \
  -e RAILS_MASTER_KEY=$(cat config/master.key) \
  -e GEMINI_API_KEY=your_api_key \
  -e DATABASE_URL=postgresql://user:password@host/infovault \
  --name infovault infovault
```

The app will be available at **[http://localhost](http://localhost)**.

> For more advanced container orchestration, the project also supports [Kamal](https://kamal-deploy.org/) — see `.kamal/` for configuration.

---

## Environment Variables Reference

| Variable | Required | Description |
|----------|----------|-------------|
| `GEMINI_API_KEY` | ✅ Yes (for AI features) | Google Gemini API key for question generation |
| `DATABASE_URL` | ✅ Yes (production) | Full PostgreSQL connection URL |
| `RAILS_MASTER_KEY` | ✅ Yes (production) | Rails credentials encryption key (`config/master.key`) |
| `RAILS_ENV` | No | Rails environment (`development` / `production`) |
| `PORT` | No | Port for the web server (default: `3000`) |
| `WEB_CONCURRENCY` | No | Number of Puma worker processes (default: `2` on Render) |
| `RAILS_MAX_THREADS` | No | Threads per Puma worker (default: `3`) |

---

## Contributing

Contributions are welcome! To get started:

1. Fork the repository.
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Make your changes and add tests.
4. Run the test suite to make sure everything passes: `bundle exec rspec`
5. Run the linter: `bin/rubocop -A`
6. Run the security scanner: `bin/brakeman`
7. Commit your changes: `git commit -m 'Add your feature'`
8. Push to your fork: `git push origin feature/your-feature-name`
9. Open a Pull Request against `main`.

---

## License

This project is open-source. See the [LICENSE](LICENSE) file for details.
