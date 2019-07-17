# Meeting with Matthew Hobbs (GDS Frontend Lead) to discuss frontend technologies
 

> On Progressive enhancement

GDS want to move away from feeling developers can’t use js; is purely about how it is being used and how it is being applied. Focus on the core functionality of the application. If you have file uploads covered without js then you are catering for core functionality then can layer on using js. Plus cater for when js is turned off + network blocking stuff etc.

 
> Trying to use a tool to generate metadata about a file.
 
OGD to generate + TNA to automate and try to harvest client side, using standards on API and design and also generating client side checksums. Without js not sure how they generate last modified file and something running on client side, and would like to resort to js to get this information.
Matt suggested using web workers as a means for running things in the background.

 
Q. Why can’t server do this for you once file been uploaded?

A. Because last modified changes on upload. So defeats purpose of the checksum. Need to generate client side checksum upfront so can guarantee upload process hasn’t changed the file.

> User considerations

Q. Do you know browsers departments are using? If using an old v of IE killing upload.

A. Running browser surveys across government. Last one indicated I.E 11 as oldest, which is minimum requirement of GDS.

Be aware of browser performance and client hardware specs, it takes time to parse react on the front end.
 

Q. In I.E cannot upload folders. If no one was using I.E can we specify only Chrome and Firefox?

A. Is survey 100% completed.

 
Q. By keeping DROID as fall back service not restricting users?

not answered…

This is an assumption that we must define, in which case is DROID a fall back service. It will need to be for certain cases.



Q. How many users?

A. Hundreds not thousands

 

Q. Checksum against each file?

A. Yes against client side + then got other activities to perform after that – MH, do that stuff in a separate web worker thread and then send it back to main thread when complete (stops main thread from locking up + can do progressive enhancement around that).

 

MH – interested to hear back from survey + user and technical considerations documented so we can mention we have had this documentation for future context.

 

Using GDS design system for sharing components around departments a massive plus (v3 coming out next week).

 

Analytics and metrics gathering – what are we using (based on ja)

 

Q  What is your opinion about server side rendering?

Serverside rendering is an improvement that was brought for Single Page Apps created with libraries like ReactJs to improve speed in the first place. An example of a server side rendering framework is NextJS.

A. Server side rendering good, but must test with app hydrated + unhydrated with js turned of

 

Q. Use of mobile to be catered for?

A. Unlikely, but LD mentioned scenario where an upload takes ages so want to use mobile to check transfer status, but test this assumption in Alpha (MH: maybe a separate status app running alongside and optimised for mobile devices using Ajax connection). If you survey about browsers then survey against mobile as well. Explore this further in Alpha.

 

MH: ok about having another meeting in a couple of months. And yes stay in touch is all about helping each other out.

 

Some more thoughts/reflections from Matt re: mobile platform…

One thing that I thought of yesterday in regards to the "mobile" version of the site, it is also worth considering users who may potentially use an extreme zoom level (200%+). Due to the way modern browsers work, these users will essentially receive the "mobile" version of the site since all the CSS media query breakpoints scale with the zoom level.  For an example of what I mean I recommend zooming the GOV.UK homepage to 250% in Chrome or Firefox. The good thing is if you are planning to use the Design System for the frontend code then this will already be mostly done for you. So an actual "mobile" version will be very little work for developers, and you cater for users who may need this functionality.

 
Matt would like to receive feedback on the design system, he’s looking for exemplars.
