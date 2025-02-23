
# Rails Project Setup

This README provides instructions for setting up and running the Rails project, including the backend API and frontend client.

## Backend Setup

### Prerequisites

Ensure you have the following installed on your system:

- Ruby (version specified in `.ruby-version`)
- Rails (version specified in `Gemfile`)
- MySQL
- Redis
- Node.js and npm (for the frontend)

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/mohdarif8299/product-scraper.git
   cd product-scraper
   ```

2. Install MySQL if not already installed:
   ```
   # For Ubuntu
   sudo apt-get install mysql-server
   # For macOS
   brew install mysql
   ```

3. Install Redis if not already installed:
   ```
   # For Ubuntu
   sudo apt-get install redis-server
   # For macOS
   brew install redis
   ```

4. Install Ruby dependencies:
   ```
   bundle install
   ```

5. Set up the database:
   ```
   rails db:create
   rails db:migrate
   ```

### Running the Application

1. Start the Redis server:
   ```
   redis-server
   ```

2. Start the Sidekiq worker:
   ```
   bundle exec sidekiq
   ```

3. Start the Rails server:
   ```
   rails s
   ```

### Running Tests

To run the test suite:

```
rspec spec/
```

## Frontend Setup

The frontend is located in the `client` directory.

1. Navigate to the client directory:
   ```
   cd client
   ```

2. Install dependencies:
   ```
   npm install
   ```

3. Start the frontend development server:
   ```
   npm start
   ```

The frontend should now be running and accessible at `http://localhost:3000` (or another port if specified).

## Additional Information

- Make sure both the backend and frontend are running for full functionality.
- Configure your database settings in `config/database.yml` if needed.
- Adjust the `config/redis.yml` and Sidekiq configuration as necessary for your environment.
