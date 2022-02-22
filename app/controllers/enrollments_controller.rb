class EnrollmentsController < ApplicationController
  before_action :set_enrollment, only: %i[ show edit update destroy ]
  before_action :correct_student?, only: %i[ edit update destroy show ]
  before_action :correct_instructor?, only: %i[ edit update destroy show create ]


  # GET /enrollments or /enrollments.json
  def index
    if is_student?
      # this shows enrollments for the current user
      @enrollments = Enrollment.where(student_id: Student.find_by(user_id: current_user.id).id)
    elsif is_instructor?
      # blocks access to instructor as he can see from the courses details page
      flash[:alert] = "Not authorised to perform this action"
      redirect_to courses_path
    elsif is_admin?
      #  this shows all the enrollemets for all students
      @enrollments = Enrollment.all
    end
  end

  # GET /enrollments/1 or /enrollments/1.json
  def show
  end

  # GET /enrollments/new
  def new
    @enrollment = Enrollment.new
  end

  # GET /enrollments/1/edit 
  # all edit operations are not authorized it can only be deleted or created
  def edit
    flash[:alert] = "Not authorised to perform this action"
    redirect_to root_path
  end

  # POST /enrollments or /enrollments.json
  def create
    enroll_course
    respond_to do |format|
      if @enrollment.save
        @course = Course.find(@enrollment.course_id)
        check_status
        format.html { redirect_to enrolled_students_path(@course.id), alert: "Enrollment was successfully created." }
        format.json { render :enrolled_students_path, status: :created, location: @course }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @enrollment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /enrollments/1 or /enrollments/1.json
  def update
    respond_to do |format|
      if @enrollment.update(enrollment_params)
        @course = Course.find(@enrollment.course_id)
        check_status
        format.html { redirect_to enrollment_url(@enrollment), notice: "Enrollment was successfully updated." }
        format.json { render :show, status: :ok, location: @enrollment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @enrollment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /enrollments/1 or /enrollments/1.json
  def destroy
    @course = Course.find(@enrollment.course_id)
    @enrollment.destroy
    move_students_from_waitlist_to_enrolled 
    check_status 
    respond_to do |format|
      if is_instructor?
        format.html { redirect_to enrolled_students_url(@enrollment.course_id), alert: "Enrollment for #{@course.name} is dropped." }
      elsif flash[:controller_from] == "Course"
        format.html { redirect_to courses_path, alert: "Enrollment for #{@course.name} is dropped." }
      else
        format.html { redirect_to enrollments_url, alert: "Enrollment for #{@course.name} is dropped." }
      end
      format.json { head :no_content }
    end
  end

  #  GET /waitlist_course/:id or /waitlist_course/1
  # this is for a student to waitlist a course
  def enroll_course
    @enrollment = Enrollment.new
    if !is_student? && (!enrollment_params[:course_id] || !enrollment_params[:student_id])
      flash[:alert] = "course and student should not be empty"
      return
    end
    if is_student?
      @course = Course.find(params[:id])
      @student = Student.find_by user_id: current_user.id
    else
      @course = Course.find(enrollment_params[:course_id])
      @student = Student.find enrollment_params[:student_id]
    end

    total_waitlist = Waitlist.where(course_id: @course.id).count
    total_enrollment = Enrollment.where(course_id: @course.id).count
    
    if Enrollment.find_by(student_id: @student.id, course_id: @course.id)
      flash[:alert] = "Student is already registered for this course"
    elsif @course.capacity > total_enrollment and @student != nil
      @enrollment.student_id = @student.id 
      @enrollment.course_id = @course.id
      if is_student?
        flash[:alert] = "Successfully enrolled for the course #{@course.name}"
        @enrollment.save
      end
      check_status
    elsif @course.capacity <= total_enrollment
      if @course.status == 'closed'
        flash[:alert] = "Course status is closed, please keep checking MyBiryaniPack protal when it opens up."
      elsif @course.status == 'waitlist'
        flash[:alert] = "Course status is waitlist, please click waitlist if you want to get added to the course waitlist."
      end
    end

    if is_student?
      redirect_to courses_path
    end
  end

  # /courses/:id/enrolled_students 
  # shows all students enrolled in the course passed as arguemnt
  # this is visible by admin and authorized instructor
  def show_enroll_course_for_student
    @enrollment = Enrollment.new
    @course = Course.find params[:course_id]
    render :new
  end

  # this is triggered when an enrollment is dropped to move students from waitlist to enrollments 
  # the top waitlist for that course (having least created_at) is converted to enrollment
  def move_students_from_waitlist_to_enrolled
    total_enrollments = Enrollment.where(course_id: @course.id).count
    total_waitlist = Waitlist.where(course_id: @course.id).count

    if total_enrollments < @course.capacity && total_waitlist > 0
      student_to_be_enrolled = Waitlist.where(course_id: @course.id).order("created_at ASC").first
      enrolled_student = Enrollment.create!(:student_id => student_to_be_enrolled.student_id , :course_id => student_to_be_enrolled.course_id)
      student_to_be_enrolled.destroy
    end
  end

  # this will check the status for a course and modify it based on the number of enrollments and waitlists
  # it considers the course waitlist_capacity and the capacity to dermine the status of the course
  def check_status
    total_enrollments = Enrollment.where(course_id: @course.id).count
    total_waitlist = Waitlist.where(course_id: @course.id).count
    
    if total_enrollments >= @course.capacity
      if total_waitlist >= @course.waitlist_capacity
        @course.status = :closed
      else
        @course.status = :waitlist
      end
    elsif total_enrollments < @course.capacity && (@course.status == "closed" || @course.status == "waitlist")
      @course.status = :open
    end
    @course.save
  end

  # this will block operations that student should not access
  def correct_student?
    @student = Student.find_by user_id: current_user.id
    if !@student.nil? && @student.id!=@enrollment.student_id
       flash[:alert] = "Not authorised to perform this action"
       redirect_to courses_path
    end
  end

  # this will block operations that instructor should not access
  # it will block the instructor if the course whose enrollments are not belongging to his/her course
  def correct_instructor?
    if is_instructor?
      @instructor = Instructor.find_by user_id: current_user.id
      course_instructor_id = 0
      if @enrollment
        course_instructor_id = @enrollment.course.instructor.id
      else
        course_instructor_id = Course.find(enrollment_params[:course_id]).instructor.id
      end
      if !@instructor.nil? && @instructor.id != course_instructor_id
        flash[:alert] = "Not authorised to perform this action"
        redirect_to root_path
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_enrollment
      @enrollment = Enrollment.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def enrollment_params
      params.require(:enrollment).permit(:student_id, :course_id)
    end
end
