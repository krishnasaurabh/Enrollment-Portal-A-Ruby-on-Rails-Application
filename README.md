# MyBiryaniPack

This is a project for CSC517 which replicates MyPack portal course registration

The application is deployed at https://mybiryanipack.herokuapp.com/

## Admin Credentials 

There will only be one admin preconfigured and the credentials for the admin are

`email: SuperUser@ncsu.edu`

`password: MyStrongPassword1`

## Some useful links to operations

1. check student enrollments
2. drop student enrollments
3. create course
4. edit course
5. check waitlisted students for a course
6. drop waitlist
7. edit profile

## Edge-case scenarios
1. Given: Instructor has created a course with capacity 30 and there are already 29 students enrolled<br> When: New student enrolls to the course<br> Then: The status of the course changes to "Waitlist"
2. Given: The total waitlist capacity is 5 and currently 4 students in the waitlist <br>When: A new student enters the waitlist<br> Then: The course status changes to "Closed"
