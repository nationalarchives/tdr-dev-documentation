# 29. AWS X-Ray for request monitoring

**Date:** 2023-05-19

## Context
We need a way to monitor requests made from our application, in addition to allowing us to view, filter and gain insights into that data to identify issues and opportunities for optimisation.

## Options considered

### Use Datadog

#### Advantages
* Comprehensive Monitoring: Datadog offers a wide range of monitoring capabilities, including application performance monitoring (APM), infrastructure monitoring, log management, and more, making it a versatile solution for monitoring your entire stack. 
* Extensive Integrations: Datadog provides extensive integrations with various technologies, frameworks, and cloud providers, allowing you to collect and analyze data from different sources in a unified dashboard. 
* Visualization and Alerting: Datadog provides powerful visualization and alerting capabilities, enabling you to create custom dashboards, set up alerts based on specific conditions, and gain actionable insights into your application's performance and health. 
* Community and Ecosystem: Datadog has an active community and a rich ecosystem of plugins, integrations, and knowledge resources, making it easier to leverage the experiences and expertise of other users.

#### Disadvantages
* Cost: Datadog can be relatively expensive compared to other monitoring solutions, especially if you have a large number of monitored resources or require advanced features. The pricing is per Gb ingested so it will be very difficult to know how much we’ll be spending from one month to the next so this isn’t ideal.
* Learning Curve: The comprehensive nature of Datadog can result in a steeper learning curve, especially for beginners or teams without prior experience with the platform. 
* Dependency on Third-Party Service: Since Datadog is a cloud-based service, it relies on a stable internet connection and availability of the Datadog infrastructure. Any disruptions or outages in the service can impact your monitoring capabilities.

### Use Logstash

#### Advantages
* Log Aggregation and Parsing: Logstash excels at collecting, aggregating, and parsing logs from various sources, allowing you to centralize your logs for easier management and analysis. 
* Extensibility: Logstash is highly extensible through its plugin system, enabling you to customize log processing and integrate with a wide range of data sources and outputs. 
* Open-Source and Community Support: Logstash is an open-source tool with an active community, which means you can find a wealth of community-contributed plugins, resources, and support. 
* Integration with ELK Stack: Logstash seamlessly integrates with Elasticsearch and Kibana as part of the ELK (Elasticsearch, Logstash, Kibana) stack, providing a comprehensive solution for log storage, processing, and visualization.

#### Disadvantages
* Scalability: Logstash can be resource-intensive, especially when processing large number of monitored resources or require advanced features.
* Cost: expensive to run due to being resource-intensive and commonly being paired with elastic search. AWS do a wrapped version called OpenSearch but this will be expensive to run as we need a fairly beefy server across multiple AZs

### Use AWS X-Ray

#### Advantages
* Ease of setting up
* Native Integration: AWS X-Ray seamlessly integrates with other AWS services, making it easy to monitor and trace requests across distributed systems within the AWS ecosystem.
* Distributed Tracing: X-Ray provides end-to-end tracing capabilities, allowing you to visualize and understand the flow of requests through your application and identify bottlenecks or latency issues. 
* AWS Service Instrumentation: X-Ray automatically instruments many AWS services, such as Lambda functions, API Gateway, and Elastic Load Balancer, providing insights into the performance of these services. 
* AWS Ecosystem Support: X-Ray is well-suited for applications running on AWS, as it offers deep integration with other AWS monitoring and analytics services, such as CloudWatch and AWS Lambda.

#### Disadvantages
* Easy and convenient feature to use with AWS exclusive systems, the tool lacks when it comes to tracing outside the realms of Amazon’s products.
* AWS-Centric: While X-Ray integrates well with AWS services, it may require additional effort to implement tracing for non-AWS resources or services. 
* Limited Non-AWS Support: X-Ray's support for non-AWS services or environments is not as extensive compared to other monitoring solutions available in the market. 

## Decision
We have decided to use AWS-Xray for it's ease of setup and integration with other AWS services. In addition, other teams on AWS can use similar setup, and we can aggregate the X-Ray logs into a central account.
Other bonuses include 
* The first 100,000 traces recorded each month are free.
* The first 1,000,000 traces retrieved or scanned each month are free.

There are two main ways to send trace data to AWS.
* Use the AWS X-Ray SDK. This needs quite a few code changes within the application to collect the data although there are plugins for Play and Akka that will make this easier. This doesn’t help much if we’re trying to run traces from Keycloak though. As part of this, we need to run a container with the X-Ray daemon.
* Use the AWS Distro for open telemetry This is much easier to integrate in that you add a jar to the docker image when it’s being built and set some java options and it works out of the box. You do need to run another container with the amazon/aws-otel-collector docker image. If you want custom annotations on your traces, for example consignment ID so we can track individual consignments through the system, then you need a custom build of the collector docker image.  There is a frontend branch and a terraform branch which show roughly how this will work.

Because of the ease of setting this up and the fact that both solutions need a separate container running, option 2 seems to be the preferred one. For now, we can add this to the frontend and run the container in the same service. When we start using this across the API and Keycloak, we can run a single collector container and use something like Service Connect but that’s a future problem.

It’s also reasonably trivial to switch on xray tracing in the step functions, so we should be able to get X-ray traces for the backend checks and the export without too much extra work. It is possible to send traces from Lambdas as well if we want to. 
