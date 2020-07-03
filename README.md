# Minimal AWS serverless full-stack CRUD web application

Now those are a lot of adjectives, but I think there're all true for this project.
Let's go trough them in reverse order.

## Project description

### CRUD on the web

CRUD stands for Create, Read, Update and Delete, which are the four basic functions of persistent storage according to Wikipedia.
This application offers exactly those capabilities through a web browser interface.
When do you considers storage to be persistent?
You can try to answer that philosophical question yourself on a rainy Sunday.
For now, I will just say that any one database will do.

### Full-stack

Full-stack is possibly even more a term open to interpretation than 'persistent storage'.
Anyway, most will probably agree that a graphical user interface, a database and everything in between are good starting requirements.

### AWS serverless

DynamoDB, Lambda, API Gateway and S3 were used to serve the requirements listed above.
No surprises there, I think.

### Minimal

The most interesting part of this project.
It is best described by explaining why I started it.

## Project purpose

There are plenty of projects out there which show you how to configure only the inner Amazon Web Services to facilitate an app like this.
Likewise, there are lots of projects which show only the front end part of the story.
And, of course, the web is bulging with examples and open frameworks for creating web apps running on servers.
There is also some good stuff out there which will deploy a fully fledged serverless application for you.
Still, I felt all these projects fall short in showing how the most elementary pieces fit together.

Creating an app with all the functionalities and patterns listed above while keeping it minimal was my main goal for this project.
Personally, I just wanted to know what the exactly made up the backbone of such an app in AWS.
Hopefully you can also benefit from this by better understanding how it all fits together.
After looking at this project I hope you can better understand and make use of the more advanced AWS serverless app examples out there.
Or, start building your own serverless full-stack apps from scratch.

## Deployment

You need programmatic access to an AWS account and have Terraform on your machine to deploy this application.
I wrote this app using Terraform v0.12.26 with provider.aws v2.65.0 and provider.archive v1.3.0, but later versions usually work in Terraform as well.
Run the regular `terraform init` and `terraform apply` command and everything should deploy fine.
Terraform will output the website and API endpoint of your app if deployment was successful.

If you don't know Terraform or how to use it, please see [their documentation](https://learn.hashicorp.com/terraform).

## Design notes

### Every commit produces a working example

This should always hold of course, but I want to name it here explicitly, because I took extra care for it.
To more easily see what part of the code does what, you can go through the commit history and see what code blocks were added to facilitate which added functionality.

### Terraform vs Cloud Formation

You might argue that using Cloud Formation would be even more minimal than using Terraform.
I chose for Terraform in the end, because I find HCL easier to read than CFN YAML/JSON.
This project is optimized for learning after all.

### Limitations when going minimal

This project was formed with a strong emphasis on 'just get it to work'.
Naturally then, a lot of stuff which you really would want to have in a real application is not there, like: authentication, logging, unit testing etc.
Also, I cleaned the code a bit from commit to commit, but there are still things like: unnecessary connascence by identity, no clear separation of concern etc.
I did this on purpose, because implementing all this would introduce additional complexity, which is not minimal.

> Note: I did put some effort in minimizing the Lambda function's permissions for obvious reasons.

## Sources

As said above, there are lots of good examples out there.
The ones I used for inspiration most are:

- [Terraform's AWS serverless API example](https://learn.hashicorp.com/terraform/aws/lambda-api-gateway)
- [This nice JavaScript example of how to create a CRUD web page](https://www.encodedna.com/javascript/how-to-create-a-simple-crud-application-using-only-javascript.htm)
- [AWS CORS docs for API Gateway](https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-cors.html)

Naturally, putting all the pieces together required some additional roaming around on the internet.
W3Schools, Stack Exchange and A Cloud Guru earn an honorable mention as dependable knowledge bases there.

## Contributing

Please raise an issue or a pull request if you encounter bugs or old/deprecated standards.
Other suggestions are also welcome, but please keep in mind that this project's intend is to show the minimal, so take extra care when it would increase the project's complexity.
