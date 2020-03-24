## Redis

### Look at the Redis monitor

* Open the redis-cli: `redis-cli`
* Now open monitor: `MONITOR`


## Assets

### Create

_Creates a new asset._

`curl -XPOST http://localhost:3003/assets -d 'asset[name]=New Asset&asset[description]=Lorem ipsum dollor&asset[bucket_url]=http://localhost/asset1.jpg'`

### Show

_Returns the data of an asset._

`curl -XGET http://localhost:3003/emails/1`

### Delete an asset

_Deletes an asset._

`curl -XDELETE http://localhost:3003/assets/1`


## Emails

This API endpoints works with email service

### Create

_Follow the steps bellow to create a new email._

### Create an asset ref using seeds

`bundle exec rails db:seed:replant`

### Add a new email using API

`curl -XPOST http://localhost:3002/emails -d 'email[name]=New Email&email[subject]=Lorem ipsum dollor&email[body]=Hello Email&email[asset_id]=1'`

### Show

_Returns the data of an email._

`curl -XGET http://localhost:3002/emails/1`


### Editing

_Edits the email fields informations._

`curl -XPUT http://localhost:3002/emails/1 -d 'email[name]=New Email Name'`

### Delete

_Removes an email._

`curl -XDELETE http://localhost:3002/emails/1`


## Platform

This API endpoints works with platform API (main application).

### Create

_Follow the steps bellow to create a new schedule._

### Create email refs using seeds

`bundle exec rails db:seed:replant`

### Add a new schedule using API

`curl -XPOST http://localhost:3001/schedules -d 'schedule[name]=`

### Show

_Returns the data of an schedule._

`curl -XGET http://localhost:3002/schedules/1`


