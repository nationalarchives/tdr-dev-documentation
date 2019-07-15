# Software evaluation Play MVC vs Next.js 

Date:2019-07-12

For TDR, we have first looked into building the frontend as a Single Page Applications with ReactJS.
We have dismissed this early, as we felt that the effort of coding to meet the standard around [progressive enhancement](https://www.gov.uk/service-manual/technology/using-progressive-enhancement) was to high.

We have then considered two frameworks for the front end development.
One candidate is PlayMVC, and the other one is Next.js with a serverless Rest API and we have evaluated these approaches in a team meeting
by assigning points from 0 to 4, 0 representing the lowest score, and 4 the highest.

We have two working prototypes with both solutions:

[Prototype Play MVC](https://github.com/nationalarchives/tdr-prototype-mvc) - Prototype Play MVC app

[Prototype Next.js](https://github.com/nationalarchives/prototype-front-end) - For prototyping TDR front-end

Considerations around both frameworks are detailed here: [considerations_playmvc_vs_nextjs](../master/considerations_playmvc_vs_nextjs.md)



Criteria | PlayMVC  | Next.js | Considerations
---------|---- | ------------- | ----
How good is the development experience using this framework for TDR (how easy is to develop, debug, test)?|4  | 2 | See Ease of Development in [considerations_playmvc_vs_nextjs](../master/considerations_playmvc_vs_nextjs.md).
Does the team have skills to use this framework?|3  | 3 | We have a mix of Scala and JavaScript knowledge in the team.
Have we used something similar in TNA?|1  | 0 | We have used Play.
How easy it is to ensure security best practices using this tool? |4   | 2 | Best practices can be achieved with both tools, it is a little bit of more effort to do it with NextJs.See Ease of Development in [considerations_playmvc_vs_nextjs](../master/considerations_playmvc_vs_nextjs.md).
How easy will it be for a new starter to pick and maintain this product in the future after the development is finished?|4   | 3 | A docker solution whould be provided, still NextJs will be a little harder to pick up.
Is it open source? How good is the open source support? Do you foresee any issues with product support in the future?|4      | 4| Both of these platforms are well established, well maintained and well used by some large companies and unlikely to be abandoned. See Software Evaluation in [considerations_playmvc_vs_nextjs](../master/considerations_playmvc_vs_nextjs.md).
How easy it is to scale for future use(big volumes of data)?|3    | 4 | Both will scale, it's easier to scale with Next.js as we are using AWS serverless infrastructure. See Scaling in [considerations_playmvc_vs_nextjs](../master/considerations_playmvc_vs_nextjs.md).
What is the impact on accessibility of using this software? How much does it rely on client side javascript?| 3 | 3 | Same, they are both rendering html.
How cheap it is to run the service? What is the cost of the service running with this software? | 3 | 4 | Based on initial costs, Next is really cheap (less than 10GBP/month), but Play is also cheap(less than 100GBP/month). See Costs in [considerations_playmvc_vs_nextjs](../master/considerations_playmvc_vs_nextjs.md).
How easy it is to deploy, configure and run the project in the cloud? |2 | 4 | It's easier to deploy and maintain the Next.js solution, as it does not involve running machines. See Infrastructure in [considerations_playmvc_vs_nextjs](../master/considerations_playmvc_vs_nextjs.md).
__Total__ |31|29| The general feeling is that development with PlayMVC is slightly easier and safer, but the deployment and system maintenance of the solution with Next.js is easier as it does not involve any running servers.
    
