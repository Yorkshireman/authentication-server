## Running the tests

`bundle exec rspec`

## Rake tasks

### Linting

`bundle exec rake lint`

### Generating an auth token

`bundle exec rake generate_token\[<user_id>\]`

eg:

`bundle exec rake generate_token\["6b8f3a4e-7ac3-49a0-85ae-fae178b86079"\]`

### Generating a password reset token

`bundle exec rake generate_password_reset_token\[<user_id>\]`

eg:

`bundle exec rake generate_password_reset_token\["6b8f3a4e-7ac3-49a0-85ae-fae178b86079"\]`
