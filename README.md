Bee Wordy API with Sinatra

This API is an continuation of my project: "Bee Wordy - Copy of NYT's Spelling Bee Game"

My goal for this API: Create an API that runs once a day to get the letter list, words and definitions that could be fetched by another React app.

Utilizing Sinatra:
The functionality for creating the 7 letters is the same as the original Bee-Wordy app. But to keep the program light, I used the Sinatra to generate the JSON output.

Challenges & Learnings:
- I originally started the project with a sqlite db, but quickly realized that Heroku runs on an postgresql setup.
- Similarly, in development I used the Rufus Scheduler gem to run the code on a daily basis. After a bit of trial and error, I realized this gem was not supported by Heroku and had to recode to utilize the built in Heroku Scheduler.
- Used to Rails, I forced myself to learn a lot about the overall app development as I needed to build up the Sinatra app from scratch. As an example, I learnt how to build up environment files and access database on Heroku without "heroku run Rails console".

Next step: create Bee Wordy React App to access API


Note: This makes use of the list of english words by dwyl: https://github.com/dwyl/english-words and also the Merriam-Webster Dictionary API to check the list and provide definitions.
