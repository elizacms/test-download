# nlu-cms README


## Initial Development Setup
1. Launch your local setup of Identity (perferably at localhost:3030)
`$ rails s -p 3030`

2. Create an application for nlu-cms in Identity. Set the redirect_uri to localhost:3000.
Copy and paste the client_id and client_secret.

3. Create a `.env` off of the root of `nlu-cms`. You will need to include the following:
```
export MONGO_DB_URI=http://www.someurl.com
export PUSHER_KEY=<get_this_from_another_dev>
export I_AM_PLUS_ENV=development
export IDENTITY_SERVICE_URI=http://localhost:3030
export NLU_CMS_URI=http://localhost:3000
export CLIENT_ID=<client_id> (from identity)
export CLIENT_SECRET=<client_secret> (from identity)
export SENDGRID_USERNAME=iamplusmailer
export SENDGRID_PASSWORD=<get_this_from_another_dev>
export LANGUAGE=en
```

4. Launch mongo server and rails app.
```
$ mongod
```
open a new tab
```
$ source .env
$ rails s
```

5. Create first Admin user.
```
$ rails c
> User.create(email: 'my_email_address@iamplus.com')
> User.first.set_role('admin')
```

6. Seed database with the initial DataFieldTypes.
```
$ rake db:seed
```

Now you should have a functional app. Load it up at localhost:3000.


## Running the tests
The tests can be run with
`$ parallel_rspec spec`
or,
`$ bundle exec guard`

[![Code Climate](https://lima.codeclimate.com/repos/58c1e8b8d82e680271000012/badges/713d59757be9dc026ee8/gpa.svg)](https://lima.codeclimate.com/repos/58c1e8b8d82e680271000012/feed)
