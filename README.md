# MyBiryaniPack

This is a project for CSC517 which replicates MyPack portal course registration

The application is deployed at https://mybiryanipack.herokuapp.com/

## Admin Credentials 

There will only be one admin preconfigured and the credentials for the admin are

`email: SuperUser@ncsu.edu`

`password: MyStrongPassword1`

## Student/Instructor created by admin Credentials 

The default password for student or instructor created by admin 

`password: defaultpassword`

## Testing instructions

To run the tests use the below commands and check if they succeed

To test the controllers run
`rails test`

To test the models run
`rspec`


## Some useful links to operations

1. [check student enrollments](https://mybiryanipack.herokuapp.com/enrollments)
2. [drop student enrollments](https://mybiryanipack.herokuapp.com/enrollments)
3. [create course](https://mybiryanipack.herokuapp.com/courses/new)
4. [edit course](https://mybiryanipack.herokuapp.com/courses)
5. [check waitlisted students for a course](https://mybiryanipack.herokuapp.com/courses)
6. [drop waitlist](https://mybiryanipack.herokuapp.com/instructor_courses)
7. [edit profile](https://mybiryanipack.herokuapp.com/users/edit)

## Edge-case scenarios
1. Given: Instructor has created a course with capacity 30 and there are already 29 students enrolled<br> When: New student enrolls to the course<br> Then: The status of the course changes to "Waitlist"
2. Given: The total waitlist capacity is 5 and currently 4 students in the waitlist <br>When: A new student enters the waitlist<br> Then: The course status changes to "Closed"
3. Given: The waitlist is full <br> When: Student tries to enroll to that course <br>Then: User should not be able to enroll to the course
4. Given: The course is in waitlist 1 <br> When: Student drops the course <br>Then: The waitlist student should get enrolled
5. Given: An Instructor has created a new course<br> When: Another Instructor tries to enroll students to the course<br> Then: Instructor should not be authorised
6. Given: A course created by an Instructor<br> When: An another Instructor/Student clicks on show <br> Then: The Instructor/Student should not be able to see the enrolled students for the course
7. Given: An Instructor has created a course<br> When: Another Instructor tries to enroll students the course <br> Then: Instructor should not be authorised
8. Given: An Instructor creates a course<br> And: Students have enrolled to the course<br> When: Instructor drops the course<br> Then: The enrollments and waitlists should be dropped.
8. Given: When an instructor updates a course capacity (can only be higher )<br> Then: The waitlists for that course will automatically convert into enrollemnts until the course enrollment capacity gets filled.
