# Burndown List

1. ~~Make sync process a background task (it takes too long to do it from the web UI)~~
2. Store both raw and canonical emails, since we apparently need raw in some cases
   (creating permissions, in some cases)
3. Write code to actually _apply_ needed sharing changes to Drive folders
4. Dig through the data to understand what's up with the 461 files that appear to be over-shared
    * Some of this may just be a bug in my code!
5. Dig through the data to understand what's up with the 16 files/folders that are accessible to
   anyone with the link
6. Work with owners of various files shared TO the org account, to see if ownership of those files
   should move to the org account
7. Sort out how sharing works (at an API level) for Calendars
8. Sort out the API for Google Groups, including fetching/updating sharing info
9. Write code to synchronize Contact Group members -> Calendar sharing
10. Write code to synchronize Contact Group members -> Google Group members
