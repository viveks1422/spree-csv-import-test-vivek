# Spree Test CSV Import Task

The project is to create feature that will let users upload a .csv file with products and variants, process it and create spree products with variants in the database. Sample .csv file is provided in the repository main directory.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

What things you need to install the software and how to install them

```
ruby '2.5.3',  Rails 5.1.4, Redis and PostgreSQL >= 9.6.15
```

### Installing

A step by step series of examples that tell you how to get a development env running

1. clone the project 

```
git clone git@github.com:viveks1422/spree-csv-import-test-vivek.git
```

2. Goto app directory and do bundle install

```
bundle install
```

3.Setting application.yml and database.yml

```
1. Create a copy of application.example and database.example
2. Rename both copied files to application.yml and database.yml
```

4. Database operations

```
1. bundle exec rails db:create 
2. bundle exec rails db:migrate
3. bundle exec rails db:seed

```
## Running background job

Run the following command to start sidekiq for background jobs using development enviornment and add within deployment script for production enviornment.

```
bundle exec sidekiq
```

## Running the tests

Run following command to run integration tests using Rspec, capybara and chrome drivers.

```
rspec spec/features/
```

## Built With

* [Spree](https://github.com/spree/spree) - API-driven open source ecommerce solution for Ruby on Rails

## Versioning

We use [Github](https://github.com/) for versioning.
