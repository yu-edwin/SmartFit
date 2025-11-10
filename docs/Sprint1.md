# Sprint 1 Report - Smartfit

##  MVP

###  Description

Our first MVP for sprint 1 will ensure that our customer/client will have a functional vitual wardrobe that allows for clothing storage. Users will be able to upload a clothing item and input specific information such as name, brand, etc to be stored in a database. In our case, we decided for a NoSQL database using MongoDB, connected by node/express and mongoose. Users will also be able to use the camera, but full upload via camera may be completed in the next sprint. 

###  MVP Goal

- Functional virtual wardrobe that is able to store clothing items in the backend along with multiple users.
- Upload by clothing item by image

###  User Problem Solved

Users would be able to mix and match multiple items to form a single outfit instead of uploading ONLY the full outfit and checking to see if they like the appearance generated. This gives the user a greater variety of outfits they can choose since they can experiment with new fits. 


**Targeted User Stories:**
As: Mathhew, a messy undergraduate student,
I want to: better organize the clothes that I have
So that: I can clearly see what options I have virtually instead of searching for them aimlessly in my closet.   

As: Alex Wang, a student attending campus career fairs
I want: Curated outfit recommendations for professional events
So that: I can feel confident and make a strong first impression with recruiters

As: John Smith, a fashion designer
I want: To explore various clothing combinations quickly
So that: I can create mood boards and satisfy my clients

**User Problems being solved:**

1. Users have difficulty in viewing all the clothing options they have for their fit of the day
- A virtual wardrobe that displays ALL clothing items stored
- Sectioned clothing items based on category (Tops, bottoms, shoes, outwear, accessories)


###  Value Proposition
How does this MVP add value to the user, how is it better than their current alternatives.
When comparing to google's version of clothing fit check, Doppl, we noticed that you were forced to upload the entire outfit at once in a top/down picture format.  
This means that their algorithm is only able to detect clothes if you submit a picture of:
- An full body image of someone wearing an outfit and Doppl will recognize the clothes they are wearing and equip it onto your model.
- An image where the tops (shirt/jacket/etc) is directly above the bottoms (pants/shorts/etc) 

Doppl lacks a wardrobe feature since they only have suggested outfits that are pre-registered and only WHOLE outfit uploads, so mixing and matching different tops/bottoms are difficult. 

###  Backlog Items Included in MVP

- [Item 1 - DONE] MUST - Wardrobe allows for upload by image (Daiki)
- [Item 2 - DONE] MUST - Working backend inventory system for wardrobe (Justin)
- [Item 3 - DONE] MUST - Inventory should have clothing categories (shoes, tops, bottoms ...) (Daiki)
- [Item 4 - DONE ] MUST - MUST - Uploaded clothing items can be turned into item descriptions with AI (Edwin)
- [Item 5 - DONE ] MUST - Wardrobe allows for equipping one of each clothing type (Edwin)
- [Item 6 - DONE] SHOULD - Save multiple outfit combinations (Edwin)

##  Evidence of SCRUM Process

### 1. Sprint Planning Meeting
Sprint Planning Meeting Summary
Date: October 16, 2025
Attendees: Justin Dong, Daiki Koike, Edwin Yu
Duration: 90 minutes
Sprint Duration: 2 weeks (October 16 - October 30, 2025)

- During this sprint meeting, we re-examined our backlog to re-evaluate the priority via MoSCoW method and assigned effort values (Fibonacci) for each item on the backlog.
- Some items (mainly the AI suggestions) were deemed non-essential or overly ambitious, which led us to reprioritize our rankings of our backlog.
- Each member were given playing cards and participated in "planning poker" where the cards represented Fibonacci numbers to estimate task difficulty.
- If fibonacci numbers greatly differed, a discussion was held on why each member placed their effort value to re-evaluate the effot value (difficulty) of that task.
- We decided that for our first sprint, it won't be too extreme as we will develop our virtual wardrobe in the frontend and the backend along with some aspects of camera integration and item storage within the wardrobe.
- Team assignments were created as each member was assigned TODOS of our first sprint backlog.
- Discussions about new potential technologies we would use were also considered along with potential API that may be implemented for current and future sprints.
- Discussed scheduling for sprint meetings to check on the status of the project and potential issues (very brief)

### 2. Sprint Standup Meetings

Date: October 22, 2025 (Wednesday)
Attendees: Justin Dong, Daiki Koike, Edwin Yu
Duration: 90 minutes (Too long)

- Discussed potential problems that we have faced thus far and what we have accomplished
- Explored options on how to proceed with AI generated outfits (Which technology to use)
- Decided on gemini to create clothing item description and using that description to generate outfits
- Familiarized group with backend structure
- Explored potential backlog items that we missed (User login system/Encrypting sensitive user info/Gemini for user + image for overlay)

Date: October 23, 2025 (Thursday)
Attendees: Justin Dong, Daiki Koike, Edwin Yu
Duration: 30 minutes

- Demo the current localhost version of our application. Everything seems to be working as intended
- Discussed structuring of the code for organization and easier understanding

Date: October 24, 2025 (Friday)
Attendees: Justin Dong, Daiki Koike, Edwin Yu
Duration: 30 minutes

- Viewed options for deployment of application.

Team Work distrbution:

Justin:
1. Created a backend using node/espress.js
2. Hosted backend on Render and connected to MongoDB database.
3. Created Schema for clothing item and users and outfits
4. Setup/Helped with GET/POST/PUT/DELETE requests for clothing item
5. Set up GET/POST request for outfits
6. Set up GET request for users (Only get for now since we only have 1 test user)

Edwin:
1. Set up xcode frontend
2. Created Gemini API for clothing item description
3. Set up camera/Allow for upload
4. Allows users to equip selected clothing item and initialized clothing equipped on start-up.
5. Selectable clothing item for outfits. Can have a total of 3 outfits thus far.

Daiki:
1. Connected CRUD requests from backend to frontend
2. Setup/Helped with GET/POST/PUT/DELETE requests for clothing item
3. Added frontend wardrobe features (category/image upload) on frontend 

### 3. Sprint Reflection

- Team Velocity: 26

**How to Increase Team Velocity For Next Sprint:**
1. Organize code into respective folders for neater, legible code.
2. Write clear descriptions on what code does during pull requests so other members take smaller time understanding what each line does.
3. Provide resources for understanding languages

**What Went Right**
1. Each team member had clear understanding of their task
2. Had standups to help cleaer confusion and change course of action if needed
3. Consistent communication via slack when task is in-progress, completed, or needs review.

**How to make it better**
1. Organization of code
2. More frequent team stand-ups to understand status of project
3. Shorter stand-ups to reduce time wasted

### 4. Sprint Review

Demo was tested by Edwin and Justin
Feedback:
- Good if we can unselect an clothing item in outfit by selecting an already selected clothing item.
- Needs a delete outfit button if user does not like outfit
- Maybe more variety of categories since accessories can be vague as we could include scarfs and bracelets.
- Delete clothing item feature
- Helpful if each clothing item displays information when you click on it (price/brand/etc)

### MVP Deployment

**Deployed URL:** [https://appetize.io/app/b_p3ygky3jpsbdttgm25pzi5du6e](https://appetize.io/app/b_p3ygky3jpsbdttgm25pzi5du6e)
